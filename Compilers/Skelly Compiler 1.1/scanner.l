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
#define ID 		 1 
#define STRING  	 2
#define LPAREN  	 3
#define RPAREN  	 4
#define LBRACE  	 5
#define RBRACE 	 6
#define SEMICOLON 7
#define NUMBER	 8
#define COMMA	 9
#define PLUS		 10
#endif
%}

/****Token Patterns*****/

%%
[ \t\n\r]* { /* Skip Whitespace */}

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


