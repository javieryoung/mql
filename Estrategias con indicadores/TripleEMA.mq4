//+------------------------------------------------------------------+
//|                                                     3 EMA 1m.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


input int Magic=8;
input double sl = 10;
input double tp = 10;
input int slowEmaPeriod = 80;
input int mediumEmaPeriod = 60;
input int fastEmaPeriod = 20;
input double minimumDistanceBetweenEmasToTrade = 30.0;


input int horaComienzo = 0; // hora comenzar a operar
input int minutoComienzo = 0; // minuto comenzar a operar
input int horaFin = 24; // hora comenzar a operar
input int minutoFin = 0; // minuto comenzar a operar

#include <../Experts/FuncionesComunes.mqh>


string trend = "";
bool rompioEmaRapido = false;
bool rompioEmaMedio = false;
bool rompioEmaLento = false;


int OnInit()
  {
   long  account  =  AccountInfoInteger(ACCOUNT_LOGIN);
   if (!in_array(account)){
      Print("CUENTA INVALIDA");
      // return(INIT_FAILED)
   }      
   return(INIT_SUCCEEDED);
  }
  
  
void OnDeinit(const int reason)
  {
  }
  
double tp () {
   return (tp / dividirEntre);
}

double sl () {
   return (sl / dividirEntre);
}
  
void OnTick()
  {
   if (filtroHora() && operacionesAbiertas() == 0) {
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
         
         if (Ask > fast && Close[1] > fast && rompioEmaRapido && !rompioEmaLento && MathAbs(fast - slow) > minimumDistanceBetweenEmasToTrade / dividirEntre) {
            OrderSend(NULL, OP_BUY, volume, Ask, 0.1, NormalizeDouble((Ask - sl()), Digits) , useTp, "", Magic);
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
            
         if (Bid < fast && Close[1] < fast && rompioEmaRapido && !rompioEmaLento && MathAbs(fast - slow) > minimumDistanceBetweenEmasToTrade / dividirEntre) {
            OrderSend(NULL, OP_SELL, volume, Bid, 0.1, NormalizeDouble((Bid + sl()), Digits) ,useTp, "", Magic);
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


bool filtroHora() {
   bool afterOpen = Hour() > horaComienzo || (Hour() == horaComienzo && Minute() >= minutoComienzo);
   bool beforeClose = Hour() < horaFin || (Hour() == horaFin && Minute() <= minutoFin);
   
   if (horaComienzo <= horaFin)
      return afterOpen && beforeClose;
   if (horaComienzo > horaFin)
      return afterOpen || beforeClose;
   
   return false; // nunca llega
}
