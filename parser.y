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



%token RDEF RMAIN RLET RIN
%token TID TINTEGER TFLOAT TCOLON
%token TLBRACE TRBRACE TSEMIC TMUL TASSIG TSUM TBIG TBIGQ TLOW TLOWQ
%token TLPAREN TRPAREN TCOMMA TAMPERSAND
%token TRES THASH TDIV TNEQL TEQL TAPOSTROPHE
%token RFOREVER RWHILE RELSE RCONTINUE RBREAK RINT RFLOAT
%token RPROG RPRINT RREAD RIF

%start programa

%nonassoc TBIG TBIGQ TLOW TLOWQ TNEQL TEQL
%left TSUM TRES
%left TMUL TDIV


%%

programa : RDEF RMAIN TLPAREN TRPAREN TCOLON bloke_nag
         ;

bloke_nag : bl_eraz TLBRACE azpiprogramen_eraz sententzia_zerrenda TRBRACE
            ;

bloke : bl_eraz TLBRACE sententzia_zerrenda TRBRACE
        ;

bl_eraz : RLET eraz RIN
			|
      ;

eraz : eraz TSEMIC id_zerrenda TCOLON mota
			| id_zerrenda TCOLON mota
      ;

id_zerrenda : TID id_zerrendaren_bestea 
      ;

id_zerrendaren_bestea : TCOMMA TID id_zerrendaren_bestea 
			|
      ;

mota : RINT 
      | RFLOAT
      ;

azpiprogramen_eraz : azpiprogramaren_eraz azpiprogramen_eraz
			|
      ;

azpiprogramaren_eraz : RDEF TID argumentuak TCOLON bloke_nag
      ;

argumentuak : TLPAREN par_zerrenda TRPAREN
			|
      ;

par_zerrenda : id_zerrenda TCOLON par_mota mota par_zerrendaren_bestea
      ;

par_mota : TAMPERSAND
      |
      ;

par_zerrendaren_bestea : TSEMIC id_zerrenda TCOLON par_mota mota par_zerrendaren_bestea 
			|
      ;

sententzia_zerrenda : sententzia sententzia_zerrenda 
			| 
      ;

sententzia : aldagaia TASSIG adierazpena TSEMIC
			| RIF adierazpena TCOLON bloke
			| RFOREVER TCOLON bloke
			| RWHILE adierazpena TCOLON bloke RELSE TCOLON bloke
			| RBREAK RIF adierazpena TSEMIC
			| RCONTINUE TSEMIC
			| RREAD TLPAREN aldagaia TRPAREN TSEMIC
			| RPRINT TLPAREN adierazpena TRPAREN TSEMIC
      ;

aldagaia : TID 
      ;

adierazpena : adierazpena TSUM adierazpena
			| adierazpena TRES adierazpena
			| adierazpena TMUL adierazpena
                  | adierazpena TDIV adierazpena
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