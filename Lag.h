#ifndef LAG_H_
#define LAG_H_

#include <string>
#include <set>
#include <vector>
#include <list>

typedef std::list<std::string> IdLista;
typedef std::list<int> ErrefLista;

struct expr_struct {
  std::string izena ;
  ErrefLista trueL ;  // true hitz erreserbatua c-z
  ErrefLista falseL ; // false hitz erreserbatua c-z
};


#endif /* LAG_H_ */
