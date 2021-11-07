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
input double minimoParaOperar = 5;
input int horaComienzo = 16;
input int minutoComienzo = 30;
input int horaFin = 16;
input int minutoFin = 30;
input int comprasPorDia = 500;
input string   InpLicence  =  "enter licence code here"; // Clave
string key = "LaVelaDesquiciada";

double usedRisk = risk;
int timezoneOffset = 8;
double standardLot = 10000;

int Magic = 15;
double max = 0.0;
double min = 30000000.0;
int diaActual = 0;
int comprasHechasHoy = 0;

int ticketBuy;
int ticketSell;

int ultimoBalance;

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
   ultimoBalance = AccountBalance();
   diaActual = Day();
  }
  
  
void OnTick()
  {
//---
   if (isNewCandle()) { 
      if (filtro()) {
         abrirPending();
      } else { 
         cerrarPendientes();
      }
   }
   
   
      
   if (diaActual != Day()) {
      double gananciaDelDia = AccountBalance() - ultimoBalance;
      Alert(StringConcatenate("Ganancia del dia: ", NormalizeDouble(DoubleToString(gananciaDelDia), Digits)));
      ultimoBalance = AccountBalance();
      diaActual = Day();
      Print(StringConcatenate("Día: "), IntegerToString(diaActual));
      usedRisk = risk;
      comprasHechasHoy = 0;
   }
   
   if (breakEvenEnabled && !trailingStopEnabled) checkBreakEven();
   if (trailingStopEnabled) checkTrailingStop();
   
  }
//+------------------------------------------------------------------+

datetime NewCandleTime = TimeCurrent();
bool isNewCandle()
{
   // If the time of the candle when the function ran last
   // is the same as the time this candle started,
   // return false, because it is not a new candle.
   if (NewCandleTime == iTime(Symbol(), 0, 0)) return false;
   
   // Otherwise, it is a new candle and we need to return true.
   else
   {
      // If it is a new candle, then we store the new value.
      NewCandleTime = iTime(Symbol(), 0, 0);
      return true;
   }
}



double sl() {
    return sl;
}


double tp() {
    return tp;
}


bool operacionesAbiertas = false;

// se fija si hay pending orders abiertas de buy y sell, y abre las que correspondan
void abrirPending() {
      
      bool abrirCompra = true;
      bool abrirVenta = true;
      // Cierro las que esten abiertas
      if (OrderSelect(ticketBuy,SELECT_BY_TICKET,MODE_TRADES)){
            if (OrderType() == OP_BUYSTOP) {
               OrderDelete(OrderTicket());
            } else {
               if (OrderCloseTime() == 0)
                  abrirCompra = false;
            }
      }
      
      if (OrderSelect(ticketSell,SELECT_BY_TICKET,MODE_TRADES)){
            if (OrderType() == OP_SELLSTOP) {
               OrderDelete(OrderTicket());
            } else {
               if (OrderCloseTime() == 0)
                  abrirVenta = false;
            }   
      }
      
      // Calculo max y min para poner buy y sell stop
      calcularMinimoYMaximo();
      
      
      double volume = (((usedRisk * cuenta) / (sl() * Point))) / standardLot;
      
      if (abrirCompra) {
         string commentCompra = StringConcatenate("Compra ", IntegerToString(Magic));
         double tpCompra;
         if (trailingStopEnabled) 
            tpCompra = 0;
         else 
            tpCompra = max+tp();
         ticketBuy = OrderSend(Symbol(), OP_BUYSTOP, volume, max, 0.1, NormalizeDouble(max-sl(), Digits), NormalizeDouble(tpCompra,Digits), commentCompra, Magic);
         comprasHechasHoy++;
      }
      if (abrirVenta) {
         string commentVenta = StringConcatenate("Venta ", IntegerToString(Magic));
         double tpVenta;
         if (trailingStopEnabled) 
            tpVenta = 0;
         else 
            tpVenta = min-tp();
         ticketSell = OrderSend(Symbol(), OP_SELLSTOP, volume, min, 0.1, NormalizeDouble(min+sl(), Digits), NormalizeDouble(tpVenta,Digits), commentVenta, Magic);
         comprasHechasHoy++;
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
   
   
   max = Ask + minimoParaOperar;
   min = Bid+ minimoParaOperar;
   
}



bool filtro() {
   // Hora
   bool afterOpen = Hour() > horaComienzo || (Hour() == horaComienzo && Minute() >= minutoComienzo);
   bool beforeClose = Hour() < horaFin || (Hour() == horaFin && Minute() <= minutoFin);
   
   if (comprasHechasHoy >= comprasPorDia+1){
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