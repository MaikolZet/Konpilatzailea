%{
 #include <string>
 #include <iostream>
 #include <vector>
 #include <algorithm>
 using namespace std ;
 #include "Lag.h"
 #include "parser.hpp" 

 /* Hau atributurik ez duten tokenentarako: */
 #define TOKEN(t) return t
 
 /* Hau izena atributua dutenetarako:       */
 #define TOKENST(t) yylval.izena = new std::string(yytext, yyleng) ; return t 

extern "C" int yywrap() { return(1) ; }
extern int yyerror(const char *);
extern int yylineno;

%}

%%
def                     TOKEN(RDEF) ;
main                    TOKEN(RMAIN) ;
let                     TOKEN(RLET) ;
in                      TOKEN(RIN) ;
if                      TOKEN(RIF) ;
forever                 TOKEN(RFOREVER) ; 
while                   TOKEN(RWHILE) ;
else                    TOKEN(RELSE) ;
continue                TOKEN(RCONTINUE) ;
break                   TOKEN(RBREAK) ;
integer                 TOKEN(RINT);
float                   TOKEN(RFLOAT);
print                   TOKEN(RPRINT);
read                    TOKEN(RREAD);
for                     TOKEN(RFOR);
and                     TOKEN(RAND);
or                      TOKEN(ROR);
not                     TOKEN(RNOT);

\*                      TOKEN(TMUL);
=                       TOKEN(TASSIG);
;                       TOKEN(TSEMIC);
\+                      TOKEN(TSUM);
\/                      TOKEN(TDIV);
\-                      TOKEN(TRES);
\>=                     TOKEN(TBIGQ);
\>                      TOKEN(TBIG);
\<                      TOKEN(TLOW);
\<=                     TOKEN(TLOWQ);
\/=                     TOKEN(TNEQL);
==                      TOKEN(TEQL);
\{                      TOKEN(TLBRACE);
\}                      TOKEN(TRBRACE);
\(                      TOKEN(TLPAREN);
\)                      TOKEN(TRPAREN);
:                      TOKEN(TCOLON);
,                       TOKEN(TCOMMA);
&                       TOKEN(TAMPERSAND);


[a-zA-Z](_[a-zA-Z0-9]|[a-zA-Z0-9])*                 TOKENST(TID); 

[0-9]+(\.[0-9]+)([e|E][-|+]?[1-9][0-9]*)?           TOKENST(TFLOAT);

[0-9]+                                              TOKENST(TINTEGER);
[ \t]                                               ;
\n                                                  {yylineno++;}

'''([^'#]|'[^'#]|''[^'#])*'*'''           {char* str = yytext;
                                                     char *pch=strchr(str,'\n');
                                                     while (pch!=NULL) {
                                                            yylineno++;
                                                            pch=strchr(pch+1,'\n');
                                                     }
                                                    }
                                
#[^#\n]*\n                                         {yylineno++;}

.                       {yyerror("Token ezezaguna");}
%%
