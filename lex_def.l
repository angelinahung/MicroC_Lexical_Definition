%{ 
	#include <stdio.h> 
	#include <stdlib.h> 
	#include <ctype.h> 
	#include <string.h>
	#define TYPE		1	 
	#define ID		2
	#define CONSTANT 	3
%} 


%x commentv1
%x commentv2
%option nounput yylineno
%option caseless
 

letter		[a-zA-Z] 
digit 		[0-9] 
id 			{letter}+({letter}|{digit})* 
number		{digit}+ 
float_num	({digit}+\.{digit}+)
constant	\"(\\.|[^\\"])*\"
 
%% 
(?i:if)		printf("%s \t\t IF FUNCTION\n",yytext);
(?i:while)	printf("%s \t\t WHILE FUNCTION\n",yytext);
(?i:print)	printf("%s \t\t PRINT FUNCTION\n",yytext);
(?i:else)	printf("%s \t\t ELSE FUNCTION\n",yytext);
(?i:int)	return (TYPE);
(?i:double)	return (TYPE);
(?i:float)	return (TYPE);
"+"			printf("%s \t\t OPERATOR\n",yytext);
"-"			printf("%s \t\t OPERATOR\n",yytext);
"*"			printf("%s \t\t OPERATOR\n",yytext);
"/"			printf("%s \t\t OPERATOR\n",yytext);
">"		printf("%s \t\t RELATIONAL\n",yytext);
">="		printf("%s \t\t RELATIONAL\n",yytext);
"<"		printf("%s \t\t RELATIONAL\n",yytext);
"<="		printf("%s \t\t RELATIONAL\n",yytext);
"=="		printf("%s \t\t RELATIONAL\n",yytext);
"!="		printf("%s \t\t RELATIONAL\n",yytext);
"("			printf("%s \t\t LB\n",yytext);
")"			printf("%s \t\t RB\n",yytext);
","		printf("%s \t\t COMMA\n",yytext);
"%"		printf("%s \t\t REMAINDER\n",yytext);
"^"		printf("%s \t\t EXPONENTIATION\n",yytext);
";"		printf("%s \t\t SEMICOLON\n",yytext);
"="		printf("%s \t\t ASSIGN\n",yytext);
{number}	printf("%s \t\t NUMBER\n",yytext);
{float_num}	printf("%s \t\t FLOAT NUMBER\n",yytext);
{id}		return (ID);
{constant}	return (CONSTANT);
[ \t\n]    	{} 
["]		printf("%s \t\t QUOTATION\n",yytext);
"{"	printf("%s \t\t OPEN BRACES\n",yytext);
"}"	printf("%s \t\t CLOSE BRACES\n",yytext);
"//"	{BEGIN(commentv1); printf("COMMENT// ");}
<commentv1>\n	{BEGIN(INITIAL); printf("\n");}
"/*"            {BEGIN(commentv2);printf("COMMENT/* ");}
<commentv2>\n	{printf("\n");}
<commentv2>"*/"	{BEGIN(INITIAL); printf("*/");}
%% 

struct word {
      char *id;
      char *type;
      struct word *next;
};

struct word *word_list; /* first element in word list */

void create_symbol();
int insert_symbol(char *type, char *word);
int lookup_symbol(char *word);
void dump_symbol(struct word* wp,int k);

int main(int argc,char *argv[]){ 
	yyin = fopen(argv[1],"r"); 
	int n=0,temp=0,k=0;
	char str[100]; 
	while (n = yylex())
	{
		switch(n){
			case TYPE:
				temp=1;
				strcpy(str,yytext); /*COPY TEXT TO STR ARRAY*/
				break;
			case ID:
				if(temp == 1)/*TYPE*/
				{
					temp=0;
					if (insert_symbol(str,yytext) == 1)
					{
						printf("%s \t\t %s TYPE VAR\n",yytext,str);
						if(k == 0)
						{
							create_symbol();
						}
						k++;
						printf("Insert a symbol: %s\n", yytext);
					}						
				}
				else /*id*/
					printf("%s \t\t ID\n",yytext);
					break;
			case CONSTANT:
				if(temp == 1)/*TYPE*/
				{
					temp=0;
					if (insert_symbol(str,yytext) == 1)
					{
						printf("%s \t\t %s TYPE VAR\n",yytext,str);
						if(k == 0)
						{
							create_symbol();
						}
						k++;
						printf("Insert a symbol: %s\n", yytext);
					}							
				}
				else /*constant*/
					printf("%s \t\t STRING CONSTANT\n",yytext);
					break;
			default:
				printf("UNDEFINED\n");
			
			
		}
	}	
	printf("\nparse over,the line number is %d\n",yylineno);
	dump_symbol(word_list,k);
	return 0; 
} 
 
int yywrap(void) {     
	return 1; 
} 

extern void *malloc() ;

void create_symbol(){
	printf("Create a symbol table\n");
}

int insert_symbol(char *type, char *word){
	struct word *wp;
	if(lookup_symbol(word) !=-1) {
        	printf(" %s has been already declared \n", word);
		return -1;
      	}
	else{
      		/*insert word*/
      		wp = (struct word *) malloc(sizeof(struct word));
      		wp->next = word_list;
      		/*copy the word itself*/
      		wp->id = (char *) malloc(strlen(word)+1);
      		strcpy(wp->id, word);
		wp->type = (char *) malloc(strlen(type)+1);
      		strcpy(wp->type, type);
      		word_list = wp;
		return 1;
	}
}

int lookup_symbol(char *word){
	struct word *wp = word_list;
	/*searching the symbol table*/
    	for(; wp; wp = wp->next) {
		if(strcmp(wp->id, word) == 0)
          		return 1;
    	}
      	return -1;       /* not found */
}

void dump_symbol(struct word* wp, int k){
	if (wp == NULL)
       		return;
	dump_symbol(wp->next,--k);
	if(k==0){
		printf("\nThe symbol table dump:\n");
	}		
    	printf("%d \t%s \t%s\n", ++k,wp->id, wp->type);
}