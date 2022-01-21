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
string currentTrend = "no trend";
#include <../Experts/FuncionesComunes.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/3EMA.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/RSI.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/BollingerBands.mqh>
#include <../Experts/Estrategias con indicadores/Licuado de Indicadores/AwesomeOscillator.mqh>


input string titlePonderadores = ""; // PONDERADORES
input double ponderador3EMA = 0; // ponderador 3EMA [0, 1]
input double ponderadorRSI = 0; // ponderador RSI [0, 1]
input double ponderadorBollingerBands = 0; // ponderador BollingerBands [0, 1]
input double ponderadorAwesomeOscillator = 0; // ponderador AwesomeOscillator [0, 1]
input double umbralDeOperacion = 0.7; // operar si el agregado de indicadores supera ... [0, 1]


input string titleSLTP = ""; // PARAMETROS GLOBALES
input double sl = 10; // stoploss
input double tp = 20; // takeprofit
input int desgasteDeSignal = 4; // período utilizado para calcular trend



input string titleHoras = ""; // HORARIOS DE OPERATIVA
input int horaComienzo = 0; // hora comenzar a operar
input int minutoComienzo = 0; // minuto comenzar a operar
input int horaFin = 24; // hora comenzar a operar
input int minutoFin = 0; // minuto comenzar a operar


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
      if (filtroHora() && operacionesAbiertas() == 0) {
      
         int cantidadDeIndicadores = contarIndicadores();
         
         double operar = (
            (ponderador3EMA ? ponderador3EMA * check3EMA() : 0) + 
            (ponderadorRSI ? ponderadorRSI * checkRSI() : 0) +
            (ponderadorBollingerBands ? ponderadorBollingerBands * checkBollingerBands() : 0) +
            (ponderadorAwesomeOscillator ? ponderadorAwesomeOscillator * checkAwesomeOscillator() : 0) 
         ) / cantidadDeIndicadores;
         
         
         if (MathAbs(operar) >= umbralDeOperacion) {
            double volume = calculateLotSize(sl());
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
   if (ponderador3EMA > 0) contador++;
   if (ponderadorRSI > 0) contador++;
   if (ponderadorBollingerBands > 0) contador++;
   if (ponderadorAwesomeOscillator > 0) contador++;
   return contador;
}

void resetSignals() {
   Signal3EMA = 0;
   SignalAwesomeOscillator = 0;
   SignalBollingerBands = 0;
   SignalRSI = 0;
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
// FALTA AGREGAR DETECTOR DE CUANDO ESTÁ ENRANGADO
// HACER QUE DEVUELVA no trend (ya lo uso como si funcionara)


void reloadTrend() {
   string trendAnterior = currentTrend; // solo para el log
   double fast = iMA(Symbol(),0,fastEmaPeriod,0,MODE_EMA,PRICE_OPEN,0);
   double fastPrev = iMA(Symbol(),0,fastEmaPeriod,0,MODE_EMA,PRICE_OPEN,1);
   double medium = iMA(Symbol(),0,mediumEmaPeriod,0,MODE_EMA,PRICE_OPEN,0);
   double mediumPrev = iMA(Symbol(),0,mediumEmaPeriod,0,MODE_EMA,PRICE_OPEN,1);
   if (fast > medium && fastPrev < mediumPrev) {
      currentTrend = "up";
   }
   
   if (fast < medium && fastPrev > mediumPrev) {
      currentTrend = "down";
   }
   Comment("Trend: ", currentTrend);
}
