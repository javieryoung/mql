
input string TitleADX = ""; // INDICADOR: ADX
input int ADXperiod = 14; // período
input double ADXUmbral = 25; // umbral

double SignalADX = 0;

double checkADX() {
   double adx = iADX(Symbol(), NULL, ADXperiod, PRICE_MEDIAN, MODE_MAIN, 0);
   if (adx > ADXUmbral) { // hay tendencia
   
      // RECARGO VARIABLE GLOBAL DE TENDENCIA
      double minusdi = iADX(Symbol(), NULL, ADXperiod, PRICE_MEDIAN, MODE_MINUSDI, 0);
      double plusdi = iADX(Symbol(), NULL, ADXperiod, PRICE_MEDIAN, MODE_PLUSDI, 0);
      if (plusdi > minusdi) {
         currentTrend = "up";
      } else {
         currentTrend = "down";
      }
      
      
      // EVALUO SI HAY SEÑAL (solo si el ADX acaba de superar el umbral)
      double prevADX = iADX(Symbol(), NULL, ADXperiod, PRICE_MEDIAN, MODE_MAIN, 1);
      if (prevADX < ADXUmbral) {
         if (currentTrend == "up") SignalADX = 1;
         if (currentTrend == "down") SignalADX = -1;
      }
   } else {
      currentTrend = "no trend";
   }
   
   double toReturn = SignalADX;
   SignalADX = SignalADX * desgasteDeSignal;
   return toReturn;
}