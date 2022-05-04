#include "Kodea.h"

using namespace std;

/*****************/
/* Eraikitzailea */
/*****************/

Kodea::Kodea()
{
  hurrengoId = 1;
}

/*******************/
/* hurrengoAgindua */
/*******************/

int Kodea::hurrengoAgindua() const
{
  return aginduak.size() + 1;
}

/************/
/* idBerria */
/************/

string Kodea::idBerria()
{
  stringstream stream;
  stream << "_t" << hurrengoId++;
  return stream.str();
}

/************/
/* agGehitu */
/************/

void Kodea::agGehitu(const string &aginduKatea)
{
  stringstream agindua;
  agindua << hurrengoAgindua() << ": " << aginduKatea;
  aginduak.push_back(agindua.str());
}

/**********************/
/* erazagupenakGehitu */
/**********************/

void Kodea::erazagupenakGehitu(const string &motaIzena, const IdLista &idIzenak)
{
  IdLista::const_iterator iter;
  for (iter = idIzenak.begin(); iter != idIzenak.end(); iter++)
  {
    agGehitu(string(motaIzena + " " + *iter));
  }
}

/**********************/
/* parametroakGehitu  */
/**********************/

void Kodea::parametroakGehitu(const IdLista &idIzenak, const string &pMota, const string &motaIzena)
{
  IdLista::const_iterator iter;
  for (iter = idIzenak.begin(); iter != idIzenak.end(); iter++)
  {
    agGehitu(pMota + motaIzena + " " + *iter);
  }
}

/***********/
/* agOsatu */
/***********/

void Kodea::agOsatu(ErrefLista &aginduZenbakiak, const int balioa)
{
  stringstream stream;
  ErrefLista::iterator iter;
  stream << " " << balioa;
  for (iter = aginduZenbakiak.begin(); iter != aginduZenbakiak.end(); iter++)
  {
    aginduak[*iter - 1].append(stream.str());
  }
}

/**********/
/* idatzi */
/**********/

void Kodea::idatzi()
{
  vector<string>::const_iterator iter;
  if (erroreak.size() == 0)
  {
    for (iter = aginduak.begin(); iter != aginduak.end(); iter++)
    {
      cout << *iter << " ;" << endl;
    }
  }
  else
  {
    for (iter = erroreak.begin(); iter != erroreak.end(); iter++)
    {
      cout << *iter << endl;
    }
  }
}

/****************/
/* erroeaGehitu */
/****************/
void Kodea::erroreaGehitu(const string &errorea)
{
  erroreak.push_back(errorea);
}

/**************/
/* lortuErref */
/**************/

int Kodea::lortuErref() const
{
  return hurrengoAgindua();
}
