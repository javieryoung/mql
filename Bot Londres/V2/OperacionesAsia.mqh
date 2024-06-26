
// Input de operaciones


double lotsize;
double minLotSize;
double maxLotSize;

//double volume=1/2.5;

void OperarFueraDeAsiaSell(int pos){
   if (!SLvariable){
      if(pos > CalcularNvelas(8) || pos <=  CalcularNvelas(1)){
         seleccionEntradaSell(pos);
      }
   }else{
      if(pos > CalcularNvelas(8) || pos <=  CalcularNvelas(1)){
         seleccionEntradaSellVariable(pos);
      }
   }
}

void OperarFueraDeAsiaBuy(int pos){
   if (!SLvariable){
      if(pos > CalcularNvelas(8) || pos <=  CalcularNvelas(1)){
         seleccionEntradaBuy(pos);
      }
   }else{
      if(pos > CalcularNvelas(8) || pos <=  CalcularNvelas(1)){
         seleccionEntradaBuyVariable(pos);
      }
   }
}

void OperarEnAsiaSell(int pos){
   if (!SLvariable){
      if(pos <= CalcularNvelas(8) && pos >  CalcularNvelas(1)){
         seleccionEntradaSell(pos);
      }
   }else{
      if(pos <= CalcularNvelas(8) && pos >  CalcularNvelas(1)){
         seleccionEntradaSellVariable(pos);
      }
   }
}

void OperarEnAsiaBuy(int pos){
   if (!SLvariable){
      if(pos <= CalcularNvelas(8) && pos >  CalcularNvelas(1)){
         seleccionEntradaBuy(pos);
      }
   }else{
      if(pos <= CalcularNvelas(8) && pos >  CalcularNvelas(1)){
         seleccionEntradaBuyVariable(pos);
      }
   }
}

double sl() {
   return (SL + slAir) / dividirEntre;
}

double tp() {
   return factorTP*sl();
}



void seleccionEntradaSell(int pos){
   if(MathAbs(Open[pos]-Close[pos]) >= tamanoCuerpoMax && High[pos] - MathMax(Open[pos], Close[pos]) >= tamanoMechaMax){
      Print("VENTA: Cuerpo grande, mecha grande");
      OperacionSell((High[pos] + MathMax(Open[pos], Close[pos]))/2, sl(), tp());
   }else{
      if(High[pos]-Low[pos] <= tamanoVelaMax/2){ // vela <= 25 pips?
         Print("VENTA: Vela menor a 25 pips");
         OperacionSell(Low[pos], sl(), tp());
      } else {
         if(High[pos] - MathMax(Close[pos], Open[pos]) <= MathAbs(Close[pos] - Open[pos])){  // mecha <= cuerpo?
            if (High[pos]-Low[pos] >= tamanoVelaMax){
               Print("VENTA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño mayor a 50 pips");
               OperacionSell((High[pos]+Low[pos])/2, sl(), tp());
            } else {
               Print("VENTA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño menor a 50 pips");
               OperacionSell(High[pos]-sl(), sl(), tp());
            }
         } else{
            if (High[pos] - MathMax(Close[pos], Open[pos]) >= tamanoVelaMax){  // mecha >= tamanoVelaMax
               Print("VENTA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño mayor a 50 pips");
               OperacionSell((High[pos] + MathMax(Close[pos], Open[pos]) )/2, sl(), tp());
            } else {
               Print("VENTA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño menor a 50 pips");
               OperacionSell(High[pos]-sl(), sl(), tp());
            }
         }
      }
   }
}

void seleccionEntradaBuy(int pos){
   if(MathAbs(Open[pos]-Close[pos]) >= tamanoCuerpoMax && -Low[pos] + MathMin(Open[pos], Close[pos]) >= tamanoMechaMax){
      Print("COMPRA: Cuerpo grande, mecha grande");
      OperacionBuy((Low[pos] + MathMin(Open[pos], Close[pos]))/2, sl(), tp()); //entry, SL, TP
   }else{
      if(High[pos]-Low[pos] <= tamanoVelaMax/2){ // vela <= 25 pips?
         Print("COMPRA: Vela menor a 25 pips");
         OperacionBuy(High[pos], sl(), tp()); //entry, SL, TP
      } else {
         if(-Low[pos] + MathMin(Close[pos], Open[pos]) <= MathAbs(Close[pos] - Open[pos])){  // mecha <= cuerpo?
            if (High[pos]-Low[pos] >= tamanoVelaMax){
               Print("COMPRA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño mayor a 50 pips");
               OperacionBuy((Low[pos] + High[pos])/2, sl(), tp()); //entry, SL, TP
            } else {
               Print("COMPRA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño menor a 50 pips");
               OperacionBuy(Low[pos]+sl(), sl(), tp()); //entry, SL, TP
            }
         }else{
            if (-Low[pos] + MathMin(Close[pos], Open[pos]) >= tamanoVelaMax){ //mecha >=50?
               Print("COMPRA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño mayor a 50 pips");
               OperacionBuy((Low[pos] + MathMin(Close[pos], Open[pos]) )/2, sl(), tp()); //entry, SL, TP
            } else {
               Print("COMPRA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño menor a 50 pips");
               OperacionBuy(Low[pos]+sl(), sl(), tp()); //entry, SL, TP
            }
         }
      }
   }
}


void seleccionEntradaSellVariable(int pos){
   double e;
   //Print("VOLUME: ",volume);
   
   if(MathAbs(Open[pos]-Close[pos]) >= tamanoCuerpoMax && High[pos] - MathMax(Open[pos], Close[pos]) >= tamanoMechaMax){
      Print("VENTA: Cuerpo grande, mecha grande"); 
      e = (High[pos] + MathMax(Open[pos], Close[pos]))/2;
      OperacionSell(e, High[pos] + slAir - e, tp());
   }else{
      if(High[pos]-Low[pos] <= tamanoVelaMax/2){ // vela <= 25 pips?
         Print("VENTA: Vela menor a 25 pips");
         e = Low[pos];
         OperacionSell(e, High[pos] + slAir - e, tp());
      } else {
         if(High[pos] - MathMax(Close[pos], Open[pos]) <= MathAbs(Close[pos] - Open[pos])){  // mecha <= cuerpo?
            if (High[pos]-Low[pos] >= tamanoVelaMax){
               Print("VENTA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño mayor a 50 pips");
               e = (High[pos]+Low[pos])/2;
               OperacionSell(e, High[pos] + slAir - e, tp());
            } else {
               Print("VENTA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño menor a 50 pips");
               e = (High[pos]+Low[pos])/2;
               OperacionSell(e, High[pos] + slAir - e, tp());
            }
         } else{
            if (High[pos] - MathMax(Close[pos], Open[pos]) >= tamanoVelaMax){  // mecha >= tamanoVelaMax
               Print("VENTA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño mayor a 50 pips");
               e = (High[pos] + MathMax(Close[pos], Open[pos]) )/2;
               OperacionSell(e, High[pos] + slAir - e, tp());
            } else {
               Print("VENTA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño menor a 50 pips");
               e = MathMax(Close[pos], Open[pos]);
               OperacionSell(e, High[pos] + slAir - e, tp());
            }
         }
      }
   }
}


void seleccionEntradaBuyVariable(int pos){
   double e;
   if(MathAbs(Open[pos]-Close[pos]) >= tamanoCuerpoMax && -Low[pos] + MathMin(Open[pos], Close[pos]) >= tamanoMechaMax){
      Print("COMPRA: Cuerpo grande, mecha grande");
      e = (Low[pos] + MathMin(Open[pos], Close[pos]))/2;
      OperacionBuy(e,e-Low[pos] - slAir, tp());
   }else{
      
      if(High[pos]-Low[pos] <= tamanoVelaMax/2){ // vela <= 25 pips?
         Print("COMPRA: Vela menor a 25 pips");
         e = High[pos];
         OperacionBuy(e,e-Low[pos] - slAir, tp());
      } else {
         if(-Low[pos] + MathMin(Close[pos], Open[pos]) <= MathAbs(Close[pos] - Open[pos])){  // mecha <= cuerpo?
            if (High[pos]-Low[pos] >= tamanoVelaMax){
               Print("COMPRA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño mayor a 50 pips");
               e = (Low[pos] + High[pos])/2;
               OperacionBuy(e,e-Low[pos] - slAir, tp());
            } else {
               Print("COMPRA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño menor a 50 pips");
               e = (Low[pos] + High[pos])/2;
               OperacionBuy(e,e-Low[pos] - slAir, tp());
            }
         } else{
            if (-Low[pos] + MathMin(Close[pos], Open[pos]) >= tamanoVelaMax){ //mecha >=50?
               Print("COMPRA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño mayor a 50 pips");
               e = (Low[pos] + MathMin(Close[pos], Open[pos]) )/2;
               OperacionBuy(e,e-Low[pos] - slAir, tp());
            } else { // Si mecha menor a 50pips, la entrada en la parte inferior +SL, el SL en entry - SL y pila de TP
               Print("COMPRA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño menor a 50 pips");
               e = MathMin(Close[pos], Open[pos]);
               OperacionBuy(e,e-Low[pos] - slAir, tp());
            }
         }
      }
   }
}

void OperacionBuy(double entrada, double SL, double TP){
   double volume = calculateLotSize(SL);
   double entry= NormalizeDouble(entrada, Digits);
   double stopLoss= NormalizeDouble(entry - SL, Digits);
   double takeProfit = NormalizeDouble(entry + TP, Digits);   
   int OrderLabelCompra = OrderSend(NULL,OP_BUYLIMIT, volume, entry, 1, stopLoss, takeProfit, "", Magic);
   if (stopsEnabled) double OrderLabelCompraSt = OrderSend(NULL,OP_BUYSTOP, volume, entry, 1, stopLoss, takeProfit, "", Magic);
}

void OperacionSell(double entrada, double SL, double TP){
   double volume = calculateLotSize(SL);
   double entry= NormalizeDouble(entrada, Digits);
   double stopLoss= NormalizeDouble(entry + SL, Digits);
   double takeProfit = NormalizeDouble(entry - TP, Digits);   
   int OrderLabelVenta = OrderSend(NULL,OP_SELLLIMIT, volume, entry, 1, stopLoss, takeProfit, "", Magic);
   if (stopsEnabled) double OrderLabelCompraSt = OrderSend(NULL,OP_BUYSTOP, volume, entry, 1, stopLoss, takeProfit, "", Magic);
}

/*
double tpVariableUp(int pos, double entrad){
   if (ArraySize(arrUmbralDw) > 0){
      int minDW;
      int min = MathAbs(arrUmbralDw[0]-pos);
      for(k=0; k<= ArraySize(arrUmbralDw);k++){
         if(min > MathAbs(arrUmbralDw[k]-pos)){
            min = MathAbs(arrUmbralDw[k]-pos);
            minDW = arrUmbralDw[k];
         }
      }
      return entrad - High[minDW];
   }else{
      return entrad-sl()*factorTP;
   }
}
*/

void CerrarAbiertas(){
   for(int i=OrdersTotal(); i!=-1; i--){
      if(OrderSelect(i,SELECT_BY_POS ,MODE_TRADES)){
         if (OrderMagicNumber() == Magic){
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

void CerrarTodo(){
   for(int i=OrdersTotal(); i!=-1; i--){
      if(OrderSelect(i,SELECT_BY_POS ,MODE_TRADES)){
         if (OrderMagicNumber() ==Magic){
            if(OrderSymbol()==Symbol()){
               if(OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT){
                  OrderDelete(OrderTicket());
               }
            }
         }
      }
   }
}