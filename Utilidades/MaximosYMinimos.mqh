/*

   Al llamarse cargarMaximosYMinimos se cargarán los arrays:
   maximos: valores maximos de precio encontrados
   minimos: valores minimos de precio encontrados
   maximosShift: shift del lugar donde se encontraron dichos maximos (en el mismo orden)
   minimosShift: shift del lugar donde se encontraron dichos minimos (en el mismo orden)
   
   Parametros:
   buscarEnLasUltimasXVleas: buscará maximos y minimos en las ultimas X velas
   rLocal: para cada vela buscará si es maximo/minimo en la región [shift - rLocal, shift + rLocal]
   buscarXExtremos: si encuntra X maximos y X minimos deja de buscar
   debug: dibuja rayitas verticales donde encuentra máximos o minimos
   
*/

double maximos[];
double minimos[];

int maximosShift[];
int minimosShift[];

void cargarMaximosYMinimos(int buscarEnLasUltimasXVelas, int rLocal, int buscarXExtremos = 10000, bool debug = false) {
   ArrayResize(maximos, 0);
   ArrayResize(minimos, 0);
   ArrayResize(maximosShift, 0);
   ArrayResize(minimosShift, 0);
   
   int velas = MathMin(buscarEnLasUltimasXVelas, ArraySize(High) - 1 - buscarEnLasUltimasXVelas - rLocal); // por si no hay suficientes velas
   
   for (int k = rLocal; k <= velas; k++){
      
      if (ArraySize(maximos) == buscarXExtremos && ArraySize(minimos) == buscarXExtremos) return ;
      
      if (esMaximo(k, rLocal, debug) && ArraySize(maximos) < buscarXExtremos) {
         int sizeMaximos = ArraySize(maximos);
         ArrayResize(maximos, sizeMaximos + 1);
         ArrayResize(maximosShift, sizeMaximos + 1);
         maximosShift[sizeMaximos] = k;
         maximos[sizeMaximos] = High[k];
      }
      if (esMinimo(k, rLocal, debug) && ArraySize(minimos) < buscarXExtremos) {
         int sizeMinimos = ArraySize(minimos);
         ArrayResize(minimos, sizeMinimos + 1);
         ArrayResize(minimosShift, sizeMinimos + 1);
         minimosShift[sizeMinimos] = k;
         minimos[sizeMinimos] = Low[k];
      }
   }
}

int esMaximo(int supuestoMaximo, int rLocal, bool debug = false){
   for (int barrido = supuestoMaximo-rLocal; barrido <= supuestoMaximo+rLocal; barrido++){
      if (High[supuestoMaximo] < High[barrido]){
         return false;
      }
   }
   if (debug) {
      datetime time = iTime(Symbol(), NULL, supuestoMaximo);
      int rAux = rand();
      ObjectCreate(0,rAux,OBJ_VLINE,0,time,0);
      ObjectSet(rAux, OBJPROP_COLOR, Green);
      ObjectSet(rAux, OBJPROP_STYLE, STYLE_DOT);
   }
   return true;
}


int esMinimo(int supuestoMinimo, int rLocal, bool debug = false){
   for (int barrido = supuestoMinimo-rLocal; barrido <= supuestoMinimo+rLocal; barrido++){
      if (Low[supuestoMinimo] > Low[barrido]){
         return false;
      }
   }
   if (debug) {
      datetime time = iTime(Symbol(), NULL, supuestoMinimo);
      int rAux = rand();
      ObjectCreate(0,rAux,OBJ_VLINE,0,time,0);
      ObjectSet(rAux, OBJPROP_COLOR, Red);
      ObjectSet(rAux, OBJPROP_STYLE, STYLE_DOT);
   }
   return true;
}

