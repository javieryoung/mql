
// Input de operaciones


double lotsize;
double minLotSize;
double maxLotSize;

double nOpen;
double nClose;
double nHigh;
double nLow;


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
/*
redefinirLOCH: 
Redefine Low Open Close y High. Los cambia si "tocaPrecio" está activado.
Partimos desde una vela, la cual sabemos de antemano que califica como bloque de orden: esto es que en el futuro, su Low si estamos en compra, High si en venta, 
no fue tocado en el futuro. Luego nos fijamos si en el futuro alguna parte de ella fue "tocada" en precio. De ser así, redefine su extremo para que vaya
bajando/subiendo (caso venta Low, caso compra High) y así quedarnos con una vela efectiva. 
Ejemplo:
tenemos una vela que define el bloque de orden inferior (habilitando una compra). Ya de pique, si el Close está por debajo del High, en la primera evaluación agarra 
al High de la vela y lo convierte al Close (u Open de la siguiente). Y así con todas las demás velas futuras.
*/
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
      nLow   = Low[pos];
      nOpen  = Open[pos];
      nClose = Close[pos];
      nHigh  = High[pos];
   }
   
}

void Operacion(int pos, bool AYB){
   double entry      = NormalizeDouble(entrada(   pos, AYB), Digits);
   double stopLoss   = NormalizeDouble(stopLoss(  pos, AYB), Digits);
   double takeProfit = NormalizeDouble(takeProfit(pos, AYB), Digits);
   Print("STOPLO: ", stopLoss, "ENTRY: ", entry, "TP: ", takeProfit);
   double volume     = calculateLotSize(MathAbs(entry - stopLoss));
   if (AYB){
      int OrderLabelCompra = OrderSend(NULL,OP_BUYLIMIT, volume, entry, 1, stopLoss, takeProfit, "", Magic);
      if (stopsEnabled) int OrderLabelCompraSt = OrderSend(NULL,OP_BUYSTOP, volume, entry, 1, stopLoss, takeProfit, "", Magic);
   } else{
      int OrderLabelVenta = OrderSend(NULL,OP_SELLLIMIT, volume, entry, 1, stopLoss, takeProfit, "", Magic);
      if (stopsEnabled) int OrderLabelVentaSt  = OrderSend(NULL,OP_SELLSTOP, volume, entry, 1, stopLoss, takeProfit, "", Magic);
   }
}


/*
SL fijo:
En esta función se entrará tanto para obtener: entrada, SL y TP. Según con qué word se haya ingresado.

Entrada:
Dependendiendo del tamaño de la vela, el cuerpo o la mecha (abajo si compra, arriba si vende) dónde colocará la entrada. El SL, luego de fijada la 
entrada, quedará fijado a una distancia fija de SL pips (variable global).

* cuerpo >= maxCuerpo & mecha >= maxMecha       ----->      entrada en la mitad de la mecha.
* vela   <= maxVela/2                           ----->      entrada en extremo (High compra, Low venta).
* mecha  <= cuerpo                              ----->      entrada a un 25% de la vela respecto a extremo.
* mecha  >  cuerpo & mecha >= maxVela           ----->      entrada en la mitad de la mecha.
* mecha  >  cuerpo & mecha <  maxVela           ----->      entrada en extremo de cuerpo (parte inferior de vela en venta, superior en compra)

SL: 
El stopLoss estará a una distancia fija (SL) de la entrada. La entrada se calcula siempre antes.
---> stopLoss = entrada (+ ó -) (SL + slAir) / dividirEntre;  (- ---> compra, + ---> venta) [opuesto en signo al tp].

TP:
Dependiendo de si estamos con TPV o fijo será uno u otro. La entrada se calcula siempre antes.
TPV ---> ver función TPV
TP fijo ---> takeProfit = entrada (+ ó -) factorTP * (SL + slAir) / dividirEntre; (+ ---> compra, - ---> venta)
*/
double ArbolSLFijo(int pos, bool AYB, string word){
   redefinirLOCH( pos, AYB ); // Redefine Low Open Close y High. Ver la función. Los cambia si "tocaPrecio" está activado.
   double entrada;
   double stopLoss;
   double takeProfit;
   
   if (!AYB){
      if(MathAbs(nOpen-nClose) >= tamanoCuerpoMax && nHigh - MathMax(nOpen, nClose) >= tamanoMechaMax){
         Print("VENTA: Cuerpo grande, mecha grande");
         entrada = (nHigh + MathMax(nOpen, nClose))/2;
      }else{
         if(nHigh - nLow <= tamanoVelaMax/2){ // vela <= 25 pips?
            Print("VENTA: Vela menor a 25 pips");
            entrada = nLow;
         } else {
            if(nHigh - MathMax(nClose, nOpen) <= MathAbs(nClose - nOpen)){  // mecha <= cuerpo?
               if (nHigh - nLow >= tamanoVelaMax){
                  Print("VENTA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño mayor a 50 pips");
                  entrada = nHigh - (SL + slAir) / dividirEntre;
               } else {
                  Print("VENTA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño menor a 50 pips");
                  entrada = nHigh - (SL + slAir) / dividirEntre;
               }
            } else{
               if (nHigh - MathMax(nClose, nOpen) >= tamanoVelaMax){  // mecha >= tamanoVelaMax
                  Print("VENTA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño mayor a 50 pips");
                  entrada = (nHigh + MathMax(nClose, nOpen) )/2;
               } else {
                  Print("VENTA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño menor a 50 pips");
                  entrada = nHigh - (SL + slAir) / dividirEntre;
               }
            }
         }
      }
      stopLoss = entrada + (SL + slAir) / dividirEntre;
      if (TPvariable && word=="takeProfit"){
         takeProfit = TPV(pos, AYB, entrada, stopLoss);
      }else{
         if(word=="takeProfit"){
            takeProfit = entrada - factorTP * (SL + slAir) / dividirEntre;
         }
      }
   }
   if (AYB){
      if(MathAbs(nOpen-nClose) >= tamanoCuerpoMax && -nLow + MathMin(nOpen, nClose) >= tamanoMechaMax){
         Print("COMPRA: Cuerpo grande, mecha grande");
         entrada = (nLow + MathMin(nOpen, nClose))/2;
      }else{
         if(nHigh - nLow <= tamanoVelaMax/2){ // vela <= 25 pips?
            Print("COMPRA: Vela menor a 25 pips");
            entrada = nHigh;
         } else {
            if(-nLow + MathMin(nClose, nOpen) <= MathAbs(nClose - nOpen)){  // mecha <= cuerpo?
               if (nHigh - nLow >= tamanoVelaMax){
                  Print("COMPRA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño mayor a 50 pips");
                  entrada = nLow + (SL + slAir) / dividirEntre;
               } else {
                  Print("COMPRA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño menor a 50 pips");
                  entrada = nLow + (SL + slAir) / dividirEntre;
               }
            }else{
               if (-nLow + MathMin(nClose, nOpen) >= tamanoVelaMax){ //mecha >=50?
                  Print("COMPRA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño mayor a 50 pips");
                  entrada = (nLow + MathMin(nClose, nOpen) )/2;
               } else {
                  Print("COMPRA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño menor a 50 pips");
                  entrada = nLow + (SL + slAir) / dividirEntre;
               }
            }
         }
      }
      stopLoss = entrada - (SL + slAir) / dividirEntre;
      if (TPvariable && word == "takeProfit"){
         takeProfit = TPV(pos, AYB, entrada, stopLoss);
      }else{
         if(word == "takeProfit"){
         //Abos TP siguientes son iguales
            //takeProfit = entrada + factorTP * (SL + slAir) / dividirEntre;
            takeProfit = entrada + factorTP * MathAbs(stopLoss - entrada);
         }
      }
      
   }
   if (word=="entrada") return entrada;
   if (word=="stopLoss") return stopLoss;
   if (word=="takeProfit") return takeProfit;
   else return 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
SL variable:
En esta función se entrará tanto para obtener: entrada, SL y TP. Según con qué word se haya ingresado.

Entrada:
Dependendiendo del tamaño de la vela, el cuerpo o la mecha (abajo si compra, arriba si vende) dónde colocará la entrada. El SL, luego de fijada la 
entrada, quedará fijado en la parte inferior de la vela (si es compra) o superior (si es venta). [si se le suma a esto el TPV podrá llegar a tener situaciones 
de A:G con G<A, ejemplo: 10:3].
* cuerpo >= maxCuerpo & mecha >= maxMecha       ----->      entrada en la mitad de la mecha.
* vela   <= maxVela/2                           ----->      entrada en extremo (High compra, Low venta).
* mecha  <= cuerpo                              ----->      entrada a un 25% de la vela respecto a extremo.
* mecha  >  cuerpo & mecha >= maxVela           ----->      entrada en la mitad de la mecha.
* mecha  >  cuerpo & mecha <  maxVela           ----->      entrada en extremo de cuerpo (parte inferior de vela en venta, superior en compra)

SL: 
El SL es el mismo para todos. La entrada se calcula siempre antes.
---> stopLoss =  extremo (High->venta, Low->compra) + slAir/dividirEntre;

TP:
Dependiendo de si estamos con TPV o fijo será uno u otro. La entrada se calcula siempre antes.
TPV ---> ver función TPV
TP fijo ---> takeProfit = entrada (+ ó -) factorTP*MathAbs(stopLoss-entrada); (+ ---> compra, - ---> venta)
*/
double ArbolSLVariable(int pos, bool AYB, string word){
   redefinirLOCH( pos, AYB ); // Redefine Low Open Close y High. Ver la función. Los cambia si "tocaPrecio" está activado.
   double entrada;
   double stopLoss;
   double takeProfit;
   
   if (!AYB){
      if(MathAbs(nOpen-nClose) >= tamanoCuerpoMax && nHigh - MathMax(nOpen, nClose) >= tamanoMechaMax){ // cuerpo >= maxCuerpo & mecha >= maxMecha
         Print("VENTA: Cuerpo grande, mecha grande"); 
         entrada = (nHigh + MathMax(nOpen, nClose))/2;
      }else{
         if(nHigh - nLow <= tamanoVelaMax/2){ // vela <= 25 pips?
            Print("VENTA: Vela menor a 25 pips");
            entrada = nLow;
         } else {
            if(nHigh - MathMax(nClose, nOpen) <= MathAbs(nClose - nOpen)){  // mecha <= cuerpo?
               Print("VENTA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño mayor a 50 pips");
               entrada = nHigh - 0.25*(nHigh - nLow);
               /*if (nHigh - nLow >= tamanoVelaMax){
                  Print("VENTA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño mayor a 50 pips");
                  entrada = nHigh - 0.25*(nHigh - nLow);
               } else {
                  Print("VENTA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño menor a 50 pips");
                  entrada = nHigh - 0.25*(nHigh - nLow);
               }*/
            } else{
               if (nHigh - MathMax(nClose, nOpen) >= tamanoVelaMax){  // mecha >= tamanoVelaMax
                  Print("VENTA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño mayor a 50 pips");
                  entrada = (nHigh + MathMax(nClose, nOpen) )/2;
               } else {
                  Print("VENTA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño menor a 50 pips");
                  entrada = MathMax(nClose, nOpen);
               }
            }
         }
      }
      stopLoss =  nHigh + slAir/dividirEntre;
      if (TPvariable && word=="takeProfit"){
         takeProfit = TPV(pos, AYB, entrada, stopLoss);
      }else{
         if(word=="takeProfit"){
            /* Fijarse que sacamos el aire para multiplicar y luego se lo re introducimos. Eso generará una ganancia levemente inferior al 1:factorTP.
            takeProfit = entrada - factorTP*MathAbs(stopLoss - slAir/dividirEntre -entrada)- slAir/dividirEntre;*/
            takeProfit = entrada - factorTP*MathAbs(stopLoss - entrada);
         }
      }
      
   }
   if (AYB){
      if(MathAbs(nOpen-nClose) >= tamanoCuerpoMax && - nLow + MathMin(nOpen, nClose) >= tamanoMechaMax){
         Print("COMPRA: Cuerpo grande, mecha grande");
         entrada = (nLow + MathMin(nOpen, nClose))/2;
      }else{
         
         if(nHigh - nLow <= tamanoVelaMax/2){ // vela <= 25 pips?
            Print("COMPRA: Vela menor a 25 pips");
            entrada = nHigh;
         } else {
            if(-nLow + MathMin(nClose, nOpen) <= MathAbs(nClose - nOpen)){  // mecha <= cuerpo?
               if (nHigh - nLow >= tamanoVelaMax){
                  Print("COMPRA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño mayor a 50 pips");
                  entrada = nLow + 0.25*(-nLow + nHigh);
               } else {
                  Print("COMPRA: Vela mayor a 25 pips, con mecha menor que cuerpo, de tamaño menor a 50 pips");
                  entrada = nLow + 0.25*(-nLow + nHigh);
               }
            } else{
               if (-nLow + MathMin(nClose, nOpen) >= tamanoVelaMax){ //mecha >=50?
                  Print("COMPRA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño mayor a 50 pips");
                  entrada = (nLow + MathMin(nClose, nOpen) )/2;
               } else { // Si mecha menor a 50pips, la entrada en la parte inferior +SL, el SL en entry - SL y pila de TP
                  Print("COMPRA: Vela mayor a 25 pips, con mecha más grande que cuerpo, de tamaño menor a 50 pips");
                  entrada = MathMin(nClose, nOpen);
               }
            }
         }
      }
      stopLoss =  nLow - slAir/dividirEntre;
      if (TPvariable && word=="takeProfit"){
         takeProfit = TPV(pos, AYB, entrada, stopLoss);
      }else{
         if(word=="takeProfit"){
         /* Fijarse que sacamos el aire para multiplicar y luego se lo re introducimos. Eso generará una ganancia levemente inferior al 1:factorTP.
            takeProfit = entrada + factorTP*MathAbs(stopLoss + slAir/dividirEntre - entrada) + slAir/dividirEntre;*/
            takeProfit = entrada + factorTP*MathAbs(stopLoss - entrada) ;
         }
      }
      
   }
   if (word=="entrada") return entrada;
   if (word=="stopLoss") return stopLoss;
   if (word=="takeProfit") return takeProfit;
   else return 0;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Take Profit Variable
// Se le ingresa la posición (número de vela desde donde comenzó a analisar el mercado), AYB (si compra true, si vende false),
// entradinha (lo primero que se calcula para tomar una posición es dónde entra, luego en base a el tipo de operación dónde estará el SL y el TP),
// y el SL (que es el valor absoluto, no la diferencia desde la entrada [también absoluta])
double TPV(int pos, bool AYB, double entradinha ,double stopLoss){ //stopLoss absoluto
   Print(" ");
   Print("TPV pos input: ", pos);
   if (!AYB){ //VENTA
      // condicional para ver si: "hay BO por debajo?"==true.
      if (ArraySize(arrUmbralDw) > 0){
         
         
         /*int minDW;
         // Lo siguiente se basa en que, en este caso, la posición del BO superior tendrá como soporte al BO inferior más cercano temporalmente. 
         // Ayuda pensar que la situación hipotética en donde hay más BO sup e inf se da cuando el mercado se encuentra enrangado entre dos rectas
         // que simulan un triángulo. Como el signo de Play.
         
         //Creo que debería comparar mínimos por entradas (entradinhas) y no por tiempo.
         int min = MathAbs(arrUmbralDw[0]-pos);
         for(int k=0; k<= ArraySize(arrUmbralDw)-1;k++){
            if(min >= MathAbs(arrUmbralDw[k]-pos)){
               min = MathAbs(arrUmbralDw[k]-pos);
               minDW = arrUmbralDw[k];
            }
         }*/
         
         int posBOopuestoMasCercano = arrUmbralDw[0];
         /* AYB == false vinculado con los BO superiores. En este caso estamos con AYB == false y en venta. Para ver la entrada de los de abajo
         colocamos su posición y la condición de AYB == true, es decir: !AYB */
         double min = MathAbs(entrada(posBOopuestoMasCercano,!AYB) - entrada(pos, AYB)); //Distancia entre entradas de pos y el primer BO opuesto
         for(int k=0; k<= ArraySize(arrUmbralDw)-1;k++){
            Print("VENTANAAA min ", min , " entrada(arrUmbralDw[k],!AYB) ",entrada(arrUmbralDw[k],!AYB) ," entrada(pos, AYB) ",entrada(pos, AYB) , " MathAbs(entrada(arrUmbralDw[k],!AYB) - entrada(pos, AYB)) " , MathAbs(entrada(arrUmbralDw[k],!AYB) - entrada(pos, AYB)));
            if(min >= MathAbs(entrada(arrUmbralDw[k],!AYB) - entrada(pos, AYB))){ 
               min = MathAbs(entrada(arrUmbralDw[k],!AYB) - entrada(pos, AYB)); //Distancia entre entradas de pos y el k-ésimo BO opuesto
               posBOopuestoMasCercano = arrUmbralDw[k];
               Print("VENTA for, if de TPV................  arrUmbralUp[k]: ",arrUmbralUp[k]," k: ", k);
            }
         }
         
         
         // En este if se fija que el BO opuesto no esté muy cerca, si es así, no entra. 
         Print("TPV VENTA posBOopuestoMasCercano ",posBOopuestoMasCercano );
         Print(" ");
         
         if(entradinha-entrada(posBOopuestoMasCercano, !AYB) > MathAbs(stopLoss-entradinha)*minAceptableProfit){
            /* Entradinha es el de la operación (venta, que se va para abajo) en donde estamos buscando el TPV. 
               entrada(minDW, true) busca la entrada del BO de abajo, aquel que tiene por entrada de AYB true.*/
            Print("entradinha-entrada(posBOopuestoMasCercano, true), VENTA ", entradinha-entrada(posBOopuestoMasCercano, !AYB));
            return entrada(posBOopuestoMasCercano, !AYB);
         }else{
            Print("-1");
            return -1;
         }
         
      }else{
         Print("VENTA. Sin BO inferior");
         return entradinha - MathAbs(stopLoss-entradinha)*factorTP;
      }
   }else{
      if (ArraySize(arrUmbralUp) > 0){
      /*
         int minUp;
         int min = MathAbs(arrUmbralUp[0]-pos);
         for(int k=0; k<= ArraySize(arrUmbralUp)-1;k++){
            if(min >= MathAbs(arrUmbralUp[k]-pos)){
               min = MathAbs(arrUmbralUp[k]-pos);
               minUp = arrUmbralUp[k];
            }
         }*/
         
         int posBOopuestoMasCercano = arrUmbralUp[0];
         /* AYB == true vinculado con los BO inferiores. En este caso estamos con AYB == true y en compra. Para ver la entrada de los de arriba
         colocamos su posición y la condición de AYB == false, es decir: !AYB */
         double min = MathAbs(entrada(posBOopuestoMasCercano,!AYB) - entrada(pos, AYB)); //Distancia entre entradas de pos y el primer BO opuesto
         for(int k=0; k<= ArraySize(arrUmbralUp)-1;k++){
            Print("COMPRANAAA min ", min , " entrada(arrUmbralUp[k],!AYB) ",entrada(arrUmbralUp[k],!AYB) ," entrada(pos, AYB) ",entrada(pos, AYB) , " MathAbs(entrada(arrUmbralUp[k],!AYB) - entrada(pos, AYB)) " , MathAbs(entrada(arrUmbralUp[k],!AYB) - entrada(pos, AYB)));
            if(min >= MathAbs(entrada(arrUmbralUp[k],!AYB) - entrada(pos, AYB))){ 
               min = MathAbs(entrada(arrUmbralUp[k],!AYB) - entrada(pos, AYB)); //Distancia entre entradas de pos y el k-ésimo BO opuesto
               posBOopuestoMasCercano = arrUmbralUp[k];
               Print("COMPRA for, if de TPV................  arrUmbralUp[k]: ",arrUmbralUp[k]," k: ", k);
            }
         }
         
         Print("TPV COMPRA posBOopuestoMasCercano ",posBOopuestoMasCercano );
         Print(" ");
         
         if(entrada(posBOopuestoMasCercano, !AYB)- entradinha > MathAbs(entradinha-stopLoss)*minAceptableProfit){ 
            Print("entrada(posBOopuestoMasCercano, false), COMPRA ",entrada(posBOopuestoMasCercano, !AYB));
            return entrada(posBOopuestoMasCercano, !AYB);
         }else{
            Print("-1");
            return -1;
         }  
      }else{
         Print("COMPRA. Sin BO superior");
         return entradinha + MathAbs(entradinha-stopLoss)*factorTP;
      }
   }
}

// Se usará para para achicar el tamaño de las velas de los mínimos.
double newHigh(int posH){
   double varAux = High[posH]; // Máximo de una vela. Ese precio es comido por algún Low (Ree) siguiente.
   for (int k=posH-1; k>=0; k--){
      if(Low[k]<varAux){ // Lo come? Si, cambia el High de esa vela que está siendo analizada.
         varAux=Low[k];
      }
   }
   return varAux;
}

double newLow(int posL){
   double varAux = Low[posL]; // Mínimo de una vela. Ese precio es comido por algún High (five) siguiente.
   for (int k=posL-1; k>=0; k--){
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





