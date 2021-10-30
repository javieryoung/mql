//+------------------------------------------------------------------+
//|                                           3-Sccccrap 1m Gold.mq4 |
//|                                                     Javier Young |
//|                                                 https://young.uy |
//+------------------------------------------------------------------+
#property copyright "Javier Young"
#property link      "https://young.uy"
#property version   "1.00"
#property strict

int Magic=3;
double lastEma9 = 0.0;
double lastEma21 = 0.0;

double breakEvenFactor = 0.6;
double cuenta = 20000; // tamaño de la cuenta
double risk = 2; // % a arriesgar
double standardLot = 1000000;

int OnInit()
  {

   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
//---
   
  }

bool bought = false;
void OnTick()
  {
   double fastCur = iMA(Symbol(),0,9,0,MODE_EMA,PRICE_OPEN,0);
   double fastPre = iMA(Symbol(),0,9,0,MODE_EMA,PRICE_OPEN,1);
   double slowCur = iMA(Symbol(),0,21,0,MODE_EMA,PRICE_OPEN,0);
   double slowPre = iMA(Symbol(),0,21,0,MODE_EMA,PRICE_OPEN,1);
   
   
   
   double volume = NormalizeDouble((((risk * cuenta) / (sl() * Point))) / standardLot, Digits);
   bool  isUp = fastCur > slowCur;
   bool wasUp = fastPre > slowPre;
   bool cross = (isUp && !wasUp) || (!isUp && wasUp);
   if (isNewCandle()) {
      bought = false;
   }
   
   bool boughtUp = false;
   bool boughtDown = false;
   
   double rsi = iRSI(Symbol(),0,14,PRICE_OPEN,0);
   Print(rsi);
   if (!bought){
      if(cross && isUp && rsi > 50){
         if ((slowPre - fastPre) * 5 <= Close[1] - Open[1]) {
            OrderSend(NULL, OP_BUY, volume, Ask, 3, NormalizeDouble(Ask-sl(), Digits), NormalizeDouble(Ask+tp(), Digits), "Compra", Magic);
            bought = true;
         }
      }
      
      if (cross && !isUp && rsi < 50)
      {
         if ((fastPre - slowPre) * 5 <= Open[1] - Close[1]) {
            OrderSend(NULL, OP_SELL, volume, Bid, 3, NormalizeDouble(Bid+sl(), Digits), NormalizeDouble(Bid-tp(), Digits), "Venta", Magic);
            bought = true;
         }
      }
      
      /*
      if (rsi < 30 && !boughtUp){
         OrderSend(NULL, OP_BUY, volume, Ask, 3, NormalizeDouble(Ask-sl(), Digits), NormalizeDouble(Ask+tp(), Digits), "Compra", Magic);
         boughtUp = true;
         boughtDown = true;
      }
      if (rsi > 70) {
         OrderSend(NULL, OP_SELL, volume, Bid, 3, NormalizeDouble(Bid+sl(), Digits), NormalizeDouble(Bid-tp(), Digits), "Venta", Magic);
         boughtUp = false;
         boughtDown = true;
      }
      */
   }
      
   
   checkBreakEven();
   
  }
//+------------------------------------------------------------------+


datetime newCandleTime = TimeCurrent();
bool isNewCandle()
{
   if (newCandleTime == iTime(Symbol(), 0, 0)) return false;
   else
   {
      newCandleTime = iTime(Symbol(), 0, 0);
      return true;
   }
}


double sl() {
   return 200 * Point;
}

double tp() {
   return 200 * Point;
}

void checkBreakEven() {
   double minimumDistance = MarketInfo( Symbol(), MODE_STOPLEVEL );
   for(int i = 0; i < OrdersTotal(); i++){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
         
            if (OrderType() == OP_BUY && OrderStopLoss() < OrderOpenPrice()) {
               double profit = Ask - OrderOpenPrice();
               if (profit > tp() * breakEvenFactor) {
                  double stoploss = NormalizeDouble(OrderOpenPrice() + minimumDistance,Digits);
                  //OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),0,Blue);
                  Print("Break Even Compra");
               }
            }
            
            if (OrderType() == OP_SELL && OrderStopLoss() > OrderOpenPrice()) {
               double profit = OrderOpenPrice() - Bid;
               if (profit > tp() * breakEvenFactor) {
                  double stoploss = NormalizeDouble(OrderOpenPrice() - minimumDistance,Digits);
                  //OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),0,Blue);
                  Print("Break Even Venta");
               }
            }
            
            
            
         }
      }
   }
}