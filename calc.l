%{
#include <stdio.h>
#include "calc.tab.h"

int linenum = 1;
%}

digit	([0-9])
alpha   [A-Za-z]

%%
"exit"			{return(TOK_EXIT);}
"printID"       {return(TOK_PRINTID);}
"printExp"      {return(TOK_PRINTEX);}
"main()"        {return(TOK_MAIN);}
"{"        		{return(TOK_OPENCURLY);}
"}"        		{return(TOK_CLOSECURLY);}
"int"			{return(TOK_INT);}
"float"			{return(TOK_FLOAT);}
"="				{return(TOK_EQ);}

";"	{	return(TOK_SEMICOLON);	}

"+"	{	return(TOK_ADD);	}
"-"	{	return(TOK_SUB);	}
"*"	{	return(TOK_MUL);	}
"/"	{	return(TOK_DIV);	}

{digit}+				{
							yylval.variable.intVar = atoi(yytext); 
							yylval.variable.floatVar = 0; 
							return TOK_NUM; 
						}

{digit}+[.]{digit}+|{digit}+[eE]{digit}+ {
							yylval.variable.intVar = 0; 
							yylval.variable.floatVar = atof(yytext); 
							return TOK_FNUM; 
						}

[a-z][A-Za-z0-9]*   {sscanf(yytext, "%s", yylval.name); return(TOK_IDENT);}
([0-9])[A-Za-z0-9]* {sscanf(yytext, "%s", yylval.name); return(TOK_IDENT_ERR);}	





[\n] 	{linenum++;}
[" "] 	{}
[\t] 	{}

.	{
		printf("Invalid character '%c', ignored\n", 
		yytext[0]);
	}

%%

