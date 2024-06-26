string fastTrend = "no trend";

double checkFastTrend() {
   double fast = iMA(Symbol(),0,fastEmaPeriod,0,MODE_EMA,PRICE_OPEN,0);
   double medium = iMA(Symbol(),0,mediumEmaPeriod,0,MODE_EMA,PRICE_OPEN,0);
   if (fast > medium) {
      fastTrend = "up";
      return 1;
   }
   
   if (fast < medium) {
      fastTrend = "down";
      return -1;
   }
   return 0;
}
