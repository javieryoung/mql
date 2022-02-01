
input string TitleRSI = ""; // INDICADOR: RSI
input int RSIperiod = 14; // período
input double rsiCotaInferior = 40; // si baja de ... compra
input double rsiCotaSuperior = 60; // si sube de ... vende

double SignalRSI = 0;

double checkRSI() {
   double rsi = iRSI(Symbol(), NULL, RSIperiod, PRICE_CLOSE, 1);
   if (rsi < rsiCotaInferior)
      SignalRSI = 1; // comprar
      
   if (rsi > 60)
      SignalRSI = -1; // vender
   
   double toReturn = SignalRSI;
   SignalRSI = SignalRSI / desgasteDeSignal;
   return toReturn;
}