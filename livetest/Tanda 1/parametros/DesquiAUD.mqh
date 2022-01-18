#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

double combinaciones[6][7][6] = {
   // 03:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {0.1, 19, 3, 0, 0, 0}, // NO USAR
      {0.1, 9, 4, 0, 0, 0},
      {0.1, 13, 6, 0, 0, 0},
      {0.1, 9, 6, 0, 0, 0},
      {0.1, 20, 6, 0, 0, 0},
      {0.1, 10, 8, 0, 0, 0},
      {0.1, 10, 8, 0, 0, 0}
   },
   // 09:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 6, 3, 0, 0, 0},
      {3, 14, 4, 0, 0, 0},
      {4, 15, 6, 0, 0, 0},
      {4, 4, 6, 0, 0, 0},
      {5, 14, 6, 0, 0, 0},
      {5, 21, 8, 0, 0, 0},
      {6, 6, 8, 0, 0, 0}
   },
   // 10:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 6, 3, 0, 0, 0},
      {3, 16, 4, 0, 0, 0},
      {4, 6, 6, 0, 0, 0},
      {4, 17, 6, 0, 0, 0},
      {5, 10, 6, 0, 0, 0},
      {5, 19, 8, 0, 0, 0},
      {6, 6, 8, 0, 0, 0}
   },
   // 15:30
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 19, 3, 0, 0, 0},
      {3, 7, 4, 0, 0, 0},
      {4, 11, 6, 0, 0, 0},
      {4, 24, 6, 0, 0, 0},
      {5, 12, 6, 0, 0, 0},
      {5, 23, 8, 0, 0, 0},
      {6, 12, 8, 0, 0, 0}
   },
   //16:30
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 8, 3, 0, 0, 0},
      {5, 18, 4, 0, 0, 0},
      {4, 8, 6, 0, 0, 0},
      {5, 26, 6, 0, 0, 0},
      {6, 14, 6, 0, 0, 0},
      {5, 12, 8, 0, 0, 0},
      {6, 8, 8, 0, 0, 0}
   },
   // 17:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 13, 7, 0, 0, 0},
      {3, 6, 7, 0, 0, 0},
      {4, 14, 8, 0, 0, 0},
      {4, 18, 10, 0, 0, 0},
      {5, 12, 10, 0, 0, 0},
      {5, 30, 10, 0, 0, 0},
      {6, 12, 10, 0, 0, 0}
   }

};