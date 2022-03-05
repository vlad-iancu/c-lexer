#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <ctokens.h>
#include <clex.h>
#include <ctype.h>

int main()
{
    Token token;
    do
    {
        token = nextToken();
        if(token.error)
        {
            printf("%s\n", errmsg);
            continue;
        }
        switch(token.token)
        {
            case OPEN_CB:
            {
                printf("OPEN_CB {");
                free(token.value.stringValue);
            }
            break;
            case CLOSE_CB:
            {
                printf("CLOSE_CB }");
                free(token.value.stringValue);
            }
            break;
            case OPEN_B:
            {
                printf("OPEN_B (");
                free(token.value.stringValue);
            }
            break;
            case CLOSE_B:
            {
                printf("CLOSE_B )");
                free(token.value.stringValue);
            }
            break;
            case OPEN_SB:
            {
                printf("OPEN_SB [");
                free(token.value.stringValue);
            }
            break;
            case CLOSE_SB:
            {
                printf("CLOSE_SB ]");
                free(token.value.stringValue);
            }
            break;
            case COMMA:
            {
                printf("COMMA ,");
                free(token.value.stringValue);
            }
            break;
            case DOT:
            {
                printf("DOT .");
                free(token.value.stringValue);
            }
            break;
            case TILDA:
            {
                printf("TILDA ~");
                free(token.value.stringValue);
            }
            break;
            case OPERATOR:
            {
                printf("OPERATOR %s", token.value.stringValue);
                free(token.value.stringValue);
            }
            break;
            case IDENTIFIER:
            {
                printf("IDENTIFIER %s", token.value.stringValue);
                free(token.value.stringValue);
            }
            break;
            case KEYWORD:
            {
                printf("KEYWORD %s", token.value.stringValue);
                free(token.value.stringValue);
            }
            break;
            case INTEGER_LIT:
            {
                printf("INTEGER_LIT %llu", token.value.intValue);
            }
            break;
            case REAL_LIT:
            {
                printf("REAL_LIT %Lf", token.value.floatValue);
            }
            break;
            case STRING_LIT:
            {
                printf("STRING_LIT %s", token.value.stringValue);
                free(token.value.stringValue);
            }
            break;
            case CHAR_LIT:
            {
                if(iscntrl(token.value.stringValue[0]))
                {
                    for(int i = 0;i < escapes; i++)
                    {
                        if(escapechr[i] == token.value.stringValue[0])
                        {
                            printf("CHAR_LIT %s %d", escapestr[i], (int)token.value.stringValue[0]);
                            break;
                        }
                    }
                }
                else
                {
                    printf("CHAR_LIT %c %d", token.value.stringValue[0], (int)token.value.stringValue[0]);
                }
                free(token.value.stringValue);
            }
            break;
            case COLON:
            {
                printf("COLON :");
                free(token.value.stringValue);
            }
            break;
            case SEMICOLON:
            {
                printf("SEMICOLON ;");
                free(token.value.stringValue);
            }
            break;
            case PREPROCESSOR_DIRECTIVE:
            {
                printf("PREPROCESSOR_DIRECTIVE %s", token.value.stringValue);
                free(token.value.stringValue);
            }
            break;
        }
        printf("\n");
    } while (!token.error && token.token);   
}