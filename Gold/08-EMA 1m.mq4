//+------------------------------------------------------------------+
//|                                                     3 EMA 1m.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


int Magic=8;
input double cuenta = 20000; // tamaño de la cuenta
input double risk = 0.04; // % a arriesgar
input double sl = 10;
input double tp = 10;
input bool breakEvenEnabled = true;
input double breakEvenFactor = 0.2;
input bool trailingStopEnabled = true; // trailing stop
input double trailingStopFactor = 10; // valor de trailing
input int slowEmaPeriod = 80;
input int mediumEmaPeriod = 60;
input int fastEmaPeriod = 20;
input double minimumDistanceBetweenEmasToTrade = 30.0;
input double pipValue = 0.1;

#include <../Experts/FuncionesComunes.mqh>

string trend = "";
bool rompioEmaRapido = false;
bool rompioEmaMedio = false;
bool rompioEmaLento = false;


int OnInit()
  {
   Print("Point");
   Print(Point);
   return(INIT_SUCCEEDED);
  }
  
  
void OnDeinit(const int reason)
  {
  }
  
double tp () {
   return (tp * pipValue);
}

double sl () {
   return (sl * pipValue);
}
  
void OnTick()
  {
   if (operacionesAbiertas() == 0) {
      string lastTrend = trend;
      reloadTrend();
      
      double slow = iMA(Symbol(),0,slowEmaPeriod,0,MODE_EMA,PRICE_OPEN,0);
      double medium = iMA(Symbol(),0,mediumEmaPeriod,0,MODE_EMA,PRICE_OPEN,0);
      double fast = iMA(Symbol(),0,fastEmaPeriod,0,MODE_EMA,PRICE_OPEN,0);
      
      
      double mediumPrev = iMA(Symbol(),0,mediumEmaPeriod,0,MODE_EMA,PRICE_OPEN,1);
      double slowPrev = iMA(Symbol(),0,slowEmaPeriod,0,MODE_EMA,PRICE_OPEN,1);
      
      if ((medium > slow && mediumPrev < slowPrev) || (medium < slow && mediumPrev > slowPrev)) {
         rompioEmaRapido = false;
         rompioEmaMedio = false;
         rompioEmaLento = false;
      }
      
      double volume = calculateLotSize(sl());
      
      if (trend == "alza" && fast > medium && medium > slow) {
         if (Ask < fast) { 
            rompioEmaRapido = true;
         }
         if (Ask < medium) { 
            rompioEmaMedio = true;
         }
         if (Ask < slow) { 
            rompioEmaLento = true;
         }
         
         double useTp;
         if (trailingStopEnabled)
            useTp = 0;
         else
            useTp = NormalizeDouble((Ask + tp()), Digits);
         
         if (Ask > fast && Close[1] > fast && rompioEmaRapido && !rompioEmaLento && MathAbs(fast - slow) > minimumDistanceBetweenEmasToTrade * pipValue) {
            OrderSend(NULL, OP_BUY, volume, Ask, 0.1, NormalizeDouble((Ask - sl()), Digits) , useTp, "Compra", Magic);
            rompioEmaRapido = false;
            rompioEmaMedio = false;
            rompioEmaLento = false;
         }
      }
      
      
      
      if (trend == "baja" && fast < medium && medium < slow) {
         if (Bid > fast) { 
            rompioEmaRapido = true;
         }
         if (Bid > medium) { 
            rompioEmaMedio = true;
         }
         if (Bid > slow) { 
            rompioEmaLento = true;
         }
         
         double useTp;
         if (trailingStopEnabled)
            useTp = 0;
         else
            useTp = NormalizeDouble((Bid - tp()), Digits);
            
         if (Bid < fast && Close[1] < fast && rompioEmaRapido && !rompioEmaLento && MathAbs(fast - slow) > minimumDistanceBetweenEmasToTrade * pipValue) {
            OrderSend(NULL, OP_SELL, volume, Bid, 0.1, NormalizeDouble((Bid + sl()), Digits) ,useTp, "Venta", Magic);
            rompioEmaRapido = false;
            rompioEmaMedio = false;
            rompioEmaLento = false;
         }
      }
      
   }
   if (breakEvenEnabled && !trailingStopEnabled) checkBreakEven();
   if (trailingStopEnabled) checkTrailingStop();
  }



void reloadTrend() {
   string trendAnterior = trend; // solo para el log
   double fast = iMA(Symbol(),0,fastEmaPeriod,0,MODE_EMA,PRICE_OPEN,0);
   double fastPrev = iMA(Symbol(),0,fastEmaPeriod,0,MODE_EMA,PRICE_OPEN,1);
   double medium = iMA(Symbol(),0,mediumEmaPeriod,0,MODE_EMA,PRICE_OPEN,0);
   double mediumPrev = iMA(Symbol(),0,mediumEmaPeriod,0,MODE_EMA,PRICE_OPEN,1);
   if (fast > medium && fastPrev < mediumPrev) {
      trend = "alza";
   }
   
   if (fast < medium && fastPrev > mediumPrev) {
      trend = "baja";
   }
   
}




int operacionesAbiertas() {
   int ordenes = 0;
   for(int i = 0; i < OrdersTotal(); i++){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
            ordenes++;
         }
      }
   }
   return ordenes;
}



