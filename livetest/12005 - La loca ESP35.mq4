//+------------------------------------------------------------------+
//|                                                     La vela Loca |
//|                                                     Javier Young |
//|                                                 https://young.uy |
//+------------------------------------------------------------------+
#property copyright "Javier Young"
#property link      "https://young.uy"
#property version   "1.10"
#property strict

int Magic = 1205;

input double cuenta = 10000; // tamaño de la cuenta
input double risk = 0.001; // % a arriesgar
input double dividirEntre = 1; // dividir sl, tp y ts entre...

string horas[1] =                 { "10:00:00" };
string horasCerrarPendientes[1] = { "10:01:00" };
int iteracion = 8;


double max = 0.0;
double min = 30000000.0;
int diaActual = 0;
int ticketBuy;
int ticketSell;
int ultimoBalance;


#include <../Experts/livetest/parametros/LocaESP35.mqh>


int combinacionActual = 0;

string nombreArchivo = StringConcatenate(IntegerToString(Magic),".csv");
int fileHandler;

int OnInit() {
   Print("Se cargó el Expert a la gráfica...");
   ultimoBalance = AccountBalance();
   diaActual = Day();
   
   fileHandler = FileOpen(nombreArchivo, FILE_READ|FILE_WRITE);
   
   Print("Iteracion");
   Print(iteracion);
   
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason) {
   Print("Se eliminó el Expert a la gráfica...");
   FileClose(nombreArchivo);
}


void OnTick() {

   if (diaActual != Day()) {
      diaActual = Day();
      reloadParameters();
   }
   
   
   if (isNewCandle()) {
      
      datetime candleTime = iTime(Symbol(), 0, 0);
      
      for (int i = 0; i < ArraySize(horasCerrarPendientes); i++) {
         datetime time = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day(), " ", horasCerrarPendientes[i]));
         if (candleTime == time) { 
            cerrarPendientes();
         }
      }
      
      for (int i = 0; i < ArraySize(horas); i++) {
         datetime time = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day(), " ", horas[i]));
         if (candleTime == time) { 
            combinacionActual = i;
            abrirPending();
         }
      }
      
      
   }
      
}

void reloadParameters() {
   for (int i = 0; i < iteracion; i++) {
      combinaciones[combinacionActual][i][3] = 0;
      combinaciones[combinacionActual][i][4] = 0;
      combinaciones[combinacionActual][i][5] = 0; // 0 si aun no se agrego al CSV
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




// se fija si hay pending orders abiertas de buy y sell, y abre las que correspondan
void abrirPending() {
   double minimumDistance = MarketInfo( Symbol(), MODE_STOPLEVEL ) * Point;
      
   for (int i = 0; i < iteracion; i++) {
      if (combinaciones[combinacionActual][i][0]) {
      
         double mpo = combinaciones[combinacionActual][i][2] / dividirEntre;
         
         max = Ask + mpo;
         min = Bid - mpo;
         
         double volume = NormalizeDouble(calculateLotSize(combinaciones[combinacionActual][i][0] / dividirEntre),Digits);
         double sl = NormalizeDouble(combinaciones[combinacionActual][i][0] / dividirEntre, Digits);
         double tp = NormalizeDouble(combinaciones[combinacionActual][i][1] / dividirEntre, Digits);
         double spread = MarketInfo( Symbol(), MODE_SPREAD );
         
         string comment = StringConcatenate(combinaciones[combinacionActual][i][0], ";", combinaciones[combinacionActual][i][1], ";", combinaciones[combinacionActual][i][2],  ";", spread); 
         
         ticketBuy = OrderSend(Symbol(), OP_BUYSTOP, volume, max, 0.1, NormalizeDouble(max-sl, Digits), NormalizeDouble(max+tp, Digits), comment, Magic);
         ticketSell = OrderSend(Symbol(), OP_SELLSTOP, volume, min, 0.1, NormalizeDouble(min+sl, Digits), NormalizeDouble(max-tp, Digits), comment, Magic);
         combinaciones[combinacionActual][i][3] = ticketBuy;
         combinaciones[combinacionActual][i][4] = ticketSell;
      }
   }
   
}

double calculateLotSize(double SL) {
   string baseCurr = StringSubstr(Symbol(),0,3);
   string crossCurr = StringSubstr(Symbol(),3,3);
    
   double lotSize = MarketInfo(Symbol(), MODE_LOTSIZE);
   
   double volume;
   if(crossCurr == AccountCurrency()) {
      volume = (cuenta * (risk / 100.0)) / (SL * lotSize);
    } else if(baseCurr == AccountCurrency()) {
      volume = (cuenta * (risk / 100.0)) / (SL * lotSize * Ask);
    } else {
      volume = (cuenta * (risk / 100.0)) / (SL * lotSize);
    }
    
   return volume;
}







void checkTrailingStop() {
   if (OrdersTotal() > 0) {
      for (int i = 0; i < iteracion; i++) {
         if (OrderSelect(combinaciones[combinacionActual][i][3], SELECT_BY_TICKET)) { // BUY
            double stoplossCompra = NormalizeDouble(Ask - (combinaciones[combinacionActual][i][1] / dividirEntre), Digits);
            if (OrderType() == OP_BUY && stoplossCompra > OrderStopLoss()) {
               OrderModify(OrderTicket(),OrderOpenPrice(),stoplossCompra,0,0,Blue);
            }
         }
         if (OrderSelect(combinaciones[combinacionActual][i][4], SELECT_BY_TICKET)) { // SELL
            double stoplossVenta = NormalizeDouble((combinaciones[combinacionActual][i][1] / dividirEntre) + Bid, Digits);
            if (OrderType() == OP_SELL && stoplossVenta < OrderStopLoss()) {
               OrderModify(OrderTicket(),OrderOpenPrice(),stoplossVenta,0,0,Blue);
            }
         }
      
      }
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
