/*** Lex Scanner ***/

/****** Header Def *****/

%{

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#ifndef LEXONLY
#include "y.tab.h"
#else
typedef union { int ival; char* str; } yystype;
#define YYSTYPE yystype
yystype yylval;
#define KWINT	 1
#define KWCHAR	 2
#define ID 		 3 
#define STRING  	 4
#define LPAREN  	 5
#define RPAREN  	 6
#define LBRACE  	 7
#define RBRACE 	 8
#define SEMICOLON 9
#define NUMBER	 10
#define COMMA	 11
#define PLUS		 12
#define EQUALS 	 13
#endif
%}

/****Token Patterns*****/

%%
[ \t\n\r]* { /* Skip Whitespace */}

int 			{
			printf("INT: (%s)\n", yytext);
			yylval.ival = yytext[0];
			return(KWINT);
			}
char\*		{
			printf("CHAR*: (%s)\n", yytext);
			yylval.ival = yytext[0];
			return(KWCHAR);
			}		
[a-zA-Z]+	{
			// printf("ID: (%s)\n", yytext);
			yylval.str = strdup(yytext);
			return(ID);
			}
\"[^\"]*\"		{
			// printf("STRING: (%s)\n", yytext);
			yylval.str = strdup(yytext);
			return(STRING);
			}
\(			{
			// printf("LPAREN: (%s)\n", yytext);
			yylval.ival = yytext[0];
			return(LPAREN);
			}

\)			{
			// printf("RPAREN: (%s)\n", yytext);
			yylval.ival = yytext[0];
			return(RPAREN);
			}

\}			{
			// printf("LBRACE: (%s)\n", yytext);
			yylval.ival = yytext[0];
			return(LBRACE);
			}

\{			{
			// printf("RBRACE: (%s)\n", yytext);
			yylval.ival = yytext[0];
			return(RBRACE);
			}

\;			{
			// printf("SEMICOLON: (%s)\n", yytext);
			yylval.ival = yytext[0];
			return(SEMICOLON);
			}
[0-9]+		{
			// printf("NUMBER: (%s)\n", yytext);
			yylval.ival = strtol( yytext, 0,10);
			return(NUMBER);
			}
\,			{
			// printf("COMMA: (%s)\n", yytext);
			yylval.ival = yytext[0];
			return(COMMA);
			}
\+			{
			// printf("PLUS: (%s)\n", yytext);
			yylval.ival = yytext[0];
			return(PLUS);
			}
\=			{
			printf("EQUALS: (%s)\n", yytext);
			yylval.ival = yytext[0];
			return(EQUALS);
			} 


%%

#ifdef LEXONLY

int main(int argc, char **argv){
	
	do{
		yylex();
	} while(1);
	
	return 0;
}

int yywrap(){
	exit(0); 
}

#endif


