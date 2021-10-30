//+------------------------------------------------------------------+
//|                                                         US30.mq4 |
//|                                                     Javier Young |
//|                                                 https://young.uy |
//+------------------------------------------------------------------+
#property copyright "Javier Young"
#property link      "https://young.uy"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

double SL = 3.0;
double TP = 9.0;
int Magic = 1;

int OnInit()
  {
//---
   Print("Se cargó el Expert a la gráfica...");
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Print("Se eliminó el Expert a la gráfica...");
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if (opreacionesAbiertas() == 0) {
      if (comprar() && filtro()) {
         OrderSend(NULL, OP_BUY, 1.0, Ask, 1, Close[1]-(iATR(NULL,0,23,1)*SL), Close[1]+(iATR(NULL,0,23,1)*TP), "Comprita", Magic);
      }
   } else {
      if (Hour() >= 12) {
         cerrarTodo();
      }
   }
   
  }
//+------------------------------------------------------------------+



bool comprar() {
   return High[1] >= iHigh(NULL, PERIOD_D1, 0);
}


bool filtro() {
   return Hour() == 8;
}

int opreacionesAbiertas() {
   int ordenes = 0;
   for(int i = 0; i < OrdersTotal(); i++){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
            ordenes++;
            break;
         }
      }
   }
   return ordenes;
}

void cerrarTodo() {
   for(int i = 0; i < OrdersTotal(); i++){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
            if (OrderType() == OP_BUY){
               OrderClose(OrderTicket(), OrderLots(), Bid, 1);
            }
            if (OrderType() == OP_SELL){
               OrderClose(OrderTicket(), OrderLots(), Ask, 1);
            }
         }
      }
   }

}