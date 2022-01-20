//+------------------------------------------------------------------+
//|                                                       tester.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <../Experts/FuncionesComunes.mqh>
#include <../Experts/Bot Londres/OrderBlockAsia.mqh>
#include <../Experts/Bot Londres/OperacionesGeneral.mqh>
#include <../Experts/Bot Londres/rectangle.mqh>


// Parámetros principales
input string t1 = " "; //PARÁMETROS PRINCIPALES
input int Magic = 7539;
input double cuenta=10000; // Cuenta
input double risk=1; // Riesgo

// Input región de operaciones
input string t2 = " "; //REGIÓN DE OPERATIVA
input bool operarFueraDeAsia = true; //Opera fuera de Asia
input bool operarEnAsia = true; //Opera en Asia

// Input temporales
input string t3 = " "; //RANGOS HORARIOS
input int HoraFin = 8; //Hora de analisis
input int MinutoFin = 0; //Minuto de analisis
input int SegundoFin = 0; //Segundo de analisis
input int RangoHoras = 12; //Horas que mira el analisis
input int HoraCerrar = 8; //Hora cierre pendientes
input int HoraCerrarAbiertas = 8; //Hora cierre abiertas

// Input bloques de órden
input string tob = " "; //BLOQUES DE ORDEN
input int regionLocal = 2; // Región local de extremos
input bool BOSenabled = false; //Activar BOS
input double umbral = 30; //Minima separacion OBs
input double umbralPendiente = 0; //Minima pendiente para que sea OB

// Input órdenes
input string t4 = " "; //INPUT DE ÓRDENES 
input bool SLvariable = false; //Stop Loss variable
input bool TPvarialbe = false; //Take Profit variable
input bool tocaPrecio=false; // Toca precio?
input double SL = 25; // Stop loss
input double factorTP=5; // Factor de take profit
input double slAir=0; // Aire del stop loss
input bool stopsEnabled=true; // Buy/Sell Stops enabled

// Input velas
input string t5 = " "; //INPUT DE VELAS
input int tamanoVelaMax = 50; //Vela grande
input int tamanoCuerpoMax = 30; //Cuerpo grande
input int tamanoMechaMax=20; //Mecha grande

// Input TS y BE
input string t6 = " "; //INPUT TS y BE
input bool breakEvenEnabled = false; //Activar Break Even
input double breakEvenFactor = 0.6; //Factor de Break Even
input bool trailingStopEnabled = false; //Activar Trailing Stop
input double trailingStopFactor = 10; // Factor de Trailing Stop

// Hiperparámetros
input string t7 = " "; //HIPERPARÁMETROS
input double dividirEntre=1; //Dividir entre

int OnInit() {
   long  account  =  AccountInfoInteger(ACCOUNT_LOGIN);
   if (!in_array(account)){
      Print("CUENTA INVALIDA");
      return(INIT_FAILED);
   }
   Print("Se cargó el Expert a la gráfica...");
   
   return(INIT_SUCCEEDED);
}


//int pos = 16;
// Si el máximo máximo es mayor al Ask actual entonces solo se programan compras

int distMax = CalcularNvelas(RangoHoras);
bool entro= false;


void OnTick(){
   if(Hour()==HoraFin && Minute()==MinutoFin && Seconds()==SegundoFin && entro==false){
      //RangosAsiaYgris(); // printea líneas de los rangos de la estrategia y Asia.
      GenerarRectangulos();
      
      entro = true;
      SearchOB(distMax, regionLocal);
      
      //Print(ArraySize(arrTrueDw));
      //Print(ArraySize(arrTrueUp));
      
      //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      if (operarFueraDeAsia){
         if(ArraySize(arrTrueDw)>0){
            for(int i=0; i<=ArraySize(arrUmbralDw)-1; i++){
               OperarFueraDeAsiaBuy(arrUmbralDw[i]);
            }
         }
         if(ArraySize(arrTrueUp)>0){
            for(int j=0; j<=ArraySize(arrUmbralUp)-1; j++){
               OperarFueraDeAsiaSell(arrUmbralUp[j]);
            }
         }
      }
      
      if (operarEnAsia){
         if(ArraySize(arrTrueDw)>0){
            for(int i=0; i<=ArraySize(arrUmbralDw)-1; i++){
               OperarEnAsiaBuy(arrUmbralDw[i]);
            }
         }
         if(ArraySize(arrTrueUp)>0){
            for(int j=0; j<=ArraySize(arrUmbralUp)-1; j++){
               OperarEnAsiaSell(arrUmbralUp[j]);
            }
         }
      }
      //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   }
   
   
   if (Hour()==HoraFin+HoraCerrar){ // Relativo a HoraFin
      entro=false;
      CerrarTodo();
      //RectangleDelete(0,"Rango Total");
      //RectangleDelete(0,"Rango Asia");
      
      ArrayFree(todosLosCandidatos);
      ArrayFree(arrUp);
      ArrayFree(arrDw);
      ArrayFree(arrTrueDw);
      ArrayFree(arrTrueUp);
      ArrayFree(arrUmbralDw);
      ArrayFree(arrUmbralUp);
   }
   
   if (Hour()==HoraFin+HoraCerrarAbiertas){ // Relativo a HoraFin
      CerrarAbiertas();
   }
   
   if (breakEvenEnabled && !trailingStopEnabled) checkBreakEven();
   if (trailingStopEnabled) checkTrailingStop();
}


void RangosAsiaYgris(){
   int randint = rand();
   datetime time = iTime(Symbol(), NULL, CalcularNvelas(0));
   ObjectCreate(NULL,randint,OBJ_VLINE,0,time,0);
   ObjectSet(randint, OBJPROP_COLOR, Gray);
   
   randint = rand();
   time = iTime(Symbol(), NULL, CalcularNvelas(12));
   ObjectCreate(NULL,randint,OBJ_VLINE,0,time,0);
   ObjectSet(randint, OBJPROP_COLOR, Gray);
   
   randint = rand();
   time = iTime(Symbol(), NULL, CalcularNvelas(1));
   ObjectCreate(NULL,randint,OBJ_VLINE,0,time,0);
   ObjectSet(randint, OBJPROP_COLOR, Purple);
   
   randint = rand();
   time = iTime(Symbol(), NULL, CalcularNvelas(8));
   ObjectCreate(NULL,randint,OBJ_VLINE,0,time,0);
   ObjectSet(randint, OBJPROP_COLOR, Purple);
}