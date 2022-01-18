#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int combinaciones[6][8][6] = {
   { // sl, tp, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 9, 3, 0, 0, 0},
      {3, 9, 5, 0, 0, 0},
      {3, 9, 3, 0, 0, 0},
      {3, 6, 5, 0, 0, 0},
      {2, 6, 3, 0, 0, 0},
      {2, 6, 5, 0, 0, 0},
      {2, 4, 3, 0, 0, 0},
      {2, 4, 5, 0, 0, 0},
   }
};