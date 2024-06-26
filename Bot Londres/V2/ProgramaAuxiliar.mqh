
// Input de operaciones




double lotsize;
double minLotSize;
double maxLotSize;

double volume=1/2.5;

void OperarFueraDeAsiaSell(int pos){
   if(pos > CalcularNvelas(8) || pos <=  CalcularNvelas(1)){
      seleccionEntradaSell(pos);
   }
}

void OperarFueraDeAsiaBuy(int pos){
   if(pos > CalcularNvelas(8) || pos <=  CalcularNvelas(1)){
      seleccionEntradaBuy(pos);
   }
}

void OperarEnAsiaSell(int pos){
   if(pos <= CalcularNvelas(8) && pos >  CalcularNvelas(1)){
      seleccionEntradaSell(pos);
   }
}

void OperarEnAsiaBuy(int pos){
   if(pos <= CalcularNvelas(8) && pos >  CalcularNvelas(1)){
      seleccionEntradaBuy(pos);
   }
}

double sl() {
   return (SL + slAir) / dividirEntre;
}

double tp() {
   return factorTP*sl();
}


void seleccionEntradaSell(int pos){
   double entry;
   double stopLoss;
   double takeProfit;
   int OrderLabelVenta;
   int OrderLabelVentaSt;
   
   if(MathAbs(Open[pos]-Close[pos]) >= tamanoCuerpoMax && High[pos] - MathMax(Open[pos], Close[pos]) >= tamanoMechaMax){
      Print("VENTA: Cuerpo grande, mecha grande");
      entry= NormalizeDouble( (High[pos] + MathMax(Open[pos], Close[pos]))/2, Digits);
      stopLoss= NormalizeDouble(entry + sl(), Digits);
      takeProfit = NormalizeDouble(entry - tp(), Digits);   
      OrderLabelVenta = OrderSend(NULL,OP_SELLLIMIT, volume, entry, 1, stopLoss, takeProfit, "", Magic);
      if (stopsEnabled) OrderLabelVentaSt = OrderSend(NULL,OP_SELLSTOP, volume, entry, 1, stopLoss, takeProfit, "", Magic);
   }else{
      if(High[pos]-Low[pos] <= tamanoVelaMax/2){ // vela <= 25 pips?
         Print("VENTA: Vela menor a 25 pips");
         entry= NormalizeDouble(Low[pos], Digits);
         stopLoss= NormalizeDouble(entry + sl(), Digits);
         takeProfit = NormalizeDouble(entry - tp(), Digits);   
         OrderLabelVenta = OrderSend(NULL,OP_SELLLIMIT, volume, entry, 1, stopLoss, takeProfit, "", Magic);
         if (stopsEnabled) OrderLabelVentaSt = OrderSend(NULL,OP_SELLSTOP, volume, entry, 1, stopLoss, takeProfit, "", Magic);
      } else {
         if(High[pos] - MathMax(Close[pos], Open[pos]) <= MathAbs(Close[pos] - Open[pos])){  // mecha <= cuerpo?
            if (High[pos]-Low[pos] >= tamanoVelaMax){
               Print("VENTA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño mayor a 50 pips");
               entry= NormalizeDouble((High[pos]+Low[pos])/2, Digits);
               stopLoss= NormalizeDouble(entry + sl(), Digits);
               takeProfit = NormalizeDouble(entry - tp(), Digits);   
               OrderLabelVenta = OrderSend(NULL,OP_SELLLIMIT, volume, entry, 1, stopLoss, takeProfit, "", Magic);
               if (stopsEnabled) OrderLabelVentaSt = OrderSend(NULL,OP_SELLSTOP, volume, entry, 1, stopLoss, takeProfit, "", Magic);
            } else {
               Print("VENTA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño menor a 50 pips");
               entry= NormalizeDouble(High[pos]-sl(), Digits);
               stopLoss= NormalizeDouble(entry + sl(), Digits);
               takeProfit = NormalizeDouble(entry - tp(), Digits);   
               OrderLabelVenta = OrderSend(NULL,OP_SELLLIMIT, volume, entry, 1, stopLoss, takeProfit, "", Magic);
               if (stopsEnabled) OrderLabelVentaSt = OrderSend(NULL,OP_SELLSTOP, volume, entry, 1, stopLoss, takeProfit, "", Magic);
            }
         } else{
            if (High[pos] - MathMax(Close[pos], Open[pos]) >= tamanoVelaMax){  // mecha >= tamanoVelaMax
               Print("VENTA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño mayor a 50 pips");
               entry= NormalizeDouble((High[pos] + MathMax(Close[pos], Open[pos]) )/2, Digits);
               stopLoss= NormalizeDouble(entry + sl(), Digits);
               takeProfit = NormalizeDouble(entry - tp(), Digits);   
               OrderLabelVenta = OrderSend(NULL,OP_SELLLIMIT, volume, entry, 1, stopLoss, takeProfit, "", Magic);
               if (stopsEnabled) OrderLabelVentaSt = OrderSend(NULL,OP_SELLSTOP, volume, entry, 1, stopLoss, takeProfit, "", Magic);
            } else {
               Print("VENTA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño menor a 50 pips");
               entry= NormalizeDouble(High[pos]-sl(), Digits);
               stopLoss= NormalizeDouble(entry + sl(), Digits);
               takeProfit = NormalizeDouble(entry - tp(), Digits);   
               OrderLabelVenta = OrderSend(NULL,OP_SELLLIMIT, volume, entry, 1, stopLoss, takeProfit, "", Magic);
               if (stopsEnabled) OrderLabelVentaSt = OrderSend(NULL,OP_SELLSTOP, volume, entry, 1, stopLoss, takeProfit, "", Magic);
            }
         }
      }
   }
}

void seleccionEntradaBuy(int pos){
   double entry;
   double stopLoss;
   double takeProfit;
   int OrderLabelCompra;
   int OrderLabelCompraSt;
   
   if(MathAbs(Open[pos]-Close[pos]) >= tamanoCuerpoMax && -Low[pos] + MathMin(Open[pos], Close[pos]) >= tamanoMechaMax){
      Print("COMPRA: Cuerpo grande, mecha grande");
      entry= NormalizeDouble( (Low[pos] + MathMin(Open[pos], Close[pos]))/2, Digits);
      stopLoss= NormalizeDouble(entry - sl(), Digits);
      takeProfit = NormalizeDouble(entry + tp(), Digits);   
      OrderLabelCompra = OrderSend(NULL,OP_BUYLIMIT, volume, entry, 1, stopLoss, takeProfit, "", Magic);
      if (stopsEnabled) OrderLabelCompraSt = OrderSend(NULL,OP_BUYSTOP, volume, entry, 1, stopLoss, takeProfit, "", Magic);
   }else{
      
      if(High[pos]-Low[pos] <= tamanoVelaMax/2){ // vela <= 25 pips?
         Print("COMPRA: Vela menor a 25 pips");
         entry= NormalizeDouble(High[pos], Digits);
         stopLoss= NormalizeDouble(entry - sl(), Digits);
         takeProfit = NormalizeDouble(entry + tp(), Digits);   
         OrderLabelCompra = OrderSend(NULL,OP_BUYLIMIT, volume, entry, 1, stopLoss, takeProfit, "", Magic);
         if (stopsEnabled) OrderLabelCompraSt = OrderSend(NULL,OP_BUYSTOP, volume, entry, 1, stopLoss, takeProfit, "", Magic);
      } else {
         if(-Low[pos] + MathMin(Close[pos], Open[pos]) <= MathAbs(Close[pos] - Open[pos])){  // mecha <= cuerpo?
            if (High[pos]-Low[pos] >= tamanoVelaMax){
               Print("COMPRA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño mayor a 50 pips");
               entry= NormalizeDouble((Low[pos] + High[pos])/2, Digits);
               stopLoss= NormalizeDouble(entry - sl(), Digits);
               takeProfit = NormalizeDouble(entry + tp(), Digits);   
               OrderLabelCompra = OrderSend(NULL,OP_BUYLIMIT, volume, entry, 1, stopLoss, takeProfit, "", Magic);
               if (stopsEnabled) OrderLabelCompraSt = OrderSend(NULL,OP_BUYSTOP, volume, entry, 1, stopLoss, takeProfit, "", Magic);
            } else {
               Print("COMPRA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño menor a 50 pips");
               entry= NormalizeDouble(Low[pos]+sl(), Digits);
               stopLoss= NormalizeDouble(entry - sl(), Digits);
               takeProfit = NormalizeDouble(entry + tp(), Digits);   
               OrderLabelCompra = OrderSend(NULL,OP_BUYLIMIT, volume, entry, 1, stopLoss, takeProfit, "", Magic);
               if (stopsEnabled) OrderLabelCompraSt = OrderSend(NULL,OP_BUYSTOP, volume, entry, 1, stopLoss, takeProfit, "", Magic);
            }
         } else{
            if (-Low[pos] + MathMin(Close[pos], Open[pos]) >= tamanoVelaMax){ //mecha >=50?
               Print("COMPRA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño mayor a 50 pips");
               entry= NormalizeDouble((Low[pos] + MathMin(Close[pos], Open[pos]) )/2, Digits);
               stopLoss= NormalizeDouble(entry - sl(), Digits);
               takeProfit = NormalizeDouble(entry + tp(), Digits);   
               OrderLabelCompra = OrderSend(NULL,OP_BUYLIMIT, volume, entry, 1, stopLoss, takeProfit, "", Magic);
               if (stopsEnabled) OrderLabelCompraSt = OrderSend(NULL,OP_BUYSTOP, volume, entry, 1, stopLoss, takeProfit, "", Magic);
            } else { // Si mecha menor a 50pips, la entrada en la parte inferior +SL, el SL en entry - SL y pila de TP
               Print("COMPRA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño menor a 50 pips");
               entry= NormalizeDouble(Low[pos]+sl(), Digits);
               stopLoss= NormalizeDouble(entry - sl(), Digits);
               takeProfit = NormalizeDouble(entry + tp(), Digits);   
               OrderLabelCompra = OrderSend(NULL,OP_BUYLIMIT, volume, entry, 1, stopLoss, takeProfit, "", Magic);
               if (stopsEnabled) OrderLabelCompraSt = OrderSend(NULL,OP_BUYSTOP, volume, entry, 1, stopLoss, takeProfit, "", Magic);
            }
         }
      }
   }
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

void CerrarAbiertas(){
   for(int i=OrdersTotal(); i!=-1; i--){
      if(OrderSelect(i,SELECT_BY_POS ,MODE_TRADES)){
         if(OrderSymbol()==Symbol()){
            if(OrderType()==OP_BUY){
               OrderClose(OrderTicket(),OrderLots(),Bid,0.1);
            }
            if(OrderType()==OP_SELL){
               OrderClose(OrderTicket(),OrderLots(),Ask,0.1);
            }
         }
      }
   }
}

int CalcularNvelas(int horas){
   int distMaxAux;
   if(Period()==PERIOD_M1){
      distMaxAux = horas*60;}
   if(Period()==PERIOD_M5){
      distMaxAux = horas*12;}
   if(Period()==PERIOD_M15){
      distMaxAux = horas*4;}
   if(Period()==PERIOD_M30){
      distMaxAux = horas*2;}
   if(Period()!=PERIOD_M30 &&Period()!=PERIOD_M15&&Period()!=PERIOD_M5&&Period()!=PERIOD_M1){
      distMaxAux = 0;
   }
   return distMaxAux;   
}