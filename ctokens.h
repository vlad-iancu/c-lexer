#ifndef CTOKENS_H_
#define CTOKENS_H_

#define OPEN_CB 258
#define CLOSE_CB 259
#define OPEN_B 260
#define CLOSE_B 261
#define OPEN_SB 262
#define CLOSE_SB 263
#define COMMA 264
#define DOT 265
#define TILDA 266
#define OPERATOR 267
#define IDENTIFIER 268
#define KEYWORD 269
#define INTEGER_LIT 270
#define REAL_LIT 271
#define STRING_LIT 272
#define CHAR_LIT 273
#define COLON 274
#define SEMICOLON 275
#define PREPROCESSOR_DIRECTIVE 276

typedef struct Token
{
    int token;
    int error;
    union
    {
        unsigned long long intValue;
        char *stringValue;
        long double floatValue;
    } value;
} Token;

extern int escapes;
extern char escapestr[11][10];
extern char escapechr[11];
extern char kwds[32][16];
extern char *errmsg;

#endif