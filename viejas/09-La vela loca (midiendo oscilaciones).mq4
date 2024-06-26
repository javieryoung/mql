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


input double cuenta = 20000; // tamaño de la cuenta
input double risk = 0.5; // % a arriesgar
input int operacionesPorDia = 1; // // operaciones por día
input double sl = 10.0; // stoploss
input double tp = 41.0; // takeprofit
input bool breakEvenEnabled = true; // activar break even
input double breakEvenFactor = 0.7; // % break even
input bool trailingStopEnabled = true; // trailing stop
input double trailingStopFactor = 10; // valor de trailing
input double desplazamientoMinimoParaOperar = 31.0; // minimo desplazamiento para activar operacion
input bool riesgoDecremental = false; // riesgo decremental

double usedRisk = risk;
int timezoneOffset = 8;
double standardLot = 10000;


int Magic = 9;
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
   if (filtro()) {
      int operar = operar();
      double volume = (((usedRisk * cuenta) / (sl * Point))) / standardLot;
      if (operar == 1) {
         string comment = StringConcatenate("Compra ", IntegerToString(Magic));
         OrderSend(NULL, OP_BUY, volume, Ask, 0.1, Ask-sl, Ask+tp, comment, Magic);
         operacionesHechasHoy++;
         if (riesgoDecremental) usedRisk -= 0.5;
      }
      if (operar == 2) {
         string comment = StringConcatenate("Venta ", IntegerToString(Magic));
         OrderSend(NULL, OP_SELL, volume, Bid, 0.1, Bid+sl, Bid-tp, comment, Magic);
         operacionesHechasHoy++;
         if (riesgoDecremental) usedRisk -= 0.5;   
      }
   }
   
   if (breakEvenEnabled && !trailingStopEnabled) checkBreakEven();
   if (trailingStopEnabled) checkTrailingStop();
   
   if (diaActual != Day()) {
      diaActual = Day();
      Print(StringConcatenate("Día: "), IntegerToString(diaActual));
      operacionesHechasHoy = 0;
      usedRisk = risk;
   }
  }
//+------------------------------------------------------------------+


double sl() {
      return sl;
}


double tp() {
      return tp;
}


int operar() { // 0: nada, 1: comprar, 2: vender
   
   
   
   
   if (Ask - Open[0] >=  desplazamientoMinimoParaOperar) { 
      return 1;
   }
   
   if (Open[0] - Bid >=  desplazamientoMinimoParaOperar) { 
      return 2;
   }
   
   return  0;
}




bool filtro() {
   // Hora
   bool afterOpen = Hour() > 8 + timezoneOffset || (Hour() == 8 + timezoneOffset && Minute() >= 30);
   bool beforeClose = Hour() < 9 + timezoneOffset;
   
   
   
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

void checkTrailingStop() {
   for(int i = 0; i < OrdersTotal(); i++){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
         
            double stoplossCompra = NormalizeDouble(Ask - trailingStopFactor, Digits);
            if (OrderType() == OP_BUY && stoplossCompra > OrderStopLoss()) {
               OrderModify(OrderTicket(),OrderOpenPrice(),stoplossCompra,0,0,Blue);
            }
            
            double stoplossVenta = NormalizeDouble(trailingStopFactor + Bid, Digits);
            if (OrderType() == OP_SELL && stoplossVenta < OrderStopLoss()) {
               OrderModify(OrderTicket(),OrderOpenPrice(),stoplossVenta,0,0,Blue);
            }
         }
      }
   }
}