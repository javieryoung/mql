
input string TitleMACD = ""; // INDICADOR: MACD
input int MACDperiodFast = 12; // período rápido
input int MACDperiodSlow = 26; // período lento
input int MACDSignalperiod = 9; // señal

double SignalMACD = 0;

double checkMACD() {
   double macd = iMACD(Symbol(), NULL, MACDperiodFast, MACDperiodSlow, MACDSignalperiod, PRICE_OPEN, MODE_MAIN, 0);
   double macdPrev = iMACD(Symbol(), NULL, MACDperiodFast, MACDperiodSlow, MACDSignalperiod, PRICE_OPEN, MODE_MAIN, 1);
   
   if (macdPrev < 0 && macd > 0) 
      SignalMACD = 1; // comprar
   
   if (macdPrev > 0 && macd < 0) 
      SignalMACD = -1; // vender
   
   double toReturn = SignalMACD;
   SignalMACD = SignalMACD * desgasteDeSignal;
   return toReturn;
}