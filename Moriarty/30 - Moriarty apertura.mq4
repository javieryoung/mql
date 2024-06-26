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

input int cantidadDeOperaciones = 10; // cantidad de operaciones a abrir en cada direccion
input double distancia = 9; // distancia en pips de las operaciones pendientes
input bool minimoLotaje = true; // ¿usar minimo lotaje?
input double lotaje = 0; // si no se usa minimo lotaje, cuanto?
input double pipValue = 1; // valor de un pip
input double sl = 3;
input double tickValue = 0.01;


bool abri = false;

int OnInit() {

   return(INIT_SUCCEEDED);
   
}
  
  
void OnDeinit(const int reason) {
   
}
  
void OnTick() {
   if (!abri) abrirPending();  
   ajustarStops();
}


void abrirPending() {
   abri = true;
   double compra = Ask + distancia * pipValue;
   double venta = Bid - distancia * pipValue;
   double volume;
   if (minimoLotaje)
      volume = MarketInfo(Symbol(), MODE_MINLOT);
   else
      volume = lotaje;
   
   double slCompra = NormalizeDouble(compra - sl * tickValue, Digits);
   double slVenta = NormalizeDouble(venta + sl * tickValue, Digits);
   for (int i = 0; i < cantidadDeOperaciones; i++) {
      OrderSend(Symbol(), OP_BUYSTOP, volume, compra, 0.1, slCompra, 0, "", Magic);
      OrderSend(Symbol(), OP_SELLSTOP, volume, venta, 0.1, slVenta, 0, "", Magic);
   }
}

void ajustarStops() {
   
   double compra = Ask + distancia * pipValue;
   double venta = Bid - distancia * pipValue;
   
   double slCompra = compra - sl * tickValue;
   double slVenta = venta + sl * tickValue;
   
   for(int i = OrdersTotal(); i >= 0; i--){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
            
            if (OrderType() == OP_BUYSTOP) {
               OrderModify(OrderTicket(),compra,slCompra,0,0);
            }   
            
            if (OrderType() == OP_SELLSTOP) {
               OrderModify(OrderTicket(),venta,slVenta,0,0);
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