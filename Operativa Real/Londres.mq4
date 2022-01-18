//+------------------------------------------------------------------+
//|                                                   OrderBlock.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OrderLimit = 100;
datetime LastActionTime = 0;

int Magic = 333;
double OrderBlockLow = 100000;
double OrderBlockHigh = 0;
double OrderBlockLow_mean = 0;
double OrderBlockHigh_mean = 0;

bool Op = True;

int HoraComienzo = 20;
int HoraFin = 24;
int PosicionLow = 0;
int PosicionHigh = 0;
double OrderLabelCompra = 0;
double OrderLabelVenta = 0;

int SL=10;
int TP=20;
double cuenta=20000;
double risk = 1;


void OnTick(){
   
   if (LastActionTime != Time[0]){
      LastActionTime = Time[0];
      if (FiltroTemporal()) {
      
         for ( int i = 1; i <= OrderLimit; i++ ){
            if (Low[i] < Low[i-1] && Low[i] < OrderBlockLow){
               OrderBlockLow = Low[i];
               OrderBlockLow_mean = NormalizeDouble((High[i]+Low[i])/2, Digits);
               PosicionLow = i;
               }
            if (High[i] > High[i-1] && High[i] > OrderBlockHigh){
               OrderBlockHigh = High[i];
               OrderBlockHigh_mean = NormalizeDouble((High[i]+Low[i])/2, Digits);
               PosicionHigh = i;
            }
         }
          
         double stopLossCompra = NormalizeDouble(OrderBlockLow_mean-SL, Digits);
         double takeProfitCompra = NormalizeDouble(OrderBlockLow_mean+TP, Digits);
         double stopLossVenta = NormalizeDouble(OrderBlockHigh_mean+SL, Digits);
         double takeProfitVenta = NormalizeDouble(OrderBlockHigh_mean-TP, Digits);      
         
         ObjectCreate(0,"HLINELow1",OBJ_HLINE,0,0,Low[PosicionLow],clrRed);
         ObjectCreate(0,"HLINELow2",OBJ_HLINE,0,0,High[PosicionLow],clrRed);
         ObjectCreate(0,"HLINEHigh1",OBJ_HLINE,0,0,High[PosicionHigh],clrBlue);
         ObjectCreate(0,"HLINEHigh2",OBJ_HLINE,0,0,Low[PosicionHigh],clrBlue);
         
         if (Op) {
           
           double volume = calculateLotSize(SL);
           
           OrderLabelCompra = OrderSend(NULL,OP_BUYLIMIT,volume,OrderBlockLow_mean,1,stopLossCompra,takeProfitCompra,"",Magic);
           OrderLabelVenta = OrderSend(NULL,OP_SELLLIMIT,volume,OrderBlockHigh_mean,1,stopLossVenta,takeProfitVenta,"",Magic);
         }
         Op = False;
      }    
   }    
}
//+------------------------------------------------------------------+

bool FiltroTemporal() {
   return Hour() >= HoraComienzo && Hour()<=HoraFin;
}

double calculateLotSize(double SL) {
   double lotSize = MarketInfo(Symbol(), MODE_LOTSIZE);
   double volume = (cuenta * (risk / 100)) / (SL * lotSize);
   
   double maxLotSize = MarketInfo(Symbol(), MODE_MAXLOT);
   if (volume > maxLotSize) volume = maxLotSize;
   double minLotSize = MarketInfo(Symbol(), MODE_MINLOT);
   if (volume < minLotSize) volume = minLotSize;
   
   return volume;
}