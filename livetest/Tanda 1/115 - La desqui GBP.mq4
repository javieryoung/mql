//+------------------------------------------------------------------+
//|                                                     La vela Loca |
//|                                                     Javier Young |
//|                                                 https://young.uy |
//+------------------------------------------------------------------+
#property copyright "Javier Young"
#property link      "https://young.uy"
#property version   "1.10"
#property strict

int Magic = 115;

input double cuenta = 10000; // tamaño de la cuenta
input double risk = 0.001; // % a arriesgar
input double dividirEntre = 100000; // dividir sl, tp y ts entre...
input int tamanioLote = 2; //0: standard, 1: mini, 2: micro

string horas[6] = { "03:00:00", "09:00:00", "10:00:00", "15:30:00", "16:30:00", "17:00:00" };
string horasCerrarPendientes[6] = { "03:02:00", "09:02:00", "10:02:00", "15:32:00", "16:32:00", "17:02:00" };

bool trailingStopEnabled = true; // trailing stop
double tp = 41; // takeprofit
bool breakEvenEnabled = false; // activar break even
double breakEvenFactor = 0.2; // % break even
int horaComienzo = 16;
int minutoComienzo = 30;
int horaFin = 17;
int minutoFin = 30;

// Licencia
double usedRisk = risk;
double max = 0.0;
double min = 30000000.0;
int diaActual = 0;
int ticketBuy;
int ticketSell;
int ultimoBalance;

#include <../Experts/livetest/parametros/DesquiAUD.mqh>


int combinacionActual = 0;
int iteracion = 7;

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
      
      for (int i = 1; i < ArraySize(horas); i++) {
         datetime time = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day(), " ", horas[i]));
         if (candleTime == time) { 
            combinacionActual = i;
            abrirPending();
         }
      }
      
      for (int i = 1; i < ArraySize(horasCerrarPendientes); i++) {
         datetime time = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day(), " ", horasCerrarPendientes[i]));
         if (candleTime == time) { 
            cerrarPendientes();
         }
      }
      
   }
      
   checkTrailingStop();
   checkCambioDeEstado();
   checkSiCerro();
}

void reloadParameters() {
   for (int i = 0; i < iteracion; i++) {
      combinaciones[combinacionActual][i][3] = 0;
      combinaciones[combinacionActual][i][4] = 0;
      combinaciones[combinacionActual][i][5] = 0; // 0 si aun no se agrego al CSV
   }
}


void checkCambioDeEstado() {

   // Si una combinacion ya compro cancelo al venta
   // y viceversa
   
   if (OrdersTotal() > 0) {
      for (int i = 0; i < iteracion; i++) {
         if (OrderSelect(combinaciones[combinacionActual][i][3], SELECT_BY_TICKET)) { // BUY
            if (OrderType() == OP_BUY)
               OrderDelete(combinaciones[combinacionActual][i][4]);
         }
         if (OrderSelect(combinaciones[combinacionActual][i][4], SELECT_BY_TICKET)) { // SELL
            if (OrderType() == OP_SELL)
               OrderDelete(combinaciones[combinacionActual][i][3]);
         }
      
      }
   }
}



void escribirEnElArchivo(string a1, string a2, string a3, string a4, string a5, string a6, string a7, string a8, string a9, string a10, string a11, string a12, string a13) {
   FileSeek(fileHandler, 0, SEEK_END);
   FileWrite(fileHandler, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13);
}

void checkSiCerro() { 
   int spread = MarketInfo(Symbol(), MODE_SPREAD);
   for (int i = 0; i < iteracion; i++) {
      if (OrderSelect(combinaciones[combinacionActual][i][3], SELECT_BY_TICKET, MODE_HISTORY)) {
         if (combinaciones[combinacionActual][i][5] != 1 && OrderProfit() != 0 && OrderCloseTime() != 0) {
            escribirEnElArchivo(
               IntegerToString(Magic),
               Symbol(),
               "compra",
               IntegerToString(OrderTicket()),
               IntegerToString(OrderCloseTime()),
               IntegerToString(DoubleToStr(combinaciones[combinacionActual][i][3])),
               IntegerToString(combinaciones[combinacionActual][i][0]),
               IntegerToString(combinaciones[combinacionActual][i][1]),
               IntegerToString(combinaciones[combinacionActual][i][2]),
               DoubleToStr(OrderProfit() + OrderSwap() + OrderCommission(),2),
               IntegerToString(spread),
               DoubleToString(dividirEntre,2),
               IntegerToString(tamanioLote)
            );
            combinaciones[combinacionActual][i][5] = 1;
         }
      }
      if (OrderSelect(combinaciones[combinacionActual][i][4], SELECT_BY_TICKET, MODE_HISTORY)) {
         if (combinaciones[combinacionActual][i][5] != 1 && OrderProfit() != 0 && OrderCloseTime() != 0) {
            escribirEnElArchivo(
               IntegerToString(Magic),
               Symbol(),
               "venta",
               IntegerToString(OrderTicket()),
               IntegerToString(OrderCloseTime()),
               IntegerToString(DoubleToStr(combinaciones[combinacionActual][i][4])),
               IntegerToString(combinaciones[combinacionActual][i][0]),
               IntegerToString(combinaciones[combinacionActual][i][1]),
               IntegerToString(combinaciones[combinacionActual][i][2]),
               DoubleToStr(OrderProfit() + OrderSwap() + OrderCommission(),2),
               IntegerToString(spread),
               DoubleToString(dividirEntre,2),
               IntegerToString(tamanioLote)
            );
            combinaciones[combinacionActual][i][5] = 1;
         }
      }
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
   calcularMinimoYMaximo();
   if (max < Ask + minimumDistance){ // Solo sucede si la el maximo de la vela anterior esta muy cerca de el cierre de la misma
      max = NormalizeDouble(MathAbs(max-min)/2 + max, Digits);
   }
   if (Bid - minimumDistance  < min) {
      min = NormalizeDouble(min - MathAbs(max-min)/2, Digits);
   }
   
      
   for (int i = 0; i < iteracion; i++) {
      if (combinaciones[combinacionActual][i][0]) {
         double volume = calculateLotSize(combinaciones[combinacionActual][i][0] / dividirEntre);
         double sl = combinaciones[combinacionActual][i][0] / dividirEntre;
         ticketBuy = OrderSend(Symbol(), OP_BUYSTOP, volume, max, 0.1, NormalizeDouble(max-sl, Digits), 0, "", Magic);
         ticketSell = OrderSend(Symbol(), OP_SELLSTOP, volume, min, 0.1, NormalizeDouble(min+sl, Digits), 0, "", Magic);
         combinaciones[combinacionActual][i][3] = ticketBuy;
         combinaciones[combinacionActual][i][4] = ticketSell;
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


double calculateLotSize(double SL) {
   int divisor;
   if (tamanioLote == 0) divisor = 1;
   if (tamanioLote == 1) divisor = 100;
   if (tamanioLote == 2) divisor = 10000;
   
   // We get the value of a tick.
   double nTickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   // If the digits are 3 or 5, we normalize multiplying by 10.
   if ((Digits == 3) || (Digits == 5)){
      nTickValue = nTickValue * 10;
   }
   
   // We apply the formula to calculate the position size and assign the value to the variable.
   double LotSize = (cuenta * risk / 100) / (SL * divisor);
   return LotSize;
}



bool filtro() {
   // Hora
   bool afterOpen = Hour() > horaComienzo || (Hour() == horaComienzo && Minute() >= minutoComienzo);
   bool beforeClose = Hour() < horaFin || (Hour() == horaFin && Minute() <= minutoFin);
   
   return afterOpen && beforeClose ;
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
