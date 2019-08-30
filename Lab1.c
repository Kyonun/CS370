// Gabriella Garcia
// 08/28/2019
// Lab 1 - String Processing

#include <stdio.h>
#include <string.h>


// This uses a string token (strtok) to count the number of words in a line.
int processLine(char *line){
	int count = 0;
	char *tok;
	tok = strtok(line, " \n\t\r");

		// Counting # of words.
		while(tok != NULL){
			count++;
			tok = strtok(NULL, " \n\t\r");
	}

	return count;
}// end processLine	   


int main(int argc, char *argv[]){

   int temp = 0;
   int wc = 0;
   int lc = 0;
   FILE *fptr;
   char line[256];
   // If there is only 1 arguement in the command line, default to 
   // keyboard input.
   if(argc == 1){
	fptr = stdin;
	
	// While loop will call processLine to get the word count as well
	// as count the number of lines
	while(fgets(line, sizeof(line), fptr)){
	   temp = processLine(line);
	   wc = wc + temp;
	   temp = 0;
	   lc++;
	} 
	
	// Print: number of  words, 1 tab char, number of lines, newline char
        printf("\n%d\t%d\n", wc, lc);
	return 0;
}

    // If there are two arguements in the cmd line, read from a file.
    if(argc == 2){
	fptr = fopen(argv[1],"r");
	
	// Returning an error if unable to open the file/file is empty.
        if(fptr == NULL){
	  printf("Error: File is either corrupt or does not exist. Please try again.");
	  return -1;
	}

	// This will call processLine to count the number of words and count the number of lines.
	while(fgets(line, sizeof(line), fptr)){
	   temp = processLine(line);
	   wc = wc + temp;
	   temp = 0;
	   lc++;
	}
	
	// Print number of words, tab char, number of lines, newline char.
	printf("%d\t%d\n", wc,lc);
	fclose(fptr);
	return 0;
	}

	// If more than 2 arguements given or none given, give error, return -1.
	printf("Error: Too many arguements. Please try again.");
	return -1;
} // end main



   
