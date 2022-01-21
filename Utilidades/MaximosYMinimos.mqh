/*
   Al llamarse cargarMaximosYMinimos se cargarán los arrays:
   maximos: valores maximos de precio encontrados
   minimos: valores minimos de precio encontrados
   maximosShift: shift del lugar donde se encontraron dichos maximos (en el mismo orden)
   minimosShift: shift del lugar donde se encontraron dichos minimos (en el mismo orden)
   
   Parametros:
   buscarEnLasUltimasXVleas: buscará maximos y minimos en las ultimas X velas
   rLocal: para cada vela buscará si es maximo/minimo en la región [shift - rLocal, shift + rLocal]
   debug: dibuja rayitas verticales donde encuentra máximos o minimos
   
*/

double maximos[];
double minimos[];

int maximosShift[];
int minimosShift[];

void cargarMaximosYMinimos(int buscarEnLasUltimasXVelas, int rLocal, bool debug = false) {
   for (int k = rLocal; k<= buscarEnLasUltimasXVelas; k++){
      if (esMaximo(k, rLocal, debug) {
         sizeMaximos = ArraySize(maximos);
         ArrayResize(maximos, sizeMaximos + 1);
         ArrayResize(maximosShift, sizeMaximos + 1);
         maximosShift[sizeMaximos] = k;
         maximos[sizeMaximos] = High[k];
      }
      if (esMinimo(k, rLocal, debug) {
         sizeMinimos = ArraySize(minimos);
         ArrayResize(minimos, sizeMinimos + 1);
         ArrayResize(minimosShift, sizeMinimos + 1);
         minimosShift[sizeMinimos] = k;
         minimos[sizeMinimos] = Low[k];
      }
   }
}

int esMaximo(int supuestoMaximo, int rLocal, bool debug = false){
   for (int barrido = supuestoMaximo-rLocal; barrido<= supuestoMaximo+rLocal; barrido++){
      if (High[supuestoMaximo] < High[barrido]){
         return false;
      }
   }
   if (debug) {
      time = iTime(Symbol(), NULL, supuestoMinimo);
      ObjectCreate(0,rand(),OBJ_VLINE,0,time,0);
   }
   return true;
}


int esMaximo(int supuestoMinimo, int rLocal, bool debug = false){
   for (int barrido = supuestoMinimo-rLocal; barrido<= supuestoMinimo+rLocal; barrido++){
      if (Low[supuestoMinimo] > Low[barrido]){
         return false;
      }
   }
   if (debug) {
      time = iTime(Symbol(), NULL, supuestoMinimo);
      ObjectCreate(0,rand(),OBJ_VLINE,0,time,0);
   }
   return true;
}

