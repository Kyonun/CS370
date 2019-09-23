/*****
* Gabriella Garcia
* CS 370 - Lab 3 - Skeleton Compiler
* 09/16/2019
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

typedef struct{
	int arrSize;
	int arrInd;
	char* strings[100];
} stringArrayType;
stringArrayType strungout = {0,1};
%}

/**** Token Val Data Types *****/
	%union {int ival; char* str;}

/***** Declare our starting non terminal *****/
	%start Prog
	%type <str> function statement statements funcall

/***** Token Types *****/
	%token<str> ID STRING
	%token<ival> LPAREN RPAREN LBRACE RBRACE SEMICOLON
	

%%

/***** Compiler Rules *****/

	Prog: function
		{
		printf("\t.section\t\t.rodata\n");
		DLines();
		printf("%s", $1);
		}
	
	function: ID LPAREN RPAREN RBRACE statements LBRACE
		  {
			char *coder = (char*)malloc(128);
			sprintf(coder,"\t.globl\t%s\n\t.type\t%s,@function\n%s:\n\tpushq\t%%rbp\n\tmovq\t%%rsp, %%rbp\n\t%s\n\tmovl\t$0, %%eax\n\tpopq\t%%rbp\n\tret\n",
			 $1, $1, $1, $5);
			$$ = coder;
		  }

	statements: /**empty: Return an empty string **/
			{ 
				$$ = "";
			}
			
		| statement statements
			{
				char *stmtcat = malloc(sizeof(char)*(strlen($1)+strlen($2)+1));
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
		funcall: ID LPAREN STRING RPAREN SEMICOLON

			{
				
				//String ID (sid) = index returned by addString method
				int sid = addString($3);
				char *code = (char*) malloc(128);
				sprintf(code, "\tmovl\t$.LC%d, %%edi\n\tcall\t%s\n", sid, 					$1);
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
	int newind = 1;
		while(strungout.strings[newind] != NULL){
		printf(".LC%d\n\t.string \"%s\"\n\t.text\n", newind, strungout.strings[newind]);
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
