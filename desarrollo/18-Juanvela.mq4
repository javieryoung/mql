//+------------------------------------------------------------------+
//|                                              La vela Desquiciada |
//|                                                     Javier Young |
//|                                                 https://young.uy |
//+------------------------------------------------------------------+
#property copyright "Javier Young"
#property link      "https://young.uy"
#property version   "1.10"
#property strict

int Magic = 18;


input double cuenta = 20000; // tamaño de la cuenta
input double risk = 0.5; // % a arriesgar
input int horaComienzo = 16;
input int minutoComienzo = 30;
input int horaFin = 17;
input int minutoFin = 30;
input int operacionesPorDia = 2;

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

int OnInit(){
   
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
      cerrarOperaciones();
      if (filtro()) {
         if (operacionesHechasHoy < operacionesPorDia)
            abrirPending();
      } else { 
      }
   }
   
   
      
   if (diaActual != Day()) {
      double gananciaDelDia = AccountBalance() - ultimoBalance;
      Alert(StringConcatenate("Ganancia del dia: ", NormalizeDouble(DoubleToString(gananciaDelDia), Digits)));
      ultimoBalance = AccountBalance();
      diaActual = Day();
      Print(StringConcatenate("Día: "), IntegerToString(diaActual));
      usedRisk = risk;
      operacionesHechasHoy = 0;
   }
   
}

datetime NewCandleTime = TimeCurrent();
bool isNewCandle() {
   if (NewCandleTime == iTime(Symbol(), 0, 0)) return false;
   else {
      NewCandleTime = iTime(Symbol(), 0, 0);
      return true;
   }
}


// se fija si hay pending orders abiertas de buy y sell, y abre las que correspondan
void abrirPending() {
      
      // Cierro las que esten abiertas y pendientes
      if (OrderSelect(ticketBuy,SELECT_BY_TICKET,MODE_TRADES)){
            if (OrderType() == OP_BUYSTOP) {
               OrderDelete(OrderTicket());
            }
      }
      
      if (OrderSelect(ticketSell,SELECT_BY_TICKET,MODE_TRADES)){
            if (OrderType() == OP_SELLSTOP) {
               OrderDelete(OrderTicket());
            }  
      }
      
      // Calculo max y min para poner buy y sell stop
      int hour = Hour();
      int minutes = Minute()-1;
      if (minutes == -1){
         minutes = 59;
         hour = hour -1;
      }
      
      datetime time = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day(), " ", IntegerToString(hour) ,":", IntegerToString(minutes),":00"));
      int shift = iBarShift(NULL, PERIOD_M1, time);
      max = iHigh(NULL, PERIOD_M1,shift);
      min = iLow(NULL, PERIOD_M1,shift);
      
      double stoploss = max - min;
      
      
      double volume = (((usedRisk * cuenta) / (stoploss * Point))) / standardLot;
      
      string commentCompra = StringConcatenate("Compra ", IntegerToString(Magic));
      double tpCompra = 0;
      operacionesHechasHoy++;
      ticketBuy = OrderSend(Symbol(), OP_BUYSTOP, volume, max, 0.1, NormalizeDouble(max-stoploss, Digits), NormalizeDouble(tpCompra,Digits), commentCompra, Magic);
      
      string commentVenta = StringConcatenate("Venta ", IntegerToString(Magic));
      double tpVenta = 0;
      operacionesHechasHoy++;
      ticketSell = OrderSend(Symbol(), OP_SELLSTOP, volume, min, 0.1, NormalizeDouble(min+stoploss, Digits), NormalizeDouble(tpVenta,Digits), commentVenta, Magic); 
      
      
}




void cerrarOperaciones() {
   for(int i = 0; i < OrdersTotal(); i++){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
            
            if (OrderType() == OP_BUY) {
               OrderClose(OrderTicket(), OrderLots(), Bid, 0.1);
            }   
            
            if (OrderType() == OP_SELL) {
               OrderClose(OrderTicket(), OrderLots(), Ask, 0.1);
            }   
            
         }
      }
   }
}



bool filtro() {
   // Hora
   bool afterOpen = Hour() > horaComienzo || (Hour() == horaComienzo && Minute() >= minutoComienzo);
   bool beforeClose = Hour() < horaFin || (Hour() == horaFin && Minute() <= minutoFin);
   
   return afterOpen && beforeClose ;
}

