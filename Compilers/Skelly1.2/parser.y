/*****
* Gabriella Garcia
* CS 370 - Lab 4 - Skeleton Compiler Enhanced
* 10/01/2019
*** Notes for me: This works on the computers in SSH 118, but my Mac is having a heck
*** of a time compiling this. On OSX, removing .section .rodata and moving my ".text" to the top 
*** solves my "unexpected token" error, and removing 'type' also fixed some of the issues.
*** However, OSX apparently doesn't like using movq, as I get the error 
*** "32-bit absolute addressing is not supported in 64-bit mode"
*** So far, changing the registers around and using only movl have not proven
*** to resolve this issue yet. Need to play around more, but for now I'll keep using SSH 118
*** computers for testing.
*****/

%{

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "symtable.h"
/***** Function Prototypes from Lex *****/
Symbol** symBun; 
int yyerror(char *s);
int yylex(void);
int addString(char* stringy);
void DLines();
int argNum = 0;
char *argRegStr[] = {"%rdi","%rsi","%rdx","%rcx","r8","r9"};	

typedef struct{
	int arrSize;
	int arrInd;
	char* strings[100];
} stringArrayType;
stringArrayType strungout = {0,0};

%}

/**** Token Val Data Types *****/
%union {int ival; char* str;}

/***** Declare our starting non terminal *****/
%start Prog
%type <str> functions function statements statement funcall arguments argument expression declarations parameters assignment varDecl

/***** Token Types *****/
%token<str> ID STRING
%token<ival> KWINT KWCHAR LPAREN RPAREN LBRACE RBRACE SEMICOLON NUMBER COMMA PLUS EQUALS

	

%%

/***** Compiler Rules *****/
	// !!!!!!!!!!!!!!!!!!!!!!
	Prog: declarations functions
		{
		printf("\t.section\t.rodata\n");
		// printf("\t.text\n%s", $1); <-- For OSX
		DLines();
		printf("\t.text\n%s", $1);
		}
	functions:/**empty: Return empty**/
		{
			$$ = "";
		}
		| function functions
		{
			char *code = (char*) malloc(sizeof(char)*1000);
			strcat(code, $1);
			strcat(code, $2);
			$$ = code;
		}
	// !!!!!!!!!!!!!!!!!!!!!!!!!!!
	function: ID LPAREN parameters RPAREN RBRACE statements LBRACE
		  {
			char *coder = (char*) malloc(sizeof(char)*1000);
			sprintf(coder,"\t.globl\t%s\n\t.type\t%s,@function\n%s:\n\tpushq\t%%rbp\nmovq\t%%rsp, %%rbp\n%s\n\tpopq\t%%rbp\n\tret\n" ,$1, $1, $1, $5);
			// Commented Out: Version that works on OSX
			// sprintf(coder,"\t.globl\t%s\n%s:\n\tpushq\t%%rbp\n\tmovq\t%%rsp, %%rbp\n%s\n\tpopq\t%%rbp\n\tret\n" , $1, $1, $5);
			$$ = coder;
		  }

	statements: /**empty: Return an empty string **/
		{ 
			$$ = "";
		}
			
		| statement SEMICOLON statements
		{
			char *stmtcat = (char*) malloc(sizeof(char)*1000);
			strcpy(stmtcat,$1);
			strcat(stmtcat,$2);
			$$ = stmtcat;
		}


		/***** Statement is just passing along the statement from Function Call *****/
	statement: funcall
		{
			// Just pass along the statement from funcall method
			$$ = $1;
		}
		| assignment
		{		
		}

	funcall: ID LPAREN arguments RPAREN
		{
		char *code = (char*) malloc(sizeof(char)*1000);
		sprintf(code,"%s\tmovl\t$0, %%eax\n\tcall\t%s\n", $3, $1);
		argNum = 0;
		$$ = code;
		}
	// !!!!!!!!!!!
	assignment: ID EQUALS expression
		{		
		}
	
	arguments: argument COMMA arguments
		{
		char *code = (char*)malloc(sizeof(char)*1000);
		strcat(code, $1);
		strcat(code,$3);
		$$ = code;
		}

		| argument
		
		{	 
			$$ = $1;
		}

		| /**empty**/
		{
		$$ = "";
		}

	argument: STRING
		{
			strungout.arrSize = addString($1);
			char *code = (char*)malloc(sizeof(char)*1000);
			sprintf(code, "\tmovq\t$.LC%d, %s\n", strungout.arrSize, argRegStr[argNum]);
			argNum++;
			$$ = code;
		}

	| expression
		{
			$$ = $1;
		}

	expression: expression PLUS expression
		{
			char *code = (char*) malloc(sizeof(char)*1000);
			sprintf(code, "%s\tpushq\t%%rdx\n%s\tpopq\t%%rcx\n\taddl\t%%ecx, %%edx\n", $1, $3);
			$$ = code;
		}

	| NUMBER
		{
			char *code = (char*)malloc(sizeof(char)*1000);
			sprintf(code, "\tmovl\t$%d, %%edx\n", $1);
			$$ = code;
		}
	| ID // This is where the x's or whatever go from the equation. Another move?
		{	
			char *code = (char*)malloc(sizeof(char)*1000);
			sprintf(code, "\tmovl\t$%s, %%eax\n",$1);
			$$ = code;
		}
	declarations: /** empty **/
		{	
			$$ = "";
		}
		| varDecl SEMICOLON declarations
		{		
		}

	varDecl: KWINT ID
		{
			addSymbol(symBun, $2, 0, T_INT);
			char *code = (char*)malloc(1000);
			sprintf(code, "\t
		}
		| KWCHAR ID
		{		
			addSymbol(symBun, $2, 0, T_STRING);
		}

	parameters:
		{
			$$ = "";
		}
		| varDecl
		{
			// addSymTable?
		}
		| varDecl COMMA parameters
		{
			// addSymTable?
		}

		;
%%
/** AddString will insert the strings from the string ID into an array and return its index **/

int addString(char* stringy){
	strungout.strings[strungout.arrInd] = stringy;
	strungout.arrInd++;
	return strungout.arrInd-1;
}

/** DLines helps out fill out the top of our assembly function by ensuring that
   * that if we have multiple puts functions, we will print multiple string lines
   * and the number after LC will be correct.
**/

void DLines(){
	int newind = 0;
		while(strungout.strings[newind] != NULL){
		printf(".LC%d:\n\t.string \t%s\n", newind, strungout.strings[newind]);
		newind++;
		}
	}
	

/***** Functions *****/
extern FILE *yyin; // From Lex

int main(int argc, char **argv){

	
   		if (argc==2) {
     			 yyin = fopen(argv[1],"r");
      				if (!yyin) {
         				printf("Error: unable to open file (%s)\n",argv[1]);
         			return(1);
      			}
   	}
   	return(yyparse());
} // End main	
int yyerror(char *s)
	{
   		fprintf(stderr, "%s\n",s);
   		return 0;
	}

	int yywrap()
	{
   	return(1);
	}
