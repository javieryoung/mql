//+------------------------------------------------------------------+
//|                                               4-MACD 1m gold.mq4 |
//|                                                     Javier Young |
//|                                                 https://young.uy |
//+------------------------------------------------------------------+
#property copyright "Javier Young"
#property link      "https://young.uy"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int Magic=7;

input double breakEvenFactor = 0.6;

double cuenta = 20000; // tamaño de la cuenta
double risk = 0.5; // % a arriesgar
double standardLot = 1000000;
int secondsBetweenTrades = 1200; // minimo de segundos a esperar entre que se cierra una orden y se abre la siguiente DEL MISMO TIPO


int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double ema = iMA(Symbol(),0,100,0,MODE_EMA,PRICE_OPEN,0);
   double macd = iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,MODE_EMA,0);
   
   
   datetime now   = TimeCurrent();
   if (opreacionesAbiertas() == 0) {
      if (now - lastClosed(OP_BUY) > secondsBetweenTrades) {
         double sl = (Ask  - ema) * 1.5;
         double tp = sl * 1;
         if (operar() == 1) {
            double volume = NormalizeDouble((((risk * cuenta) / (sl * Point))) / standardLot, Digits);
            
            OrderSend(NULL, OP_BUY, volume, Ask, 3, NormalizeDouble((Ask - sl), Digits) , NormalizeDouble((Ask + tp), Digits), "Compra", Magic);
         }
      }
      
      if (now - lastClosed(OP_SELL) > secondsBetweenTrades) {
         double sl = (ema - Bid) * 1.5;
         double tp = sl * 1;
         if (operar() == 2) {
            double volume = NormalizeDouble((((risk * cuenta) / (sl * Point))) / standardLot, Digits);
            
            OrderSend(NULL, OP_SELL, volume, Bid, 3, NormalizeDouble((Bid + sl), Digits) , NormalizeDouble((Bid - tp), Digits), "Venta", Magic);
         }
      }
   }
   checkCerrarTodo();
  }
//+------------------------------------------------------------------+



int lastClosed(int tipo) {
   datetime lastTime = 0;
   for(int j = 0; j < OrdersHistoryTotal(); j++){
      if (OrderSelect(j,SELECT_BY_POS,MODE_HISTORY)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == tipo){
            if (OrderCloseTime() > lastTime){
               lastTime   = OrderCloseTime();
            }
         }
      }
   }
   
   return lastTime;
}


int operar() {
   
   double macd0 = (iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0));
   double macd1 = (iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1));
   
   if (macd1 < 0 && macd0 > 0) {
      return 1;
   }
   if (macd1 > 0 && macd0 < 0) {
      return 2;
   }
   return 0;
}


datetime newCandleTime = TimeCurrent();
bool isNewCandle() {
   if (newCandleTime == iTime(Symbol(), 0, 0)) return false;
   else
   {
      newCandleTime = iTime(Symbol(), 0, 0);
      return true;
   }
}


void checkCerrarTodo() {
   for(int i = 0; i < OrdersTotal(); i++){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
                     
            double macd0 = (iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0));
            double macd1 = (iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1));
            
            if (OrderType() == OP_BUY && macd0 < macd1 && Bid > OrderOpenPrice() + 50 * Point) {
               OrderClose(OrderTicket(), OrderLots(), Bid, 1);
            }
            if (OrderType() == OP_SELL && macd0 > macd1 && Ask < OrderOpenPrice() - 50 * Point) {
               OrderClose(OrderTicket(), OrderLots(), Ask, 1);
            }
          }
      }
   }
   
}



int opreacionesAbiertas() {
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
