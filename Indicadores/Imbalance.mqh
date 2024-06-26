
#include <../Experts/Indicadores/TocaPrecio.mqh>

float rangoImbalanceAbajo;
float rangoImbalanceArriba;

// devuelve true si la vela en pos está imbalanceada
// debug true dibuja rayitas
// además carga las variables rangoImbalanceadoAbajo y Arriba con el rango de precios donde hay imbalance
bool velaImbalanceada(int pos, bool debug = false) {
   
   bool imbalanced = High[pos+1] < Low[pos-1] || (Low[pos+1] > High[pos-1]);
   
   if (imbalanced) {
      if (High[pos+1] < Low[pos-1]) {
         rangoImbalanceAbajo = High[pos+1];
         rangoImbalanceArriba = Low[pos-1];
      }  
      if (Low[pos+1] > High[pos-1]) {
         rangoImbalanceArriba = Low[pos+1];
         rangoImbalanceAbajo = High[pos-1];
      }
      if (debug){ 
         datetime time = iTime(Symbol(), NULL, pos);
         string rand = IntegerToString(MathRand());
         ObjectCreate(0,rand,OBJ_VLINE,0,time,0);
         ObjectSetInteger(0,rand,OBJPROP_STYLE,STYLE_DOT);
      }
   }
   return imbalanced;
}


// devuelve el shift de la última vela imbalanceada
int buscarUltimoImbalance(bool debug = false) {
   bool encontre = false;
   int shift = 2;
   while (!encontre) {
      if (velaImbalanceada(shift, debug)) {
         encontre = precioPendiente(rangoImbalanceAbajo, rangoImbalanceArriba, shift);
         if (encontre) return shift;
      }
      shift++;
   }
   return 0;
}