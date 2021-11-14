//+------------------------------------------------------------------+
//|                                                     La vela Loca |
//|                                                     Javier Young |
//|                                                 https://young.uy |
//+------------------------------------------------------------------+
#property copyright "Javier Young"
#property link      "https://young.uy"
#property version   "1.10"
#property strict

int Magic = 101;

input double cuenta = 20000; // tamaño de la cuenta
input double risk = 0.005; // % a arriesgar

double sl[6] = { 3, 4, 5, 6, 7, 9 }; // stoploss
double trailingStopFactor[3]= { 3, 6, 9 }; // valor de trailing
double minimoParaOperar[5] = { 3, 5, 7, 9, 11 };


bool trailingStopEnabled = true; // trailing stop
double tp = 41; // takeprofit
bool breakEvenEnabled = false; // activar break even
double breakEvenFactor = 0.2; // % break even
int horaComienzo = 16;
int minutoComienzo = 30;
int horaFin = 17;
int minutoFin = 30;

input double pipValue = 1;


bool opereHoy = false;
// Licencia

double usedRisk = risk;
double standardLot = 10000;


double max = 0.0;
double min = 30000000.0;
int diaActual = 0;
int ticketBuy;
int ticketSell;
int ultimoBalance;

int iteracion = 0;
double combinaciones[100][6]; // sl, trailing, minimoParaOperar, ticketBuy, ticketSell

string nombreArchivo = StringConcatenate(IntegerToString(Magic),".csv");
int fileHandler;

int OnInit() {
   Print("Se cargó el Expert a la gráfica...");
   ultimoBalance = AccountBalance();
   diaActual = Day();
   
   
   fileHandler = FileOpen(nombreArchivo, FILE_READ|FILE_WRITE);
   
   int cantidadDeCombinaciones = ArraySize(sl) * ArraySize(trailingStopFactor) * ArraySize(minimoParaOperar);
   ArrayResize(combinaciones,cantidadDeCombinaciones); 
   
   for (int i = 0; i < ArraySize(sl); i++) {
      for (int j = 0; j < ArraySize(trailingStopFactor); j++) {
         for (int k = 0; k < ArraySize(minimoParaOperar); k++) {
            if (sl[i] >= trailingStopFactor[j]) {
                combinaciones[iteracion][0] = sl[i];
                combinaciones[iteracion][1] = trailingStopFactor[j];
                combinaciones[iteracion][2] = minimoParaOperar[k];
                combinaciones[iteracion][3] = 0;
                combinaciones[iteracion][4] = 0;
                combinaciones[iteracion][5] = 0; // 0 si aun no se agrego al CSV
                iteracion++;
            }
         }
      }
   }
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
      double gananciaDelDia = AccountBalance() - ultimoBalance;
      Alert(StringConcatenate("Ganancia del dia: ", NormalizeDouble(DoubleToString(gananciaDelDia), Digits)));
      ultimoBalance = AccountBalance();
      diaActual = Day();
      Print(StringConcatenate("Día: "), IntegerToString(diaActual));
      usedRisk = risk;
      opereHoy = false;
      reloadParameters();
   }
   
   
   if (filtro()) {
      if (!opereHoy) abrirPending();
   } else { 
      cerrarPendientes();
   }
   
   
   checkTrailingStop();
   checkCambioDeEstado();
   checkSiCerro();
}

void reloadParameters() {
   for (int i = 0; i < iteracion; i++) {
      combinaciones[i][3] = 0;
      combinaciones[i][4] = 0;
      combinaciones[i][5] = 0; // 0 si aun no se agrego al CSV
   }
}


void checkCambioDeEstado() {

   // Si una combinacion ya compro cancelo al venta
   // y viceversa
   
   if (OrdersTotal() > 0) {
      for (int i = 0; i < iteracion; i++) {
         if (OrderSelect(combinaciones[i][3], SELECT_BY_TICKET)) { // BUY
            if (OrderType() == OP_BUY)
               OrderDelete(combinaciones[i][4]);
         }
         if (OrderSelect(combinaciones[i][4], SELECT_BY_TICKET)) { // SELL
            if (OrderType() == OP_SELL)
               OrderDelete(combinaciones[i][3]);
         }
      
      }
   }
}


void escribirEnElArchivo(string a1, string a2, string a3, string a4, string a5, string a6, string a7) {
   FileSeek(fileHandler, 0, SEEK_END);
   FileWrite(fileHandler, a1, a2, a3, a4, a5, a6, a7);
}

void checkSiCerro() { 
   for (int i = 0; i < iteracion; i++) {
      if (OrderSelect(combinaciones[i][3], SELECT_BY_TICKET)) {
         if (combinaciones[i][5] != 1 && OrderCloseTime() != 0) {
            escribirEnElArchivo(
               IntegerToString(Magic),
               IntegerToString(OrderCloseTime()),
               IntegerToString(DoubleToStr(combinaciones[i][3])),
               IntegerToString(combinaciones[i][0]),
               IntegerToString(combinaciones[i][1]),
               IntegerToString(combinaciones[i][2]),
               IntegerToString(OrderClosePrice() - OrderOpenPrice())
            );
            combinaciones[i][5] = 1;
         }
      }
      if (OrderSelect(combinaciones[i][4], SELECT_BY_TICKET)) {
         if (combinaciones[i][5] != 1 && OrderCloseTime() != 0) {
            escribirEnElArchivo(
               IntegerToString(Magic),
               IntegerToString(OrderCloseTime()),
               IntegerToString(DoubleToStr(combinaciones[i][4])),
               IntegerToString(combinaciones[i][0]),
               IntegerToString(combinaciones[i][1]),
               IntegerToString(combinaciones[i][2]),
               IntegerToString(OrderClosePrice() - OrderOpenPrice())
            );
            combinaciones[i][5] = 1;
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
      opereHoy = true;
      for (int i = 0; i < iteracion; i++) {
         double volume = calculateLotSize(combinaciones[i][0]);
         double max = Ask + combinaciones[i][2];
         double min = Bid - combinaciones[i][2];
         double sl = combinaciones[i][0];
         ticketBuy = OrderSend(Symbol(), OP_BUYSTOP, volume, max, 0.1, NormalizeDouble(max-sl, Digits), 0, "", Magic);
         ticketSell = OrderSend(Symbol(), OP_SELLSTOP, volume, min, 0.1, NormalizeDouble(min+sl, Digits), 0, "", Magic);
         combinaciones[i][3] = ticketBuy;
         combinaciones[i][4] = ticketSell;
      }
   
}





double calculateLotSize(double SL) {
   double lotSize = (cuenta * risk / 100) / (SL);
   return (lotSize * pipValue);
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
         if (OrderSelect(combinaciones[i][3], SELECT_BY_TICKET)) { // BUY
            double stoplossCompra = NormalizeDouble(Ask - (combinaciones[i][1] * pipValue), Digits);
            if (OrderType() == OP_BUY && stoplossCompra > OrderStopLoss()) {
               OrderModify(OrderTicket(),OrderOpenPrice(),stoplossCompra,0,0,Blue);
            }
         }
         if (OrderSelect(combinaciones[i][4], SELECT_BY_TICKET)) { // SELL
            double stoplossVenta = NormalizeDouble((combinaciones[i][1] * pipValue) + Bid, Digits);
            if (OrderType() == OP_SELL && stoplossVenta < OrderStopLoss()) {
               OrderModify(OrderTicket(),OrderOpenPrice(),stoplossVenta,0,0,Blue);
            }
         }
      
      }
   }

}

