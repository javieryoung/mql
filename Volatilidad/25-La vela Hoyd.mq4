//+------------------------------------------------------------------+
//|                                              La vela Definitiva  |
//|                                                     Javier Young |
//|                                                 https://young.uy |
//+------------------------------------------------------------------+
#property copyright "Javier Young"
#property link      "https://young.uy"
#property version   "1.10"
#property strict

input int Magic = 24;

input double cuenta = 20000; // tamaño de la cuenta
input double minimoSpread = 180; // no operar si el spread es mayor que
input double risk = 0.5; // % a arriesgar
input double sl = 5; // stoploss
input double tp = 15; // takeprofit
input bool forzarTp = true; // usar tp igual
input bool cerrarSiHayTp = true; // si la primera operacion toca TP cerrar la segunda
input double minimoParaOperar = 5;
input bool breakEvenEnabled = true; // activar break even
input double breakEvenFactor = 0.2; // % break even
input bool trailingStopEnabled = true; // trailing stop
input double trailingStopFactor = 10; // valor de trailing
input int abrirSegundosAntes = 15;
input int horaComienzo = 16;
input int minutoComienzo = 30;
input int horaFin = 16;
input int minutoFin = 33;
input double dividirEntre = 1; // dividir dolares entre
int operacionesPorDia = 2;

// Licencia
input string   licencia  =  ""; // Clave
string key = "desquiciadaComunv1.10yo";

double standardLot = 10000;

double min;
double max;

int diaActual = 0;
int operacionesHechasHoy = 0;
int ticketBuy;
int ticketSell;
int ultimoBalance;



#include <../Experts/LicenceCheck.mqh>
#include <../Experts/FuncionesComunes.mqh>

int cuentas[] = {44127800,44127805,220080060,4310842,4310839,4336520,
   4312124, 3364688, 4312124, 4337328, 66240634, 4310843, 4313395, 4313866, 4313865, 4314119,
   4313793, // Mati
   4314267,
   4315773, // JD y Javi MFF
   1658897, 2132180945,
   1300158229, 1300159075, // Juan FTMO
   66281006 // True Forex Funds
};

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

bool abriHoy = false;
void OnTick() {
   
   datetime candleTime = iTime(Symbol(), 0, 0);
   datetime time = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day(), " ", IntegerToString(horaComienzo), ":", IntegerToString(minutoComienzo), ":00"));
   datetime timeClose = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day(), " ", IntegerToString(horaFin), ":", IntegerToString(minutoFin), ":00"));
   
   if (TimeCurrent() >= time - abrirSegundosAntes && !abriHoy && TimeCurrent() < timeClose) {
      abriHoy = true;
      abrirPending();
   }
   if (TimeCurrent() > time - abrirSegundosAntes && TimeCurrent() < time) {
      acomodarVelas();
   }
   
   if (candleTime == time) {
      double Spread = MarketInfo(Symbol(), MODE_SPREAD);
      if (Spread > minimoSpread) {
         cerrarPendientes();
      }
   }
   
     
   
   if (candleTime == timeClose) { 
      cerrarPendientes();
      abriHoy = false;
   }
      
   
   if (cerrarSiHayTp) checkSiCerro();
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
      if (trailingStopEnabled && !forzarTp) 
         tpCompra = 0;
      else 
         tpCompra = max+tp();
            
      operacionesHechasHoy++;
      
      double ts = NormalizeDouble(trailingStopFactor / dividirEntre, Digits);
      double mpo = NormalizeDouble(minimoParaOperar / dividirEntre, Digits);
      
      string comment = StringConcatenate("SL=", sl(), ";TS=", ts, ";MPO=", mpo); 
      

     ticketBuy = OrderSend(Symbol(), OP_BUYSTOP, volume, max, 0.1, NormalizeDouble(max-sl(), Digits), NormalizeDouble(tpCompra,Digits), comment, Magic);
      
      
      
      string commentVenta = StringConcatenate("Venta ", IntegerToString(Magic));
      double tpVenta;
      if (trailingStopEnabled && !forzarTp) 
         tpVenta = 0;
      else 
         tpVenta = min-tp();
      operacionesHechasHoy++;
      
      
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


void acomodarVelas () {
   calcularMinimoYMaximo();
   
   
   double tpCompra;
   if (trailingStopEnabled && !forzarTp) 
      tpCompra = 0;
   else 
      tpCompra = max+tp();
   if(OrderSelect(ticketBuy, SELECT_BY_TICKET)) {
      OrderModify(ticketBuy, max, NormalizeDouble(max-sl(), Digits), NormalizeDouble(tpCompra,Digits), 0, Blue);
   }
   
   
   double tpVenta;
   if (trailingStopEnabled && !forzarTp) 
      tpVenta = 0;
   else 
      tpVenta = min-tp();
         
         
   if(OrderSelect(ticketSell, SELECT_BY_TICKET)) {
      OrderModify(ticketSell, min, NormalizeDouble(min+sl(), Digits), NormalizeDouble(tpVenta,Digits), 0, Red);
   }
}