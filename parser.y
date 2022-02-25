%{
   #include <stdio.h>
   #include <iostream>
   #include <vector>
   #include <string>
   using namespace std; 
   extern int yyerrornum;
   extern int yylex();
   extern int yylineno;
   extern char *yytext;
   void yyerror (const char *msg) {
     printf("line %d: %s at '%s'\n", yylineno, msg, yytext) ;
     yyerrornum++;
   }

%}

/* 
   Ikurrek zein atributu-mota duten 

%union {
    string *izena ; 
}
*/

/* 
   Tokenak erazagutu. Honek tokens.l fitxategiarekin 
   bat etorri behar du.
*/

%token RDEF RMAIN RLET RIN TMUL TASSIG TSEMIC TLBRACE
%token TRBRACE TID TFLOAT TINTEGER TLPAREN TRPAREN TCOLON
%token TCOMMA TAPOSTROPHE TLOWER THIGHER TAMPERSAND TSUM
%token TREST THASH TSLASH TCGE TCLE TCEQ TLAK TLBK RIF
%token RFOREVER RWHILE RELSE RCONTINUE RBREAK RINT RFLOAT
%token RPROG RPRINT RREAD

%start programa

%nonassoc TBIG TBIGQ TLOW TLOWQ TNEQL TEQL
%left TSUM TRES
%left TMUL TDIV


%%

programa : RDEF RMAIN TLPAREN TRPAREN TCOLON bloke_nag
         ;

bloke_nag : bl_eraz TLBRACE 
            azpiprogramaren_eraz
            sententzia_zerrenda
            TRBRACE
            ;

bloke :	bl_eraz TLBRACE
			  sententzia_zerrenda
			  TRBRACE
        ;

bl_eraz : RLET eraz RIN
			| 
      ;

eraz : eraz TSEMIC id_zerrenda TCOLON mota
			| id_zerrenda TCOLON mota

id_zerrenda : TID id_zerrendaren_bestea 
      ;

id_zerrendaren_bestea : TCOMMA TID id_zerrendaren_bestea 
			| 
      ;

mota : RINT 
      | RFLOAT

azpiprogramen_eraz : azpiprogramaren_eraz azpiprogramen_eraz
			| 
      ;

azpiprogramaren_eraz : RDEF TID argumentuak TCOLON bloke_nag

argumentuak :	TLPAREN par_zerrenda TRPAREN
			| 
      ;

par_zerrenda : id_zerrenda : par_mota mota par_zerrendaren_bestea
      ;

par_mota : TAMPERSAND
      |
      ;

par_zerrendaren_bestea : TSEMIC id_zerrenda TCOLON par_mota mota par_zerrendaren_bestea 
			| 
      ;

sententzia_zerrenda : sententzia sententzia_zerrenda 
			| TAMPERSAND
      ;

sententzia	: aldagaia TASSIG adierazpena TSEMIC
			| RIF adierazpena TCOLON bloke
			| RFOREVER TCOLON bloke
			| RWHILE adierazpena TCOLON bloke RELSE TCOLON bloke
			| RBREAK RIF adierazpena TCOLON
			| RCONTINUE TSEMIC
			| RREAD TLPAREN aldagaia TRPAREN TSEMIC
			| RREAD TLPAREN adierazpena TRPAREN TSEMIC
      ;

aldagaia : TID 

adierazpena : adierazpena TSUM adierazpena
			| adierazpena TRES adierazpena
			| adierazpena TMUL adierazpena
			| adierazpena TID adierazpena
			| adierazpena TEQL adierazpena
			| adierazpena TBIG adierazpena
			| adierazpena TLOW adierazpena
			| adierazpena TBIGQ adierazpena
			| adierazpena TLOWQ adierazpena
			| adierazpena TNEQL adierazpena
			| aldagaia
			| TINTEGER
			| TFLOAT
			| TLPAREN adierazpena TRPAREN
      ;
%%