string mediumTrend = "no trend";

double checkMediumTrend() {
   double medium = iMA(Symbol(),0,mediumEmaPeriod,0,MODE_EMA,PRICE_OPEN,0);
   double slow = iMA(Symbol(),0,slowEmaPeriod,0,MODE_EMA,PRICE_OPEN,0);
   if (medium > slow) {
      mediumTrend = "up";
      return 1;
   }
   
   if (medium < slow) {
      mediumTrend = "down";
      return -1;
   }
   return 0;
}
