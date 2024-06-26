// devuelve true si el precio en algun momento tapó al rango [abajo, arriba] en las n ultimas velas
// recibe dos parametros que pueden ser modificados
// abajo    borde inferior del margen de precios que quiero ver si fue alcanzado por alguna vela
// arriba   borde superior del margen de precios que quiero ver si fue alcanzado por alguna vela


bool precioPendiente(float &abajo, float &arriba, int n) {
   int i;   
   if (Bid > abajo) { // estamos por encima del precio buscado (o dentro del rango)
      for (i = 1; i < n; i++) {
         if (Low[i] < arriba) 
            arriba = Low[i];
         if (Low[i] < abajo)
            return false;
      }
   }
   
   if (Bid < arriba) { // estamos por debajo del precio buscado (o dentro del rango)
      for (i = 1; i < n; i++) {
         if (High[i] > abajo) 
            abajo = High[i];
         if (High[i] > arriba)
            return false;
      }
   }
   
   string rand = IntegerToString(MathRand());
   ObjectCreate(0,rand,OBJ_HLINE,0,0,abajo);
   ObjectSetInteger(0,rand,OBJPROP_STYLE,STYLE_DOT);
   rand = IntegerToString(MathRand());
   ObjectCreate(0,rand,OBJ_HLINE,0,0,arriba);
   ObjectSetInteger(0,rand,OBJPROP_STYLE,STYLE_DOT);
   return true;
}

