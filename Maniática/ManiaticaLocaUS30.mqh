#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int combinaciones[14][3][6] = {
   { // sl, tp, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {5, 15, 8, 0, 0, 0},
      {5, 15, 9, 0, 0, 0},
      {5, 15, 10, 0, 0, 0}
   },
   {
      {5, 15, 6, 0, 0, 0},
      {5, 15, 7, 0, 0, 0},
      {5, 15, 8, 0, 0, 0}
   },
   {
      {5, 10, 5, 0, 0, 0},
      {5, 15, 5, 0, 0, 0},
      {5, 15, 6, 0, 0, 0}
   },
   { {5, 10, 5, 0, 0, 0}, {5, 15, 5, 0, 0, 0}, {5, 15, 6, 0, 0, 0} },{ {5, 10, 5, 0, 0, 0}, {5, 15, 5, 0, 0, 0}, {5, 15, 6, 0, 0, 0} },{ {5, 10, 5, 0, 0, 0}, {5, 15, 5, 0, 0, 0}, {5, 15, 6, 0, 0, 0} },{ {5, 10, 5, 0, 0, 0}, {5, 15, 5, 0, 0, 0}, {5, 15, 6, 0, 0, 0} },
   {
      {5, 10, 3, 0, 0, 0},
      {5, 10, 4, 0, 0, 0},
      {5, 10, 5, 0, 0, 0}
   },
   { {5, 10, 3, 0, 0, 0}, {5, 10, 4, 0, 0, 0}, {5, 10, 5, 0, 0, 0} },{ {5, 10, 3, 0, 0, 0}, {5, 10, 4, 0, 0, 0}, {5, 10, 5, 0, 0, 0} },{ {5, 10, 3, 0, 0, 0}, {5, 10, 4, 0, 0, 0}, {5, 10, 5, 0, 0, 0} },
   {
      {5, 10, 3, 0, 0, 0},
      {5, 10, 4, 0, 0, 0},
      {5, 10, 5, 0, 0, 0}
   },{ {5, 10, 3, 0, 0, 0}, {5, 10, 4, 0, 0, 0}, {5, 10, 5, 0, 0, 0} },{ {5, 10, 3, 0, 0, 0}, {5, 10, 4, 0, 0, 0}, {5, 10, 5, 0, 0, 0} }
};