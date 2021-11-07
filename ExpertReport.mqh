/*
   LicenceCheck.mqh
   Copyright 2021, Orchard Forex
*/

#property copyright "Copyright 2013-2020, Orchard Forex"
#property link      "https://orchardforex.com"
#property version   "1.00"
#property strict

string printQueue[];
int prints = 0;
bool reportTick() {
   
   printQueue[prints] = 'Ah';
   prints++;
   ArrayResize(printQueue,prints);

}


bool printReport() {
   for (int i = 0; i < prints; i ++){
      Print(printQueue[i]);
   }
}