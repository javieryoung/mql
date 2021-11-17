#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

double combinaciones[6][7][6] = {
   // 03:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {5, 15, 3, 0, 0, 0},
      {5, 13, 4, 0, 0, 0},
      {3, 15, 6, 0, 0, 0},
      {4, 15, 6, 0, 0, 0},
      {3, 6, 6, 0, 0, 0},
      {3, 20, 8, 0, 0, 0},
      {5, 15, 8, 0, 0, 0}
   },
   // 09:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {5, 15, 3, 0, 0, 0},
      {5, 13, 4, 0, 0, 0},
      {3, 15, 6, 0, 0, 0},
      {4, 15, 6, 0, 0, 0},
      {3, 6, 6, 0, 0, 0},
      {3, 20, 8, 0, 0, 0},
      {5, 15, 8, 0, 0, 0}
   },
   // 10:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {5, 15, 3, 0, 0, 0},
      {5, 13, 4, 0, 0, 0},
      {3, 15, 6, 0, 0, 0},
      {4, 15, 6, 0, 0, 0},
      {3, 6, 6, 0, 0, 0},
      {3, 20, 8, 0, 0, 0},
      {5, 15, 8, 0, 0, 0}
   },
   // 15:30
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {5, 15, 3, 0, 0, 0},
      {5, 13, 4, 0, 0, 0},
      {4, 15, 6, 0, 0, 0},
      {3, 15, 6, 0, 0, 0},
      {3, 6, 6, 0, 0, 0},
      {3, 20, 8, 0, 0, 0},
      {5, 15, 8, 0, 0, 0}
   },
   //16:30
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {4, 8, 7, 0, 0, 0},
      {3, 7, 7, 0, 0, 0},
      {5, 8, 7, 0, 0, 0},
      {3, 10, 10, 0, 0, 0},
      {4, 10, 10, 0, 0, 0},
      {3, 10, 10, 0, 0, 0},
      {5, 12, 10, 0, 0, 0}
   },
   // 17:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 10, 7, 0, 0, 0},
      {6, 10, 7, 0, 0, 0},
      {5, 11, 8, 0, 0, 0},
      {3, 16, 10, 0, 0, 0},
      {4, 16, 10, 0, 0, 0},
      {4, 10, 10, 0, 0, 0},
      {5, 10, 10, 0, 0, 0}
   }
};