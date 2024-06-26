/*
   Al llamarse a la función trend devolverá un string:
   "up" si hay tendencia alzista
   "down" si hay tendencia bajista
   "no trend" si está enrangado
   
   Parametros:
   buscarEnLasUltimosXExtremos: se fijara en los ultimos X minimos y maximos encontrados para decidir el trend (si no hay suficientes, busca en los que haya)
   debug: dibuja rayitas verticales donde encuentra máximos o minimos
   
*/

#include <../Experts/Utilidades/MaximosYMinimos.mqh>

string trend(int buscarEnLosUltimosXExtremos, int rLocal, bool debug = false) {
   cargarMaximosYMinimos(10000, rLocal, buscarEnLosUltimosXExtremos, debug);
   bool maximosCrecientes = true;
   bool maximosDecrecientes = true;
   int mirarLosUltimosXMaximos = (ArraySize(maximos)-1 < buscarEnLosUltimosXExtremos) ? ArraySize(maximos)-1 : buscarEnLosUltimosXExtremos-1;
   for (int i = 0; i < mirarLosUltimosXMaximos; i ++) {
      if (maximos[i] < maximos[i+1])
         maximosCrecientes = false;
      if (maximos[i] > maximos[i+1])
         maximosDecrecientes = false;
   }
   
   bool minimosCrecientes = true;
   bool minimosDecrecientes = true;
   int mirarLosUltimosXMinimos = (ArraySize(minimos)-1 < buscarEnLosUltimosXExtremos) ? ArraySize(minimos)-1 : buscarEnLosUltimosXExtremos-1;
   for (int i = 0; i < mirarLosUltimosXMinimos; i ++) {
      if (minimos[i] > minimos[i+1])
         minimosDecrecientes = false;
      if (minimos[i] < minimos[i+1])
         minimosCrecientes = false;
   }
   
   if (minimosCrecientes) return "up"; // lo que esta despues del or no se si está bien (o si aporta algo)
   if (maximosDecrecientes) return "down";
   if (!minimosCrecientes && !maximosDecrecientes) return "no trend";
   
   return "no trend";
}


