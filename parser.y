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
   extern string tab ;
   void yyerror (const char *msg) {
     printf("line %d: %s at '%s'\n", yylineno, msg, yytext) ;
     yyerrornum++;
   }

%}

/* 
   Ikurrek zein atributu-mota duten 
*/
%union {
    string *izena ; 
}

/* 
   Tokenak eta bere atributuak erazagutu. Honek tokens.l fitxategiarekin 
   bat etorri behar du.
   Lexikoak atributua duten tokenetarako memoria alokatzen du,
   hemen askatu behar da.
*/


%token <izena> TID TINTEGER TFLOAT
%token TLBRACE TRBRACE  TSEMIC TMUL TASSIG RPROG TSUM TRES TDIV TBIG TBIGQ TLOW TLOWQ TEQL TNEQL

/* Hemen erazagutu atributuak dauzkaten ez-bukaerakoak */
%type <izena> sententzia_zerrenda sententzia adierazpena bloke

%start programa

%nonassoc TBIG TBIGQ TLOW TLOWQ TNEQL TEQL
%left TSUM TRES
%left TMUL TDIV





%%
programa : RPROG TID bloke TSEMIC
         { 
          cout << "\n<programa>\n prog " + *$2 + " " + *$3  + "\n</programa>\n" << endl;
	  delete $2; delete $3; 
         }
         ;


bloke : TLBRACE
        sententzia_zerrenda
        TRBRACE
      { 
       $$ = $2; 
      }
      ;


sententzia_zerrenda : /* hutsa */
                { 
	          $$ = new string; *$$ = "\n<sententzia_zerrenda1>\n</sententzia_zerrenda1>\n";
	        }
              | sententzia_zerrenda sententzia TSEMIC 
                {
                  $$ = new string; *$$ = "\n<sententzia_zerrenda2>\n" + *$1 + *$2  + "\n</sententzia_zerrenda2>\n";
	          delete $1; delete $2;
 	        }
              ;

sententzia : TID TASSIG adierazpena 
             {
	       $$ = new string ; *$$ = "\n<sententzia>\n" + *$1 + "=" + *$3 + "\n</sententzia>\n" ;
	       delete $1; delete $3;
	     }
           ;

adierazpena : adierazpena TMUL adierazpena 
              {
	        $$ = new string; *$$ = "\n<adierazpena>\n" + *$1 + " * " + *$3 + "\n</adierazpena>\n" ;
	        delete $1; delete $3;
	      }
            | adierazpena TSUM adierazpena
              {
          $$ = new string; *$$ = "\n<adierazpena>\n" + *$1 + " + " + *$3 + "\n</adierazpena>\n" ;
	        delete $1; delete $3;

        }
            | adierazpena TRES adierazpena
              {
          $$ = new string; *$$ = "\n<adierazpena>\n" + *$1 + " - " + *$3 + "\n</adierazpena>\n" ;
	        delete $1; delete $3;

        }
            | adierazpena TDIV adierazpena
              {
          $$ = new string; *$$ = "\n<adierazpena>\n" + *$1 + " / " + *$3 + "\n</adierazpena>\n" ;
	        delete $1; delete $3;

        }
            | adierazpena TBIG adierazpena
              {
          $$ = new string; *$$ = "\n<adierazpena>\n" + *$1 + " > " + *$3 + "\n</adierazpena>\n" ;
	        delete $1; delete $3;

        }
            | adierazpena TBIGQ adierazpena
              {
          $$ = new string; *$$ = "\n<adierazpena>\n" + *$1 + " >= " + *$3 + "\n</adierazpena>\n" ;
	        delete $1; delete $3;

        }
            | adierazpena TLOW adierazpena
              {
          $$ = new string; *$$ = "\n<adierazpena>\n" + *$1 + " < " + *$3 + "\n</adierazpena>\n" ;
	        delete $1; delete $3;

        }
            | adierazpena TLOWQ adierazpena
              {
          $$ = new string; *$$ = "\n<adierazpena>\n" + *$1 + " <= " + *$3 + "\n</adierazpena>\n" ;
	        delete $1; delete $3;

        }
            | adierazpena TEQL adierazpena
              {
          $$ = new string; *$$ = "\n<adierazpena>\n" + *$1 + " == " + *$3 + "\n</adierazpena>\n" ;
	        delete $1; delete $3;

        }
            | adierazpena TNEQL adierazpena
              {
          $$ = new string; *$$ = "\n<adierazpena>\n" + *$1 + " /= " + *$3 + "\n</adierazpena>\n" ;
	        delete $1; delete $3;

        }

            
            | TID       { $$ = $1; }
            | TINTEGER  { $$ = $1; }
            | TFLOAT    { $$ = $1; }
            ;







