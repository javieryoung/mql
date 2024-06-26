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

//#include <../FuncionesComunes.mqh>


input int SL=10;
input int TP=20;
input double OrderBlockFactor = 0.5;

datetime LastActionTime = 0;

int OrderLimit = 720;
int Magic = 333;
double OrderBlockLow_arriba = 0;
double OrderBlockHigh_abajo = 0;
double OrderBlockLow_mean = 0;
double OrderBlockHigh_mean = 0;

bool Op = True;
bool ImbalanceUp = False;
bool ImbalanceDown = False;

int HoraComienzo = 20;
int HoraFin = 8;
int MinutoFin = 0;
int SegundoFin = 0;
int HoraCierre = 11;
int pos = 1;
int PosicionLow = 0;
int PosicionHigh = 0;
double OrderLabelCompra = 0;
double OrderLabelVenta = 0;

bool ImbalanceArriba = False;
bool ImbalanceAbajo = False;

double cuenta=20000;
double risk = 5;


void OnTick(){
   double OrderBlockLow = 100000;
   double OrderBlockHigh = 0;
   
   if (Hour() == HoraFin && Minute() == MinutoFin && Seconds() == SegundoFin){
      
      for ( int i = 1; i <= OrderLimit; i++ ){
         if (Low[i] < Low[i-1] && Low[i] < OrderBlockLow){
            OrderBlockLow = Low[i];
            OrderBlockLow_arriba = High[i];
            OrderBlockLow_mean = NormalizeDouble(Low[i] + (High[i]-Low[i])*(1-OrderBlockFactor), Digits);
            PosicionLow = i;
            }
         if (High[i] > High[i-1] && High[i] > OrderBlockHigh){
            OrderBlockHigh = High[i];
            OrderBlockHigh_abajo = Low[i];
            OrderBlockHigh_mean = NormalizeDouble(Low[i] + (High[i]-Low[i])*OrderBlockFactor, Digits);
            PosicionHigh = i;
         }
      }
      
      ImbalanceArriba = ImbalanceCheckHigh(PosicionHigh);
      ImbalanceAbajo = ImbalanceCheckLow(PosicionLow);
      
      Print(PosicionHigh);
      Print(" ", ImbalanceArriba, " ", ImbalanceAbajo);
      
      
      //double stopLossCompra = NormalizeDouble(OrderBlockLow_mean-SL, Digits);
      //double takeProfitCompra = NormalizeDouble(OrderBlockLow_mean+TP, Digits);
      //double stopLossVenta = NormalizeDouble(OrderBlockHigh_mean+SL, Digits);
      //double takeProfitVenta = NormalizeDouble(OrderBlockHigh_mean-TP, Digits);      
       
      double stopLossCompra = NormalizeDouble(OrderBlockLow, Digits);
      double takeProfitCompra = NormalizeDouble(OrderBlockLow_arriba, Digits);
      double stopLossVenta = NormalizeDouble(OrderBlockHigh, Digits);
      double takeProfitVenta = NormalizeDouble(OrderBlockHigh_abajo, Digits);      
      
      //ObjectCreate(0,"HLINELow1",OBJ_HLINE,0,0,Low[PosicionLow],clrRed);
      //ObjectCreate(0,"HLINELow2",OBJ_HLINE,0,0,High[PosicionLow],clrRed);
      //ObjectCreate(0,"HLINEHigh1",OBJ_HLINE,0,0,High[PosicionHigh],clrBlue);
      //ObjectCreate(0,"HLINEHigh2",OBJ_HLINE,0,0,Low[PosicionHigh],clrBlue);
      
      //ObjectCreate(0,"VLINEini",OBJ_VLINE,0,0,0,clrBlue);
      //ObjectCreate(0,"VLINEfin",OBJ_VLINE,0,0,0,clrBlue);
      
      if (Op) {
        
        double volume = calculateLotSize(SL);
        
        OrderLabelCompra = OrderSend(NULL,OP_BUYLIMIT,volume,OrderBlockLow_mean,1,stopLossCompra,takeProfitCompra,"",Magic);
        OrderLabelVenta = OrderSend(NULL,OP_SELLLIMIT,volume,OrderBlockHigh_mean,1,stopLossVenta,takeProfitVenta,"",Magic);
      }
      Op = False;
   }   
   if (Hour() == HoraCierre){
      CerrarTodo();
      Op = True;
   }  
}
//+------------------------------------------------------------------+

/*
void Operar(HayImbalance, MechaLarga){
   if (Compra){
      if (HayImbalanceCompra){
         
      }else{
         if (MechaLargaCompra){
            
         }else{
            
         }
      }
   }else{
      if (HayImbalanceVenta){
      
      }else{
         if (MechaLargaVenta){
            
         }else{
            
         }
      }
}
*/

bool FiltroTemporal() {
   return Hour() >= HoraComienzo && Hour()<=HoraFin;
}

bool FiltroTemporalCortado() {
   if (Hour() < HoraFin || Hour() >= HoraComienzo){
      return True;
   } else {
      CerrarTodo();
      Print("CIERRO TODO");
      Op = True;
      return False;
   }
}

bool ImbalanceCheckHigh(int pos) {
   if (Low[pos] > High[pos-2] && Low[pos] > Low[pos-1] && !RellenaArriba() ){
      return True;
   }else{
      return False;
   }
}

bool ImbalanceCheckLow(int pos) {
   if (High[pos] < Low[pos-2] && High[pos] < High[pos-1] && !RellenaAbajo() ){
      return True;
   }else{
      return False;
   }
}

bool RellenaArriba(){
   int aux=0;
   bool auxbool=False;
   for ( int i = 1; i <= PosicionHigh; i++ ){
      if (High[i] > Low[PosicionHigh]){
         aux++;
      }
   }
   if (aux>0){
      auxbool=True;
   }else{
      auxbool=False;
   }
   return auxbool;
}

bool RellenaAbajo(){
   int aux=0;
   bool auxbool=False;
   for ( int i = 1; i <= PosicionLow; i++ ){
      if (Low[i] < High[PosicionLow]){
         aux++;
      }
   }
   if (aux>0){
      auxbool=True;
   }else{
      auxbool=False;
   }
   return auxbool;
}


double calculateLotSize(double SL) {
   double lotSize = MarketInfo(Symbol(), MODE_LOTSIZE);
   double volume = (cuenta * (risk / 100)) / (SL * lotSize);
   
   double maxLotSize = MarketInfo(Symbol(), MODE_MAXLOT);
   if (volume > maxLotSize) volume = maxLotSize;
   double minLotSize = MarketInfo(Symbol(), MODE_MINLOT);
   if (volume < minLotSize) volume = minLotSize;
   
   return volume/10;
}

void CerrarTodo(){
   for(int i=0;i<OrdersTotal();i++){
      if(OrderSelect(i,SELECT_BY_POS ,MODE_TRADES)){
         if(OrderSymbol()==Symbol() &&OrderMagicNumber()==Magic){
            if(OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT){
               OrderDelete(OrderTicket());
            }
         }
      
      }
   }
}