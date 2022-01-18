#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

double combinaciones[6][7][6] = {
   // 03:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {4, 20, 3, 0, 0, 0},
      {6, 8, 4, 0, 0, 0},
      {5, 20, 6, 0, 0, 0},
      {7, 9, 6, 0, 0, 0},
      {9, 8, 6, 0, 0, 0},
      {11, 8, 8, 0, 0, 0},
      {8, 8, 8, 0, 0, 0}
   },
   // 09:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 7, 3, 0, 0, 0},
      {5, 9, 4, 0, 0, 0},
      {8, 9, 6, 0, 0, 0},
      {6, 10, 6, 0, 0, 0},
      {4, 9, 6, 0, 0, 0},
      {10, 8, 8, 0, 0, 0},
      {7, 8, 8, 0, 0, 0}
   },
   // 10:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 9, 3, 0, 0, 0},
      {3, 14, 4, 0, 0, 0},
      {4, 8, 6, 0, 0, 0},
      {7, 10, 6, 0, 0, 0},
      {3, 4, 6, 0, 0, 0},
      {5, 11, 8, 0, 0, 0},
      {6, 9, 8, 0, 0, 0}
   },
   // 15:30
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 19, 3, 0, 0, 0},
      {3, 12, 4, 0, 0, 0},
      {4, 20, 6, 0, 0, 0},
      {4, 13, 6, 0, 0, 0},
      {5, 14, 6, 0, 0, 0},
      {7, 20, 8, 0, 0, 0},
      {6, 19, 8, 0, 0, 0}
   },
   //16:30
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {5, 10, 7, 0, 0, 0},
      {4, 20, 7, 0, 0, 0},
      {3, 10, 7, 0, 0, 0},
      {3, 19, 10, 0, 0, 0},
      {5, 20, 10, 0, 0, 0},
      {5, 15, 10, 0, 0, 0},
      {6, 15, 10, 0, 0, 0}
   },
   // 17:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 15, 7, 0, 0, 0},
      {5, 15, 7, 0, 0, 0},
      {6, 20, 8, 0, 0, 0},
      {3, 4, 10, 0, 0, 0},
      {8, 15, 10, 0, 0, 0},
      {4, 4, 10, 0, 0, 0},
      {7, 16, 10, 0, 0, 0}
   }

};