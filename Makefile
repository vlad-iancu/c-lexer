main: clex.a
	gcc main.c -o main -I. -L. -lclex -lfl -lm

clex.a:
	flex -o clex.yy.c tokens.l
	gcc clex.yy.c -c -I. -lfl -lm -o clex.o
	ar rc libclex.a clex.o 
	ranlib libclex.a

clean:
	rm clex.yy.c main clex.o libclex.a
	