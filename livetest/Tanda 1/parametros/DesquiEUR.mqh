#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

double combinaciones[6][7][6] = {
   // 03:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {0.1, 15, 3, 0, 0, 0}, // no operar
      {0.1, 13, 4, 0, 0, 0},
      {0.1, 15, 6, 0, 0, 0},
      {0.1, 15, 6, 0, 0, 0},
      {0.1, 6, 6, 0, 0, 0},
      {0.1, 20, 8, 0, 0, 0},
      {0.1, 15, 8, 0, 0, 0}
   },
   // 09:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 12, 3, 0, 0, 0},
      {9, 9, 4, 0, 0, 0},
      {7, 9, 6, 0, 0, 0},
      {4, 12, 6, 0, 0, 0},
      {8, 8, 6, 0, 0, 0},
      {3, 6, 8, 0, 0, 0},
      {3, 15, 8, 0, 0, 0}
   },
   // 10:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 7, 3, 0, 0, 0},
      {3, 19, 4, 0, 0, 0},
      {4, 20, 6, 0, 0, 0},
      {4, 8, 6, 0, 0, 0},
      {3, 5, 6, 0, 0, 0},
      {5, 10, 8, 0, 0, 0},
      {4, 12, 8, 0, 0, 0}
   },
   // 15:30
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 10, 3, 0, 0, 0},
      {3, 3, 4, 0, 0, 0},
      {4, 13, 6, 0, 0, 0},
      {5, 13, 6, 0, 0, 0},
      {3, 15, 6, 0, 0, 0},
      {6, 9, 8, 0, 0, 0},
      {4, 9, 8, 0, 0, 0}
   },
   //16:30
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 7, 7, 0, 0, 0},
      {5, 7, 7, 0, 0, 0},
      {8, 18, 7, 0, 0, 0},
      {5, 16, 10, 0, 0, 0},
      {6, 7, 10, 0, 0, 0},
      {6, 20, 10, 0, 0, 0},
      {7, 15, 10, 0, 0, 0}
   },
   // 17:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 20, 7, 0, 0, 0},
      {3, 11, 7, 0, 0, 0},
      {5, 18, 8, 0, 0, 0},
      {6, 18, 10, 0, 0, 0},
      {4, 13, 10, 0, 0, 0},
      {7, 18, 10, 0, 0, 0},
      {6, 15, 10, 0, 0, 0}
   }

};