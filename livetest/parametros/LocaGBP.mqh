#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

double combinaciones[6][6][6] = {
   // 03:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {4, 10, 2, 0, 0, 0},
      {4, 12, 2, 0, 0, 0},
      {5, 10, 2, 0, 0, 0},
      {5, 12, 2, 0, 0, 0},
      {6, 10, 2, 0, 0, 0},
      {6, 12, 2, 0, 0, 0}
   },
   // 09:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {4, 10, 2, 0, 0, 0},
      {4, 12, 2, 0, 0, 0},
      {5, 10, 2, 0, 0, 0},
      {5, 12, 2, 0, 0, 0},
      {6, 10, 2, 0, 0, 0},
      {6, 12, 2, 0, 0, 0}
   },
   // 10:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {4, 10, 6, 0, 0, 0},
      {4, 12, 6, 0, 0, 0},
      {5, 10, 6, 0, 0, 0},
      {5, 12, 6, 0, 0, 0},
      {6, 10, 6, 0, 0, 0},
      {6, 12, 6, 0, 0, 0}
   },
   // 15:30
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {4, 10, 10, 0, 0, 0},
      {4, 12, 10, 0, 0, 0},
      {5, 10, 10, 0, 0, 0},
      {5, 12, 10, 0, 0, 0},
      {6, 10, 10, 0, 0, 0},
      {6, 12, 10, 0, 0, 0}
   },
   //16:30
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {4, 10, 8, 0, 0, 0},
      {4, 12, 8, 0, 0, 0},
      {5, 10, 8, 0, 0, 0},
      {5, 12, 8, 0, 0, 0},
      {6, 10, 8, 0, 0, 0},
      {6, 12, 8, 0, 0, 0}
   },
   // 17:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {4, 10, 10, 0, 0, 0},
      {4, 12, 10, 0, 0, 0},
      {5, 10, 10, 0, 0, 0},
      {5, 12, 10, 0, 0, 0},
      {6, 10, 10, 0, 0, 0},
      {6, 12, 10, 0, 0, 0}
   }

};