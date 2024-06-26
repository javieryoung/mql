//+------------------------------------------------------------------+
//|                                               DemostracionOB.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <../Experts/Bot Londres/OrderBlockAsia.mqh>

input int HoraFin = 20; //Hora de analisis
input int MinutoFin = 0; //Minuto de analisis
input int SegundoFin = 0; //Segundo de analisis

input int regionLocal = 2; // Región local de extremos

void OnTick(){
   if(Hour()==HoraFin && Minute()==MinutoFin && Seconds()==SegundoFin && entro==false){
      SearchOB(distMax, regionLocal);
   }
}