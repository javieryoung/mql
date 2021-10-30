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

input double breakEvenFactor = 0.55; // % break even
input int secondsBetweenTrades = 800; // minimo de segundos a esperar entre que se cierra una orden y se abre la siguiente DEL MISMO TIPO
input double minimoConsideradoOscilacion = 30; // minimo movimiento considerado oscilacion (ruidosa)
input int operacionesPorDia = 2; // // operaciones por día
input bool slFijo = false; // fijar el stoploss 
input double sl = 50.0; // stoploss
input double tp = 50.0; // takeprofit
input double risk = 2; // % a arriesgar
input bool riesgoDecremental = false; // baja la inversion 0.5% en cada trade (se resetea por dia)

double usedRisk = risk;

int timezoneOffset = 8;
double cuenta = 20000; // tamaño de la cuenta
double standardLot = 10000;


int Magic = 2;
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
         double volume = (((usedRisk * cuenta) / (sl * Point))) / standardLot;
         if (operar == 1) {
            OrderSend(NULL, OP_BUY, volume, Ask, 3, Ask-sl, Ask+tp, "Compra", Magic);
            operacionesHechasHoy++;
            if (riesgoDecremental) usedRisk -= 0.5;
         }
         if (operar == 2) {
            OrderSend(NULL, OP_SELL, volume, Bid, 3, Bid+sl, Bid-tp, "Venta", Magic);
            operacionesHechasHoy++;
            if (riesgoDecremental) usedRisk -= 0.5;   
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
      usedRisk = risk;
   }
  }
//+------------------------------------------------------------------+


double sl() {
   if (slFijo) 
      return sl;
   else
      if (sl > max - min) 
         return max - min;
      else
         return sl;
}


double tp() {
   if (slFijo) 
      return tp;
   else
      if (tp > max - min) 
         return sl;
      else
         return tp;
}


int operar() { // 0: nada, 1: comprar, 2: vender
   int startHour = 4 + timezoneOffset;
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
   
   
   // falta primera vela de 5 min
   
      datetime time = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day(), " ", IntegerToString(finishHour) ,":00:00"));
      int shift = iBarShift(NULL, PERIOD_M5, time);
      double high = iHigh(NULL, PERIOD_M5,shift);
      double low = iLow(NULL, PERIOD_M5,shift);
      
      if (high > max) {
         max = high;
      }
      if (low < min) {
         min = low;
      }
   
   
   
   datetime now   = TimeCurrent();
   if (Ask >= max && lastAsk < max) { // la linea está por fuera del maximo && el tick anterior fue menor que el maximo
      if (now - lastOpenTime(OP_BUY) > secondsBetweenTrades) { // pasaron X segundos entre el ultimo trade de compra y este trade
         /*
         if (Open[1] > Close[1] && Open[1] > max) { // si la vela anterior es a la baja y comenzo por fuera del max
            return 0;
         }
         */
         if (Open[0] > Ask && Open[0] > max // si la vela actual esta a la baja (hasta ahora) y se abrió por fuera del max (probably en bajada)
               && !(Ask - Low[0] > minimoConsideradoOscilacion)) {  // si el minimo de esta vela está más lejos que 15 dejo pasar, a ver si está en alza
            return 0;
         }
         return 1;
      }
   }
   
   if (Bid <= min && lastBid > min) {
      if (now - lastOpenTime(OP_SELL) > secondsBetweenTrades) {
         /*
         if (Open[1] < Close[1] && Open[1] < min) { // si la vela anterior es al alza y comenzo por fuera del min
             return 0;
         }
         */
         if (Open[0] < Bid && // si la vela actual esta al alza (hasta ahora) y se abrió por fuera del min (probably en alza)
             !(High[0] - Bid > minimoConsideradoOscilacion) ) { // lo mismo que en buy pero dado vuelta
            return 0;
         }
         return 2;
      }
   }
   
   return  0;
}


int lastOpenTime(int tipo) {
   datetime lastTime = 0;
   for(int j = 0; j < OrdersHistoryTotal(); j++){
      if (OrderSelect(j,SELECT_BY_POS,MODE_HISTORY)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == tipo){
            if (OrderOpenTime() > lastTime){
               lastTime   = OrderOpenTime();
            }
         }
      }
   }
   
   return lastTime;
}


bool filtro() {
   // Hora
   bool afterOpen = Hour() > 8 + timezoneOffset || (Hour() == 8 + timezoneOffset && Minute() >= 30);
   bool beforeClose = Hour() < 12 + timezoneOffset;
   
   
   
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


void checkBreakEven() {
   double minimumDistance = MarketInfo( Symbol(), MODE_STOPLEVEL );
   for(int i = 0; i < OrdersTotal(); i++){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
         
            if (OrderType() == OP_BUY && OrderStopLoss() < OrderOpenPrice()) {
               double profit = Ask - OrderOpenPrice();
               if (profit > sl * breakEvenFactor) {
                  double stoploss = NormalizeDouble(OrderOpenPrice() + minimumDistance,Digits);
                  OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),0,Blue);
                  Print("Break Even Compra");
               }
            }
            
            if (OrderType() == OP_SELL && OrderStopLoss() > OrderOpenPrice()) {
               double profit = OrderOpenPrice() - Bid;
               if (profit > sl * breakEvenFactor) {
                  double stoploss = NormalizeDouble(OrderOpenPrice() - minimumDistance,Digits);
                  OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),0,Blue);
                  Print("Break Even Venta");
               }
            }
            
            
            
         }
      }
   }
}