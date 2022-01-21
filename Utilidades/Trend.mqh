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



#include <../Experts/Utilidades/MaximosYMinimos.mqh>

string trend(int buscarEnLasUltimasXVleas, bool debug = false) {
   bool maximosCrecientes = true;
   for (int i = 0; i < ArraySize(maximos)-1; i ++) {
      if (maximos[i-1] > maximos[i]
      // ya sigo, sry
   }
}
