//+------------------------------------------------------------------+
//|                                              La vela Desquiciada |
//|                                                     Javier Young |
//|                                                 https://young.uy |
//+------------------------------------------------------------------+
#property copyright "Javier Young"
#property link      "https://young.uy"
#property version   "1.10"
#property strict

int Magic = 25;

input double cuenta = 20000; // tamaño de la cuenta
input double risk = 0.5; // % a arriesgar
input double sl = 30; // stoploss
input double tp = 90; // takeprofit
input double precioCompra = 0;
input double precioVenta = 0;
input double aire = 40;
input bool breakEvenEnabled = true; // activar break even
input double breakEvenFactor = 0.6; // % break even
input bool trailingStopEnabled = false; // trailing stop
input double trailingStopFactor = 10; // valor de trailing
input int horaComienzoBuscar = 21;
input int minutoComienzoBuscar = 00;
input int horaFinBuscar = 8;
input int minutoFinBuscar = 30;
input int horaComienzoOperar = 8;
input int minutoComienzoOperar = 30;
input int horaFinOperar = 16;
input int minutoFinOperar = 30;
input double dividirEntre = 1; // dividir dolares entre

// Licencia
input string   licencia  =  ""; // Clave
string key = "adr1.0yo";


double max,min;
int diaActual = 0;
int operacionesHechasHoy = 0;
int ticketBuy;
int ticketSell;
int ultimoBalance;



#include <../Experts/LicenceCheck.mqh>
#include <../Experts/FuncionesComunes.mqh>

int cuentas[] = {44127800,44127805,220080060,4310842,4310839,4336520,
   4312124, 3364688};

int OnInit(){

   long  account  =  AccountInfoInteger(ACCOUNT_LOGIN);
   if (!in_array(account)){
      Print("CUENTA INVALIDA");
      // return(INIT_FAILED);
   }      
   
   Print("MODE_LOTSIZE = ", MarketInfo(Symbol(), MODE_LOTSIZE));
   Print("MODE_TICKVALUE = ", MarketInfo(Symbol(), MODE_TICKVALUE));
   Print("DIGITS = ", Digits);

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
      
      datetime candleTime = iTime(Symbol(), 0, 0);
      datetime time = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day(), " ", IntegerToString(horaComienzoOperar), ":", IntegerToString(minutoComienzoOperar), ":00"));
      if (candleTime == time) {
         abrirPending();
      }
        
        
      datetime timeClose = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day(), " ", IntegerToString(horaFinOperar), ":", IntegerToString(minutoFinOperar), ":00"));
      if (candleTime == timeClose) { 
         cerrarPendientes();
      }
      
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
      
      // Calculo max y min para poner buy y sell stop
      calcularMinimoYMaximo();
      
      
      double volume = calculateLotSize(sl());      
      
      double tpCompra;
      if (trailingStopEnabled) 
         tpCompra = 0;
      else 
         tpCompra = max+tp();
      
      double ts = NormalizeDouble(trailingStopFactor / dividirEntre, Digits);
      double spread = Ask - Bid;
      
      string comment = StringConcatenate("SL=", sl(), ";TS=", ts); 
      
      ticketBuy = OrderSend(Symbol(), OP_BUYSTOP, volume, max, 0.1, NormalizeDouble(max-sl(), Digits), NormalizeDouble(tpCompra,Digits), comment, Magic);
      
      
      
      double tpVenta;
      if (trailingStopEnabled) 
         tpVenta = 0;
      else 
         tpVenta = min-tp();
      ticketSell = OrderSend(Symbol(), OP_SELLSTOP, volume, min, 0.1, NormalizeDouble(min+sl(), Digits), NormalizeDouble(tpVenta,Digits), comment, Magic);
}


void cerrarPendientes() {
   for(int i = OrdersTotal(); i >= 0; i--){
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
   
   int dayComienzo = Day();
   if (horaFinBuscar < horaComienzoBuscar) 
      dayComienzo = dayComienzo-1;
   datetime in  = StrToTime(StringConcatenate(Year(), ".", Month(), ".", dayComienzo, " ", IntegerToString(horaComienzoBuscar) ,":", IntegerToString(minutoComienzoBuscar),":00"));
   datetime out = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day(), " ", IntegerToString(horaFinBuscar) ,":", IntegerToString(minutoFinBuscar),":00"));
   
   int  inBar  = iBarShift(NULL,PERIOD_M30,in),
        outBar = iBarShift(NULL,PERIOD_M30,out-1),
        BarRange  = inBar - outBar + 1,
        MaxShift = iHighest(NULL,PERIOD_M30,MODE_HIGH,BarRange,outBar),
        MinShift = iLowest(NULL,PERIOD_M30, MODE_LOW,BarRange,outBar);



            max = iHigh(NULL,PERIOD_M30,MaxShift);
            min = iLow(NULL,PERIOD_M30,MinShift); 

   Print("Max: ", max);   
   Print("Min: ", min); 
   
   max = NormalizeDouble(max, Digits);
   min = NormalizeDouble(min, Digits);
   
}

