//+------------------------------------------------------------------+
//|                                                     La vela Loca |
//|                                                     Javier Young |
//|                                                 https://young.uy |
//+------------------------------------------------------------------+
#property copyright "Javier Young"
#property link      "https://young.uy"
#property version   "1.10"
#property strict

int Magic = 16;

input double cuenta = 20000; // tamaño de la cuenta
input double risk = 0.5; // % a arriesgar
input double sl = 3; // stoploss
input double tp = 41; // takeprofit
input bool breakEvenEnabled = true; // activar break even
input double breakEvenFactor = 0.2; // % break even
input bool trailingStopEnabled = true; // trailing stop
input double trailingStopFactor = 11; // valor de trailing
input double minimoParaOperar = 9;
input int horaComienzo = 16;
input int minutoComienzo = 30;
input int horaFin = 17;
input int minutoFin = 30;
input double dividirEntre = 1; // dividir sl, tp, ts y mpo entre...
input int tamanioLote = 1; //0: standard, 1: mini, 2: micro

bool opereHoy = false;
// Licencia
input string   licencia  =  ""; // Clave
string key = "locaComunv1.10yo";


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
#include <../Experts/pruebas/FuncionesComunes.mqh>

int OnInit() {
   
   // if (!LicenceCheck(licencia,key)) return(INIT_FAILED);
   
   Print("Se cargó el Expert a la gráfica...");
   ultimoBalance = AccountBalance();
   diaActual = Day();
   buscarImbalances();
   
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason) {
   Print("Se eliminó el Expert a la gráfica...");
}
  
  
int 
void OnTick() {
   if (filtro()) {
      if (!opereHoy) abrirPending();
   } else { 
      cerrarPendientes();
   }
   
      
   if (diaActual != Day()) {
      double gananciaDelDia = AccountBalance() - ultimoBalance;
      Alert(StringConcatenate("Ganancia del dia: ", NormalizeDouble(DoubleToString(gananciaDelDia), Digits)));
      ultimoBalance = AccountBalance();
      diaActual = Day();
      Print(StringConcatenate("Día: "), IntegerToString(diaActual));
      usedRisk = risk;
      operacionesHechasHoy = 0;
      opereHoy = false;
   }
   
   if (breakEvenEnabled && !trailingStopEnabled) checkBreakEven();
   if (trailingStopEnabled) checkTrailingStop();
   checkCambioDeEstado();
   
}



int estadoOrdenCompra;
int estadoOrdenVenta;
void checkCambioDeEstado() {
   OrderSelect(ticketBuy, SELECT_BY_TICKET);
   if (/*estadoOrdenCompra == OP_BUYSTOP && */OrderType() == OP_BUY) {
      cerrarPendientes();
   }
   
   OrderSelect(ticketSell, SELECT_BY_TICKET);
   if (/*estadoOrdenVenta == OP_SELLSTOP && */OrderType() == OP_SELL) {
      cerrarPendientes();
   }
      
   OrderSelect(ticketBuy, SELECT_BY_TICKET);
   estadoOrdenCompra = OrderType();
   OrderSelect(ticketSell, SELECT_BY_TICKET);
   estadoOrdenVenta = OrderType();
}



double sl() {
    return sl / dividirEntre;
}


double tp() {
    return tp / dividirEntre;
}


// se fija si hay pending orders abiertas de buy y sell, y abre las que correspondan
void abrirPending() {
      opereHoy = true;
      bool abrirCompra = true;
      bool abrirVenta = true;
      // Cierro las que esten abiertas
      if (OrderSelect(ticketBuy,SELECT_BY_TICKET,MODE_TRADES)){
         if (OrderCloseTime() == 0)
            abrirCompra = false;
      }
      
      if (OrderSelect(ticketSell,SELECT_BY_TICKET,MODE_TRADES)){
         if (OrderCloseTime() == 0)
            abrirVenta = false;
      }
      
      // Calculo max y min para poner buy y sell stop
      calcularMinimoYMaximo();
      
      
      double volumeCompra = calculateLotSize(sl());
      double volumeVenta = calculateLotSize(sl());
      
      if (abrirCompra) {
         string commentCompra = StringConcatenate("Compra ", IntegerToString(Magic));
         double tpCompra;
         if (trailingStopEnabled) 
            tpCompra = 0.0;
         else 
            tpCompra = max+tp();
         ticketBuy = OrderSend(Symbol(), OP_BUYSTOP, volumeCompra, NormalizeDouble(max, Digits), 0.1, NormalizeDouble(max-sl(), Digits), NormalizeDouble(tpCompra,Digits), commentCompra, Magic);
      }
      if (abrirVenta) {
         string commentVenta = StringConcatenate("Venta ", IntegerToString(Magic));
         double tpVenta;
         if (trailingStopEnabled) 
            tpVenta = 0.0;
         else 
            tpVenta = min-tp();
         ticketSell = OrderSend(Symbol(), OP_SELLSTOP, volumeVenta, NormalizeDouble(min, Digits), 0.1, NormalizeDouble(min+sl(), Digits), NormalizeDouble(tpVenta,Digits), commentVenta, Magic);
      }   
      
      
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
   
   max = Ask + minimoParaOperar/dividirEntre;
   min = Bid - minimoParaOperar/dividirEntre;
   
}



bool filtro() {
   // Hora
   bool afterOpen = Hour() > horaComienzo || (Hour() == horaComienzo && Minute() >= minutoComienzo);
   bool beforeClose = Hour() < horaFin || (Hour() == horaFin && Minute() <= minutoFin);
   
   
   return afterOpen && beforeClose ;
}

