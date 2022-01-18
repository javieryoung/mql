#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

double combinaciones[6][7][6] = {
   // 03:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 7, 3, 0, 0, 0},
      {3, 10, 4, 0, 0, 0},
      {4, 7, 6, 0, 0, 0},
      {4, 10, 6, 0, 0, 0},
      {5, 7, 6, 0, 0, 0},
      {5, 10, 8, 0, 0, 0},
      {6, 5, 8, 0, 0, 0}
   },
   // 09:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 7, 3, 0, 0, 0},
      {3, 11, 4, 0, 0, 0},
      {4, 7, 6, 0, 0, 0},
      {4, 11, 6, 0, 0, 0},
      {5, 7, 6, 0, 0, 0},
      {5, 11, 8, 0, 0, 0},
      {6, 7, 8, 0, 0, 0}
   },
   // 10:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 8, 3, 0, 0, 0},
      {3, 11, 4, 0, 0, 0},
      {4, 8, 6, 0, 0, 0},
      {4, 11, 6, 0, 0, 0},
      {5, 8, 6, 0, 0, 0},
      {5, 11, 8, 0, 0, 0},
      {6, 8, 8, 0, 0, 0}
   },
   // 15:30
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 8, 3, 0, 0, 0},
      {3, 11, 4, 0, 0, 0},
      {4, 8, 6, 0, 0, 0},
      {4, 11, 6, 0, 0, 0},
      {5, 8, 6, 0, 0, 0},
      {5, 11, 8, 0, 0, 0},
      {6, 8, 8, 0, 0, 0}
   },
   //16:30
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 10, 7, 0, 0, 0},
      {3, 12, 7, 0, 0, 0},
      {4, 10, 7, 0, 0, 0},
      {4, 8, 10, 0, 0, 0},
      {5, 10, 10, 0, 0, 0},
      {5, 8, 10, 0, 0, 0},
      {6, 8, 10, 0, 0, 0}
   },
   // 17:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 10, 7, 0, 0, 0},
      {3, 12, 7, 0, 0, 0},
      {4, 11, 8, 0, 0, 0},
      {4, 13, 10, 0, 0, 0},
      {5, 10, 10, 0, 0, 0},
      {5, 15, 10, 0, 0, 0},
      {6, 12, 10, 0, 0, 0}
   }

};