//+------------------------------------------------------------------+
//|                                                     La vela Loca |
//|                                                     Javier Young |
//|                                                 https://young.uy |
//+------------------------------------------------------------------+
#property copyright "Javier Young"
#property link      "https://young.uy"
#property version   "1.10"
#property strict

#include <../Experts/pruebas/FuncionesComunes.mqh>
#include <../Experts/Indicadores/Imbalance.mqh>

int Magic = 0;
float risk = 0;
int cuentas[1] = {};
int cuenta = 20;
float trailingStopFactor = 0;
float dividirEntre = 1;
int tp = 0;
float breakEvenFactor = 0.1;
int tp() { return tp; }



int OnInit() {
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason) {
   Print("Se eliminó el Expert a la gráfica...");
}
  
  
void OnTick() {
   if (isNewCandle() && Hour() == 5 && Minute() == 51) {
      buscarUltimoImbalance(true);
   }
}
