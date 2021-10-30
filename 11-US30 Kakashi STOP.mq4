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

input bool breakEvenON = true;
input double breakEvenFactor = 0.1; // % break even
input int operacionesPorDia = 2; // // operaciones por día
input bool slFijo = false; // fijar el stoploss 
input double sl = 10.0; // stoploss
input double tp = 50.0; // takeprofit
input double risk = 0.5; // % a arriesgar

double usedRisk = risk;

int timezoneOffset = 8;
double cuenta = 20000; // tamaño de la cuenta
double standardLot = 10000;


int Magic = 11;
double max = 0.0;
double min = 30000000.0;
int diaActual = 0;
int operacionesHechasHoy = 0;

int ticketBuy;
int ticketSell;

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
   calcularMinimoYMaximo();
   checkCambioDeEstado();
   if (filtro()) {
      abrirPending();
   } else { 
      cerrarPendientes();
   }
   
   if(breakEvenON) checkBreakEven();
   
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


int estadoOrdenCompra;
int estadoOrdenVenta;
void checkCambioDeEstado() {
   OrderSelect(ticketBuy, SELECT_BY_TICKET);
   if (estadoOrdenCompra == OP_BUYSTOP && OrderType() == OP_BUY) {
      operacionesHechasHoy++;
   }
   
   OrderSelect(ticketSell, SELECT_BY_TICKET);
   if (estadoOrdenVenta == OP_SELLSTOP && OrderType() == OP_SELL) {
      operacionesHechasHoy++;
   }
      
   OrderSelect(ticketBuy, SELECT_BY_TICKET);
   estadoOrdenCompra = OrderType();
   OrderSelect(ticketSell, SELECT_BY_TICKET);
   estadoOrdenVenta = OrderType();
}


// se fija si hay pending orders abiertas de buy y sell, y abre las que correspondan
void abrirPending() {
   if (Ask < max && Bid > min) {
      bool buy = true;
      bool sell = true;
      for(int i = 0; i < OrdersTotal(); i++){
         if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
               
               if (OrderType() == OP_BUY || OrderType() == OP_BUYSTOP) {
                  buy = false;
               }   
               
               if (OrderType() == OP_SELL || OrderType() == OP_SELLSTOP) {
                  sell = false;
               }
               
            }
         }
      }
      
      
      double volume = (((usedRisk * cuenta) / (sl() * Point))) / standardLot;
      if (buy) {
         string comment = StringConcatenate("Compra ", IntegerToString(Magic));
         ticketBuy = OrderSend(NULL, OP_BUYSTOP, volume, max, 0.1, max-sl(), max+tp(), comment, Magic);
         Print(StringConcatenate("Pending ", operacionesHechasHoy));
      }
      if (sell) {
         string comment = StringConcatenate("Venta ", IntegerToString(Magic));
         ticketSell = OrderSend(NULL, OP_SELLSTOP, volume, min, 0.1, min+sl(), min-tp(), comment, Magic);
         Print(StringConcatenate("Pending ", operacionesHechasHoy));
      }
   }
}

void cerrarPendientes() {
   for(int i = 0; i < OrdersTotal(); i++){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
            
            if (OrderType() == OP_BUYSTOP) {
               OrderDelete(OrderTicket());
            }   
            
            if (OrderType() == OP_SELLSTOP) {
               OrderDelete(OrderTicket());
            }   
            
         }
      }
   }
}

void calcularMinimoYMaximo() { // 0: nada, 1: comprar, 2: vender
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


void checkBreakEven() {
   double minimumDistance = MarketInfo( Symbol(), MODE_STOPLEVEL );
   for(int i = 0; i < OrdersTotal(); i++){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
         
            if (OrderType() == OP_BUY && OrderStopLoss() < OrderOpenPrice()) {
               double profit = Ask - OrderOpenPrice();
               if (profit > tp() * breakEvenFactor) {
                  double stoploss = NormalizeDouble(OrderOpenPrice() + minimumDistance,Digits);
                  OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),0,Blue);
                  Print("Break Even Compra");
               }
            }
            
            if (OrderType() == OP_SELL && OrderStopLoss() > OrderOpenPrice()) {
               double profit = OrderOpenPrice() - Bid;
               if (profit > tp() * breakEvenFactor) {
                  double stoploss = NormalizeDouble(OrderOpenPrice() - minimumDistance,Digits);
                  OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),0,Blue);
                  Print("Break Even Venta");
               }
            }
         }
      }
   }
}