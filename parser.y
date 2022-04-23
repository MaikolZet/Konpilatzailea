%{
   #include <stdio.h>
   #include <iostream>
   #include <vector>
   #include <list>
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

   #include "Kodea.h"
   #include "Lag.h"


   Kodea kodea;
%}

/*******************************************************************************/
/* Ikurrek zein atributu-mota izan dezaketen.                                  */
/* Gogoratu ikur bakoitzak atributu bakarra eta oinarrizko motetakoak          */
/* (osoko, erreal, karaktere, erakusle).                                       */

%union {
    string *izena ;
    expr_struct *adi ;  /* Bertan izena trueL eta falseL */
    IdLista *idList ;
    int erref ;
    ErrefLista *next, *cont, *exit;
    string *mota;
}


/* LEXIKOAK */

%token <izena> TID TINTEGER TFLOAT
%token <mota> RINT RFLOAT

/* ATRIBUTU GABEKOAK */

%token RDEF RMAIN RLET RIN
%token TCOLON
%token TLBRACE TRBRACE TSEMIC TMUL TASSIG TSUM TBIG TBIGQ TLOW TLOWQ
%token TLPAREN TRPAREN TCOMMA TAMPERSAND
%token TRES THASH TDIV TNEQL TEQL 
%token RFOREVER RWHILE RELSE RCONTINUE RBREAK 
%token RPROG RPRINT RREAD RIF

/* SINTETIZATUAK */

%type <erref> M
%type <list> id_zerrendaren_bestea id_zerrenda
%type <mota> mota par_mota
%type <adi> adierazpena
%type <next> N 
%type <exit,cont> bloke sententzia sententzia_zerrenda
%type <izena> aldagaia







%nonassoc TBIG TBIGQ TLOW TLOWQ TNEQL TEQL
%left TSUM TRES
%left TMUL TDIV

%start programa

%%

programa : RDEF RMAIN TLPAREN TRPAREN TCOLON 
      {kodea.agGehitu("programa");} 

bloke_nag
         ;

bloke_nag : bl_eraz TLBRACE azpiprogramen_eraz sententzia_zerrenda TRBRACE
            {kodea.agGehitu("halt");
            kodea.idatzi();}
            ;

bloke : bl_eraz TLBRACE sententzia_zerrenda TRBRACE
            {$<exit>$ = $<exit>3;
             $<cont>$ = $<cont>3; }
        ;

bl_eraz : RLET eraz RIN
			|
      ;

eraz : eraz TSEMIC id_zerrenda TCOLON mota
                        { kodea.erazagupenakGehitu(*$<mota>5,*$<idList>3);}
			| id_zerrenda TCOLON mota
                        { kodea.erazagupenakGehitu(*$<mota>3,*$<idList>1);}
      ;

id_zerrenda : TID id_zerrendaren_bestea 
                  {$<idList>$ = $<idList>2;}
      ;

id_zerrendaren_bestea : TCOMMA TID id_zerrendaren_bestea 
                        {$<idList>$ = $<idList>3;
                        $<idList>$->push_back(*$<izena>2);
                        delete $<izena>2;}
			|
                        {$<idList>$ = new IdLista;}
      ;

mota : RINT 
            {$<mota>$ = new std::string;
            *$<mota>$ = "integer";}
      | RFLOAT
            {$<mota>$ = new std::string;
            *$<mota>$ = "float";}
      ;

azpiprogramen_eraz : azpiprogramaren_eraz azpiprogramen_eraz
			|
      ;

azpiprogramaren_eraz : RDEF TID {kodea.agGehitu("proc " + *$<izena>2);} argumentuak TCOLON bloke_nag {kodea.agGehitu("endproc " + *$<izena>2);}
      ;

argumentuak : TLPAREN par_zerrenda TRPAREN
			|
      ;

par_zerrenda : id_zerrenda TCOLON par_mota mota {kodea.erazagupenakGehitu2(*$<mota>3,*$<mota>4,*$<idList>1);} par_zerrendaren_bestea
      ;

par_mota : TAMPERSAND
            {$<mota>$ = new std::string;
            *$<mota>$ = "ref_";}
      |
            {$<mota>$ = new std::string;
            *$<mota>$ = "val_";}
      ;

par_zerrendaren_bestea : TSEMIC id_zerrenda TCOLON par_mota mota {kodea.erazagupenakGehitu2(*$<mota>4,*$<mota>5,*$<idList>2);} par_zerrendaren_bestea 
			|
      ;

sententzia_zerrenda : sententzia sententzia_zerrenda 
                        {$<exit>$ = new ErrefLista;
                        $<exit>$->splice($<exit>$->end(), *$<exit>1);
                        $<exit>$->splice($<exit>$->end(), *$<exit>2);
                        $<cont>$ = new ErrefLista;
                        $<cont>$->splice($<cont>$->end(), *$<cont>1);
                        $<cont>$->splice($<cont>$->end(), *$<cont>2);}
			| 
                        {$<exit>$ = new ErrefLista;
                        $<cont>$ = new ErrefLista;}
      ;

sententzia : aldagaia TASSIG adierazpena TSEMIC
                        {$<exit>$ = new ErrefLista;
                        $<cont>$ = new ErrefLista;}
			| RIF adierazpena TCOLON M bloke M
                        {kodea.agOsatu($<adi>2->trueL,$<erref>4);
                        kodea.agOsatu($<adi>2->falseL,$<erref>6);
                        $<exit>$ = $<exit>5;
                        $<cont>$ = $<cont>5;}
			|M RFOREVER TCOLON bloke M
                        {kodea.agGehitu("goto " + to_string($<erref>1));
                        kodea.agOsatu(*$<exit>4,$<erref>5);
                        $<exit>$ = new ErrefLista;
                        $<cont>$ = $<cont>4;}
			| M RWHILE adierazpena TCOLON M bloke N RELSE TCOLON M bloke M
                        {kodea.agOsatu($<adi>2->trueL,$<erref>5);
                        kodea.agOsatu($<adi>2->falseL,$<erref>10);
                        kodea.agOsatu(*$<next>7,$<erref>1);
                        kodea.agOsatu(*$<exit>6,$<erref>10);
                        kodea.agOsatu(*$<exit>11,$<erref>12);
                        $<exit>$ = new ErrefLista;
                        kodea.agOsatu(*$<cont>6,$<erref>1);
                        kodea.agOsatu(*$<cont>11,$<erref>1);
                        $<cont>$ = new ErrefLista;}
			| RBREAK RIF adierazpena M TSEMIC
                        {kodea.agOsatu($<adi>3->falseL,$<erref>4);
                        $<exit>$ = new ErrefLista;
                        *$<exit>$ = $<adi>3->trueL;
                        $<cont>$ = new ErrefLista;
                        }
			| RCONTINUE TSEMIC
                        {$<cont>$ = new ErrefLista;
                        $<cont>$->push_back(kodea.lortuErref());
                        kodea.agGehitu("goto ");
                        $<exit>$ = new ErrefLista;}
			| RREAD TLPAREN aldagaia TRPAREN TSEMIC
                        {kodea.agGehitu("read " + *$<izena>3);
                        $<cont>$ = new ErrefLista;
                        $<exit>$ = new ErrefLista;}
			| RPRINT TLPAREN adierazpena TRPAREN TSEMIC
                        {kodea.agGehitu("write " + *$<izena>3);
                        kodea.agGehitu("writeln");
                        $<cont>$ = new ErrefLista;
                        $<exit>$ = new ErrefLista;}
      ;

aldagaia : TID 
      {$<izena>$ = $<izena>1;}
      ;

adierazpena : adierazpena TSUM adierazpena
                        {$<adi>$ = new expr_struct;
                        $<adi>$->izena = kodea.idBerria();
                        kodea.agGehitu($<adi>$->izena + " := " + $<adi>1->izena + " + " + $<adi>3->izena);
                        delete $<adi>1;
                        delete $<adi>2;}
			| adierazpena TRES adierazpena
                        {$<adi>$ = new expr_struct;
                        $<adi>$->izena = kodea.idBerria();
                        kodea.agGehitu($<adi>$->izena + " := " + $<adi>1->izena + " - " + $<adi>3->izena);
                        delete $<adi>1;
                        delete $<adi>2;}
			| adierazpena TMUL adierazpena
                        {$<adi>$ = new expr_struct;
                        $<adi>$->izena = kodea.idBerria();
                        kodea.agGehitu($<adi>$->izena + " := " + $<adi>1->izena + " * " + $<adi>3->izena);
                        delete $<adi>1;
                        delete $<adi>2;}
                  | adierazpena TDIV adierazpena
                        {$<adi>$ = new expr_struct;
                        $<adi>$->izena = kodea.idBerria();
                        kodea.agGehitu($<adi>$->izena + " := " + $<adi>1->izena + " / " + $<adi>3->izena);
                        delete $<adi>1;
                        delete $<adi>2;}
			| adierazpena TEQL adierazpena
                        {$<adi>$ = new expr_struct;
                        $<adi>$->trueL.push_back(kodea.lortuErref());
                        kodea.agGehitu("if " + $<adi>1->izena + " == " + $<adi>3->izena + " goto");
                        $<adi>$->falseL.push_back(kodea.lortuErref());
                        kodea.agGehitu("goto");
                        delete $<adi>1;
                        delete $<adi>3;}
			| adierazpena TBIG adierazpena
                        {$<adi>$ = new expr_struct;
                        $<adi>$->trueL.push_back(kodea.lortuErref());
                        kodea.agGehitu("if " + $<adi>1->izena + " > " + $<adi>3->izena + " goto");
                        $<adi>$->falseL.push_back(kodea.lortuErref());
                        kodea.agGehitu("goto");
                        delete $<adi>1;
                        delete $<adi>3;}
			| adierazpena TLOW adierazpena
                        {$<adi>$ = new expr_struct;
                        $<adi>$->trueL.push_back(kodea.lortuErref());
                        kodea.agGehitu("if " + $<adi>1->izena + " < " + $<adi>3->izena + " goto");
                        $<adi>$->falseL.push_back(kodea.lortuErref());
                        kodea.agGehitu("goto");
                        delete $<adi>1;
                        delete $<adi>3;}
			| adierazpena TBIGQ adierazpena
                        {$<adi>$ = new expr_struct;
                        $<adi>$->trueL.push_back(kodea.lortuErref());
                        kodea.agGehitu("if " + $<adi>1->izena + " >= " + $<adi>3->izena + " goto");
                        $<adi>$->falseL.push_back(kodea.lortuErref());
                        kodea.agGehitu("goto");
                        delete $<adi>1;
                        delete $<adi>3;}
			| adierazpena TLOWQ adierazpena
                        {$<adi>$ = new expr_struct;
                        $<adi>$->trueL.push_back(kodea.lortuErref());
                        kodea.agGehitu("if " + $<adi>1->izena + " <= " + $<adi>3->izena + " goto");
                        $<adi>$->falseL.push_back(kodea.lortuErref());
                        kodea.agGehitu("goto");
                        delete $<adi>1;
                        delete $<adi>3;}
			| adierazpena TNEQL adierazpena
                        {$<adi>$ = new expr_struct;
                        $<adi>$->trueL.push_back(kodea.lortuErref());
                        kodea.agGehitu("if " + $<adi>1->izena + " /= " + $<adi>3->izena + " goto");
                        $<adi>$->falseL.push_back(kodea.lortuErref());
                        kodea.agGehitu("goto");
                        delete $<adi>1;
                        delete $<adi>3;}
			| aldagaia
                        {$<adi>$ = new expr_struct;
                        $<adi>$->izena = *$<izena>1;}
			| TINTEGER
                        {$<adi>$ = new expr_struct;
                        $<adi>$->izena = *$<izena>1;}
			| TFLOAT
                        {$<adi>$ = new expr_struct;
                        $<adi>$->izena = *$<izena>1;}
			| TLPAREN adierazpena TRPAREN
                        {$<adi>$ = $<adi>2;}
      ;

M : /*  produkzio hutsa */
	{ $<erref>$ = kodea.lortuErref(); }
  ;

N : /*  produkzio hutsa */
    {
      $<next>$ = new ErrefLista;
      $<next>$->push_back(kodea.lortuErref());
      kodea.agGehitu("goto");
    }
  ;

%%