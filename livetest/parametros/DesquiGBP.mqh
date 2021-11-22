#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

double combinaciones[6][7][6] = {
   // 03:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {0.1, 15, 3, 0, 0, 0}, // NO USA
      {0.1, 13, 4, 0, 0, 0},
      {0.1, 15, 6, 0, 0, 0},
      {0.1, 15, 6, 0, 0, 0},
      {0.1, 6, 6, 0, 0, 0},
      {0.1, 20, 8, 0, 0, 0},
      {0.1, 15, 8, 0, 0, 0}
   },
   // 09:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 16, 3, 0, 0, 0},
      {3, 8, 4, 0, 0, 0},
      {4, 16, 6, 0, 0, 0},
      {4, 10, 6, 0, 0, 0},
      {5, 17, 6, 0, 0, 0},
      {5, 10, 8, 0, 0, 0},
      {6, 8, 8, 0, 0, 0}
   },
   // 10:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 11, 3, 0, 0, 0},
      {3, 20, 4, 0, 0, 0},
      {4, 11, 6, 0, 0, 0},
      {4, 20, 6, 0, 0, 0},
      {5, 9, 6, 0, 0, 0},
      {5, 15, 8, 0, 0, 0},
      {6, 9, 8, 0, 0, 0}
   },
   // 15:30
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 20, 3, 0, 0, 0},
      {3, 10, 4, 0, 0, 0},
      {4, 20, 6, 0, 0, 0},
      {4, 10, 6, 0, 0, 0},
      {5, 19, 6, 0, 0, 0},
      {5, 13, 8, 0, 0, 0},
      {6, 10, 8, 0, 0, 0}
   },
   //16:30
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 19, 3, 0, 0, 0},
      {3, 9, 4, 0, 0, 0},
      {4, 13, 6, 0, 0, 0},
      {4, 9, 6, 0, 0, 0},
      {5, 20, 6, 0, 0, 0},
      {5, 10, 8, 0, 0, 0},
      {6, 9, 8, 0, 0, 0}
   },
   // 17:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 18, 3, 0, 0, 0},
      {3, 10, 4, 0, 0, 0},
      {4, 16, 6, 0, 0, 0},
      {4, 12, 6, 0, 0, 0},
      {5, 13, 6, 0, 0, 0},
      {5, 9, 8, 0, 0, 0},
      {6, 10, 8, 0, 0, 0}
   }

};