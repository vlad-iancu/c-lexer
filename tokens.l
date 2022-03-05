%{
    #include <stdio.h>
    #include <ctokens.h>
    #include <stdint.h>
    #include <stdlib.h>
    #include <errno.h>
    #include <string.h>
    #include <ctype.h>
    #include <math.h>

    char *stringValue = NULL;
    unsigned long long intValue = 0;
    long double floatValue = 0;
    int error = 0;
    char *errmsg = NULL;

    char kwds[32][16] =
    {
        "auto",
        "break",
        "case",
        "char",
        "const",
        "continue",
        "default",
        "do",
        "double",
        "else",
        "enum",
        "extern",
        "float",
        "for",
        "goto",
        "if",
        "int",
        "long",
        "register",
        "return",
        "short",
        "signed",
        "static",
        "struct",
        "switch",
        "typedef",
        "union",
        "unsigned",
        "void",
        "volatile",
        "while"
    };
    int escapes = 10;
    char escapestr[11][10] = {
        "\'","\\\"","\\?",
        "\\\\","\\a","\\b",
        "\\f","\\n","\\r",
        "\\t","\\v"};
    char escapechr[11] = {
        '\'','\"','\?',
        '\\','\a','\b',
        '\f','\n','\r',
        '\t','\v'};
    int is_keyword(const char *str)
    {
        for(int i = 0;i < 32; i++)
        {
            if(!strcmp(str, kwds[i]))
            {
                return 1;
            }
        }
        return 0;
    }
%}

line_comment           "//".*
multiline_comment      [\/][\*](.*)[\*][\/]
string                 \"(\\.|[^"\\])*\"
decimal_float          ([0-9]*\.[0-9]+|[0-9]+\.)([eE][0-9]+)?
decimal_integer        [0-9]+([eE][-+]?[0-9]+)?
hex_integer            0[xX][0-9a-fA-F]+
hex_float              0[xX][0-9a-fA-F]+(\.[0-9]*(p[0-9]+)?)
identifier             [[:alpha:]_][[:alnum:]_]*
chr                    '\\?[^']'
oct_chr                '\\[0-7]{0,3}'
hex_chr                '\\x[0-9a-fA-F]{0,2}'
preprocessor_directive #[[:alpha:]]+(.*)
%%
{line_comment}      ;
{multiline_comment} ;
{preprocessor_directive} {
                            stringValue = yytext;
                            return PREPROCESSOR_DIRECTIVE;
                         }
{string}            {
                        stringValue = yytext;
                        return STRING_LIT;
                    }
"("                 { return OPEN_B; }
")"                 { return CLOSE_B; }
"{"                 { return OPEN_CB; }
"}"                 { return CLOSE_CB; }
"["                 { return OPEN_SB; }
"]"                 { return CLOSE_SB; }
","                 { return COMMA; }
":"                 { return COLON; }
"~"                 { return TILDA; }
"."                 { return DOT; }
";"                 { return SEMICOLON; }
"+" |
"-" |
"/" |
"*" |
"?" |
"|" |
"||" |
"&" |
"&&" |
"^" |
"%" |
"!" |
"<" |
">" |
"<=" |
">=" | 
">>" |
"<<" |
"=" |
"==" |
"!=" |
"+=" |
"-=" |
"*=" |
"/=" |
"^=" |
">>=" |
"<<=" |
"|=" |
"&=" |
"++" |
"--" |
"sizeof"    {stringValue = yytext; return OPERATOR;}

{hex_float} |
{decimal_integer}f |
{decimal_float} {
                    char *p;
                    floatValue = strtold(yytext, &p);
                    if(errno)
                    {
                        error = 1;
                        errmsg = malloc(100 * sizeof(char));
                        sprintf(errmsg, "floating point literal \"%s\" is invalid", yytext);
                    }
                    return REAL_LIT;
                }
{hex_integer} {
                char *p;
                intValue = strtoull(yytext, &p, 16);
                unsigned long long temp = (unsigned long long)floatValue;
                if(errno)
                {
                  error = 1;
                  errmsg = malloc(100 * sizeof(char));
                  sprintf(errmsg, "integer literal \"%s\" is invalid", yytext);
                }
                return INTEGER_LIT;
              }
{decimal_integer}[uU]
{decimal_integer}[lL]
{decimal_integer} {
                    char *p;
                    intValue = strtoull(yytext, &p, 10);
                    unsigned long long temp = (unsigned long long)floatValue;
                    if(errno)
                    {
                        error = 1;
                        errmsg = malloc(100 * sizeof(char));
                        sprintf(errmsg, "integer literal \"%s\" is invalid", yytext);
                    }
                    return INTEGER_LIT;
                  }


{identifier} {
                stringValue = yytext;
                if(is_keyword(stringValue))
                {
                    return KEYWORD;
                }
                return IDENTIFIER;
             }
{chr} {
        char chr[5] = {0};
        strncpy(chr, yytext + 1, yyleng - 2);
        if(strchr(chr, '\\'))
        {
            int valid = 0;
            for(int i = 0;i < escapes; i++)
            {
                if(!strcmp(chr, escapestr[i]))
                {
                    valid = 1;
                    stringValue[0] = escapechr[i];
                    return CHAR_LIT;
                }
            }
            if(!valid)
            {
                error = 1;
                errmsg = "Invalid escape";
            }
            return CHAR_LIT;
        }
        else
        {
            stringValue[0] = chr[0];
        }
        return CHAR_LIT;
      }
{oct_chr} {
            char chr[10] = {0};
            strncpy(chr, yytext + 2, yyleng - 3);
            int l = yyleng - 3;
            int res = 0;
            for(int i = 0; i < l; i++)
            {
                res += ((int)(pow(8, l - i - 1)) * (chr[i] - '0'));
            }
            stringValue[0] = res;
            return CHAR_LIT;
          }
{hex_chr} {
            char chr[10] = {0};
            strncpy(chr, yytext + 3, yyleng - 4);
            int c;
            sscanf(chr, "%x", &c);
            stringValue[0] = (char)c;
            return CHAR_LIT;
          }
[[:space:]]*    ;
%%


Token nextToken()
{
    int tok;
    Token token;
    tok = yylex();
    token.error = error;
    if(error)
    {
        return token;
    }
    token.token = tok;
    switch(tok)
    {
        case OPEN_CB:
        {
            token.value.stringValue = malloc(1);
            token.value.stringValue[0] = '{';
        }
        break;
        case CLOSE_CB:
        {
            token.value.stringValue = malloc(1);
            token.value.stringValue[0] = '}';
        }
        break;
        case OPEN_B:
        {
            token.value.stringValue = malloc(1);
            token.value.stringValue[0] = '(';
        }
        break;
        case CLOSE_B:
        {
            token.value.stringValue = malloc(1);
            token.value.stringValue[0] = ')';
        }
        break;
        case OPEN_SB:
        {
            token.value.stringValue = malloc(1);
            token.value.stringValue[0] = '[';
        }
        break;
        case CLOSE_SB:
        {
            token.value.stringValue = malloc(1);
            token.value.stringValue[0] = ']';
        }
        break;
        case COMMA:
        {
            token.value.stringValue = malloc(1);
            token.value.stringValue[0] = ',';
        }
        break;
        case DOT:
        {
            token.value.stringValue = malloc(1);
            token.value.stringValue[0] = ',';
        }
        case TILDA:
        {
            token.value.stringValue = malloc(1);
            token.value.stringValue[0] = '~';
        }
        break;
        case OPERATOR:
        {
            token.value.stringValue = strdup(stringValue);
        }
        break;
        case IDENTIFIER:
        {
            token.value.stringValue = strdup(stringValue);
        }
        break;
        case KEYWORD:
        {
            token.value.stringValue = strdup(stringValue);
        }
        break;
        case INTEGER_LIT:
        {
            token.value.intValue = intValue;
        }
        break;
        case REAL_LIT:
        {
            token.value.floatValue = floatValue;
        }
        break;
        case STRING_LIT:
        {
            token.value.stringValue = strdup(stringValue);
        }
        break;
        case CHAR_LIT:
        {
            token.value.stringValue = strdup(stringValue);
        }
        break;
        case COLON:
        {
            token.value.stringValue = strdup(stringValue);
        }
        break;
        case SEMICOLON:
        {
            token.value.stringValue = strdup(stringValue);
        }
        break;
        case PREPROCESSOR_DIRECTIVE:
        {
            token.value.stringValue = strdup(stringValue);
        }
        break;
    }
    return token;       
}
