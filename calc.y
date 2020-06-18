%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int linenum;
int yylex();
int search(char name[]);
void insert(char name[], int type, char value[]);
void printTab();
int yyerror(char *s);
void yyerror2(int type, char *s, char b[]);
void insertVal(char value[], int posi);
void valAssign(int modifier, char s1[], char s3[]);

struct symtab{
	char name[20];
	int type; // 1 is int, 2 is float
	char value[20];
};

struct symtab tab[20];
int ptr = 0;

%}

%token  TOK_SEMICOLON
		TOK_ADD TOK_SUB TOK_MUL TOK_DIV TOK_EQ
	    TOK_INT TOK_FLOAT TOK_IDENT
		TOK_PRINTID TOK_PRINTEX TOK_EXIT TOK_MAIN TOK_OPENCURLY TOK_CLOSECURLY
		TOK_IDENT_ERR
%token <variable> TOK_NUM TOK_FNUM


%union{
	char name[20];
    int int_val;

	struct strVariable{
		int intVar;
		float floatVar;
	}variable;

}


%type <variable> expr RAW
%type <name> TOK_IDENT
%type <name> TOK_IDENT_ERR

%left TOK_ADD TOK_SUB
%left TOK_MUL TOK_DIV

%%

prog:
	TOK_MAIN TOK_OPENCURLY vardefs stmts TOK_CLOSECURLY
	| {
		char *t ="Parsing Error";
		yyerror2(3,t,"");
	  }

;

vardefs:
	| vardef TOK_SEMICOLON vardefs
;

vardef:
	  TOK_INT TOK_IDENT {

	    int flag;
		char *t;
	    flag = search($2);

		if(flag == -1){
			insert($2, 1, "0");
		}else{
			t = "Identifier already defined - ";
			yyerror2(3,t, $2);
		}

	  }
	| TOK_INT TOK_IDENT_ERR
	  {
		char *t ="Invalid Identifier - ";
		yyerror2(3,t,$2);
	  }

	| TOK_FLOAT TOK_IDENT {

	    int flag;
		char *t;
	    flag = search($2);

		if(flag == -1){
			insert($2, 2, "0.0");
		}else{
			t = "Identifier already defined - ";
			yyerror2(3,t,$2);
		}

	  }
	| TOK_FLOAT TOK_IDENT_ERR
	  {
		char *t ="Invalid Identifier - ";
		yyerror2(3,t,$2);
	  }
;

stmts:
	| stmt TOK_SEMICOLON stmts
;

stmt:
	TOK_IDENT TOK_EQ expr
	  {
		int modifier;
		char val[15];
		if($3.intVar != 0) {
			modifier = 1;
			sprintf(val, "%d", $3.intVar);
		}else if($3.floatVar != 0){
			modifier = 2;
			sprintf(val, "%f", $3.floatVar);
		}
		valAssign(modifier, $1, val);
	  }
	| TOK_PRINTID TOK_IDENT
	  {
		//todo change print to file
		int flag;
		char *t;
	    flag = search($2);

		if(flag == -1){
			t = "Identifier not defined - ";
			yyerror2(3,t, $2);
		}else{
			printf("%s\n", tab[flag].value);
		}
	  }
	| TOK_PRINTEX expr 
	{
		if($2.intVar != 0){
			printf("%d", $2.intVar);
		}
		else{
			printf("%f", $2.floatVar);
		}
	}

;


expr:
	expr TOK_ADD expr
	  {
		char *t;
		t = " + ";
		yyerror2(2,t, NULL);
	  }
	|
	expr TOK_DIV expr
	  {
		char *t;
		t = " / ";
		yyerror2(2,t, NULL);
	  }
	| expr TOK_SUB expr
	  {
		struct strVariable temp2;

		int flag;
		if($1.intVar != 0 && $3.intVar != 0) {
			temp2.floatVar = 0;
			temp2.intVar = $1.intVar - $3.intVar;
		}else if($1.floatVar != 0 && $3.floatVar != 0) {
			temp2.intVar = 0;
			temp2.floatVar = $1.floatVar - $3.floatVar;
		}else {
			char *t = "Type mismatch";
			yyerror2(3,t, "");
		}
		
		$$ = temp2;

	  }
	| expr TOK_MUL expr
	  {
		//$$ = $1 * $3;
		
		struct strVariable temp;

		int flag;
		if($1.intVar != 0 && $3.intVar != 0) {
			temp.floatVar = 0;
			temp.intVar = $1.intVar * $3.intVar;
		}else if($1.floatVar != 0 && $3.floatVar != 0) {
			temp.intVar = 0;
			temp.floatVar = $1.floatVar * $3.floatVar;
		}else {
			char *t = "Type mismatch";
			yyerror2(3,t, "");
		}
		
		$$ = temp;
	  }
	| TOK_IDENT
	  {
		int flag;
		char *t;
	    flag = search($1);
		
		struct strVariable temp;

		if(flag == -1){
			t = "Identifier not defined - ";
			yyerror2(3,t, $1);
		}else{
			if(tab[flag].type == 1){
				temp.intVar = atoi(tab[flag].value);
				temp.floatVar = 0;
			}
			else {
				temp.intVar = 0;
				temp.floatVar = atof(tab[flag].value);
			}
		}
		
		$$ = temp;
	  }
	| RAW
;

RAW:
	TOK_NUM
	{
		$$ = $1;
	}
	| TOK_FNUM
	{
		$$ = $1;
	}
;



%%


void valAssign(int modifier, char s1[], char s3[]){
	int flag,flag2 = 0;
	char temp[20];

	flag = search(s1);

	if(flag == -1){
		char *t ="Identifier Not present - ";
		yyerror2(3,t,s1);
	}else{
		switch(modifier){
			case 1:
				if(tab[flag].type == 1) flag2 = 1;
				break;

			case 2:
				if(tab[flag].type == 2) flag2 = 1;
				break;
		}
		if(flag2 == 1){
			insertVal(s3, flag);
		}else{
			char *t ="Wrong Type Error - ";
			yyerror2(3,t,s3);
		}
	}
}

int yyerror(char *s)
{
	printf("Syntax Error on line %d\n%s\n",linenum, s);
	return 0;
}

void yyerror2(int type, char *s, char b[])
{
	//todo change print to file
	switch(type){
		case 1:
			printf("Syntax Error on line - %d\n%s\n",linenum, s);
			break;
		case 2:
			printf("Lexical Error on line - %d: %s\n",linenum, s);
			break;
		case 3:
			printf("Line - %d: %s%s\n",linenum, s, b);
			break;
	}

	exit(0);
}

int search(char name[]){

	int i;
	int flag = -1;

	for(i = 0; i < ptr; i++){
		if(strcmp(tab[i].name, name) == 0){
			flag = i;
			break;
		}
	}

	return flag;

}

void insert(char name[], int type, char value[]){

	strcpy(tab[ptr].name, name);
	strcpy(tab[ptr].value, value);
	tab[ptr].type = type;

	ptr++;

	printTab();
}

void insertVal(char value[], int posi){

	strcpy(tab[posi].value, value);

	printTab();

}

void printTab(){

	int i;

	for(i = 0; i < ptr; i++){

	//use for testing
		/*printf("Name - %s, value - %s, type - ", tab[i].name, tab[i].value);
		if(tab[i].type == 1) printf("int\n");
		else if(tab[i].type == 2) printf("float\n");*/
	}
}

int main()
{
	//todo remove clear
    system("clear");
    yyparse();
    return 0;
}
