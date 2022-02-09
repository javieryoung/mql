#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int combinaciones[14][3][6] = {
   { // sl, tp, minimoParaOperar, ticketBuy, ticketSell, partial sell (0 nada, 1 vendio a 1:1, 2 vendio a 1:2)
      {5, 15, 8, 0, 0, 0}
   },
   {
      {5, 15, 6, 0, 0, 0}
   },
   {
      {5, 15, 5, 0, 0, 0}
   },
   { {5, 15, 5, 0, 0, 0} }, { {5, 15, 5, 0, 0, 0} },{ {5, 15, 5, 0, 0, 0} },{ {5, 15, 5, 0, 0, 0} },
   {
      {5, 15, 3, 0, 0, 0}
   },
   { {5, 15, 3, 0, 0, 0} },{ {5, 15, 3, 0, 0, 0} },{ {5, 15, 3, 0, 0, 0} },
   {
      {5, 10, 3, 0, 0, 0}
   },{ {5, 10, 3, 0, 0, 0} }, { {5, 10, 3, 0, 0, 0} }
};