//+------------------------------------------------------------------+
//|                                                       tester.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <../Experts/OrderBlock.mqh>
#include <../Experts/Operaciones.mqh>
//#include <../Experts/FuncionesComunes.mqh>

// Hiperparámetro
input int regionLocal = 5;

// Input temporales
input int HoraFin = 20; //Finaliza el análisis
input int MinutoFin = 0;
input int SegundoFin = 0;
input int HoraCerrar = 11; //Cierra las pendientes
input int RangoHoras = 12;


//int pos = 16;
// Si el máximo máximo es mayor al Ask actual entonces solo se programan compras

int distMax = CalcularNvelas(RangoHoras);
bool entro= False;

void OnTick(){
   if(Hour()==HoraFin && Minute()==MinutoFin && Seconds()==SegundoFin && entro==False){
      Rangos();
      
      entro = True;
      SearchOB(distMax, regionLocal);
      
      //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      if(ArraySize(arrTrueDw)>0){
         for(int i=0; i<=ArraySize(arrTrueDw)-1; i++){
            OperarBuySLvariable(arrTrueDw[i]);
         }
      }
      if(ArraySize(arrTrueUp)>0){
         for(int j=0; j<=ArraySize(arrTrueUp)-1; j++){
            OperarSellSLvariable(arrTrueUp[j]);
         }
      }
      //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   }
   
   
   if (Hour()==HoraCerrar){
      entro=False;
      CerrarTodo();
      int arrTrueDw[];
      int arrTrueUp[];
   }
   
}

