#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int combinaciones[6][6][6] = {
   // 03:00
   { // sl, tp, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 9, 2, 0, 0, 0},
      {3, 12, 2, 0, 0, 0},
      {4, 8, 2, 0, 0, 0},
      {4, 12, 2, 0, 0, 0},
      {5, 10, 2, 0, 0, 0},
      {5, 10, 3, 0, 0, 0}
   },
   // 09:00
   { // sl, tp, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 9, 2, 0, 0, 0},
      {3, 12, 2, 0, 0, 0},
      {4, 8, 2, 0, 0, 0},
      {4, 12, 2, 0, 0, 0},
      {5, 10, 2, 0, 0, 0},
      {5, 15, 2, 0, 0, 0}
   },
   // 10:00
   { // sl, tp, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      
      {3, 9, 3, 0, 0, 0},
      {3, 12, 3, 0, 0, 0},
      {4, 8, 2, 0, 0, 0},
      {4, 12, 3, 0, 0, 0},
      {5, 10, 3, 0, 0, 0},
      {5, 15, 3, 0, 0, 0}
   },
   // 15:30
   { // sl, tp, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 9, 3, 0, 0, 0},
      {3, 12, 4, 0, 0, 0},
      {4, 8, 3, 0, 0, 0},
      {4, 12, 4, 0, 0, 0},
      {5, 10, 4, 0, 0, 0},
      {5, 15, 4, 0, 0, 0}
   },
   //16:30
   { // sl, tp, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 9, 4, 0, 0, 0},
      {3, 12, 4, 0, 0, 0},
      {4, 8, 4, 0, 0, 0},
      {4, 12, 4, 0, 0, 0},
      {5, 10, 4, 0, 0, 0},
      {5, 15, 4, 0, 0, 0}
   },
   // 17:00
   { // sl, tp, minimoParaOperar, ticketBuy, ticketSell, ya se agrego al csv (o no)
      {3, 9, 4, 0, 0, 0},
      {3, 12, 4, 0, 0, 0},
      {4, 8, 4, 0, 0, 0},
      {4, 12, 4, 0, 0, 0},
      {5, 10, 4, 0, 0, 0},
      {5, 15, 4, 0, 0, 0}
   }

};