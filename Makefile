all:
	flex tokens.l
	gcc lex.yy.c -I. -lfl -lm -o lex

common:
	