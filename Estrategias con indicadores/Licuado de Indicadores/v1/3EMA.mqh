
input string title3EMA = ""; // INDICADOR: TRIPLE EMA
input int slowEmaPeriod = 60; // período EMA lento
input int mediumEmaPeriod = 20; // período EMA medio
input int fastEmaPeriod = 10; // período EMA rápido

bool rompioEmaRapido = false;
bool rompioEmaMedio = false;
bool rompioEmaLento = false;

double Signal3EMA = 0;

double check3EMA() {

   double slow = iMA(Symbol(),0,slowEmaPeriod,0,MODE_EMA,PRICE_OPEN,0);
   double medium = iMA(Symbol(),0,mediumEmaPeriod,0,MODE_EMA,PRICE_OPEN,0);
   double fast = iMA(Symbol(),0,fastEmaPeriod,0,MODE_EMA,PRICE_OPEN,0);
   
   
   double mediumPrev = iMA(Symbol(),0,mediumEmaPeriod,0,MODE_EMA,PRICE_OPEN,1);
   double slowPrev = iMA(Symbol(),0,slowEmaPeriod,0,MODE_EMA,PRICE_OPEN,1);
   
   if ((medium > slow && mediumPrev < slowPrev) || (medium < slow && mediumPrev > slowPrev)) {
      rompioEmaRapido = false;
      rompioEmaMedio = false;
      rompioEmaLento = false;
   }
   
   
   if (trendLong == "up" && fast > medium && medium > slow) {
      if (Ask < fast) { 
         rompioEmaRapido = true;
      }
      if (Ask < medium) { 
         rompioEmaMedio = true;
      }
      if (Ask < slow) { 
         rompioEmaLento = true;
      }
      
      if (Ask > fast && Close[1] > fast && rompioEmaRapido && !rompioEmaLento) {
         rompioEmaRapido = false;
         rompioEmaMedio = false;
         rompioEmaLento = false;
         Signal3EMA = 1;
      }
   }
   
   
   
   if (trendLong == "down" && fast < medium && medium < slow) {
      if (Bid > fast) { 
         rompioEmaRapido = true;
      }
      if (Bid > medium) { 
         rompioEmaMedio = true;
      }
      if (Bid > slow) { 
         rompioEmaLento = true;
      }
      
         
      if (Bid < fast && Close[1] < fast && rompioEmaRapido && !rompioEmaLento) {
         rompioEmaRapido = false;
         rompioEmaMedio = false;
         rompioEmaLento = false;
         Signal3EMA = -1;
      }
   }
   
   
   double toReturn = Signal3EMA;
   Signal3EMA = Signal3EMA / desgasteDeSignal;
   return toReturn;
}
