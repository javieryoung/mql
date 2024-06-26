//+------------------------------------------------------------------+
//|                                                     La vela Loca |
//|                                                     Javier Young |
//|                                                 https://young.uy |
//+------------------------------------------------------------------+
#property copyright "Javier Young"
#property link      "https://young.uy"
#property version   "1.10"
#property strict

int Magic = 15;

input double cuenta = 20000; // tamaño de la cuenta
input double risk = 0.5; // % a arriesgar
input double sl = 6; // stoploss
input double tp = 41; // takeprofit
input bool breakEvenEnabled = true; // activar break even
input double breakEvenFactor = 0.2; // % break even
input bool trailingStopEnabled = true; // trailing stop
input double trailingStopFactor = 6; // valor de trailing
input double minimoParaOperar = 3;
input int horaComienzo = 16;
input int minutoComienzo = 30;
input int horaFin = 17;
input int minutoFin = 30;
input int operacionesPorDia = 500;
input double pipValue = 1;
input double dividirEntre = 1;
input int tamanioLote = 1;


// Licencia
input string   licencia  =  ""; // Clave
string key = "locaManiaticav1.10yo";


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

int OnInit() {
   
   // if (!LicenceCheck(licencia,key)) return(INIT_FAILED);
   
   Print("Se cargó el Expert a la gráfica...");
   ultimoBalance = AccountBalance();
   diaActual = Day();
   
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason) {
   Print("Se eliminó el Expert a la gráfica...");
}
  
  
void OnTick() {
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
      operacionesHechasHoy = 0;
   }
   
   if (breakEvenEnabled && !trailingStopEnabled) checkBreakEven();
   if (trailingStopEnabled) checkTrailingStop();
   
}



double sl() {
    return sl;
}


double tp() {
    return tp;
}


// se fija si hay pending orders abiertas de buy y sell, y abre las que correspondan
void abrirPending() {
      
      bool abrirCompra = true;
      bool abrirVenta = true;
      // Cierro las que esten abiertas
      if (OrderSelect(ticketBuy,SELECT_BY_TICKET,MODE_TRADES)){
            if (OrderType() == OP_BUYSTOP) {
               OrderDelete(OrderTicket());
               operacionesHechasHoy--;
            } else {
               if (OrderCloseTime() == 0)
                  abrirCompra = false;
            }
      }
      
      if (OrderSelect(ticketSell,SELECT_BY_TICKET,MODE_TRADES)){
            if (OrderType() == OP_SELLSTOP) {
               OrderDelete(OrderTicket());
               operacionesHechasHoy--;
            } else {
               if (OrderCloseTime() == 0)
                  abrirVenta = false;
            }   
      }
      
      // Calculo max y min para poner buy y sell stop
      calcularMinimoYMaximo();
      
      
      double volume = calculateLotSize(sl());
      
      if (abrirCompra) {
         string commentCompra = StringConcatenate("Compra ", IntegerToString(Magic));
         double tpCompra;
         if (trailingStopEnabled) 
            tpCompra = 0;
         else 
            tpCompra = max+tp();
         ticketBuy = OrderSend(Symbol(), OP_BUYSTOP, volume, max, 0.1, NormalizeDouble(max-sl(), Digits), NormalizeDouble(tpCompra,Digits), commentCompra, Magic);
         operacionesHechasHoy++;
      }
      if (abrirVenta) {
         string commentVenta = StringConcatenate("Venta ", IntegerToString(Magic));
         double tpVenta;
         if (trailingStopEnabled) 
            tpVenta = 0;
         else 
            tpVenta = min-tp();
         ticketSell = OrderSend(Symbol(), OP_SELLSTOP, volume, min, 0.1, NormalizeDouble(min+sl(), Digits), NormalizeDouble(tpVenta,Digits), commentVenta, Magic);
         operacionesHechasHoy++;
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
   
   max = Ask + minimoParaOperar;
   min = Bid - minimoParaOperar;
   
}



bool filtro() {
   // Hora
   bool afterOpen = Hour() > horaComienzo || (Hour() == horaComienzo && Minute() >= minutoComienzo);
   bool beforeClose = Hour() < horaFin || (Hour() == horaFin && Minute() <= minutoFin);
   
   if (operacionesHechasHoy >= operacionesPorDia){
      return false;
   }   
   return afterOpen && beforeClose ;
}
