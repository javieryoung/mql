
input string TitleLongTrend = ""; // INDICADOR: LONG TREND (EMA)
input int LongTrendPeriod = 200; // período

double checkLongTrend() {
   
   double slow[10];
   for (int i = 0; i < 10; i++) {
      slow[i] = iMA(Symbol(),0,LongTrendPeriod,0,MODE_EMA,PRICE_OPEN,i);
   }
   
   bool upTrend = true;
   for (int i = 0; i < 10; i++) {
      if (Low[i] < slow[i]) upTrend = false;
   }
   
   
   bool downTrend = true;
   for (int i = 0; i < 10; i++) {
      if (High[i] > slow[i]) downTrend = false;
   }
   
   
   if (upTrend){
      longTrend = "up";
      return 1;
   }
   if (downTrend){
      longTrend = "down";
      return -1;
   }
   longTrend = "no trend";
   return 0;
}