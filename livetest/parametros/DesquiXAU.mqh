#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

double combinaciones[6][7][6] = {
   // 03:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 8, 3, 0, 0, 0},
      {3, 11, 4, 0, 0, 0},
      {4, 7, 6, 0, 0, 0},
      {4, 5, 6, 0, 0, 0},
      {5, 10, 6, 0, 0, 0},
      {5, 5, 8, 0, 0, 0},
      {6, 6, 8, 0, 0, 0}
   },
   // 09:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 5, 3, 0, 0, 0},
      {3, 8, 4, 0, 0, 0},
      {5, 5, 6, 0, 0, 0},
      {5, 8, 6, 0, 0, 0},
      {4, 5, 6, 0, 0, 0},
      {4, 8, 8, 0, 0, 0},
      {6, 8, 8, 0, 0, 0}
   },
   // 10:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 8, 3, 0, 0, 0},
      {4, 8, 4, 0, 0, 0},
      {3, 16, 6, 0, 0, 0},
      {4, 16, 6, 0, 0, 0},
      {5, 8, 6, 0, 0, 0},
      {5, 16, 8, 0, 0, 0},
      {6, 8, 8, 0, 0, 0}
   },
   // 15:30
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {4, 6, 3, 0, 0, 0},
      {3, 5, 4, 0, 0, 0},
      {5, 8, 6, 0, 0, 0},
      {7, 8, 6, 0, 0, 0},
      {4, 12, 6, 0, 0, 0},
      {3, 10, 8, 0, 0, 0},
      {5, 8, 8, 0, 0, 0}
   },
   //16:30
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 3, 7, 0, 0, 0},
      {3, 7, 7, 0, 0, 0},
      {4, 3, 7, 0, 0, 0},
      {4, 7, 10, 0, 0, 0},
      {5, 3, 10, 0, 0, 0},
      {5, 7, 10, 0, 0, 0},
      {6, 6, 10, 0, 0, 0}
   },
   // 17:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 3, 7, 0, 0, 0},
      {3, 7, 7, 0, 0, 0},
      {4, 3, 7, 0, 0, 0},
      {4, 7, 10, 0, 0, 0},
      {5, 3, 10, 0, 0, 0},
      {5, 7, 10, 0, 0, 0},
      {6, 6, 10, 0, 0, 0}
   },

};