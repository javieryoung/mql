#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int combinaciones[6][8][6] = {
   { // sl, tp, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {10, 30, 10, 0, 0, 0},
      {10, 30, 27, 0, 0, 0},
      {10, 20, 10, 0, 0, 0},
      {10, 20, 27, 0, 0, 0},
      {8, 24, 10, 0, 0, 0},
      {8, 24, 27, 0, 0, 0},
      {8, 16, 10, 0, 0, 0},
      {8, 16, 27, 0, 0, 0},
   },
   { // sl, tp, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {10, 30, 10, 0, 0, 0},
      {10, 30, 27, 0, 0, 0},
      {10, 20, 10, 0, 0, 0},
      {10, 20, 27, 0, 0, 0},
      {8, 24, 10, 0, 0, 0},
      {8, 24, 27, 0, 0, 0},
      {8, 16, 10, 0, 0, 0},
      {8, 16, 27, 0, 0, 0},
   }
};