//+------------------------------------------------------------------+
//|                                                       Prueba.mq4 |
//|                                         Matías Fernández Lakatos |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Matías Fernández Lakatos"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

// Dudas y cosas pendientes:
// if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
// (iATR(NULL,0,23)*SL ) 
// Symbol() par de divisas del chart en donde fue tirado el Expert

int Magic = 1;
double SL = 3.0;
double TP = 9.0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

/*
Comentar
*/


int OnInit()
  {
//---
   Print("Acá es al cargarlo");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Print("Acá es cuando sacas el Expert");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  
   /*Print("Cada vez que se mueve un tick entra en esta función");
   High(#) -> vela actual 0, anterior 1, anterior de la anterior 2
   iHigh -> Alto de la temporalidad, máximo de la temporalidad
   (NULL -> 
   , PERIOD_D1 -> Temporalidad, D->día , tomás un día
   ,0) -> Desde qué vela empezas a contar
   */
   //Una operación a la vez
    if(OperacionesAbiertas()==0   ) //Control de operaciones, sólo una en este caso.
      {
         if(/*Comprar()==*/true/*&&FiltroCompra()==true*/)
         {
         // OrderSend(símbolo,operación(buy/sell), volumen,precio de compra(Ask/Bid), slippeage, SL,TP: -(iATR(NULL,0,23)*SL ) para comprar y eso. Opción NULL aplica a cualquier divisa y eso
            // Close[0] precio de cierre de la vela actual, precio actual?
            // 
            OrderSend(NULL,OP_BUY,1.0,Ask,1,Close[1]-SL,Close[1]+TP,"Comentarios al hacer la oepración",Magic);
         }
         else
         {
            Print("qcyo");
         }
      }
      else
      {
      // Acá hay operaciones abiertas
         if(Hour()>=18&&Minute()>=32)
            CerrarTodo();
      }
  }
//+------------------------------------------------------------------+

bool Comprar()
   {
      if(High[1]>= iHigh(NULL, PERIOD_M1,0) && Low[1]==3 )
      {
         return true; //Si voy a comprar
      }
      else 
         return false;
   }
   
bool FiltroCompra()
{
if(Minute()==0 || Hour()==8)
{return true;}
else
return false;
}

int OperacionesAbiertas()
{
   int NumOrdenes=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
      // OrderSelect
      // SELECT_BY_POS
      // MODE_TRADES
      
      {
         //if(OrderType()==OP_BUY&&OrderMagicNumber()==Magic)
         if(OrderSymbol()==Symbol()&&OrderMagicNumber()==Magic)
         {
         NumOrdenes++;
         break;
         }
      }
   }
   return NumOrdenes;
}

void CerrarTodo()
 {
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS ,MODE_TRADES)==true)
      {
         // OrderSymbol() -> corresponde al símbolo actual
         // Symbol() par de divisas del chart en donde fue tirado el Expert
         if(OrderSymbol()==Symbol()&&OrderMagicNumber()==Magic)
         {
            if(OrderType()==OP_BUY)
            {
               OrderClose(OrderTicket(),OrderLots(),Bid,1 );
            }
            else
            if(OrderType()==OP_SELL)
            {
               OrderClose(OrderTicket(),OrderLots(),Ask,1 );
            }
         }
      }
      
   }
 }