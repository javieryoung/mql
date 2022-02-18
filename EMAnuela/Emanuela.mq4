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
input int patras = 5;
// Licencia
input string   licencia  =  ""; // Clave
string key = "desquiciadaComunv1.10yo";

double standardLot = 10000;

double min;
double max;

int diaActual = 0;
int operacionesHechasHoy = 0;
int ticketBuy;
int ticketSell;
int ultimoBalance;



bool tendiendo;
bool bajando;
bool subiendo;


#include <../Experts/LicenceCheck.mqh>
#include <../Experts/FuncionesComunes.mqh>


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
   
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason) {
   
   Print("Se eliminó el Expert a la gráfica...");
   ultimoBalance = AccountBalance();
   diaActual = Day();
}
  
bool  abriHoy = false;
void OnTick() {

   ///Todo esto de tendiendo y el chequeo debería ser una función auxiliar que se llame cuando se castea el bot y hasta que de bien, 
   ///y ahí marcar que tiende o no y ya no llamarla más e ir chequeando cada nueva vela con la anterior, recordando y marcando tendencias asi.
   tendiendo = true;
   bajando=true;
   subiendo=true;
   ///CAMBIAR patras > 1 SI NO FUNCA ASI
   while (patras > 0 && tendiendo) {
   

      double EMAc1 = iMA(Symbol(), PERIOD_CURRENT, EMA_chekeet, 0, MODE_EMA, PRICE_CLOSE, patras-1);
      double EMAm1 = iMA(Symbol(), PERIOD_CURRENT, EMA_medeen, 0, MODE_EMA, PRICE_CLOSE, patras-1);
      double EMAg1 = iMA(Symbol(), PERIOD_CURRENT, EMA_grandoot, 0, MODE_EMA, PRICE_CLOSE, patras-1);
      double EMAc2 = iMA(Symbol(), PERIOD_CURRENT, EMA_chekeet, 0, MODE_EMA, PRICE_CLOSE, patras);
      double EMAm2 = iMA(Symbol(), PERIOD_CURRENT, EMA_medeen, 0, MODE_EMA, PRICE_CLOSE, patras);
      double EMAg2 = iMA(Symbol(), PERIOD_CURRENT, EMA_grandoot, 0, MODE_EMA, PRICE_CLOSE, patras);
      //Si los EMA están todos yendo pal mismo lado
      if (((EMAc1 > EMAc2) && (EMAm1 > EMAm2) && (EMAg1 > EMAg2)) || ((EMAc1 < EMAc2) && (EMAm1 < EMAm2) && (EMAg1 < EMAg2))) {
         //Si vienen en orden, ema chico primero, mediano despues y grande despues, o al reves.
         if ((EMAc1 > EMAm1) && (EMAm1 > EMAg1)) {
            
         } else if ((EMAg1 > EMAm1) && (EMAm1 > EMAc1)) {
         
         }
      } else {
         tendiendo = false;
      }
      
      
      //Si vienen subiendo los tres EMAs
      if ((EMAc1 > EMAc2) && (EMAm1 > EMAm2) && (EMAg1 > EMAg2)) {
         //Si vienen en orden, ema chico primero, mediano por debajo y grande debajo de los otros dos.
         if ((EMAc1 > EMAm1) && (EMAm1 > EMAg1)) {
            subiendo = true;
         }
         //si vienen bajando los tres EMAs
      } else if ((EMAc1 < EMAc2) && (EMAm1 < EMAm2) && (EMAg1 < EMAg2)) {
         //Si vienen en orden, ema chico primero, mediano por encima y grande por encima de los otros dos.
         if ((EMAg1 > EMAm1) && (EMAm1 > EMAc1)) {
            bajando = true;
         }
      } else {
         tendiendo = false;
      }
      
      patras--;
      
   }
   
   
   
   
   datetime candleTime = iTime(Symbol(), 0, 0);
   datetime time = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day(), " ", IntegerToString(horaComienzo), ":", IntegerToString(minutoComienzo), ":00"));
   if (candleTime == time && Seconds() >= segundoComienzo && !abriHoy) {
      Print("Segundos: ", Seconds());
      abriHoy = true;
      abrirPending();
   }
     
     
   datetime timeClose = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day(), " ", IntegerToString(horaFin), ":", IntegerToString(minutoFin), ":00"));
   if (candleTime == timeClose) { 
      cerrarPendientes();
      abriHoy = false;
   }
      
   
   if (cerrarSiHayTp) checkSiCerro();
   if (breakEvenFactor > 0 && trailingStopFactor==0) checkBreakEven();
   if (trailingStopFactor > 0) checkTrailingStop();
   
}



double sl() {
    return sl / dividirEntre;
}


double tp() {
    return tp / dividirEntre;
}



// se fija si hay pending orders abiertas de buy y sell, y abre las que correspondan
void abrirPending() {
      double Spread = MarketInfo(Symbol(), MODE_SPREAD);
      // Calculo max y min para poner buy y sell stop
      calcularMinimoYMaximo();
      
      double volume = calculateLotSize(sl());      
      
      double tpCompra;
      if (trailingStopFactor > 0 && !forzarTp) 
         tpCompra = 0;
      else 
         if (minimoParaOperar == 0)
            tpCompra = Ask+tp();
         else
            tpCompra = max+tp();
            
      operacionesHechasHoy++;
      
      double ts = NormalizeDouble(trailingStopFactor / dividirEntre, Digits);
      double mpo = NormalizeDouble(minimoParaOperar / dividirEntre, Digits);
      double mpul  = NormalizeDouble(minimoParaUsarLoca / dividirEntre, Digits);
      
      string comment = StringConcatenate("SL=", sl(), ";TS=", ts, ";MPO=", mpo, ";MPUL=", mpul); 
      
      if (minimoSpread > Spread) {

         if (abrirCompra) {
            if (minimoParaOperar == 0)
               ticketBuy = OrderSend(Symbol(), OP_BUY, volume, Ask, 0.01, NormalizeDouble(Ask-sl(), Digits), NormalizeDouble(tpCompra,Digits), comment, Magic);
            else
               ticketBuy = OrderSend(Symbol(), OP_BUYSTOP, volume, max, 0.01, NormalizeDouble(max-sl(), Digits), NormalizeDouble(tpCompra,Digits), comment, Magic);
         }
         
         string commentVenta = StringConcatenate("Venta ", IntegerToString(Magic));
         double tpVenta;
         if (trailingStopFactor > 0 && !forzarTp) 
            tpVenta = 0;
         else 
            if (minimoParaOperar == 0)
               tpVenta = Bid-tp();
            else
               tpVenta = min-tp();
         operacionesHechasHoy++;
         
         if (abrirVenta) {
            if (minimoParaOperar == 0) 
               ticketSell = OrderSend(Symbol(), OP_SELL, volume, Bid, 0.01, NormalizeDouble(Bid+sl(), Digits), NormalizeDouble(tpVenta,Digits), comment, Magic);
            else
               ticketSell = OrderSend(Symbol(), OP_SELLSTOP, volume, min, 0.01, NormalizeDouble(min+sl(), Digits), NormalizeDouble(tpVenta,Digits), comment, Magic);
         }
      }

}


void cerrarPendientes() {
   for(int i = OrdersTotal(); i >= 0; i--){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
            
            if (OrderType() == OP_BUYSTOP) {
               OrderDelete(OrderTicket());
               operacionesHechasHoy--;
            }   
            
            if (OrderType() == OP_SELLSTOP) {
               OrderDelete(OrderTicket());
               operacionesHechasHoy--;
            }   
            
         }
      }
   }
}

void calcularMinimoYMaximo() { 
   
   int hour = Hour();
   int minutes = Minute()-1;
   if (minutes == -1){
      minutes = 60;
      hour = hour -1;
   }
   
   datetime time = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day(), " ", IntegerToString(hour) ,":", IntegerToString(minutes),":00"));
   int shift = iBarShift(NULL, PERIOD_M1, time);
   max = iHigh(NULL, PERIOD_M1,shift);
   min = iLow(NULL, PERIOD_M1,shift);
   
   
   if (max-min > minimoParaUsarLoca/dividirEntre) {
      max = Ask + minimoParaOperar/dividirEntre;
      min = Bid - minimoParaOperar/dividirEntre;
   } 
   
   double minimumDistance = MarketInfo( Symbol(), MODE_STOPLEVEL ) * Point;
   if (max < Ask + minimumDistance) { // Solo sucede si la el maximo de la vela anterior esta muy cerca de el cierre de la misma 
      max = Ask + minimoParaOperar/dividirEntre;
   }
   
   if (Bid - minimumDistance < min) {
      min = Bid - minimoParaOperar/dividirEntre;
   }
   
   max = NormalizeDouble(max, Digits);
   min = NormalizeDouble(min, Digits);
   
}




void checkSiCerro() {
   if(OrderSelect(ticketBuy, SELECT_BY_TICKET)) {
      if (OrderCloseTime() != 0 && (MathAbs( OrderClosePrice() - OrderTakeProfit() ) < 1) && OrderSelect(ticketSell, SELECT_BY_TICKET)) {
         OrderDelete(ticketSell);
         ticketSell = 0;
      }
   }
   if(OrderSelect(ticketSell, SELECT_BY_TICKET)) {
      if (OrderCloseTime() != 0 && (MathAbs( OrderClosePrice() - OrderTakeProfit() ) < 1) && OrderSelect(ticketBuy, SELECT_BY_TICKET)){
         OrderDelete(ticketBuy);
         ticketBuy = 0;
      }
   }
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