//+------------------------------------------------------------------+
//|                                                         US30.mq4 |
//|                                                     Javier Young |
//|                                                 https://young.uy |
//+------------------------------------------------------------------+
#property copyright "Javier Young"
#property link      "https://young.uy"
#property version   "1.00"
#property strict




input double cuenta = 20000; // tamaño de la cuenta
input double risk = 0.5; // % a arriesgar
input double sl = 5; // stoploss
input double tp = 11; // takeprofit
input bool breakEvenEnabled = true; // activar break even
input double breakEvenFactor = 0.2; // % break even
input bool trailingStopEnabled = true; // trailing stop
input double trailingStopFactor = 10; // valor de trailing
input bool operarEnDoSentidos = true; // opera siempre a la venta y a la compra



input string   InpLicence  =  "enter licence code here"; // Clave
string key = "LaVelaDesquiciada";

double usedRisk = risk;
int timezoneOffset = 8;
double standardLot = 10000;

int Magic = 12;
double max = 0.0;
double min = 30000000.0;
int diaActual = 0;

int ticketBuy;
int ticketSell;

#include <../Experts/LicenceCheck.mqh>

int OnInit()
  {
   
   // if (!LicenceCheck(InpLicence,key)) return(INIT_FAILED);
   
   Print("Se cargó el Expert a la gráfica...");
   
   return(INIT_SUCCEEDED);
  }
  
void OnDeinit(const int reason)
  {
   Print("Se eliminó el Expert a la gráfica...");
   
  }
  
  
void OnTick()
  {
//---
   calcularMinimoYMaximo();
   if (filtro()) {
      abrirPending();
   } else { 
      cerrarPendientes();
   }
   
   if (diaActual != Day()) {
      diaActual = Day();
      Print(StringConcatenate("Día: "), IntegerToString(diaActual));
      operacionesAbiertas = false;
      usedRisk = risk;
   }
   
   
   
   if (breakEvenEnabled && !trailingStopEnabled) checkBreakEven();
   if (trailingStopEnabled) checkTrailingStop();
   
  }
//+------------------------------------------------------------------+


double sl() {
    return sl;
}


double tp() {
    return tp;
}


bool operacionesAbiertas = false;

// se fija si hay pending orders abiertas de buy y sell, y abre las que correspondan
void abrirPending() {
   if (!operacionesAbiertas) {
      operacionesAbiertas = true;
      double volume = (((usedRisk * cuenta) / (sl() * Point))) / standardLot;
      
      string commentCompra = StringConcatenate("Compra ", IntegerToString(Magic));
      double tpCompra;
      if (trailingStopEnabled) 
         tpCompra = 0;
      else 
         tpCompra = max+tp();
      ticketBuy = OrderSend(Symbol(), OP_BUYSTOP, volume, max, 0.1, NormalizeDouble(max-sl(), Digits), NormalizeDouble(tpCompra,Digits), commentCompra, Magic);
      
      string commentVenta = StringConcatenate("Venta ", IntegerToString(Magic));
      double tpVenta;
      if (trailingStopEnabled) 
         tpVenta = 0;
      else 
         tpVenta = min-tp();
      ticketSell = OrderSend(Symbol(), OP_SELLSTOP, volume, min, 0.1, NormalizeDouble(min+sl(), Digits), NormalizeDouble(tpVenta,Digits), commentVenta, Magic);
      
      
      Print(ticketSell);
      Print(ticketBuy);
         
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

void calcularMinimoYMaximo() { 
   int startHour = 4 + timezoneOffset;
   int finishHour = 8 + timezoneOffset;
   
   datetime time = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day(), " ", IntegerToString(finishHour) ,":29:00"));
   int shift = iBarShift(NULL, PERIOD_M1, time);
   max = iHigh(NULL, PERIOD_M1,shift);
   min = iLow(NULL, PERIOD_M1,shift);
   
}



bool filtro() {
   // Hora
   bool afterOpen = Hour() > 8 + timezoneOffset || (Hour() == 8 + timezoneOffset && Minute() >= 30);
   bool beforeClose = Hour() < 10 + timezoneOffset;
   
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