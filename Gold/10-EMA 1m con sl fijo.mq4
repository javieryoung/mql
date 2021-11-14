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
input double breakEvenFactor = 0.6;
input int slowEmaPeriod = 150;
input int mediumEmaPeriod = 100;
input int fastEmaPeriod = 50;
input double minimumDistanceBetweenEmasToTrade = 100;
input double aire = 6;


double cuenta = 20000; // tamaño de la cuenta
double risk = 0.5; // % a arriesgar
double standardLot = MarketInfo( Symbol(), MODE_LOTSIZE );


string trend = "";  
bool rompioEmaRapido = false;
bool rompioEmaMedio = false;
bool rompioEmaLento = false;


int OnInit()
  {
   return(INIT_SUCCEEDED);
   Print(Point);
  }
  
  
void OnDeinit(const int reason)
  {
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
         
         if (Ask > fast && Close[1] > fast && rompioEmaRapido && !rompioEmaLento && MathAbs(fast - slow) > minimumDistanceBetweenEmasToTrade * Point) {
            double sl = MathAbs(Ask - slow) + aire*Point;
            double tp = sl;
            double volume = NormalizeDouble((((risk * cuenta) / sl)) / standardLot, Digits);
            
            OrderSend(NULL, OP_BUY, volume, Ask, 3, NormalizeDouble((Ask - sl), Digits) , NormalizeDouble((Ask + tp), Digits), "Compra", Magic);
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
         
         if (Bid < fast && Close[1] < fast && rompioEmaRapido && !rompioEmaLento && MathAbs(fast - slow) > minimumDistanceBetweenEmasToTrade * Point) {
            double sl = MathAbs(Bid - slow) + aire*Point;
               
            double tp = sl;
            double volume = NormalizeDouble((((risk * cuenta) / sl)) / standardLot, Digits);
            
            OrderSend(NULL, OP_SELL, volume, Bid, 3, NormalizeDouble((Bid + sl), Digits) , NormalizeDouble((Bid - tp), Digits), "Venta", Magic);
            rompioEmaRapido = false;
            rompioEmaMedio = false;
            rompioEmaLento = false;
         }
      }
      
   }
   checkBreakEven();
  }



void reloadTrend() {
   string trendAnterior = trend; // solo para el log
   double fast = iMA(Symbol(),0,fastEmaPeriod,0,MODE_EMA,PRICE_OPEN,0);
   double fastPrev = iMA(Symbol(),0,fastEmaPeriod,0,MODE_EMA,PRICE_OPEN,1);
   double medium = iMA(Symbol(),0,mediumEmaPeriod,0,MODE_EMA,PRICE_OPEN,0);
   double mediumPrev = iMA(Symbol(),0,mediumEmaPeriod,0,MODE_EMA,PRICE_OPEN,1);
   if (fast > medium && fastPrev < mediumPrev) {
      if (trend != "alza") Print("alza");
      trend = "alza";
   }
   
   if (fast < medium && fastPrev > mediumPrev) {
      if (trend != "baja") Print("baja");
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





void checkBreakEven() {
   double minimumDistance = MarketInfo( Symbol(), MODE_STOPLEVEL ) * Point;
   for(int i = 0; i < OrdersTotal(); i++){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
         
            if (OrderType() == OP_BUY && OrderStopLoss() < OrderOpenPrice()) {
               double profit = Bid - OrderOpenPrice();
               if (profit > (OrderTakeProfit() - OrderOpenPrice()) * breakEvenFactor) {
                  double stoploss = NormalizeDouble(OrderOpenPrice() + minimumDistance, Digits);
                  OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),0,Blue);
                  Print("Break Even Compra");
               }
            }
            
            if (OrderType() == OP_SELL && OrderStopLoss() > OrderOpenPrice()) {
               double profit = OrderOpenPrice() - Ask;
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































































