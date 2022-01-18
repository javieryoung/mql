//+------------------------------------------------------------------+
//|                                              pruebaEngulfing.mq4 |
//|                                                              plp |
//|                                         https://www.lolencio.com |
//+------------------------------------------------------------------+
#property copyright "plp"
#property link      "https://www.lolencio.com"
#property version   "1.00"
#property strict

#include <../Experts/Indicadores/Engulf.mqh>
#include <../Experts/FuncionesComunes.mqh>

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int Magic = 0;
float risk = 0;
int cuentas[1] = {};
int cuenta = 20;
float trailingStopFactor = 0;
float dividirEntre = 1;
int tp = 0;
float breakEvenFactor = 0.1;
int tp() { return tp; }

int OnInit()
  {
//---
   Print("Ta cargao el tester de engulfing");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
int num=0;
void OnTick()
  {
//---
   if (num%2 == 0)
      Print("Tick");
   else
      Print("Tock");
   num++;
   if (isNewCandle()) {
      isEngulfing(1,true);
   }
  }
//+------------------------------------------------------------------+
