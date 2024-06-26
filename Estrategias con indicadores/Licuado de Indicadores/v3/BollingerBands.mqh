
input string TitleBollingerBands = ""; // INDICADOR: BOLLINGER BANDS
input int BBPeriod = 20; // período
input double deviation= 2; // desviacíon [1, 3]

double SignalBollingerBands = 0;
// 0 - MODE_MAIN, 1 - MODE_UPPER, 2 - MODE_LOWER

double checkBollingerBands() {
   double mainBand = iBands(Symbol(), NULL, BBPeriod, deviation, 0, PRICE_CLOSE, MODE_MAIN, 0);
   
   if (currentTrend == "up" || currentTrend == "no trend") {
      double lowerBand = iBands(Symbol(), NULL, BBPeriod, deviation, 0, PRICE_CLOSE, MODE_LOWER, 0);
      if (Ask <= lowerBand) // si se pasó de la banda de arriba señal de compra
         SignalBollingerBands = 1;
      
      if (Ask > lowerBand && Ask < mainBand) // si está en el rango entre el medio y la de arriba estoy en sona de compras
         SignalBollingerBands = 0.5;
   }
   
   if (currentTrend == "down" || currentTrend == "no trend") {
      double upperBand = iBands(Symbol(), NULL, BBPeriod, deviation, 0, PRICE_CLOSE, MODE_UPPER, 0);
      if (Bid >= upperBand) // si se pasó de la banda de arriba señal de venta
         SignalBollingerBands = -1;
      
      if (Bid < upperBand && Bid > mainBand) // si está en el rango entre el medio y la de abajo estoy en sona de ventas
         SignalBollingerBands = -0.5;
   }
   
   double toReturn = SignalBollingerBands;
   SignalBollingerBands = SignalBollingerBands * desgasteDeSignal;
   return toReturn; 
}