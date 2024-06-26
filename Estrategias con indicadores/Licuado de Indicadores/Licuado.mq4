//+------------------------------------------------------------------+
//|                                                      Licuado.mq4 |
//|                                                     Javier Young |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Javier Young"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int Magic = 381738;

#include <../Experts/FuncionesComunes.mqh>

input string titleSLTP = ""; // PARAMETROS GLOBALES
input int operacionesSimultaneas = 1; // operaciones en simultaneo
input double sl = 10; // stoploss
input double tp = 20; // takeprofit
input double desgasteDeSignal = 0.75; // desgaste de señal


input string titleHoras = ""; // HORARIOS DE OPERATIVA
input int horaComienzo = 0; // hora comienzo
input int minutoComienzo = 0; // minuto comienzo
input int horaFin = 24; // hora final
input int minutoFin = 0; // minuto final


input string titlePonderadores = ""; // PONDERADORES
input double ponderadorADX = 0; // ponderador ADX [0, 1]
input double ponderadorTrend = 0; // ponderador tendencia local [0, 1]
input double ponderadorLongTrend = 0; // ponderador tendencia larga [0, 1]
input double ponderador3EMA = 0; // ponderador 3EMA [0, 1]
input double ponderadorRSI = 0; // ponderador RSI [0, 1]
input double ponderadorBollingerBands = 0; // ponderador BollingerBands [0, 1]
input double ponderadorAwesomeOscillator = 0; // ponderador AwesomeOscillator [0, 1]
input double ponderadorMACD = 0; // ponderador MACD [0, 1]
input double ponderadorAccumulationDistribution = 0; // ponderador AccumulationDistribution [0, 1]
input double umbralDeOperacion = 0.7; // umbral de opreacion [0, 1]


#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/ADX.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/Trend.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/LongTrend.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/3EMA.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/RSI.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/BollingerBands.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/AwesomeOscillator.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/MACD.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/AccumulationDistribution.mqh>


string currentTrend = "no trend";
string longTrend = "no trend";

int OnInit() {
   long  account  =  AccountInfoInteger(ACCOUNT_LOGIN);
   if (!in_array(account)){
      Print("CUENTA INVALIDA");
      // return(INIT_FAILED);
   }      
   return(INIT_SUCCEEDED);
}
  
  
void OnDeinit(const int reason) {

}

double sl() {
   return sl / dividirEntre;
}

double tp() {
   return tp / dividirEntre;
}


void OnTick() {
   if (isNewCandle()) {
      int cantidadDeIndicadores = contarIndicadores();
      
      double operar = (
         ponderadorADX * checkADX() + // lo llamamos siempre pues es quien carga la variable currentTrend
         ponderadorLongTrend * checkLongTrend() +  // lo llamamos siempre pues es quien se encarga de cargar la variable longTrend
         (ponderadorTrend ? ponderadorTrend * checkTrend() : 0) + 
         (ponderador3EMA ? ponderador3EMA * check3EMA() : 0) + 
         (ponderadorRSI ? ponderadorRSI * checkRSI() : 0) +
         (ponderadorBollingerBands ? ponderadorBollingerBands * checkBollingerBands() : 0) +
         (ponderadorAwesomeOscillator ? ponderadorAwesomeOscillator * checkAwesomeOscillator() : 0) +
         (ponderadorMACD ? ponderadorMACD * checkMACD() : 0) +
         (ponderadorAccumulationDistribution ? ponderadorAccumulationDistribution * checkAccumulationDistribution() : 0)
      ) / cantidadDeIndicadores;
      
      Comment("LongTrend: ", longTrend);
      if (filtroHora() && operacionesAbiertas() < operacionesSimultaneas) {
         if (MathAbs(operar) >= umbralDeOperacion) {
            double volume = calculateLotSize(sl()) / operacionesSimultaneas;
            if (operar > 0) { // compra
               OrderSend(Symbol(),OP_BUY, volume, Ask, 0.1, NormalizeDouble(Bid - sl(), Digits), NormalizeDouble(Bid + tp(), Digits), NULL, Magic);
            } else { // vende
               OrderSend(Symbol(),OP_SELL, volume, Bid, 0.1, NormalizeDouble(Bid + sl(), Digits), NormalizeDouble(Bid - tp(), Digits), NULL, Magic);
            }
         }
      } else {
         resetSignals();
      }
   }
   if (breakEvenFactor > 0 && trailingStopFactor <= 0) checkBreakEven();
   if (trailingStopFactor > 0) checkTrailingStop();
}




int contarIndicadores() {
   int contador = 0;
   if (ponderadorADX > 0) contador++;
   if (ponderadorTrend > 0) contador++;
   if (ponderadorLongTrend > 0) contador++;
   if (ponderador3EMA > 0) contador++;
   if (ponderadorRSI > 0) contador++;
   if (ponderadorBollingerBands > 0) contador++;
   if (ponderadorAwesomeOscillator > 0) contador++;
   if (ponderadorMACD > 0) contador++;
   if (ponderadorAccumulationDistribution > 0) contador++;
   
   return contador;
}

void resetSignals() {
   SignalADX = 0;
   Signal3EMA = 0;
   SignalAwesomeOscillator = 0;
   SignalBollingerBands = 0;
   SignalRSI = 0;
   SignalMACD = 0;
   SignalAccumulationDistribution = 0;
}


int operacionesAbiertas() {
   int orders = 0;
   for (int i = 0; i < OrdersTotal(); i ++) {
      if (OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == Magic) {
         orders++;
      }
   }   
   return orders;
}


bool filtroHora() {
   bool afterOpen = Hour() > horaComienzo || (Hour() == horaComienzo && Minute() >= minutoComienzo);
   bool beforeClose = Hour() < horaFin || (Hour() == horaFin && Minute() <= minutoFin);
   
   if (horaComienzo <= horaFin)
      return afterOpen && beforeClose;
   if (horaComienzo > horaFin)
      return afterOpen || beforeClose;
   
   return false; // nunca llega
}






