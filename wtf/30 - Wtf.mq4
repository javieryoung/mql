//+------------------------------------------------------------------+
//|                                                     30 - Wtf.mq4 |
//|                                                     Javier Young |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Javier Young"
#property link      ""
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

input int Magic = 30;

input int cantidadDeOperaciones = 10;
input double distancia = 9;
input int horaApertura = 1;
input int minutoApertura = 58;

input int horaCierre = 2;
input int minutoCierre = 30;

bool abri = false;

int OnInit() {

   return(INIT_SUCCEEDED);
   
}
  
  
void OnDeinit(const int reason) {
   
}
  
void OnTick() {
   if (
      Hour() == horaApertura && 
      Minute() == minutoApertura
   ) {
      if (!abri) abrirPending();  
   }
   
   if (
      Hour() > horaCierre ||
      (Hour() == horaCierre && Minute() >= minutoCierre)
   ) {
      cerrarTodo();
   } else {
      ajustarStops();
   }
}


void abrirPending() {
   abri = true;
   double compra = Ask + distancia;
   double venta = Bid - distancia;
   double volume = MarketInfo(Symbol(), MODE_MINLOT);
   for (int i = 0; i < cantidadDeOperaciones; i++) {
      OrderSend(Symbol(), OP_BUYSTOP, volume, compra, 0.1, 0, 0, "", Magic);
      OrderSend(Symbol(), OP_SELLSTOP, volume, venta, 0.1, 0, 0, "", Magic);
   }
}

void ajustarStops() {
   
   double compra = Ask + distancia;
   double venta = Bid - distancia;
   
   for(int i = OrdersTotal(); i >= 0; i--){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
            
            if (OrderType() == OP_BUYSTOP) {
               OrderModify(OrderTicket(),compra,0,0,0);
            }   
            
            if (OrderType() == OP_SELLSTOP) {
               OrderModify(OrderTicket(),venta,0,0,0);
            }   
            
         }
      }
   }
}



void cerrarTodo() {
   
   for(int i = OrdersTotal(); i >= 0; i--){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
            
            if (OrderType() == OP_BUYSTOP) {
               OrderDelete(OrderTicket());
            }   
            
            if (OrderType() == OP_SELLSTOP) {
               OrderDelete(OrderTicket());
            }   
            
            if (OrderType() == OP_BUY) {
               OrderClose(OrderTicket(),OrderLots(),Bid,0.1);
            }   
            
            if (OrderType() == OP_SELL) {
               OrderClose(OrderTicket(),OrderLots(),Ask,0.1);
            }   
            
         }
      }
   }
}