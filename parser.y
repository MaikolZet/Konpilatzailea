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

   void errorea (const char *msg) {
     kodea.erroreaGehitu("ERROREA, Lerroa " + to_string(yylineno) + ": " + msg);
     yyerrornum++;
   }

%}

/*******************************************************************************/
/* Ikurrek zein atributu-mota izan dezaketen.                                  */
/* Gogoratu ikur bakoitzak atributu bakarra eta oinarrizko motetakoak          */
/* (osoko, erreal, karaktere, erakusle).                                       */

%union {
    string *izena ;
    expr_struct *adi ;  /* Bertan izena trueL eta falseL */
    IdLista *izenak ;
    int erref ;
    ErrefLista *next;
    contbreak_struct *bc; /* Bertan cont eta breakL */
    string *mota;
}


/* LEXIKOAK */

%token <izena> TID TINTEGER TFLOAT


/* ATRIBUTU GABEKOAK */

%token RDEF RMAIN RLET RIN RFOR
%token TCOLON RAND ROR RNOT
%token TLBRACE TRBRACE TSEMIC TMUL TASSIG TSUM TBIG TBIGQ TLOW TLOWQ
%token TLPAREN TRPAREN TCOMMA TAMPERSAND
%token TRES THASH TDIV TNEQL TEQL 
%token RFOREVER RWHILE RELSE RCONTINUE RBREAK 
%token RPROG RPRINT RREAD RIF
%token RINT RFLOAT

/* SINTETIZATUAK */

%type <erref> M
%type <izenak> id_zerrendaren_bestea id_zerrenda
%type <mota> mota par_mota
%type <adi> adierazpena
%type <next> N 
%type <bc> bloke sententzia sententzia_zerrenda
%type <izena> aldagaia






%left RNOT RAND ROR
%nonassoc TBIG TBIGQ TLOW TLOWQ TNEQL TEQL
%left TSUM TRES
%left TMUL TDIV

%start programa

%%

programa : RDEF RMAIN TLPAREN TRPAREN TCOLON 
      {kodea.agGehitu("proc main");} 

bloke_nag
        {kodea.agGehitu("halt");
            kodea.idatzi();}
         ;

bloke_nag : bl_eraz TLBRACE azpiprogramen_eraz sententzia_zerrenda TRBRACE
            
            ;

bloke : bl_eraz TLBRACE sententzia_zerrenda TRBRACE
            {$<bc>$ = $<bc>3;}
        ;

bl_eraz : RLET eraz RIN
			|
      ;

eraz : eraz TSEMIC id_zerrenda TCOLON mota
                        { kodea.erazagupenakGehitu(*$<mota>5,*$<izenak>3);}
			| id_zerrenda TCOLON mota
                        { kodea.erazagupenakGehitu(*$<mota>3,*$<izenak>1);}
      ;

id_zerrenda : TID id_zerrendaren_bestea 
                  {$<izenak>$ = $<izenak>2;
                  $<izenak>$->push_front(*$<izena>1);}
      ;

id_zerrendaren_bestea : TCOMMA TID id_zerrendaren_bestea 
                        {$<izenak>$ = $<izenak>3;
                        $<izenak>$->push_front(*$<izena>2);
                        delete $<izena>2;}
			|
                        {$<izenak>$ = new IdLista;}
      ;

mota : RINT 
            {$<mota>$ = new std::string;
            *$<mota>$ = "int";}
      | RFLOAT
            {$<mota>$ = new std::string;
            *$<mota>$ = "real";}
      ;

azpiprogramen_eraz : azpiprogramaren_eraz azpiprogramen_eraz
			|
      ;

azpiprogramaren_eraz : RDEF TID {kodea.agGehitu("proc " + *$<izena>2); } argumentuak TCOLON bloke_nag {kodea.agGehitu("endproc " + *$<izena>2);}
      ;

argumentuak : TLPAREN par_zerrenda TRPAREN
			|
      ;

par_zerrenda : id_zerrenda TCOLON par_mota mota {kodea.parametroakGehitu(*$<izenak>1,*$<mota>3,*$<mota>4); } par_zerrendaren_bestea
      ;

par_mota : TAMPERSAND
            {$<mota>$ = new std::string;
            *$<mota>$ = "ref_";}
      |
            {$<mota>$ = new std::string;
            *$<mota>$ = "val_";}
      ;

par_zerrendaren_bestea : TSEMIC id_zerrenda TCOLON par_mota mota {kodea.parametroakGehitu(*$<izenak>2,*$<mota>4,*$<mota>5);} par_zerrendaren_bestea 
			|
      ;

sententzia_zerrenda : sententzia sententzia_zerrenda 
                        {$<bc>$ = new contbreak_struct;
                        $<bc>$->breakL.splice($<bc>$->breakL.end(), $<bc>1->breakL);
                        $<bc>$->breakL.splice($<bc>$->breakL.end(), $<bc>2->breakL);
                        $<bc>$->cont.splice($<bc>$->cont.end(), $<bc>1->cont);
                        $<bc>$->cont.splice($<bc>$->cont.end(), $<bc>2->cont);}
			| 
                        {$<bc>$ = new contbreak_struct;}
      ;

sententzia : aldagaia TASSIG adierazpena TSEMIC
                        {$<bc>$ = new contbreak_struct;
                        if ($<adi>3->trueL.size() != 0){
                                errorea("Adierazpen ez boolear bat espero zen.");
                        }
                        kodea.agGehitu(*$<izena>1 + " := " + $<adi>3->izena);
                        delete $<adi>3;
                        delete $<izena>1;}
			| RIF adierazpena TCOLON 
                        {if($<adi>2->trueL.size() == 0){
                                errorea("Adierazpen boolear bat espero zen.");
                        }}
                        M bloke M
                        {if($<adi>2->trueL.size() != 0){
                                kodea.agOsatu($<adi>2->trueL,$<erref>5);
                                kodea.agOsatu($<adi>2->falseL,$<erref>7);
                        }
                        $<bc>$ = $<bc>6;}
			|M RFOREVER TCOLON bloke M
                        {kodea.agGehitu("goto " + to_string($<erref>1));
                        kodea.agOsatu($<bc>4->breakL,$<erref>5+1);
                        $<bc>$ = new contbreak_struct;
                        $<bc>$->cont = $<bc>4->cont;}
			| M RWHILE adierazpena TCOLON 
                        {if($<adi>3->trueL.size() == 0){
                                errorea("Adierazpen boolear bat espero zen.");
                        }}
                        M bloke N RELSE TCOLON M bloke
                        {
                        if($<adi>3->trueL.size() != 0){
                                kodea.agOsatu($<adi>3->trueL,$<erref>6);
                                kodea.agOsatu($<adi>3->falseL,$<erref>11);
                        }
                        kodea.agOsatu(*$<next>8,$<erref>1);
                        $<bc>$ = new contbreak_struct;
                        kodea.agOsatu($<bc>7->breakL,$<erref>11);
                        $<bc>$->breakL = $<bc>12->breakL;
                        kodea.agOsatu($<bc>7->cont,$<erref>1);
                        kodea.agOsatu($<bc>12->cont,$<erref>1);}
			| RBREAK RIF adierazpena M TSEMIC
                        {
                        $<bc>$ = new contbreak_struct;
                        if($<adi>3->trueL.size() == 0){
                                errorea("Adierazpen boolear bat espero zen.");
                        }else{
                                kodea.agOsatu($<adi>3->falseL,$<erref>4);
                                $<bc>$->breakL = $<adi>3->trueL;
                        }
                        }
			| RCONTINUE TSEMIC
                        {$<bc>$ = new contbreak_struct;
                        $<bc>$->cont.push_back(kodea.lortuErref());
                        kodea.agGehitu("goto");}
			| RREAD TLPAREN aldagaia TRPAREN TSEMIC
                        {kodea.agGehitu("read " + *$<izena>3);
                        $<bc>$ = new contbreak_struct;}
			| RPRINT TLPAREN adierazpena TRPAREN TSEMIC
                        {kodea.agGehitu("write " + $<adi>3->izena);
                        kodea.agGehitu("writeln");
                        $<bc>$ = new contbreak_struct;}
                        | RFOR TLPAREN aldagaia TASSIG adierazpena TSEMIC
                        {if ($<adi>5->trueL.size() != 0){
                                errorea("1. Adierazpenean adierazpen ez boolear bat espero zen.");
                        }
                        kodea.agGehitu(*$<izena>3 + " := " + $<adi>5->izena);
                        delete $<adi>5;
                        delete $<izena>3;} 
                        M adierazpena TSEMIC M aldagaia TASSIG adierazpena
                        {if($<adi>9->trueL.size() == 0){
                                 errorea("2. Adierazpenean adierazpen boolear bat espero zen");
                        }else if ($<adi>14->trueL.size() != 0){
                                errorea("3. Adierazpenean adierazpen ez boolear bat espero zen.");
                        }
                        kodea.agGehitu(*$<izena>12 + " := " + $<adi>14->izena);
                        delete $<adi>14;
                        delete $<izena>12;}
                        N TRPAREN TCOLON M bloke M
                        {$<bc>$ = new contbreak_struct;
                         if($<adi>9->trueL.size() != 0){
                                 kodea.agOsatu($<adi>9->trueL, $<erref>19);
                                 kodea.agOsatu($<adi>9->falseL, $<erref>21 + 1);
                                 kodea.agOsatu(*$<next>16, $<erref>8);
                                 kodea.agGehitu("goto " + to_string($<erref>11));
                                 kodea.agOsatu($<bc>20->breakL, $<erref>21 + 1);
                                 kodea.agOsatu($<bc>20->cont, $<erref>11);
                         }
                        }
      ;

aldagaia : TID 
      {$<izena>$ = $<izena>1;}
      ;

adierazpena : adierazpena TSUM adierazpena
                        {$<adi>$ = new expr_struct;
                        $<adi>$->izena = kodea.idBerria();
                        kodea.agGehitu($<adi>$->izena + " := " + $<adi>1->izena + " + " + $<adi>3->izena);
                        delete $<adi>1;
                        delete $<adi>3;}
			| adierazpena TRES adierazpena
                        {$<adi>$ = new expr_struct;
                        $<adi>$->izena = kodea.idBerria();
                        kodea.agGehitu($<adi>$->izena + " := " + $<adi>1->izena + " - " + $<adi>3->izena);
                        delete $<adi>1;
                        delete $<adi>3;}
			| adierazpena TMUL adierazpena
                        {$<adi>$ = new expr_struct;
                        $<adi>$->izena = kodea.idBerria();
                        kodea.agGehitu($<adi>$->izena + " := " + $<adi>1->izena + " * " + $<adi>3->izena);
                        delete $<adi>1;
                        delete $<adi>3;}
                        | adierazpena TDIV adierazpena
                        {$<adi>$ = new expr_struct;
                        $<adi>$->izena = kodea.idBerria();
                        kodea.agGehitu($<adi>$->izena + " := " + $<adi>1->izena + " / " + $<adi>3->izena);
                        delete $<adi>1;
                        delete $<adi>3;}
			| adierazpena TEQL adierazpena
                        {$<adi>$ = new expr_struct;
                        $<adi>$->trueL.push_back(kodea.lortuErref());
                        kodea.agGehitu("if " + $<adi>1->izena + " = " + $<adi>3->izena + " goto");
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
                        kodea.agGehitu("if " + $<adi>1->izena + " != " + $<adi>3->izena + " goto");
                        $<adi>$->falseL.push_back(kodea.lortuErref());
                        kodea.agGehitu("goto");
                        delete $<adi>1;
                        delete $<adi>3;}
			| aldagaia
                        {$<adi>$ = new expr_struct;
                        $<adi>$->izena = *$<izena>1;}
			| TINTEGER
                        {$<adi>$ = new expr_struct;
                        $<adi>$->izena = *$<izena>1;
                        delete $<izena>1;}
			| TFLOAT
                        {$<adi>$ = new expr_struct;
                        $<adi>$->izena = *$<izena>1;
                        delete $<izena>1;}
			| TLPAREN adierazpena TRPAREN
                        {$<adi>$ = $<adi>2;}
                        | adierazpena RAND M adierazpena
                        {$<adi>$ = new expr_struct;
                        if($<adi>1->trueL.size() == 0){
                                errorea("adierazpen boolear bat espero zen AND-eko lehenengo adierazpenean");
                        }else if($<adi>4->trueL.size() == 0){
                                errorea("adierazpen boolear bat espero zen AND-eko bigarren adierazpenean");
                        }else{
                                kodea.agOsatu($<adi>1->trueL,$<erref>3);
                                $<adi>$->falseL.splice($<adi>$->falseL.end(),$<adi>1->falseL);
                                $<adi>$->falseL.splice($<adi>$->falseL.end(),$<adi>4->falseL);
                                $<adi>$->trueL = $<adi>4->trueL;}
                        }
                        | adierazpena ROR M adierazpena
                        {$<adi>$ = new expr_struct;
                        if($<adi>1->trueL.size() == 0){
                                errorea("adierazpen boolear bat espero zen OR-eko lehenengo adierazpenean");
                        }else if($<adi>4->trueL.size() == 0){
                                errorea("adierazpen boolear bat espero zen OR-eko bigarren adierazpenean");
                        }else{
                                kodea.agOsatu($<adi>1->falseL,$<erref>3);
                                $<adi>$->trueL.splice($<adi>$->trueL.end(),$<adi>1->trueL);
                                $<adi>$->trueL.splice($<adi>$->trueL.end(),$<adi>4->trueL);
                                $<adi>$->falseL = $<adi>4->falseL;}
                        }
                        | RNOT adierazpena
                        {$<adi>$ = new expr_struct;
                        if($<adi>2->trueL.size() == 0){
                                errorea("adierazpen boolear bat espero zen NOT-ean");
                        }else{
                                $<adi>$->trueL = $<adi>2->falseL;
                                $<adi>$->falseL = $<adi>2->trueL;}
                        }
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