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
input int desgasteDeSignal = 4; // desgaste de señal

input string titleTrends= ""; // PARAMETROS DE TENDENCIA
input int BuscarExtremosTrendShort = 2; // tendencia corta (comparar ... extremos)
input int RegionLocalTrendShort= 2;  // tendencia corta (region local)
input int BuscarExtremosTrendMedium = 3;  // tendencia media (comparar ... extremos)
input int RegionLocalTrendMedium = 8; // tendencia media (region local)
input int BuscarExtremosTrendLong = 3;  // tendencia larga (comparar ... extremos)
input int RegionLocalTrendLong= 20; // tendencia larga (region local)

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
input bool breakEvenEnabled = false;
input bool trailingStopEnabled = true;




#include <../Experts/Utilidades/Trend.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/v1/TrendFast.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/v1/TrendMedium.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/v1/3EMA.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/v1/RSI.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/v1/BollingerBands.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/v1/AwesomeOscillator.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/v1/MACD.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/v1/AccumulationDistribution.mqh>


string trendShort = "no trend";
string trendMedium = "no trend";
string trendLong = "no trend";

int OnInit(){

   long  account  =  AccountInfoInteger(ACCOUNT_LOGIN);
   if (!in_array(account)){
      Print("CUENTA INVALIDA");
      return(INIT_FAILED);
   }      
   
   Print("MODE_LOTSIZE = ", MarketInfo(Symbol(), MODE_LOTSIZE));
   Print("MODE_TICKVALUE = ", MarketInfo(Symbol(), MODE_TICKVALUE));
   Print("DIGITS = ", Digits);
   Print("POINT = ", Point);
   Print("SYMBOL = ", Symbol());
   Print("STOPLEVEL = ", MarketInfo( Symbol(), MODE_STOPLEVEL ));

   Print("Se cargó el Expert a la gráfica...");
   
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
      reloadTrends();
      
      int cantidadDeIndicadores = contarIndicadores();
      
      double operar = (
         // TODO: Trend
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
   if (breakEvenEnabled && !trailingStopEnabled) checkBreakEven();
   if (trailingStopEnabled) checkTrailingStop();
}




int contarIndicadores() {
   int contador = 0;
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

void reloadTrends() {
   trendShort  = trend(BuscarExtremosTrendShort, RegionLocalTrendShort);
   trendMedium = trend(BuscarExtremosTrendMedium, RegionLocalTrendMedium);
   trendLong   = trend(BuscarExtremosTrendLong, RegionLocalTrendLong);
   Comment(trendShort);
}
