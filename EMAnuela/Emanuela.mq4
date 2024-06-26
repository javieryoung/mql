//+------------------------------------------------------------------+
//|                                              La vela Definitiva  |
//|                                                     Javier Young |
//|                                                 https://young.uy |
//+------------------------------------------------------------------+
#property copyright "Plap"
#property link      "https://www.plolencio.com"
#property version   "1.00"
#property strict

input int Magic = 394;

input int EMA_chekeet = 25;
input int EMA_medeen = 50;
input int EMA_grandoot = 100;
input int patras = 15;
input int changuy = 5;
// Licencia
input string   licencia  =  ""; // Clave
string key = "desquiciadaComunv1.10yo";

double standardLot = 10000;

double min;
double max;

bool tiende;
bool sube;
bool subio;
bool baja;
bool bajo;
bool estoylistoabajo = false;
bool estoylistoarriba = false;
bool chekie=false;
int auxiguy = changuy;
int racha = 0;
int esperar = changuy;
double EMArmotachico;
double EMAmediano;
double EMAgrande;


#include <../Experts/LicenceCheck.mqh>
#include <../Experts/FuncionesComunes.mqh>

bool existeSubeOBaja (bool &subiendo , bool &bajando, int shif);

int OnInit(){

   long  account  =  AccountInfoInteger(ACCOUNT_LOGIN);
   if (!in_array(account)){
      Print("CUENTA INVALIDA");
      return(INIT_FAILED);
   }      
   
   Print("MODE_LOTSIZE = ", MarketInfo(Symbol(), MODE_LOTSIZE));
   Print("MODE_TICKVALUE = ", MarketInfo(Symbol(), MODE_TICKVALUE));
   Print("DIGITS = ", Digits);
   Print("POINT = ", Point);
   Print("SYMBOL = ", Symbol());
   Print("STOPLEVEL = ", MarketInfo( Symbol(), MODE_STOPLEVEL ));

   Print("Se cargó el Expert a la gráfica...");
   if (!faltainfo() && existeSubeOBaja(sube, baja, patras) && (sube || baja)) {
      racha = patras;
      chekie = true;
   }
   Comment("hola");
   Print("hola2");
   return(INIT_SUCCEEDED);
   

}
  
void OnDeinit(const int reason) {
   
   Print("Se eliminó el Expert de la gráfica...");
}
  

void OnTick() {
   if (chekie) {
      if (isNewCandle() && (tiende || subio || bajo)) {
         
         if ((sube || subio) && (!estoylistoabajo)) {
            tiende = existeSubeOBaja(sube, baja, 2);
            if (sube) {
               racha++;
            } else if (racha > patras && auxiguy > 0) {
                  auxiguy--;
                  subio = true;
            } else  {
               racha = 0;
               subio = false;
            }
            EMArmotachico = iMA(Symbol(), PERIOD_CURRENT, EMA_chekeet, 0, MODE_EMA, PRICE_CLOSE, 1);
            EMAmediano = iMA(Symbol(), PERIOD_CURRENT, EMA_medeen, 0, MODE_EMA, PRICE_CLOSE, 1);
            EMAgrande = iMA(Symbol(), PERIOD_CURRENT, EMA_grandoot, 0, MODE_EMA, PRICE_CLOSE, 1);
            if (racha > patras && auxiguy > 0 && (High[1] <  EMArmotachico || High[1] < EMAmediano) && Low[1] > EMAgrande) {
               estoylistoabajo = true;
               sube = false;
               subio = false;
               racha = 0;
               auxiguy = 0;
            }
         }
         if ((baja || bajo) && (!estoylistoarriba)) {
            tiende = existeSubeOBaja(sube, baja, 2);
            if (baja) {
               racha++;
            } else if (racha > patras && auxiguy > 0) {
                  auxiguy--;
                  bajo = true;
            } else {
               racha = 0;
               bajo = false;
               auxiguy = changuy;
            }
         }   else if (estoylistoabajo) {
            esperar--;
            if (High[1] > EMArmotachico && esperar > 0) {
               Operamosuba();
               esperar = changuy;
            } else if (esperar == 0) {
               estoylistoabajo = false;
               esperar = changuy;
            }
         } else if (estoylistoarriba) {
            esperar--;
            if (Low[1] < EMArmotachico && esperar > 0) {
               Operamosbaja();
               esperar = changuy;
            } else if (esperar == 0) {
               estoylistoarriba = false;
               esperar = changuy;
            }
         }
            
      }  
      
   } else if (!faltainfo()) {
      tiende = existeSubeOBaja(sube, baja, patras);
      if (tiende) racha = patras;
      chekie = true;
   }
}
 
   
///Todo esto de tendiendo y el chequeo debería ser una función auxiliar que se llame cuando se castea el bot y hasta que de bien, 
///y ahí marcar que tiende o no y ya no llamarla más e ir chequeando cada nueva vela con la anterior, recordando y marcando tendencias asi.

bool existeSubeOBaja(bool &subiendo , bool &bajando, int shif){

   bool tendiendo = true;
   bajando=false;
   subiendo=false;
   ///CAMBIAR patras > 0 SI NO FUNCA ASI
   
      while (shif > 1 && tendiendo) {
      
         double EMAc1 = iMA(Symbol(), PERIOD_CURRENT, EMA_chekeet, 0, MODE_EMA, PRICE_CLOSE, shif-1);
         double EMAm1 = iMA(Symbol(), PERIOD_CURRENT, EMA_medeen, 0, MODE_EMA, PRICE_CLOSE, shif-1);
         double EMAg1 = iMA(Symbol(), PERIOD_CURRENT, EMA_grandoot, 0, MODE_EMA, PRICE_CLOSE, shif-1);
         double EMAc2 = iMA(Symbol(), PERIOD_CURRENT, EMA_chekeet, 0, MODE_EMA, PRICE_CLOSE, shif);
         double EMAm2 = iMA(Symbol(), PERIOD_CURRENT, EMA_medeen, 0, MODE_EMA, PRICE_CLOSE, shif);
         double EMAg2 = iMA(Symbol(), PERIOD_CURRENT, EMA_grandoot, 0, MODE_EMA, PRICE_CLOSE, shif);
         
         //si vienen subiendo los tres EMAs, tienden
         if ((EMAc1 > EMAc2) && (EMAm1 > EMAm2) && (EMAg1 > EMAg2)) {
            //Si vienen en orden, ema chico primero, mediano por debajo y grande debajo de los otros dos.
            if ((EMAc1 > EMAm1) && (EMAm1 > EMAg1)) {
               subiendo = true;
            } else {
               tendiendo = false;
               subiendo = false;
            }
            //si vienen bajando los tres EMAs, tienden tambien
         } else if ((EMAc1 < EMAc2) && (EMAm1 < EMAm2) && (EMAg1 < EMAg2)) {
            //Si vienen en orden, ema chico primero, mediano por encima y grande por encima de los otros dos.
            if ((EMAg1 > EMAm1) && (EMAm1 > EMAc1)) {
               bajando = true;
            } else {
               tendiendo = false;
               subiendo = false;
            }
         } 
         else {
            tendiendo = false;
         }
         
         shif--;
       
      
      }
   
   
   return tendiendo;
}

bool faltainfo(){
   if (iClose(0,0,patras) != 0) 
      return false;
   else return true;
}
   
   
         //DUDAS: 
         //Es necesario que durante todo el tiempo estén en orden los EMAs? Cuánto debería ser el valor de patras? Optimizable pero preguntar
         //Es inmediato? Ni bien cruza el EMA? O se espera a algo en particular? Que se cierre la vela?
         //Si vienen subiendo los tres EMAs
         //Cuánto esperar una vez esté abajo
   
   
void Operamosuba() { //toma la compra donde cerró la vela anterior, con SL la distancia hasta EMA 50 y TP de eso x1,5
   
   double estoplo = iMA(Symbol(), PERIOD_CURRENT, EMA_medeen, 0, MODE_EMA, PRICE_CLOSE, 1);
   double tepe = estoplo * 1.5;
   double volume = calculateLotSize(Ask-estoplo);
   OrderSend(_Symbol, OP_BUY, volume, Ask, 0.01, NormalizeDouble(estoplo, Digits), NormalizeDouble(tepe, Digits), "no comments" , Magic);
}

void Operamosbaja() {
   double estoplo = iMA(Symbol(), PERIOD_CURRENT, EMA_medeen, 0, MODE_EMA, PRICE_CLOSE, 1);
   double tepe = estoplo * 1.5;
   double volume = calculateLotSize(estoplo-Bid);
   OrderSend(_Symbol, OP_SELL, volume, Bid, 0.01, NormalizeDouble(estoplo, Digits), NormalizeDouble(tepe, Digits), "no coments", Magic);
}

















/*
Medias móviles exponenciales
25
50
100
temp 5min


Los 3 emas en la misma dirección (parriba o pabajo)

Velas fuera del EMA más chiquiteet

De pronto entran en la línea de 25 o incluso 50 EMA
Cuando vuelva a romper los 25 EMA por el otro lado, opera.
Digamos que fue compra, el SL queda en EMA 50 y el TP en donde se te cante (limite de perdidas)
Si pasa de los 100 ya no

https://www.youtube.com/watch?v=Q85ZsFK5WK8


ETAPA 1: Los 3 EMAs en la misma direccion
	subetapa 1: Los 3 EMAs en orden, de menor a mayor, sea que suban o que bajen. 
		Si tiende al alza, EMA chico > EMA mediano > EMA grande
		Si tiende a la baja EMA chico < EMA mediano < EMA grande
	
	Este chequeo se puede hacer un primero para ver como viene la tendencia en las ultimas N velas y luego tick a tick si es una vela nueva
	Idea: Usar una funcion auxiliar para chequear esto, y llamarla solo cuando se inicializa el bot, si el retorno es exitoso que cambie una bandera para ya no ser llamada más, y que de ahí en más solo chequee tendencia vela a vela, y si cumple que llega a las necesarias para que sea considerado tendencia (N velas) lo marca como tendencia.

	Subetapa 2: Dependiendo de la tendencia:
		Si la tendencia es al alza, que las velas estén por encima del EMA de 25 (también, por un período de N velas)
		Si la tendencia es a la baja, que las velas estén por debajo del EMA de 25 (N velas)

ETAPA 2: Vela rompe EMA 25 y hasta EMA 50 (NO LLEGA A EMA 100, si llega se cancela y hasta nuevo aviso)
	
	Idea (con alza pero viceversa para baja): Luego de chequear que se den las condiciones (dejamos como true alguna bandera) esperar chequeando (tendriamos que determinar cuantas velas de baja le damos de aire antes de decir que ya no sirve, pues aqui se rompe un poco la tendencia que marca la operacion) , si llega a darse que una vela se encuentra por debajo de EMA25 o incluso EMA 50, pero sin llegar a tocar EMA 100, seguimos esperando (aqui bandera si toca EMA 100 ponele), si luego se da que no tocó EMA 100 y la vela cierra por encima de EMA 25 nuevamente, se compra, con SL del cierre de esa vela hasta EMA 50 y TP eso x1.5
*/