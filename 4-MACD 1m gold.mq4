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

int Magic=4;

input double breakEvenFactor = 0.9;
input double minimumAngle = 2;
input int minimumStoplossPoints = 50;
input int fastTrendPeriod = 50;
input int slowTrendPeriod = 100;

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
   double fastTrend = iMA(Symbol(),0,fastTrendPeriod,0,MODE_EMA,PRICE_OPEN,0);
   double slowTrend = iMA(Symbol(),0,slowTrendPeriod,0,MODE_EMA,PRICE_OPEN,0);
   
   double macd = iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,MODE_EMA,0);
   
   
   double angle = calcularAnguloEma();
   
   datetime now   = TimeCurrent();
   if (opreacionesAbiertas() == 0) {
      if (now - lastClosed(OP_BUY) > secondsBetweenTrades) {
         double sl = (Ask  - fastTrend) * 1;
         double tp = sl * 1;
         if (Ask > slowTrend && macd > 0 && angle > minimumAngle && sl > minimumStoplossPoints * Point) {
            double volume = NormalizeDouble((((risk * cuenta) / (sl * Point))) / standardLot, Digits);
            
            OrderSend(NULL, OP_BUY, volume, Ask, 3, NormalizeDouble((Ask - sl), Digits) , NormalizeDouble((Ask + tp), Digits), "Compra", Magic);
         }
      }
      
      if (now - lastClosed(OP_SELL) > secondsBetweenTrades) {
         double sl = (fastTrend - Bid) * 1;
         double tp = sl * 1;
         if (Bid < slowTrend && macd < 0 && angle < minimumAngle  && sl > minimumStoplossPoints * Point) {
            double volume = NormalizeDouble((((risk * cuenta) / (sl * Point))) / standardLot, Digits);
            
            OrderSend(NULL, OP_SELL, volume, Bid, 3, NormalizeDouble((Bid + sl), Digits) , NormalizeDouble((Bid - tp), Digits), "Venta", Magic);
         }
      }
   }
   
   if (isNewCandle()) {
      Print(angle);
   }
   
   
   checkBreakEven();
  }
//+------------------------------------------------------------------+



datetime newCandleTime = TimeCurrent();
bool isNewCandle() {
   if (newCandleTime == iTime(Symbol(), 0, 0)) return false;
   else
   {
      newCandleTime = iTime(Symbol(), 0, 0);
      return true;
   }
}



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


int hayImpulso() { // 1: alza, 2: baja, 0 no hay
   double macd0 = (iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,MODE_EMA,0));
   double macd1 = (iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,MODE_EMA,1));
   double macd2 = (iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,MODE_EMA,2));
   
   if (macd0 >= macd1 && macd1 >= macd2) {
      return 1;
   }
   if (macd0 <= macd1 && macd1 <= macd2) {
      return 2;
   }
   return 0;
}

double calcularAnguloEma() {
   int overLast = 3;
   double angle = 0;
   for (int i = overLast; i > 0; i--) {
      double last = iMA(Symbol(),0,3,0,MODE_EMA,PRICE_OPEN,i-1);;
      double current = iMA(Symbol(),0,3,0,MODE_EMA,PRICE_OPEN,i);;
      
      double tangente = ((last-current) / 1);
      angle = angle + MathArctan(tangente);
   }
   return (angle / overLast) * 57.2958; // return angle average (converted to degrees);
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



void checkBreakEven() {
   double minimumDistance = MarketInfo( Symbol(), MODE_STOPLEVEL ) * Point;
   for(int i = 0; i < OrdersTotal(); i++){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
         
            if (OrderType() == OP_BUY && OrderStopLoss() < OrderOpenPrice()) {
               double profit = Ask - OrderOpenPrice();
               if (profit > (OrderTakeProfit() - OrderOpenPrice()) * breakEvenFactor) {
                  double stoploss = NormalizeDouble(OrderOpenPrice() + minimumDistance, Digits);
                  OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),0,Blue);
                  Print("Break Even Compra");
               }
            }
            
            if (OrderType() == OP_SELL && OrderStopLoss() > OrderOpenPrice()) {
               double profit = OrderOpenPrice() - Bid;
               if (profit > (OrderOpenPrice() - OrderTakeProfit()) * breakEvenFactor) {
                  double stoploss = NormalizeDouble(OrderOpenPrice() - minimumDistance , Digits);
                  OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),0,Blue);
                  Print("Break Even Venta");
               }
            }
            
         }
      }
   }
}