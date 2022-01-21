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

input string titleTrends = ""; // PARAMETROS GLOBALES
input int operacionesSimultaneas = 1; // operaciones en simultaneo
input double sl = 10; // stoploss
input double tp = 20; // takeprofit
input int desgasteDeSignal = 4; // desgaste de señal

input string titleSLTP = ""; // PARAMETROS DE TENDENCIA
input int slowEmaPeriod = 60; // período EMA lento
input int mediumEmaPeriod = 20; // período EMA medio
input int fastEmaPeriod = 10; // período EMA rápido

input string titlePonderadores = ""; // PONDERADORES
input double ponderadorFastTrend = 0; // ponderador tendencia rápida [0, 1]
input double ponderadorMediumTrend = 0; // ponderador tendencia media [0, 1]
input double ponderador3EMA = 0; // ponderador 3EMA [0, 1]
input double ponderadorRSI = 0; // ponderador RSI [0, 1]
input double ponderadorBollingerBands = 0; // ponderador BollingerBands [0, 1]
input double ponderadorAwesomeOscillator = 0; // ponderador AwesomeOscillator [0, 1]
input double ponderadorMACD = 0; // ponderador MACD [0, 1]
input double ponderadorAccumulationDistribution = 0; // ponderador AccumulationDistribution [0, 1]
input double umbralDeOperacion = 0.7; // operar si el agregado de indicadores supera ... [0, 1]

input string titleHoras = ""; // HORARIOS DE OPERATIVA
input int horaComienzo = 0; // hora comenzar a operar
input int minutoComienzo = 0; // minuto comenzar a operar
input int horaFin = 24; // hora comenzar a operar
input int minutoFin = 0; // minuto comenzar a operar




#include <../Experts/Utilidades/Trend.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/TrendFast.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/TrendMedium.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/3EMA.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/RSI.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/BollingerBands.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/AwesomeOscillator.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/MACD.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/AccumulationDistribution.mqh>


string currentTrend = "no trend";

int OnInit() {
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
      reloadTrend();
      
      int cantidadDeIndicadores = contarIndicadores();
      
      double operar = (
         // TODO: Trend
         // TODO: Acumulation distribution
         checkFastTrend() * ponderadorFastTrend + 
         checkMediumTrend() * ponderadorMediumTrend + 
         (ponderador3EMA ? ponderador3EMA * check3EMA() : 0) + 
         (ponderadorRSI ? ponderadorRSI * checkRSI() : 0) +
         (ponderadorBollingerBands ? ponderadorBollingerBands * checkBollingerBands() : 0) +
         (ponderadorAwesomeOscillator ? ponderadorAwesomeOscillator * checkAwesomeOscillator() : 0) +
         (ponderadorMACD ? ponderadorMACD * checkMACD() : 0) +
         (ponderadorAccumulationDistribution ? ponderadorAccumulationDistribution * checkAccumulationDistribution() : 0)
      ) / cantidadDeIndicadores;
      
         
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
}




int contarIndicadores() {
   int contador = 0;
   if (ponderadorFastTrend > 0) contador++;
   if (ponderadorMediumTrend > 0) contador++;
   if (ponderador3EMA > 0) contador++;
   if (ponderadorRSI > 0) contador++;
   if (ponderadorBollingerBands > 0) contador++;
   if (ponderadorAwesomeOscillator > 0) contador++;
   if (ponderadorMACD > 0) contador++;
   if (ponderadorAccumulationDistribution > 0) contador++;
   
   return contador;
}

void resetSignals() {
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






//////////////////////////////////////////
/////////// mejorar esto!! ///////////////
//////////////////////////////////////////

void reloadTrend() {
   if (fastTrend == "up" && mediumTrend == "up") currentTrend = "up";
   if (fastTrend == "down" && mediumTrend == "down") currentTrend = "down";
   if (fastTrend == "up" && mediumTrend == "down") currentTrend = "no trend";
   if (fastTrend == "down" && mediumTrend == "up") currentTrend = "no trend";
   Comment(currentTrend);
}
