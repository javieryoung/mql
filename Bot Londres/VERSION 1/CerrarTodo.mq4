//+------------------------------------------------------------------+
//|                                                   CerrarTodo.mq4 |
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

int Magic = 222;

input int HoraFin = 11;


void OnTick(){
   if(Hour()==HoraFin)
      CerrarTodo();
}

void CerrarTodo(){
   for(int i=OrdersTotal(); i!=-1; i--){
      if(OrderSelect(i,SELECT_BY_POS ,MODE_TRADES)){
         if(OrderSymbol()==Symbol()){
            if(OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT){
               OrderDelete(OrderTicket());
            }
         }
      }
   }
}