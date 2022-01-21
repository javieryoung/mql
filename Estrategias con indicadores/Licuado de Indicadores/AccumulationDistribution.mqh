/*
   Explicacion como si el valor de período fuera 10:
   
   Si el resultado de este indicador está en subida, pero el 
   precio está enragnado, o en la dirección opuestase genera una señal.
   Para esto iteramos sobre los ultimos 10 valores del indicador y 
   si existen al menos 8 en determinada direccion asumimos que la
   tendencia del indicador va en dicha dirección
   
   Para analizar la tendencia del precio veremos los valores de CLOSE
   de las últimas 10 velas, y haremos el mismo procedimiento.
*/


input string TitleAD = ""; // INDICADOR: ACCUMULATION/DISTRIBUTION
input int AccumulationDistributionPeriod = 10; // velas a analizar
double SignalAccumulationDistribution = 0;

double checkAccumulationDistribution() {
   
   double ad[];
   ArrayResize(ad, AccumulationDistributionPeriod+1);
   double ema[];
   ArrayResize(ema, AccumulationDistributionPeriod+1);

   for(int i = 0; i != AccumulationDistributionPeriod+1; i++) {
      ad[i] = iAD(Symbol(), NULL, i);
      ema[i] = iMA(Symbol(), NULL, AccumulationDistributionPeriod, 0, MODE_EMA, PRICE_MEDIAN, i);
   }
   
   int goingUpAD = 0;
   int goingDownAD = 0;
   int goingUpEMA = 0;
   int goingDownEMA = 0;
   
   for(int i = 0; i != AccumulationDistributionPeriod; i++) {
      if (ad[i] > ad[i+1]) goingUpAD++;
      if (ad[i] < ad[i+1]) goingDownAD++;
      
      if (ema[i] > ema[i+1]) goingUpEMA++;
      if (ema[i] < ema[i+1]) goingDownEMA++;
   }
   
   double minimaDistancia = AccumulationDistributionPeriod / 3;
   string directionAD = "no direction";
   if (goingUpAD-goingDownAD >= minimaDistancia) // el indicador está en subida
      directionAD = "up";
      
   if (goingDownAD-goingUpAD >= minimaDistancia)  // el indicador está en bajada
      directionAD = "down";
   
   string directionEMA = "no trend";
   if (goingUpEMA-goingDownEMA >= minimaDistancia) // el precio está en subida
      directionEMA = "up";
      
   if (goingDownEMA-goingUpEMA >= minimaDistancia)  // el precio está en bajada
      directionEMA = "down";
      
      
      
      
   if ((directionEMA == "no trend" || directionEMA == "down") && directionAD == "up") 
      SignalAccumulationDistribution = 1;
   
   if ((directionEMA == "no trend" || directionEMA == "up") && directionAD == "down") 
      SignalAccumulationDistribution = -1;
      
   double toReturn = SignalAccumulationDistribution;
   SignalAccumulationDistribution = SignalAccumulationDistribution / desgasteDeSignal;
   return toReturn;
}