%option noyywrap
%{

#include "qmc.tab.h"

%}

%%
"true"		{return TRUE;} 	
"succ"		{return SUCC;}
"fail"		{return FAIL;}
"not"		{return NOT;}
"and"		{return AND;}
";"			{return EOE;}

[0-9]		{yylval.n_val = atoi(yytext); return STEP;}

([0-9]+)(\.)([0-9]+)		{ yylval.f_val = atof(yytext); return NUMBER; }
"Q"			{return Q;}

">="		{return GE;}
"<="		{return LE;}

"("			{return L;}
")"			{return R;}

%%
