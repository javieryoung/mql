//+------------------------------------------------------------------+
//|                                              La vela Definitiva  |
//|                                                     Javier Young |
//|                                                 https://young.uy |
//+------------------------------------------------------------------+
#property copyright "Javier Young"
#property link      "https://young.uy"
#property version   "1.10"
#property strict

input int Magic = 2400;

input double cuenta = 20000; // tamaño de la cuenta
input double risk = 0.5; // % a arriesgar
input bool forzarTp = true; // usar tp igual
input bool cerrarSiHayTp = true; // si la primera operacion toca TP cerrar la segunda
input double minimoParaOperar = 5;
input bool breakEvenEnabled = false; // activar break even
input double breakEvenFactor = 0.6; // % break even
input bool trailingStopEnabled = true; // trailing stop
input double trailingStopFactor = 10; // valor de trailing
input double dividirEntre = 1; // dividir dolares entre

// Licencia
input string   licencia  =  ""; // Clave
string key = "definitivaYManiaticav1.10yo";

double min;
double max;

int diaActual = 0;
int operacionesHechasHoy = 0;
int ticketBuy;
int ticketSell;
int ultimoBalance;



#include <../Experts/LicenceCheck.mqh>
#include <../Experts/FuncionesComunes.mqh>


string horas[10] = { "16:30:00", "16:31:00", "16:32:00", "16:33:00", "16:34:00", "16:35:00", "16:36:00", "16:37:00", "16:38:00", "16:39:00", "16:40:00" };
double parametros[11][3] = { // SL TP MPO
   {4, 8, 3},
   {4, 9, 4},
   {4, 8, 2},
   {4, 8, 3},
   {4, 8, 3},
   {4, 8, 2},
   {4, 8, 3},
   {4, 9, 2},
   {4, 8, 3},
   {4, 7, 4},
   {4, 7, 3}, 
};
int combinacionActual =0;
int cuentas[1] = { 0 };

int OnInit(){

   long  account  =  AccountInfoInteger(ACCOUNT_LOGIN);
   if (!in_array(account)){
      Print("CUENTA INVALIDA");
      // return(INIT_FAILED);
   }
   
   Print("MODE_LOTSIZE = ", MarketInfo(Symbol(), MODE_LOTSIZE));
   Print("MODE_TICKVALUE = ", MarketInfo(Symbol(), MODE_TICKVALUE));
   Print("DIGITS = ", Digits);
   Print("POINT = ", Point);
   Print("SYMBOL = ", Symbol());
   Print("STOPLEVEL = ", MarketInfo( Symbol(), MODE_STOPLEVEL ));

   Print("Se cargó el Expert a la gráfica...");
   
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason) {
   
   Print("Se eliminó el Expert a la gráfica...");
   ultimoBalance = AccountBalance();
   diaActual = Day();
}
  
bool  abriHoy = false;
void OnTick() {

   if (diaActual != Day()) {
      diaActual = Day();
   }
   
   
   if (isNewCandle()) {
      
      datetime candleTime = iTime(Symbol(), 0, 0);
      
      for (int i = 0; i < ArraySize(horas); i++) {
         datetime time = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day(), " ", horas[i]));
         if (candleTime == time) { 
            cerrarPendientes();
            combinacionActual = i;
            abrirPending();
         }
      }
      
      
   }
   
   if (cerrarSiHayTp) checkSiCerro();
   if (breakEvenEnabled && !trailingStopEnabled) checkBreakEven();
   if (trailingStopEnabled) checkTrailingStop();
   
}



double sl() {
    return parametros[combinacionActual][0] / dividirEntre;
}


double tp() {
    return parametros[combinacionActual][1] / dividirEntre;
}



// se fija si hay pending orders abiertas de buy y sell, y abre las que correspondan
void abrirPending() {
      
      // Calculo max y min para poner buy y sell stop
      calcularMinimoYMaximo();
      
      double volume = calculateLotSize(sl());      
      
      double tpCompra;
      if (trailingStopEnabled && !forzarTp) 
         tpCompra = 0;
      else 
         if (minimoParaOperar == 0)
            tpCompra = Ask+tp();
         else
            tpCompra = max+tp();
            
      operacionesHechasHoy++;
      
      double ts = NormalizeDouble(trailingStopFactor / dividirEntre, Digits);
      double mpo = NormalizeDouble(parametros[combinacionActual][2] / dividirEntre, Digits);
      
      string comment = StringConcatenate(parametros[combinacionActual][0], ";", parametros[combinacionActual][1], ";", parametros[combinacionActual][1]); 
      
      if (minimoParaOperar == 0)
         ticketBuy = OrderSend(Symbol(), OP_BUY, volume, Ask, 0.1, NormalizeDouble(Ask-sl(), Digits), NormalizeDouble(tpCompra,Digits), comment, Magic);
      else
         ticketBuy = OrderSend(Symbol(), OP_BUYSTOP, volume, max, 0.1, NormalizeDouble(max-sl(), Digits), NormalizeDouble(tpCompra,Digits), comment, Magic);
      
      double tpVenta;
      if (trailingStopEnabled && !forzarTp) 
         tpVenta = 0;
      else 
         if (minimoParaOperar == 0)
            tpVenta = Bid-tp();
         else
            tpVenta = min-tp();
      operacionesHechasHoy++;
      
      if (minimoParaOperar == 0) 
         ticketSell = OrderSend(Symbol(), OP_SELL, volume, Bid, 0.1, NormalizeDouble(Bid+sl(), Digits), NormalizeDouble(tpVenta,Digits), comment, Magic);
      else
         ticketSell = OrderSend(Symbol(), OP_SELLSTOP, volume, min, 0.1, NormalizeDouble(min+sl(), Digits), NormalizeDouble(tpVenta,Digits), comment, Magic);
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
   
   max = Ask + minimoParaOperar/dividirEntre;
   min = Bid - minimoParaOperar/dividirEntre;

   max = NormalizeDouble(max, Digits);
   min = NormalizeDouble(min, Digits);
   
}




void checkSiCerro() {
   if(OrderSelect(ticketBuy, SELECT_BY_TICKET)) {
      if (OrderCloseTime() != 0 && (MathAbs( OrderClosePrice() - OrderTakeProfit() ) < 1) && OrderSelect(ticketSell, SELECT_BY_TICKET)) {
         OrderDelete(ticketSell);
         ticketSell = 0;
      }
   }
   if(OrderSelect(ticketSell, SELECT_BY_TICKET)) {
      if (OrderCloseTime() != 0 && (MathAbs( OrderClosePrice() - OrderTakeProfit() ) < 1) && OrderSelect(ticketBuy, SELECT_BY_TICKET)){
         OrderDelete(ticketBuy);
         ticketBuy = 0;
      }
   }
}