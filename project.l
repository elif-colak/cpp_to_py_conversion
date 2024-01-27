
%{
  #include <stdio.h>
  #include <string.h>
  #include "y.tab.h"
  #include <iostream>
  using namespace std;
  int linenum=1;
%}


%%
"-"?[0-9]+ {yylval.str = strdup(yytext); return INTEGER;}
"-"?[0-9]+\.[0-9]+ {yylval.str = strdup(yytext); return FLOAT;}
"if" {yylval.str = strdup(yytext); return IF;}
"elif" {yylval.str = strdup("else if"); return ELIF;}
"else" {yylval.str=strdup(yytext); return ELSE;}
([a-zA-Z])([a-zA-Z]|[0-9]|"_")*|("_")([a-zA-Z]|[0-9]|"_")+ {yylval.str = strdup(yytext); return VARNAME;}
"-"|"+"|"/"|"*" {yylval.str=strdup(yytext); return OPERATOR;}
"=="|"<"|">"|"!="|"<="|">=" {yylval.str=strdup(yytext); return COMPR;}
\=    {yylval.str=strdup(yytext); return EQ;}
: return COLON;
\".+\"|'.+' {yylval.str = strdup(yytext); return STRING;}
"(" {yylval.str=strdup(yytext); return OP;}
")" {yylval.str=strdup(yytext); return CP;}
"{" {yylval.str=strdup(yytext); return OCB;}
"}" {yylval.str=strdup(yytext); return CCB;}
("\t"|" "{6})+  {yylval.str = strdup(yytext);return TAB;}
\n	{linenum++;}
[ \t]+
%%
