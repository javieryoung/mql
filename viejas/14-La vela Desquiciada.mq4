//+------------------------------------------------------------------+
//|                                              La vela Desquiciada |
//|                                                     Javier Young |
//|                                                 https://young.uy |
//+------------------------------------------------------------------+
#property copyright "Javier Young"
#property link      "https://young.uy"
#property version   "1.10"
#property strict

int Magic = 14;

input double cuenta = 20000; // tamaño de la cuenta
input double risk = 0.5; // % a arriesgar
input double sl = 5; // stoploss
input double tp = 11; // takeprofit
input bool breakEvenEnabled = true; // activar break even
input double breakEvenFactor = 0.2; // % break even
input bool trailingStopEnabled = true; // trailing stop
input double trailingStopFactor = 10; // valor de trailing
input int horaComienzo = 16;
input int minutoComienzo = 30;
input int horaFin = 17;
input int minutoFin = 30;
input double dividirEntre = 1; // dividir sl, tp y ts entre...
input int tamanioLote = 1; //0: standard, 1: mini, 2: micro
int operacionesPorDia = 2;

// Licencia
input string   licencia  =  ""; // Clave
string key = "desquiciadaComunv1.10yo";

double usedRisk = risk;
double standardLot = 10000;

double max = 0.0;
double min = 30000000.0;
int diaActual = 0;
int operacionesHechasHoy = 0;
int ticketBuy;
int ticketSell;
int ultimoBalance;

#include <../Experts/LicenceCheck.mqh>
#include <../Experts/FuncionesComunes.mqh>

int OnInit(){
   
   Print("MODE_LOTSIZE = ", MarketInfo(Symbol(), MODE_LOTSIZE));
   Print("MODE_TICKVALUE = ", MarketInfo(Symbol(), MODE_TICKVALUE));
   Print("DIGITS = ", Digits);


   // if (!LicenceCheck(licencia,key)) return(INIT_FAILED);
   
   Print("Se cargó el Expert a la gráfica...");
   
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason) {
   
   Print("Se eliminó el Expert a la gráfica...");
   ultimoBalance = AccountBalance();
   diaActual = Day();
}
  
  
void OnTick() {

   if (isNewCandle()) { 
      if (filtro()) {
         if (operacionesHechasHoy < operacionesPorDia)
            abrirPending();
      } else { 
         cerrarPendientes();
      }
   }
   
   
      
   if (diaActual != Day()) {
      double gananciaDelDia = AccountBalance() - ultimoBalance;
      ultimoBalance = AccountBalance();
      diaActual = Day();
      Print(StringConcatenate("Día: "), IntegerToString(diaActual));
      usedRisk = risk;
      operacionesHechasHoy = 0;
   }
   
   if (breakEvenEnabled && !trailingStopEnabled) checkBreakEven();
   if (trailingStopEnabled) checkTrailingStop();
   
}



double sl() {
    return sl / dividirEntre;
}


double tp() {
    return tp / dividirEntre;
}



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
      
      
      double volume = calculateLotSize(sl());      
      double minimumDistance = MarketInfo( Symbol(), MODE_STOPLEVEL ) * Point;
      if (abrirCompra) {
         string commentCompra = StringConcatenate("Compra ", IntegerToString(Magic));
         double tpCompra;
         if (trailingStopEnabled) 
            tpCompra = 0;
         else 
            tpCompra = max+tp();
         operacionesHechasHoy++;
         if (max < Ask + minimumDistance){ // Solo sucede si la el maximo de la vela anterior esta muy cerca de el cierre de la misma
            max = NormalizeDouble(MathAbs(max-min)/2 + max, Digits);
         }   
         max++;
         ticketBuy = OrderSend(Symbol(), OP_BUYSTOP, volume, max, 0.1, NormalizeDouble(max-sl(), Digits), NormalizeDouble(tpCompra,Digits), commentCompra, Magic);
         
      }
      if (abrirVenta) {
         string commentVenta = StringConcatenate("Venta ", IntegerToString(Magic));
         double tpVenta;
         if (trailingStopEnabled) 
            tpVenta = 0;
         else 
            tpVenta = min-tp();
         operacionesHechasHoy++;
         if (Bid - minimumDistance  < min) {
            min = NormalizeDouble(min - MathAbs(max-min)/2, Digits);
         }
         min--;
         ticketSell = OrderSend(Symbol(), OP_SELLSTOP, volume, min, 0.1, NormalizeDouble(min+sl(), Digits), NormalizeDouble(tpVenta,Digits), commentVenta, Magic);
      }        
}


void cerrarPendientes() {
   for(int i = OrdersTotal(); i >= 0; i--){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
            
            if (OrderType() == OP_BUYSTOP) {
               OrderDelete(OrderTicket());
               operacionesHechasHoy--;
            }   
            
            if (OrderType() == OP_SELLSTOP) {
               OrderDelete(OrderTicket());
               operacionesHechasHoy--;
            }   
            
         }
      }
   }
}

void calcularMinimoYMaximo() { 
   
   int hour = Hour();
   int minutes = Minute()-1;
   if (minutes == -1){
      minutes = 60;
      hour = hour -1;
   }
   
   datetime time = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day(), " ", IntegerToString(hour) ,":", IntegerToString(minutes),":00"));
   int shift = iBarShift(NULL, PERIOD_M1, time);
   max = iHigh(NULL, PERIOD_M1,shift);
   min = iLow(NULL, PERIOD_M1,shift);
   
}



bool filtro() {
   // Hora
   bool afterOpen = Hour() > horaComienzo || (Hour() == horaComienzo && Minute() >= minutoComienzo);
   bool beforeClose = Hour() < horaFin || (Hour() == horaFin && Minute() <= minutoFin);
   
   return afterOpen && beforeClose ;
}

