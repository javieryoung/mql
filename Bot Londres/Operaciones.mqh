

// Input de operaciones
input double porcentajeEntrada=0.25; //%EntradaEnLaVela
input double factorTP=100; //TP= factorTP*SL
input double entryAir=0;
input double slAir=0;

int Magic = 45699;
double dividirEntre=1;
double SL = 25/dividirEntre; // <--------------------- FALTA AJUSTAR
double cuenta=200000;
double risk=1;
double lotsize;
double minLotSize;
double maxLotSize;

void OperarSellSLfijo(int pos){
   //double volume = calculateLotSize(SL);
   double entry= NormalizeDouble(Low[pos]+porcentajeEntrada*(High[pos]-Low[pos]), Digits);
   double stopLoss= NormalizeDouble(entry + SL, Digits);
   double takeProfit = NormalizeDouble(entry - factorTP*SL, Digits);   
   int OrderLabelVenta = OrderSend(NULL,OP_SELLLIMIT, 1, entry, 1, stopLoss, takeProfit, "", Magic);
}

void OperarBuySLfijo(int pos){
   //double volume = calculateLotSize(SL);
   double entry= NormalizeDouble(High[pos]-porcentajeEntrada*(High[pos]-Low[pos]), Digits);
   double stopLoss= NormalizeDouble(entry - SL, Digits);
   double takeProfit = NormalizeDouble(entry + factorTP*SL, Digits);   
   int OrderLabelCompra = OrderSend(NULL,OP_BUYLIMIT, 1, entry, 1, stopLoss, takeProfit, "", Magic);
}

void OperarSellSLvariable(int pos){
   //double volume = calculateLotSize(SL);
   double entry= NormalizeDouble(Low[pos]+porcentajeEntrada*(High[pos]-Low[pos]), Digits);
   double stopLoss= NormalizeDouble(High[pos], Digits);
   double takeProfit = NormalizeDouble(entry - factorTP*SL, Digits);   
   int OrderLabelVenta = OrderSend(NULL,OP_SELLLIMIT, 1, entry, 1, stopLoss, takeProfit, "", Magic);
}

void OperarBuySLvariable(int pos){
   //double volume = calculateLotSize(SL);
   double entry= NormalizeDouble(High[pos]-porcentajeEntrada*(High[pos]-Low[pos]), Digits);
   double stopLoss= NormalizeDouble(Low[pos], Digits);
   double takeProfit = NormalizeDouble(entry + factorTP*SL, Digits);   
   int OrderLabelCompra = OrderSend(NULL,OP_BUYLIMIT, 1, entry, 1, stopLoss, takeProfit, "", Magic);
}


void CerrarTodo(){
   for(int i=OrdersTotal(); i!=-1; i--){
      if(OrderSelect(i,SELECT_BY_POS ,MODE_TRADES)){
         if(OrderSymbol()==Symbol()){
            if(OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT){
               OrderDelete(OrderTicket());
            }
         }
      }
   }
}

