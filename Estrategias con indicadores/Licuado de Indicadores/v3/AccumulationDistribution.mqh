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

   for(int i = 0; i != AccumulationDistributionPeriod+1; i++) {
      ad[i] = iAD(Symbol(), NULL, i);
   }
   
   int goingUpAD = 0;
   int goingDownAD = 0;
   
   for(int i = 0; i != AccumulationDistributionPeriod; i++) {
      if (ad[i] > ad[i+1]) goingUpAD++;
      if (ad[i] < ad[i+1]) goingDownAD++;
   }
   
   double minimaDistancia = AccumulationDistributionPeriod / 5;
   string directionAD = "no direction";
   if (goingUpAD-goingDownAD >= minimaDistancia) // el indicador está en subida
      directionAD = "up";
      
   if (goingDownAD-goingUpAD >= minimaDistancia)  // el indicador está en bajada
      directionAD = "down";
   
      
      
   if ((currentTrend == "no trend" || currentTrend == "down") && directionAD == "up") 
      SignalAccumulationDistribution = 1;
   
   if ((currentTrend == "no trend" || currentTrend == "up") && directionAD == "down") 
      SignalAccumulationDistribution = -1;
      
   double toReturn = SignalAccumulationDistribution;
   SignalAccumulationDistribution = SignalAccumulationDistribution * desgasteDeSignal;
   return toReturn;
}