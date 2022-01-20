//+------------------------------------------------------------------+
//|                                                     RSI test.mq4 |
//|                                                     Javier Young |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Javier Young"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <../Experts/FuncionesComunes.mqh>

input int Magic = 101010;


input double cuenta = 20000;
input double risk = 0.1;
input bool breakEvenEnabled = false; // activar break even
input double breakEvenFactor = 0.6; // % break even
input bool trailingStopEnabled = false; // trailing stop
input double trailingStopFactor = 10; // valor de trailing


input int horaComienzo = 0; // hora comenzar a operar
input int minutoComienzo = 0; // minuto comenzar a operar
input int horaFin = 24; // hora comenzar a operar
input int minutoFin = 0; // minuto comenzar a operar

input double takeprofit = 3;
input double stoploss = 10;
input double dividirEntre = 10000;




double tp() {
   return takeprofit / dividirEntre;
}
double sl() {
   return stoploss / dividirEntre;
}

int OnInit() {
   return(INIT_SUCCEEDED);
}


void OnDeinit(const int reason) {

}

void OnTick() {
   if (isNewCandle()) {
      if (filtroHora() && operacionesAbiertas() == 0) {
         double rsi = iRSI(Symbol(), NULL, 14, PRICE_CLOSE, 1);
         double volume = calculateLotSize(sl());
         if (rsi < 40) {
            OrderSend(Symbol(),OP_BUY, volume, Ask, 0.1, NormalizeDouble(Bid - sl(), Digits), NormalizeDouble(Bid + tp(), Digits), NULL, Magic);
         }
         
         if (rsi > 60) {
            OrderSend(Symbol(),OP_SELL, volume, Bid, 0.1, NormalizeDouble(Bid + sl(), Digits), NormalizeDouble(Bid - tp(), Digits), NULL, Magic);
         }
      }
   }
   
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


int operacionesAbiertas() {
   int orders = 0;
   for (int i = 0; i < OrdersTotal(); i ++) {
      if (OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == Magic) {
         orders++;
      }
   }   
   return orders;
}