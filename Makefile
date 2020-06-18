default:
	clear
	flex -l calc.l
	bison -dv calc.y 
	gcc -o calc calc.tab.c lex.yy.c -lfl
