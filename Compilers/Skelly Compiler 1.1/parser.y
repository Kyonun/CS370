/*****
* Gabriella Garcia
* CS 370 - Lab 4 - Skeleton Compiler Enhanced
* 10/01/2019
*****/

%{

#include<stdio.h>
#include<stdlib.h>
#include<string.h>

/***** Function Prototypes from Lex *****/
	int yyerror(char *s);
	int yylex(void);
	int addString(char* stringy);
	void DLines();
	int argNum = 0;
	char *argRegStr[] = {"%rsi","%rdi","%rdx","%rcx","r8","r9"};	

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
	%type <str> functions function statements statement funcall arguments argument expression

/***** Token Types *****/
	%token<str> ID STRING
	%token<ival> LPAREN RPAREN LBRACE RBRACE SEMICOLON NUMBER COMMA PLUS
	

%%

/***** Compiler Rules *****/

	Prog: functions
		{
		printf("\t.section\t.rodata\n");
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

	function: ID LPAREN RPAREN RBRACE statements LBRACE
		  {
			char *coder = (char*) malloc(sizeof(char)*1000);
			sprintf(coder,"\t.globl\t%s\n\t.type\t%s, @function\n%s:\n\tpushq\t%%rbp\n\tmovq\t%%rsp, %%rbp\n\t%s\n\tmovl\t$0, %%eax\n\tpopq\t%%rbp\n\tret\n",
			 $1, $1, $1, $5);
			$$ = coder;
		  }

	statements: /**empty: Return an empty string **/
			{ 
				$$ = "";
			}
			
		| statement statements
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

		/**Funcall**/
	funcall: ID LPAREN arguments RPAREN SEMICOLON

			{
			char *code = (char*) malloc(sizeof(char)*1000);
			sprintf(code,"%s\tmovl\t$0, %%edx\n\tcall\t%s\n\n", $3, $1);
			argNum = 0;
			$$ = code;
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
			sprintf(code, "%s\tpushq\t%%rax\n%s\tpopq\t%%rcx\n\taddl\t%%ecx, %%eax\n", $1, $3);
			$$ = code;
		}

	| NUMBER
		{
			char *code = (char*)malloc(sizeof(char)*1000);
			sprintf(code, "\tmovl\t$%d, %%eax\n", $1);
			$$ = code;
		}

		;
%%
/** AddString will insert the strings from the string ID into an array and return its index **/

int addString(char* stringy){
	strungout.strings[strungout.arrInd] = stringy;
	strungout.arrInd++;
	strungout.arrSize++;
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

	int main(int argc, char **argv)
		{
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
