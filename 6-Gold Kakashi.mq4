//+------------------------------------------------------------------+
//|                                                         US30.mq4 |
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

double breakEvenFactor = 0.6;
int timezoneOffset = 8;
double cuenta = 20000; // tamaño de la cuenta
double risk = 1; // % a arriesgar
int secondsBetweenTrades = 300; // minimo de segundos a esperar entre que se cierra una orden y se abre la siguiente DEL MISMO TIPO
int operacionesPorDia = 2;


double standardLot = 100000;


int Magic = 6;
double lastAsk;
double lastBid;
double max = 0.0;
double min = 30000000.0;
int diaActual = 0;
int operacionesHechasHoy = 0;

int OnInit()
  {
//---
   Print("Se cargó el Expert a la gráfica...");
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Print("Se eliminó el Expert a la gráfica...");
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
   if (opreacionesAbiertas() == 0) {
      if (filtro()) {
         int operar = operar();
         double volume = (((risk * cuenta) / (sltp() * Point))) / standardLot;
         if (operar == 1) {
            OrderSend(NULL, OP_BUY, volume, Ask, 3, Ask-sltp(), Ask+sltp(), "Compra", Magic);
            operacionesHechasHoy++;
         }
         if (operar == 2) {
            OrderSend(NULL, OP_SELL, volume, Bid, 3, Bid+sltp(), Bid-sltp(), "Venta", Magic);
            operacionesHechasHoy++;
         }
      }
   } else {
      if (Hour() >= 12) {
         // cerrarTodo();
      }
   }
   checkBreakEven();
   
   lastAsk = Ask;
   lastBid = Bid;
   
   
   if (diaActual != Day()) {
      diaActual = Day();
      Print(StringConcatenate("Día: "), IntegerToString(diaActual));
      operacionesHechasHoy = 0;
   }
  }
//+------------------------------------------------------------------+


double sltp() {
   if (max-min < 100.0) {
      return max-min;
   }
   return 100.0;
}


int operar() { // 0: nada, 1: comprar, 2: vender
   int startHour = 6 + timezoneOffset;
   int finishHour = 7 + timezoneOffset;
   min = 30000000.0;
   max = 0.0;
   for (int i = startHour; i < finishHour; i++) {
      datetime time = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day(), " ", IntegerToString(i) ,":00:00"));
      int shift = iBarShift(NULL, PERIOD_H1, time);
      double high = iHigh(NULL, PERIOD_H1,shift);
      double low = iLow(NULL, PERIOD_H1,shift);
      
      if (high > max) {
         max = high;
      }
      if (low < min) {
         min = low;
      }
   }
   datetime now   = TimeCurrent();
   if (Ask >= max && lastAsk < max) { // la linea está por fuera del maximo && el tick anterior fue menor que el maximo
      if (now - lastClosed(OP_BUY) > secondsBetweenTrades) { // pasaron X segundos entre el ultimo trade de compra y este trade
         return 1;
      }
   }
   
   if (Bid <= min && lastBid > min) {
      if (now - lastClosed(OP_SELL) > secondsBetweenTrades) {
         return 2;
      }
   }
   
   return  0;
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


bool filtro() {
   // Hora
   bool afterOpen = Hour() > 7 + timezoneOffset; // || (Hour() == 8 + timezoneOffset && Minute() >= 30);
   bool beforeClose = Hour() < 9 + timezoneOffset;
   
   
   
   // Maximo de operaciones por día
   if (operacionesHechasHoy >= operacionesPorDia) {
      return false;   
   }
   
   return afterOpen && beforeClose ;
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

void cerrarTodo() {
   for(int i = 0; i < OrdersTotal(); i++){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
            if (OrderType() == OP_BUY){
               OrderClose(OrderTicket(), OrderLots(), Bid, 1);
            }
            if (OrderType() == OP_SELL){
               OrderClose(OrderTicket(), OrderLots(), Ask, 1);
            }
         }
      }
   }

}




void checkBreakEven() {
   double minimumDistance = MarketInfo( Symbol(), MODE_STOPLEVEL );
   for(int i = 0; i < OrdersTotal(); i++){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
         
            if (OrderType() == OP_BUY && OrderStopLoss() < OrderOpenPrice()) {
               double profit = Ask - OrderOpenPrice();
               if (profit > (OrderTakeProfit() - OrderOpenPrice()) * breakEvenFactor) {
                  double stoploss = NormalizeDouble(OrderOpenPrice() + minimumDistance,Digits);
                  OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),0,Blue);
                  Print("Break Even Compra");
               }
            }
            
            if (OrderType() == OP_SELL && OrderStopLoss() > OrderOpenPrice()) {
               double profit = OrderOpenPrice() - Bid;
               if (profit > (OrderOpenPrice() - OrderTakeProfit()) * breakEvenFactor) {
                  double stoploss = NormalizeDouble(OrderOpenPrice() - minimumDistance,Digits);
                  OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),0,Blue);
                  Print("Break Even Venta");
               }
            }
            
         }
      }
   }
}