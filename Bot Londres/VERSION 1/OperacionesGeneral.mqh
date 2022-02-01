
// Input de operaciones


double lotsize;
double minLotSize;
double maxLotSize;

double nOpen;
double nClose;
double nHigh;
double nLow;

/*
   if (tocaPrecio){
      
   }else{
      nOpen=Open[pos];
      nClose=Close[pos];
      nHigh=High[pos];
      nLow=Low[pos];
*/


void OperarFueraDeAsiaSell(int pos){
   if(pos > CalcularNvelas(8) || pos <=  CalcularNvelas(1)){
      Operacion(pos, false);
   }
}

void OperarFueraDeAsiaBuy(int pos){
   if(pos > CalcularNvelas(8) || pos <=  CalcularNvelas(1)){
      Operacion(pos, true);
   }
}

void OperarEnAsiaSell(int pos){
   if(pos <= CalcularNvelas(8) && pos >  CalcularNvelas(1)){
      Operacion(pos, false);
   }
}

void OperarEnAsiaBuy(int pos){
   if(pos <= CalcularNvelas(8) && pos >  CalcularNvelas(1)){
      Operacion(pos, true);
   }
}

double entrada(int pos, bool AYB){
   double entry;
   if(!SLvariable){
      entry = ArbolSLFijo(pos, AYB, "entrada");
   }
   if(SLvariable){
      entry = ArbolSLVariable(pos, AYB,"entrada");
   }
   return entry;
}

double stopLoss(int pos, bool AYB){
   double sl;
   if (!SLvariable){
      sl = ArbolSLFijo(pos, AYB, "stopLoss");
   }
   if(SLvariable){
      sl = ArbolSLVariable(pos, AYB, "stopLoss");
   }
   return sl;
}

double takeProfit(int pos, bool AYB){
   double tp;
   if (!SLvariable){
      tp = ArbolSLFijo(pos, AYB, "takeProfit");
   }
   if(SLvariable){
       tp = ArbolSLVariable(pos, AYB, "takeProfit");
   }
   return tp;
}

void redefinirLOCH(int pos,bool AYB ){
   if(tocaPrecio){
      if(AYB){
         nLow = Low[pos]; //el LowRí no cambia
         nHigh = newHigh(pos);
         if(nHigh< MathMin(Open[pos],Close[pos])){    // nHigh en mecha de abajo
            nOpen = nHigh;
            nClose = nHigh;
         }
         if(nHigh>MathMax(Open[pos],Close[pos])){     // nHigh mecha de arriba, no cambia nada nuevo
            nOpen = Open[pos];
            nClose = Close[pos];
         }
         if(nHigh<MathMax(Open[pos],Close[pos]) && nHigh>MathMin(Open[pos],Close[pos]) ){ // nhigh en cuerpo
            if(Close[pos]>Open[pos]){
               nOpen = Open[pos];
               nClose = nHigh;
            }
            if(Close[pos]<Open[pos]){
               nOpen = nHigh;
               nClose = Close[pos];
            }
         }
         
      }
      if(!AYB){
         nLow = newLow(pos);
         nHigh = High[pos]; //el HighFive no cambia
         if(nLow> MathMax(Open[pos],Close[pos])){    // nLow en mecha de arriba
            nOpen = nLow;
            nClose = nLow;
         }
         if(nLow<MathMin(Open[pos],Close[pos])){     // nLow mecha de abajo, no cambia nada nuevo
            nOpen = Open[pos];
            nClose = Close[pos];
         }
         if(nLow<MathMax(Open[pos],Close[pos]) && nLow>MathMin(Open[pos],Close[pos]) ){ // nLow en cuerpo
            if(Close[pos]>Open[pos]){
               nOpen = nLow;
               nClose = Close[pos];
            }
            if(Close[pos]<Open[pos]){
               nOpen = Open[pos];
               nClose = nLow;
            }
         }
         
      }
   }
   if(!tocaPrecio){
      nLow = Low[pos];
      nOpen = Open[pos];
      nClose = Close[pos];
      nHigh = High[pos];
   }
}

void Operacion(int pos, bool AYB){
   double entry= NormalizeDouble(entrada(pos, AYB), Digits);
   double stopLoss= NormalizeDouble(stopLoss(pos, AYB), Digits);
   double takeProfit = NormalizeDouble(takeProfit(pos, AYB), Digits);
   double volume = calculateLotSize(MathAbs(entry - SL));
   if (AYB){
      int OrderLabelCompra = OrderSend(NULL,OP_BUYLIMIT, volume, entry, 1, stopLoss, takeProfit, "", Magic);
      if (stopsEnabled) double OrderLabelCompraSt = OrderSend(NULL,OP_BUYSTOP, volume, entry, 1, stopLoss, takeProfit, "", Magic);
   } else{
      int OrderLabelVenta = OrderSend(NULL,OP_SELLLIMIT, volume, entry, 1, stopLoss, takeProfit, "", Magic);
      if (stopsEnabled) double OrderLabelCompraSt = OrderSend(NULL,OP_BUYSTOP, volume, entry, 1, stopLoss, takeProfit, "", Magic);
   }
}


double ArbolSLFijo(int pos, bool AYB, string word){
   double entrada;
   double stopLoss;
   double takeProfit;
   
   if (!AYB){
      if(MathAbs(Open[pos]-Close[pos]) >= tamanoCuerpoMax && High[pos] - MathMax(Open[pos], Close[pos]) >= tamanoMechaMax){
         Print("VENTA: Cuerpo grande, mecha grande");
         entrada = (High[pos] + MathMax(Open[pos], Close[pos]))/2;
      }else{
         if(High[pos]-Low[pos] <= tamanoVelaMax/2){ // vela <= 25 pips?
            Print("VENTA: Vela menor a 25 pips");
            entrada = Low[pos];
         } else {
            if(High[pos] - MathMax(Close[pos], Open[pos]) <= MathAbs(Close[pos] - Open[pos])){  // mecha <= cuerpo?
               if (High[pos]-Low[pos] >= tamanoVelaMax){
                  Print("VENTA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño mayor a 50 pips");
                  entrada = (High[pos]+Low[pos])/2;
               } else {
                  Print("VENTA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño menor a 50 pips");
                  entrada = High[pos]-(SL + slAir) / dividirEntre;
               }
            } else{
               if (High[pos] - MathMax(Close[pos], Open[pos]) >= tamanoVelaMax){  // mecha >= tamanoVelaMax
                  Print("VENTA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño mayor a 50 pips");
                  entrada = (High[pos] + MathMax(Close[pos], Open[pos]) )/2;
               } else {
                  Print("VENTA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño menor a 50 pips");
                  entrada = High[pos]-(SL + slAir) / dividirEntre;
               }
            }
         }
      }
      stopLoss = entrada + (SL + slAir) / dividirEntre;
      if (TPvarialbe){
         takeProfit = TPV(pos, AYB, entrada, stopLoss);
      }else{
         takeProfit = entrada - factorTP * (SL + slAir) / dividirEntre;
      }
   }
   if (AYB){
      if(MathAbs(Open[pos]-Close[pos]) >= tamanoCuerpoMax && -Low[pos] + MathMin(Open[pos], Close[pos]) >= tamanoMechaMax){
         Print("COMPRA: Cuerpo grande, mecha grande");
         entrada = Low[pos] + MathMin(Open[pos], Close[pos])/2;
      }else{
         if(High[pos]-Low[pos] <= tamanoVelaMax/2){ // vela <= 25 pips?
            Print("COMPRA: Vela menor a 25 pips");
            entrada = High[pos];
         } else {
            if(-Low[pos] + MathMin(Close[pos], Open[pos]) <= MathAbs(Close[pos] - Open[pos])){  // mecha <= cuerpo?
               if (High[pos]-Low[pos] >= tamanoVelaMax){
                  Print("COMPRA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño mayor a 50 pips");
                  entrada = (Low[pos] + High[pos])/2;
               } else {
                  Print("COMPRA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño menor a 50 pips");
                  entrada = Low[pos]+(SL + slAir) / dividirEntre;
               }
            }else{
               if (-Low[pos] + MathMin(Close[pos], Open[pos]) >= tamanoVelaMax){ //mecha >=50?
                  Print("COMPRA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño mayor a 50 pips");
                  entrada = (Low[pos] + MathMin(Close[pos], Open[pos]) )/2;
               } else {
                  Print("COMPRA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño menor a 50 pips");
                  entrada = Low[pos]+(SL + slAir) / dividirEntre;
               }
            }
         }
      }
      stopLoss = entrada - (SL + slAir) / dividirEntre;
      if (TPvarialbe){
         takeProfit = TPV(pos, AYB, entrada, stopLoss);
      }else{
         takeProfit = entrada + factorTP * (SL + slAir) / dividirEntre;
      }
      
   }
   if (word=="entrada") return entrada;
   if (word=="stopLoss") return stopLoss;
   if (word=="takeProfit") return takeProfit;
   else return 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

double ArbolSLVariable(int pos, bool AYB, string word){
   double entrada;
   double stopLoss;
   double takeProfit;
   
   if (!AYB){
      if(MathAbs(Open[pos]-Close[pos]) >= tamanoCuerpoMax && High[pos] - MathMax(Open[pos], Close[pos]) >= tamanoMechaMax){
         Print("VENTA: Cuerpo grande, mecha grande"); 
         entrada = (High[pos] + MathMax(Open[pos], Close[pos]))/2;
      }else{
         if(High[pos]-Low[pos] <= tamanoVelaMax/2){ // vela <= 25 pips?
            Print("VENTA: Vela menor a 25 pips");
            entrada = Low[pos];
         } else {
            if(High[pos] - MathMax(Close[pos], Open[pos]) <= MathAbs(Close[pos] - Open[pos])){  // mecha <= cuerpo?
               if (High[pos]-Low[pos] >= tamanoVelaMax){
                  Print("VENTA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño mayor a 50 pips");
                  entrada = (High[pos]+Low[pos])/2;
               } else {
                  Print("VENTA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño menor a 50 pips");
                  entrada = (High[pos]+Low[pos])/2;
               }
            } else{
               if (High[pos] - MathMax(Close[pos], Open[pos]) >= tamanoVelaMax){  // mecha >= tamanoVelaMax
                  Print("VENTA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño mayor a 50 pips");
                  entrada = (High[pos] + MathMax(Close[pos], Open[pos]) )/2;
               } else {
                  Print("VENTA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño menor a 50 pips");
                  entrada = MathMax(Close[pos], Open[pos]);
               }
            }
         }
      }
      stopLoss =  High[pos] + slAir/dividirEntre;
      if (TPvarialbe){
         takeProfit = TPV(pos, AYB, entrada, stopLoss);
      }else{
         takeProfit = entrada - factorTP * (- entrada + stopLoss);
      }
      
   }
   if (AYB){
      if(MathAbs(Open[pos]-Close[pos]) >= tamanoCuerpoMax && -Low[pos] + MathMin(Open[pos], Close[pos]) >= tamanoMechaMax){
         Print("COMPRA: Cuerpo grande, mecha grande");
         entrada = (Low[pos] + MathMin(Open[pos], Close[pos]))/2;
      }else{
         
         if(High[pos]-Low[pos] <= tamanoVelaMax/2){ // vela <= 25 pips?
            Print("COMPRA: Vela menor a 25 pips");
            entrada = High[pos];
         } else {
            if(-Low[pos] + MathMin(Close[pos], Open[pos]) <= MathAbs(Close[pos] - Open[pos])){  // mecha <= cuerpo?
               if (High[pos]-Low[pos] >= tamanoVelaMax){
                  Print("COMPRA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño mayor a 50 pips");
                  entrada = (Low[pos] + High[pos])/2;
               } else {
                  Print("COMPRA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño menor a 50 pips");
                  entrada = (Low[pos] + High[pos])/2;
               }
            } else{
               if (-Low[pos] + MathMin(Close[pos], Open[pos]) >= tamanoVelaMax){ //mecha >=50?
                  Print("COMPRA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño mayor a 50 pips");
                  entrada = (Low[pos] + MathMin(Close[pos], Open[pos]) )/2;
               } else { // Si mecha menor a 50pips, la entrada en la parte inferior +SL, el SL en entry - SL y pila de TP
                  Print("COMPRA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño menor a 50 pips");
                  entrada = MathMin(Close[pos], Open[pos]);
               }
            }
         }
      }
      stopLoss =  Low[pos] - slAir/dividirEntre;
      if (TPvarialbe){
         takeProfit = TPV(pos, AYB, entrada, stopLoss);
      }else{
         takeProfit = entrada + factorTP * (entrada - stopLoss);
      }
      
   }
   if (word=="entrada") return entrada;
   if (word=="stopLoss") return stopLoss;
   if (word=="takeProfit") return takeProfit;
   else return 0;
}


double TPV(int pos, bool AYB, double entrada ,double stopLoss){
   if (!AYB){
      if (ArraySize(arrUmbralDw) > 0){
         int minDW;
         int min = MathAbs(arrUmbralDw[0]-pos);
         for(int k=0; k<= ArraySize(arrUmbralDw);k++){
            if(min > MathAbs(arrUmbralDw[k]-pos)){
               min = MathAbs(arrUmbralDw[k]-pos);
               minDW = arrUmbralDw[k];
            }
         }
         return High[minDW];
      }else{
         return entrada-stopLoss*factorTP;
      }
   }else{
      if (ArraySize(arrUmbralUp) > 0){
         int minUp;
         int min = MathAbs(arrUmbralUp[0]-pos);
         for(int k=0; k<= ArraySize(arrUmbralUp);k++){
            if(min > MathAbs(arrUmbralUp[k]-pos)){
               min = MathAbs(arrUmbralUp[k]-pos);
               minUp = arrUmbralUp[k];
            }
         }
         return Low[minUp];
      }else{
         return entrada-stopLoss*factorTP;
      }
   }
}

// Se usará para para achicar el tamaño de las velas de los mínimos.
double newHigh(int posH){
   double varAux = High[posH]; // Máximo de una vela. Ese precio es comido por algún Low (Ree) siguiente.
   for (int k=posH; k>=0; k--){
      if(Low[k]<varAux){ // Lo come? Si, cambia el High de esa vela que está siendo analizada.
         varAux=Low[k];
      }
   }
   return varAux;
}

double newLow(int posL){
   double varAux = Low[posL]; // Mínimo de una vela. Ese precio es comido por algún High (five) siguiente.
   for (int k=posL; k>=0; k--){
      if(High[k]>varAux){ // Lo come? Si, cambia el High de esa vela que está siendo analizada.
         varAux=High[k];
      }
   }
   return varAux;
}

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





