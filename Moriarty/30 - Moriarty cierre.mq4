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

input int cantidadDeTicksAEsperar = 1; // cantidad de ticks a esperar para cerrar operaciones


int OnInit() {
   return(INIT_SUCCEEDED);
   
}
  
  
void OnDeinit(const int reason) {

}
  
int ticksEsperados = 0;
void OnTick() {
   ticksEsperados++;
   if (ticksEsperados >= cantidadDeTicksAEsperar)
      cerrarTodo();
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