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
input double trailingStopFactor = 7; // valor de trailing
input double minimoParaOperar = 3;
input int horaComienzo = 16;
input int minutoComienzo = 30;
input int horaFin = 17;
input int minutoFin = 30;


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
   if (estadoOrdenCompra == OP_BUYSTOP && OrderType() == OP_BUY) {
      cerrarPendientes();
   }
   
   OrderSelect(ticketSell, SELECT_BY_TICKET);
   if (estadoOrdenVenta == OP_SELLSTOP && OrderType() == OP_SELL) {
      cerrarPendientes();
   }
      
   OrderSelect(ticketBuy, SELECT_BY_TICKET);
   estadoOrdenCompra = OrderType();
   OrderSelect(ticketSell, SELECT_BY_TICKET);
   estadoOrdenVenta = OrderType();
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
      
      
      double volume = (((usedRisk * cuenta) / (sl() * Point))) / standardLot;
      
      if (abrirCompra) {
         string commentCompra = StringConcatenate("Compra ", IntegerToString(Magic));
         double tpCompra;
         if (trailingStopEnabled) 
            tpCompra = 0.0;
         else 
            tpCompra = max+tp();
         ticketBuy = OrderSend(Symbol(), OP_BUYSTOP, volume, max, 0.1, NormalizeDouble(max-sl(), Digits), NormalizeDouble(tpCompra,Digits), commentCompra, Magic);
      }
      if (abrirVenta) {
         string commentVenta = StringConcatenate("Venta ", IntegerToString(Magic));
         double tpVenta;
         if (trailingStopEnabled) 
            tpVenta = 0.0;
         else 
            tpVenta = min-tp();
         ticketSell = OrderSend(Symbol(), OP_SELLSTOP, volume, min, 0.1, NormalizeDouble(min+sl(), Digits), NormalizeDouble(tpVenta,Digits), commentVenta, Magic);
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