#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

double combinaciones[6][6][6] = {
   // 03:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {5, 15, 1, 0, 0, 0},
      {5, 13, 1, 0, 0, 0},
      {3, 15, 1, 0, 0, 0},
      {4, 15, 1, 0, 0, 0},
      {3, 6, 1, 0, 0, 0},
      {3, 20, 1, 0, 0, 0},
   },
   // 09:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 5, 1.5, 0, 0, 0},
      {3, 7, 1.5, 0, 0, 0},
      {4, 8, 1.5, 0, 0, 0},
      {4, 10, 1.5, 0, 0, 0},
      {5, 5, 1.5, 0, 0, 0},
      {5, 7, 1.5, 0, 0, 0}
   },
   // 10:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {5, 15, 2, 0, 0, 0},
      {5, 13, 2, 0, 0, 0},
      {3, 15, 2, 0, 0, 0},
      {4, 15, 2, 0, 0, 0},
      {3, 6, 2, 0, 0, 0},
      {3, 20, 2, 0, 0, 0}
   },
   // 15:30
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {4, 11, 3, 0, 0, 0},
      {4, 9, 3, 0, 0, 0},
      {5, 11, 3, 0, 0, 0},
      {5, 9, 3, 0, 0, 0},
      {6, 11, 3, 0, 0, 0},
      {6, 9, 3, 0, 0, 0}
   },
   //16:30
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {4, 11, 3, 0, 0, 0},
      {4, 9, 3, 0, 0, 0},
      {5, 11, 3, 0, 0, 0},
      {5, 9, 3, 0, 0, 0},
      {6, 11, 3, 0, 0, 0},
      {6, 9, 3, 0, 0, 0}
   },
   // 17:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {4, 7, 3, 0, 0, 0},
      {4, 9, 3, 0, 0, 0},
      {5, 7, 3, 0, 0, 0},
      {5, 9, 3, 0, 0, 0},
      {6, 7, 3, 0, 0, 0},
      {6, 9, 3, 0, 0, 0}
   }

};