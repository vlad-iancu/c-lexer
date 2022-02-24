%{
    #include <stdio.h>
    #include <ctokens.h>
    #include <stdint.h>
    #include <stdlib.h>
    #include <errno.h>
    #include <string.h>
    #include <ctype.h>
    #include <math.h>

    int brackets = 0;
    int comments = 0;
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
hex_integer            0[xX][0-9]+
hex_float              0[xX][0-9]+(\.[0-9]*(p[0-9]+)?)?
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
{decimal_float} {
                    sscanf(yytext, "%lle", &floatValue);
                    if(errno)
                    {
                        error = 1;
                        errmsg = malloc(100 * sizeof(char));
                        sprintf(errmsg, "floating point literal \"%s\" is invalid", yytext);
                    }
                    return REAL_LIT;
                }
{hex_integer} |
{decimal_integer} {
                    sscanf(yytext, "%lle", &floatValue);
                    unsigned long long temp = (unsigned long long)floatValue;
                    if(temp == floatValue)
                    {
                        intValue = temp;
                    }
                    else
                    {
                        error = 1;
                        errmsg = malloc(100 * sizeof(char));
                        sprintf(errmsg, "integer literal \"%s\" is invalid", yytext);
                    }
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

int main(int argc, char **argv)
{
    int tok;
    while(!error && (tok = yylex()))
    {
        if(error)
        {
            printf("%s\n", errmsg);
            continue;
        }
        switch(tok)
        {
            case OPEN_CB:
            {
                printf("OPEN_CB {");
            }
            break;
            case CLOSE_CB:
            {
                printf("CLOSE_CB }");
            }
            break;
            case OPEN_B:
            {
                printf("OPEN_B (");
            }
            break;
            case CLOSE_B:
            {
                printf("CLOSE_B )");
            }
            break;
            case OPEN_SB:
            {
                printf("OPEN_SB [");
            }
            break;
            case CLOSE_SB:
            {
                printf("CLOSE_SB ]");
            }
            break;
            case COMMA:
            {
                printf("COMMA ,");
            }
            break;
            case DOT:
            {
                printf("DOT .");
            }
            case TILDA:
            {
                printf("TILDA ~");
            }
            break;
            case OPERATOR:
            {
                printf("OPERATOR %s", stringValue);
            }
            break;
            case IDENTIFIER:
            {
                printf("IDENTIFIER %s", stringValue);
            }
            break;
            case KEYWORD:
            {
                printf("KEYWORD %s", stringValue);
            }
            break;
            case INTEGER_LIT:
            {
                printf("INTEGER_LIT %llu", intValue);
            }
            break;
            case REAL_LIT:
            {
                printf("REAL_LIT %Lf", floatValue);
            }
            break;
            case STRING_LIT:
            {
                printf("STRING_LIT %s", stringValue);
            }
            break;
            case CHAR_LIT:
            {
                if(iscntrl(stringValue[0]))
                {
                    for(int i = 0;i < escapes; i++)
                    {
                        if(escapechr[i] == stringValue[0])
                        {
                            printf("CHAR_LIT %s %d", escapestr[i], (int)stringValue[0]);
                            break;
                        }
                    }
                }
                else
                {
                    printf("CHAR_LIT %c %d", stringValue[0], (int)stringValue[0]);
                }
            }
            break;
            case COLON:
            {
                printf("COLON :");
            }
            break;
            case SEMICOLON:
            {
                printf("SEMICOLON ;");
            }
            break;
            case PREPROCESSOR_DIRECTIVE:
            {
                printf("PREPROCESSOR_DIRECTIVE %s", stringValue);
            }
            break;
        }
        //Don't forget about hex for decimal and char literals
        printf("\n");
    }
    //free(errmsg);
}
