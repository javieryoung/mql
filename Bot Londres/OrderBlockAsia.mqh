
int arrUp[];
int arrDw[];

int arrTrueDw[];
int arrTrueUp[];

int arrUmbralDw[];
int arrUmbralUp[];

int todosLosCandidatos[];
//int masCercano;
//int aux;

void SearchOB(int dMax, int rLocal){
   int posicionesUp;
   int posicionesDw;
   int posAuxUp=0;
   int posAuxDw=0;
   for (int k = rLocal; k<= dMax; k++){
      posicionesUp = OBup(k, rLocal);
      posicionesDw = OBdw(k, rLocal);
      
      int size;
      int sizeTodos;
      if (posicionesUp != 0){
         //Print(posicionesUp);
         // Array de todos los candidatos
         sizeTodos = ArraySize(todosLosCandidatos);
         ArrayResize(todosLosCandidatos, sizeTodos + 1);
         todosLosCandidatos[sizeTodos] = posicionesUp;
         
         if(ArraySize(todosLosCandidatos) <= 1 ){ // ESTO ELIMINA LOS BLOQUES DE ORDEN DEL MISMO TIPO CONSECUTIVOS
            // Array de los candidatos arriba
            size = ArraySize(arrUp);
            ArrayResize(arrUp, size + 1);
            arrUp[size] = posicionesUp;
         } else {
            size = ArraySize(arrUp);
            if(todosLosCandidatos[sizeTodos] * todosLosCandidatos[sizeTodos-1] < 0 ){  // Se fija si hay max o min consecutivos
               // Array de los candidatos arriba
               ArrayResize(arrUp, size + 1);  // Si están intercalados, hace lo de siempre
               arrUp[size] = posicionesUp;
            } else {
            
               if(High[todosLosCandidatos[sizeTodos]]>High[todosLosCandidatos[sizeTodos-1]]){
                  arrUp[size-1] = posicionesUp;  
               }else{
                  ArrayResize(arrUp, size + 1);
                  arrUp[size] = posicionesUp;  // De lo contrario, sobreescribe el último del vector (sobreescribe al más cercano en el tiempo con el más lejano)
               }
            }
            
         }
         
         
         //Print("SE AGREGO ARRUP", arrUp[size]);
         //posAuxUp = posicionesUp;
      }
      if (posicionesDw != 0){
      
         // Array de todos los candidatos
         sizeTodos = ArraySize(todosLosCandidatos);
         ArrayResize(todosLosCandidatos, sizeTodos + 1);
         todosLosCandidatos[sizeTodos] = -posicionesDw;
         
         if(ArraySize(todosLosCandidatos) <= 1 ){ // ESTO ELIMINA LOS BLOQUES DE ORDEN DEL MISMO TIPO CONSECUTIVOS
            // Array de los candidatos arriba
            size = ArraySize(arrDw);
            ArrayResize(arrDw, size + 1);
            arrDw[size] = posicionesDw;
         } else {
            size = ArraySize(arrDw);
            if(todosLosCandidatos[sizeTodos] * todosLosCandidatos[sizeTodos-1] < 0 ){
               // Array de los candidatos arriba
               ArrayResize(arrDw, size + 1);
               arrDw[size] = posicionesDw;
            } else {
               
               if(Low[-todosLosCandidatos[sizeTodos]]<Low[-todosLosCandidatos[sizeTodos-1]]){
                     arrDw[size-1] = posicionesDw;  
                  }else{
                     ArrayResize(arrDw, size + 1);
                     arrDw[size] = posicionesDw;  // De lo contrario, sobreescribe el último del vector (sobreescribe al más cercano en el tiempo con el más lejano)
                  }
            }
         }
         
         
         //Print("SE AGREGO ARRDW", arrDw[size]);
         //posAuxDw = posicionesDw;
      }
      
   }
   //Print("ArraySize(arrUp)", ArraySize(arrUp));
   //Print("arrDw[ArraySize(arrUp)-1]",arrUp[ArraySize(arrUp)-1]);
   
   
   //Filtrar candidatos
   TrueOBdw();
   TrueOBup();
   
   //Filtra candidatos por separación
   UmbralOBup();
   UmbralOBdw();
   
   //Dibujar líneas
   DrawlinesUp();
   DrawlinesDw();
   //Print(arrTrueUp[1]);
   //Print(arrTrueUp[2]);
   //Print(arrTrueUp[3]);
   //Print(arrTrueUp[4]);
}


void TrueOBdw(){ //true order block para los valores mínimos. Itera en todos
   for (int i=0; i<=ArraySize(arrDw)-1; i++){
      
      bool rupturaEstructuraDesdeAbajo;
      int BOcandidatoDeAbajo = arrDw[i];
      int closerBOporEncima;
      if (BOSenabled){
         closerBOporEncima = BuscarValorCercanoAbajo(BOcandidatoDeAbajo);
         rupturaEstructuraDesdeAbajo = BOSalza(closerBOporEncima, BOcandidatoDeAbajo);
      }else{
         rupturaEstructuraDesdeAbajo = true;
      }
      bool esMinElBO = MinimoHaciaElPresente(BOcandidatoDeAbajo);
      double factorPendiente = Calculador_Pendiente(arrDw[i]);
      
      Print("pos: ", arrDw[i], "esMinElBO: ", esMinElBO, "BOS: ", rupturaEstructuraDesdeAbajo, "fP: ",factorPendiente > umbralPendiente);
      //Print(rupturaEstructuraDesdeAbajo);
      if (esMinElBO && rupturaEstructuraDesdeAbajo && factorPendiente > umbralPendiente){
         int size = ArraySize(arrTrueDw);
         ArrayResize(arrTrueDw, size + 1);
         arrTrueDw[size] = BOcandidatoDeAbajo;
      }
   }
}


void TrueOBup(){ //true order block para los valores maximos. Itera en todos
   for (int i=0; i<=ArraySize(arrUp)-1; i++){
      
      bool rupturaEstructuraDesdeArriba;
      int BOcandidatoDeArriba = arrUp[i];
      int closerBOporDebajo;
      if (BOSenabled){
         closerBOporDebajo = BuscarValorCercanoArriba(BOcandidatoDeArriba);
         rupturaEstructuraDesdeArriba = BOSbaja(closerBOporDebajo, BOcandidatoDeArriba);
      }else{
         rupturaEstructuraDesdeArriba = true;
      }
      bool esMaxElBO = MaximoHaciaElPresente(BOcandidatoDeArriba);
      double factorPendiente = Calculador_Pendiente(arrUp[i]);
      
      Print(rupturaEstructuraDesdeArriba);
      if (esMaxElBO && rupturaEstructuraDesdeArriba && factorPendiente > umbralPendiente){
         int size = ArraySize(arrTrueUp);
         ArrayResize(arrTrueUp, size + 1);
         arrTrueUp[size] = BOcandidatoDeArriba;
      }
   }
}

void UmbralOBdw(){
   for (int i=0; i<=ArraySize(arrTrueDw)-1; i++){
      bool estanLejos = BloquesLejosDw(i);
      if (estanLejos){
         int size = ArraySize(arrUmbralDw);
         ArrayResize(arrUmbralDw, size + 1);
         arrUmbralDw[size] = arrTrueDw[i];
      }
   }
}

void UmbralOBup(){
   for (int i=0; i<=ArraySize(arrTrueUp)-1; i++){
      bool estanLejos = BloquesLejosUp(i);
      if (estanLejos){
         int size = ArraySize(arrUmbralUp);
         ArrayResize(arrUmbralUp, size + 1);
         arrUmbralUp[size] = arrTrueUp[i];
      }
   }
}

bool  BloquesLejosDw(int i){
   if(i < ArraySize(arrTrueDw)-1){
      if(MathAbs(entrada(arrTrueDw[i], true)-entrada(arrTrueDw[i+1], true)) > umbral){
         return true;
      }else{
         return false;
      }
   }else{
      return true;
   }
}

bool  BloquesLejosUp(int i){
   if(i < ArraySize(arrTrueUp)-1){
      if(MathAbs(entrada(arrTrueUp[i], false)-entrada(arrTrueUp[i+1], false)) > umbral){
         return true;
      }else{
         return false;
      }
   }else{
      return true;
   }
}

// BuscarValorCercanoAbajo (BuscarValorCercanoArriba):
// Arranca desde el valor del tiempo(N) del posible bloque de orden inferior, que es un mínimo. Luego se 
// recorren los valores de los máximos encontrados / su tiempo sea menor (arrUp[j]>N), que cumpla que 
// el máximo de la vela máxima (posible bloque de orden superior) sea mayor que el máximo de la vela mínima.
// Esto último se hace para eliminar la posibilidad que el máximo del máximo sea menor que el máximo del mínimo (problema a la hora de encontrarlos todos)
// ´La flag es para que encuentre el primero que cumpla con esto. Idem para BuscarValorCercanoArriba
int BuscarValorCercanoAbajo(int N){
   bool flag = False;
   int masCercano;
   
   for(int j=0; j<=ArraySize(arrUp)-1; j++ ){
      if( N < arrUp[j] && High[arrUp[j]] > High[N] && flag == False){
         flag = True;
         masCercano = arrUp[j];
      }
   }
   return masCercano;
}

int BuscarValorCercanoArriba(int N){
   bool flag = False;
   int masCercano;
   
   for(int j=0; j<=ArraySize(arrDw)-1; j++ ){
      if( N < arrDw[j] && Low[arrDw[j]] < Low[N] && flag == False){
         flag = True;
         masCercano = arrDw[j];
      }
   }
   return masCercano;
}


// Le das un tiempo de un Min (bocda) y un tiempo de un max (cbope). Se fija si en algun momento 
// las velas más reciente superan al máximo (true) o no lo hacen nunca (false)
bool BOSalza(int cbope, int bocda){ 
   int k = bocda-1;
   //Print(cbope);
   while ( High[k] < High[cbope] && k>0 ){  //Sigue buscando
      k--;
   }
   if(k!=0 && cbope!=0){ //<-------- k!=0 implica que no llegó a la vela de las 20hs. El cbope!=0 que hay al menos un máximo.
   return true;
   } 
   else{ //if(k==0)
   return false;
   }
}

bool BOSbaja(int cbopd, int bocdarr){ 
   int k = bocdarr-1;
   while ( Low[k] > Low[cbopd] && k>0){  //Sigue buscando
      k--;
   }
   if(k!=0 && cbopd!=0){
   return true;
   } 
   else{ //if(k==0)
   return false;
   }
}


int OBup(int posUp,int rLocal){
   datetime time;
   bool OB=True;
   for (int barrido = posUp-rLocal; barrido<= posUp+rLocal; barrido++){
      //Print("barrido: ",barrido, " ", High[pos]," ", High[barrido], High[pos]>High[barrido]);
      
      time = iTime(Symbol(), NULL, barrido);
      //ObjectCreate(0,barrido,OBJ_VLINE,0,time,0);  //<------------Marca lo que mira
      
      if ( High[posUp] < High[barrido]){
         OB=False;
      }
   }
   if (OB){
      time = iTime(Symbol(), NULL, posUp);
      int raux = rand();
      //ObjectCreate(NULL,raux,OBJ_VLINE,0,time,0);
      return posUp;
   }else{
      return 0;
   }
}


int OBdw(int posDw,int rLocal){
   datetime time;
   bool OB = True;
   for (int barrido = posDw-rLocal; barrido<= posDw+rLocal; barrido++){
      
      time = iTime(Symbol(), NULL, barrido);
      //ObjectCreate(raux,barrido,OBJ_VLINE,0,time,0);  //<------------Marca lo que mira
      
      if ( Low[posDw] > Low[barrido]){
         OB=False;
      }
   }
   if (OB){
      time = iTime(Symbol(), NULL, posDw);
      int raux2 = rand();
      //ObjectCreate(NULL,raux2,OBJ_VLINE,0,time,0);
      return posDw;
   }else{
      return False;
   }
}


bool MinimoHaciaElPresente(int N){ //busca mínimo inferior que el mínimo del bloque de orden N
   for (int i=N-1; i>=0; i--){ 
      //Print("AXIS: ", i, " ", N);
      if(Low[i]<=Low[N]){
         return false; //False si el bloque de orden es cubierto
      }
   }
   return true; 
}

bool MaximoHaciaElPresente(int N){ //busca máximo superior que el máximo del bloque de orden N
   for (int i=N-1; i>=0; i--){ 
      if(High[i]>=High[N]){
         return false; //False si el bloque de orden es cubierto
      } 
   }
   return true; 
}

//double queTantoSeComio


void DrawlinesUp(){
   for (int m=0; m<=ArraySize(arrUmbralUp)-1; m++){
      int time = iTime(Symbol(), NULL, arrUmbralUp[m]);
      int rAux = rand();
      ObjectCreate(0,m+rAux,OBJ_VLINE,0,time,0);
      ObjectSet(m+rAux, OBJPROP_COLOR, Blue);
      ObjectSet(m+rAux, OBJPROP_STYLE, STYLE_DOT);
   }
}

void DrawlinesDw(){
   for (int m=0; m<=ArraySize(arrUmbralDw)-1; m++){
      int time = iTime(Symbol(), NULL, arrUmbralDw[m]);
      int rAux = rand();
      ObjectCreate(0,m+rAux,OBJ_VLINE,0,time,0);
      ObjectSet(m+rAux, OBJPROP_COLOR, Green);
      ObjectSet(m+rAux, OBJPROP_STYLE, STYLE_DOT);
   }
}

void DrawRango(){
   int time = iTime(Symbol(), NULL, 0);
   int rAux = rand();
   ObjectCreate(0,rAux,OBJ_VLINE,0,time,0);
   ObjectSet(rAux, OBJPROP_COLOR, Gray);

   time = iTime(Symbol(), NULL, 2);
   rAux = rand();
   ObjectCreate(0,rAux,OBJ_VLINE,0,time,0);
   ObjectSet(rAux, OBJPROP_COLOR, Purple);
   
   time = iTime(Symbol(), NULL, 24);
   rAux = rand();
   ObjectCreate(0,rAux,OBJ_VLINE,0,time,0);
   ObjectSet(rAux, OBJPROP_COLOR, Gray);

   time = iTime(Symbol(), NULL, 16);
   rAux = rand();
   ObjectCreate(0,rAux,OBJ_VLINE,0,time,0);
   ObjectSet(rAux, OBJPROP_COLOR, Purple);
}

// genera los dos rectángulos en Rango Mayor y Asia

void GenerarRectangulos(){
   //Observación: 1) En el rectángulo,Los minutos del comienzo del rectángulo coinciden con los del fin del mismo (idem para el rango Asia)
   //             2) RM = rango mayor. RA = Rango Asia
   
   
   // ------------------------------------- RANGO ASIA -------------------------------------
   // Rango Asia de 12 a 19hs GMT +2.
   datetime timeRA1 = StrToTime(StringConcatenate(HoraFin-RangoHoras+4, ":", MinutoFin, ":00")); //fin del rango mayor
   int ShiftComienzo_RA = iBarShift( NULL, Period(),timeRA1); //seguramente sea cero
   //double price1 = iOpen(NULL, Period(), ShiftComienzo_RM);
   double priceRA1 = MaxEnRango(12,0,19, 0);
   
   datetime timeRA2 = StrToTime(StringConcatenate(HoraFin-1, ":", MinutoFin, ":00")); //fin del rango mayor
   int ShiftFin_RA = iBarShift( NULL, Period(),timeRA2); //seguramente sea cero
   //double price2 = iOpen(NULL, Period(), ShiftFin_RM);
   double priceRA2 = MinEnRango(12,0,19, 0);
   
   //RectangleCreate(0,"Rango Total",0,time1,price1,time2,price2,clr=clrLightGray, style=STYLE_SOLID,width=1,fill=true,back=false,selection=false,hidden=true,z_order=0);
   int randomico=rand();
   RectangleCreate(0,randomico,0,timeRA1,priceRA1,timeRA2,priceRA2,clrLightSkyBlue, STYLE_SOLID,1,true,false,false,true,0);
   // -------------------------------------            -------------------------------------
   
   
   // ------------------------------------- RANGO MAYOR -------------------------------------
   datetime timeRM1 = StrToTime(StringConcatenate(HoraFin-RangoHoras, ":", MinutoFin, ":00")); //fin del rango mayor
   int ShiftComienzo_RM = iBarShift( NULL, Period(),timeRM1); //seguramente sea cero
   //double price1 = iOpen(NULL, Period(), ShiftComienzo_RM);
   double priceRM1 = MaxEnRango(8,0,20, 0);
   
   datetime timeRM2 = StrToTime(StringConcatenate(HoraFin, ":", MinutoFin, ":00")); //fin del rango mayor
   int ShiftFin_RM = iBarShift( NULL, Period(),timeRM2); //seguramente sea cero
   //double price2 = iOpen(NULL, Period(), ShiftFin_RM);
   double priceRM2 = MinEnRango(8,0,20, 0);
   
   //RectangleCreate(0,"Rango Total",0,time1,price1,time2,price2,clr=clrLightGray, style=STYLE_SOLID,width=1,fill=true,back=false,selection=false,hidden=true,z_order=0);
   RectangleCreate(0,randomico+1,0,timeRM1,priceRM1,timeRM2,priceRM2,clrLightGray, STYLE_SOLID,1,true,false,false,true,0);
   // -------------------------------------             -------------------------------------
}

// Para el rectangle (MaxEnRango y MinEnRango):
int MaxEnRango(int HoraInicioRG,int MinutoInicioRG,int HoraFinRG, int MinutoFinRG){
   
   datetime timeInicioRG = StrToTime(StringConcatenate(HoraInicioRG, ":", MinutoInicioRG, ":00")); //
   int ShiftInicioRM = iBarShift( NULL, Period(),timeInicioRG); 
   //double price1 = iOpen(NULL, Period(), ShiftComienzo_RM);
   //Print("datetime: ",timeInicioRG," ShiftInicioRM ", ShiftInicioRM); // datetime: 2021.01.20 08:00:00 ShiftInicioRM 24

   datetime timeFinRG = StrToTime(StringConcatenate(HoraFinRG, ":", MinutoFinRG, ":00")); 
   int ShiftFinRM = iBarShift( NULL, Period(),timeFinRG);
   //Print("datetime: ",timeFinRG," ShiftInicioRM ", ShiftFinRM); // datetime: 2021.01.20 20:00:00 ShiftInicioRM 0

   
   double MaxValue = High[ShiftFinRM];
   for (int k = ShiftFinRM; k<= ShiftInicioRM; k++){ // como se cuenta del presente para atrás, el fin está más cerca que el inicio.
      //datetime time = iTime(Symbol(), NULL, k);
      //Print("tiempoooooooooooo ", time);
      if ( MaxValue < High[k]){
         MaxValue=High[k]; 
      }
   }
   return MaxValue;

}

int MinEnRango(int HoraInicioRG,int MinutoInicioRG,int HoraFinRG, int MinutoFinRG){
   
   datetime timeInicioRG = StrToTime(StringConcatenate(HoraInicioRG, ":", MinutoInicioRG, ":00")); //
   int ShiftInicioRM = iBarShift( NULL, Period(),timeInicioRG); 
   //double price1 = iOpen(NULL, Period(), ShiftComienzo_RM);

   datetime timeFinRG = StrToTime(StringConcatenate(HoraFinRG, ":", MinutoFinRG, ":00")); 
   int ShiftFinRM = iBarShift( NULL, Period(),timeFinRG);
   
   double MinValue = Low[ShiftFinRM];
   for (int k = ShiftFinRM+1; k<= ShiftInicioRM; k++){ // como se cuenta del presente para atrás, el fin está más cerca que el inicio.
      //time = iTime(Symbol(), NULL, k);
      
      if ( MinValue > Low[k]){
         MinValue=Low[k]; 
      }
   }
   return MinValue;

}


double Calculador_Pendiente(int pos){
   double diff;
   int barrido;
   double mean1=0;
   double mean2=0;
   int count1=0;
   int count2=0;
   double FactorPendiente;
   for (barrido = pos-regionLocal+1; barrido<= pos; barrido++){
      count1++;
      diff = High[barrido-1]-High[barrido];
      diff = NormalizeDouble(diff,4);
      mean1 = (mean1*(count1-1) + diff)/(count1); //Calculo el valor medio de forma iterativa
      //Print(" 1 ", barrido, " ", barrido-1," ", diff, " ");
   }
   for (barrido = pos+1; barrido<= pos+regionLocal; barrido++){
      count2++;
      diff = High[barrido-1]-High[barrido];
      diff = NormalizeDouble(diff,4);
      mean2 = (mean2*(count2-1) + diff)/(count2); //Calculo el valor medio de forma iterativa
      //Print(" 2 ", barrido, " ", barrido-1," " , diff, " ");
   }
   
   FactorPendiente = (MathAbs(mean1) + MathAbs(mean2))/regionLocal;
   //Print("media 1: ", mean1);
   //Print("media 2: ", mean2);
   //Print("Factor pendiente:", FactorPendiente);
   Print("FP: ", FactorPendiente);
   return FactorPendiente;
}

/*
double Calculador_Concavidad(int pos, int regionLocal){
   for (int barrido = pos-regionLocal; barrido<= pos+regionLocal; barrido++){
      double diff = (High[barrido-1]-2*High[barrido]+High[barrido+1])/2;
      diff = NormalizeDouble(diff,4);
      Print(barrido, " ", diff);
   }
   return 0;
}
*/