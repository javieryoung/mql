#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

double combinaciones[6][6][6] = {
   // 03:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {4, 12, 6, 0, 0, 0},
      {4, 10, 6, 0, 0, 0},
      {5, 12, 6, 0, 0, 0},
      {5, 10, 6, 0, 0, 0},
      {6, 12, 6, 0, 0, 0},
      {6, 10, 6, 0, 0, 0}
   },
   // 09:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {4, 12, 5, 0, 0, 0},
      {4, 10, 5, 0, 0, 0},
      {5, 12, 5, 0, 0, 0},
      {5, 10, 5, 0, 0, 0},
      {6, 12, 5, 0, 0, 0},
      {6, 10, 5, 0, 0, 0}
   },
   // 10:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {4, 12, 6, 0, 0, 0},
      {4, 10, 6, 0, 0, 0},
      {5, 12, 6, 0, 0, 0},
      {5, 10, 6, 0, 0, 0},
      {6, 12, 6, 0, 0, 0},
      {6, 10, 6, 0, 0, 0}
   },
   // 15:30
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {4, 12, 3, 0, 0, 0},
      {4, 10, 3, 0, 0, 0},
      {5, 12, 3, 0, 0, 0},
      {5, 10, 3, 0, 0, 0},
      {6, 12, 3, 0, 0, 0},
      {6, 10, 3, 0, 0, 0}
   },
   //16:30
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {4, 12, 6, 0, 0, 0},
      {4, 10, 6, 0, 0, 0},
      {5, 12, 6, 0, 0, 0},
      {5, 10, 6, 0, 0, 0},
      {6, 12, 6, 0, 0, 0},
      {6, 10, 6, 0, 0, 0}
   },
   // 17:00
   { // sl, trailing, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {4, 12, 6, 0, 0, 0},
      {4, 10, 6, 0, 0, 0},
      {5, 12, 6, 0, 0, 0},
      {5, 10, 6, 0, 0, 0},
      {6, 12, 6, 0, 0, 0},
      {6, 10, 6, 0, 0, 0}
   }

};