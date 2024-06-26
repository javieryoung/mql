
int arrUp[];
int arrDw[];

int arrTrueDw[];
int arrTrueUp[];

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
            if(todosLosCandidatos[sizeTodos] * todosLosCandidatos[sizeTodos-1] < 0){  // Se fija si hay max o min consecutivos
               // Array de los candidatos arriba
               ArrayResize(arrUp, size + 1);  // Si están intercalados, hace lo de siempre
               arrUp[size] = posicionesUp;
            } else {
               arrUp[size-1] = posicionesUp;  // De lo contrario, sobreescribe el último del vector (sobreescribe al más cercano en el tiempo con el más lejano)
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
            if(todosLosCandidatos[sizeTodos] * todosLosCandidatos[sizeTodos-1] < 0){
               // Array de los candidatos arriba
               ArrayResize(arrDw, size + 1);
               arrDw[size] = posicionesDw;
            } else {
               arrDw[size-1] = posicionesDw;
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
      //Print(i);
      int BOcandidatoDeAbajo = arrDw[i];
      int closerBOporEncima = BuscarValorCercanoAbajo(BOcandidatoDeAbajo);
      bool rupturaEstructuraDesdeAbajo = BOSalza(closerBOporEncima, BOcandidatoDeAbajo);
      bool esMinElBO = MinimoHaciaElPresente(BOcandidatoDeAbajo);
      if (rupturaEstructuraDesdeAbajo && esMinElBO){
         int size = ArraySize(arrTrueDw);
         ArrayResize(arrTrueDw, size + 1);
         arrTrueDw[size] = BOcandidatoDeAbajo;
         //Print("SE AGREGO UN TRUE BO DOWN", arrTrueDw[size]);
      }
   }
}


void TrueOBup(){ //true order block para los valores maximos. Itera en todos
   for (int i=0; i<=ArraySize(arrUp)-1; i++){
   
      int BOcandidatoDeArriba = arrUp[i];
      int closerBOporDebajo = BuscarValorCercanoArriba(BOcandidatoDeArriba);
      bool rupturaEstructuraDesdeArriba = BOSbaja(closerBOporDebajo, BOcandidatoDeArriba);
      bool esMaxElBO = MaximoHaciaElPresente(BOcandidatoDeArriba);
      if (rupturaEstructuraDesdeArriba && esMaxElBO){
         int size = ArraySize(arrTrueUp);
         ArrayResize(arrTrueUp, size + 1);
         arrTrueUp[size] = BOcandidatoDeArriba;
         //Print("SE AGREGO UN TRUE BO UP", arrTrueUp[size]);
      }
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
   Print(cbope);
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
      //Print("barrido: ",barrido, " ", High[pos]," ", High[barrido], High[pos]>High[barrido]);
      
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
      return 0;
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
   for (int m=6969; m<=ArraySize(arrTrueUp)-1+6969; m++){
      int time = iTime(Symbol(), NULL, arrTrueUp[m-6969]);
      ObjectCreate(0,m,OBJ_VLINE,0,time,0);
      ObjectSet(m, OBJPROP_COLOR, Green);
      ObjectSet(m, OBJPROP_STYLE, STYLE_DOT);
   }
}

void DrawlinesDw(){
   for (int m=0; m<=ArraySize(arrTrueDw)-1; m++){
      int time = iTime(Symbol(), NULL, arrTrueDw[m]);
      ObjectCreate(0,m,OBJ_VLINE,0,time,0);
      ObjectSet(m, OBJPROP_COLOR, Blue);
      ObjectSet(m, OBJPROP_STYLE, STYLE_DOT);
   }
}

int CalcularNvelas(int horas){
   int distMaxAux;
   Print("Temporalidad: ",Period(),Period()==PERIOD_M1);
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
   Print("distMax ",distMaxAux);
   return distMaxAux;   
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

double Calculador_Pendiente(int pos, int regionLocal){
   double diff;
   int barrido;
   double mean1=0;
   double mean2=0;
   int count1=0;
   int count2=0;
   double FactorPendiente;
   for (barrido = pos-regionLocal; barrido<= pos; barrido++){
      count1++;
      diff = High[barrido-1]-High[barrido];
      diff = NormalizeDouble(diff,4);
      mean1 = (mean1*(count1-1) + diff)/(count1); //Calculo el valor medio de forma iterativa
      Print(" 1 ", barrido," ", diff, " ");
   }
   for (barrido = pos+1; barrido<= pos+regionLocal+1; barrido++){
      count2++;
      diff = High[barrido-1]-High[barrido];
      diff = NormalizeDouble(diff,4);
      mean2 = (mean2*(count2-1) + diff)/(count2); //Calculo el valor medio de forma iterativa
      Print(" 2 ", barrido," " , diff, " ");
   }
   
   FactorPendiente = (MathAbs(mean1) + MathAbs(mean2))/regionLocal;
   Print("media 1: ", mean1);
   Print("media 2: ", mean2);
   Print("Factor pendiente:", FactorPendiente);
   return FactorPendiente;
}
*/