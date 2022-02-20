%option yylineno 

%{
 #include <string>
 #include <iostream>
 #include <vector>
 using namespace std ;
 #include "parser.hpp" 

 #define TOKEN(t) return t 
 #define TOKENST(t) yylval.izena = new std::string(yytext, yyleng) ; return t 

extern "C" int yywrap() { return(1) ; }
extern int yyerror(const char *);

%}

%%
prog                    TOKEN(RPROG);
\*                     TOKEN(TMUL);
=                     TOKEN(TASSIG);
;                     TOKEN(TSEMIC);
\+                      TOKEN(TSUM);
\/                       TOKEN(TDIV);
\-                      TOKEN(TRES);
\>=                       TOKEN(TBIGQ);
\>                        TOKEN(TBIG);
\<                        TOKEN(TLOW);
\<=                       TOKEN(TLOWQ);
\/=                        TOKEN(TNEQL);
==                        TOKEN(TEQL);
\{                     TOKEN(TLBRACE);
\}                     TOKEN(TRBRACE);
%{
/*\(                      TOKEN(TLPAREN);*/
/*\)                      TOKEN(TRPAREN);*/
/*\:                      TOKEN(TCOLON);*/
/*,                       TOKEN(TCOMMA);*/
/*'                       TOKEN(TAPOSTROPHE);*/
/*&                       TOKEN(TAMPERSAND);*/
/*#                       TOKEN(THASH);*/


/*[a-zA-Z]([a-zA-Z0-9]*_?[a-zA-Z0-9]+)* TOKEN(TID);*/
/*[0-9]+\.[0-9]+                        TOKEN(TFLOAT);*/
/*[0-9]+                                TOKEN(TINTEGER);*/
/*'''([ ^'#]|('[^'#])|(''[^'#]))*'''    TOKEN(TLAK);*/
/*\#([^#]|\n)*                          TOKEN(TLBK); */

%}

[ \t\n]                 ;

[a-zA-Z][a-zA-Z0-9]*    TOKENST(TID) ; 
[0-9]+\.[0-9]+          TOKENST(TFLOAT);
[0-9]+                  TOKENST(TINTEGER); 

.                       {yyerror("Token ezezaguna");}
%%
