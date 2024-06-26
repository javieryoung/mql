//+------------------------------------------------------------------+
//|                                                     La vela Loca |
//|                                                     Javier Young |
//|                                                 https://young.uy |
//+------------------------------------------------------------------+
#property copyright "Javier Young"
#property link      "https://young.uy"
#property version   "1.10"
#property strict

int Magic = 1202;
#include <../Experts/FuncionesComunes.mqh>

input int intentos = 6;
input bool usarLotes = false; // usar lotes fijos en vez que risk
input double lotes = 1;

string horas[14] =                 { "16:30:00", "16:35:00", "16:31:00", "16:32:00", "16:36:00", "16:40:00", "17:00:00", "16:33:00", "16:34:00", "16:37:00", "16:45:00", "16:38:00", "16:39:00", "16:50:00" };
string horasCerrarPendientes[14] = { "16:31:00", "16:36:00", "16:32:00", "16:33:00", "16:37:00", "16:41:00", "17:01:00", "16:34:00", "16:35:00", "16:38:00", "16:46:00", "16:39:00", "16:40:00", "16:51:00", "17:30:00" };
int iteracion = 3;

double max = 0.0;
double min = 30000000.0;
int diaActual = 0;
int ticketBuy;
int ticketSell;
int ultimoBalance;

double profitMasBajo = 0;

#include <../Experts/Maniática/ManiaticaLocaUS30.mqh>


int combinacionActual = 0;

int fileHandler;

int OnInit() {
   Print("Se cargó el Expert a la gráfica...");
   ultimoBalance = AccountBalance();
   diaActual = Day();
   
   
   Print("Iteracion");
   Print(iteracion);
   
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason) {
   Print("Se eliminó el Expert a la gráfica...");
   Print("Profit más bajo: ", profitMasBajo);
}



double profit = 0;
int velasYaOperadas = 0;
void OnTick() {

   if (diaActual != Day()) {
      diaActual = Day();
      reloadParameters();
      velasYaOperadas = 0;
   }
   
   
   if (isNewCandle()) {
      
      datetime candleTime = iTime(Symbol(), 0, 0);
      
      for (int i = 0; i < ArraySize(horasCerrarPendientes); i++) {
         datetime time = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day(), " ", horasCerrarPendientes[i]));
         if (candleTime == time) {
            cerrarPendientes();
         }
      }
      
      for (int i = 0; i < ArraySize(horas); i++) {
         datetime time = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day(), " ", horas[i]));
         if (candleTime == time) { 
            combinacionActual = i;
            abrirPending();
            velasYaOperadas++;
         }
      }
      
      
   }
   if (breakEvenFactor > 0 && trailingStopFactor==0) checkBreakEven();
   if (trailingStopFactor > 0) checkTrailingStop();
      
}

void reloadParameters() {
   for (int i = 0; i < iteracion; i++) {
      combinaciones[combinacionActual][i][3] = 0;
      combinaciones[combinacionActual][i][4] = 0;
      combinaciones[combinacionActual][i][5] = 0; // 0 si aun no se agrego al CSV
   }
}



void cerrarPendientes() {
   for(int i = OrdersTotal(); i >= 0; i--){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
            
            if (OrderType() == OP_BUYSTOP) {
               OrderDelete(OrderTicket());
            }
            
            if (OrderType() == OP_SELLSTOP) {
               OrderDelete(OrderTicket());
            }   
            
         }
      }
   }
}






// se fija si hay pending orders abiertas de buy y sell, y abre las que correspondan
void abrirPending() {
   
   reloadTodayProfit(); 
   
   double useRisk = risk;
   if (!usarLotes) {
      double profitTodayPercent = (profit * 100) / cuenta; // guarda el profit hecho hasta ahora con esta estrateiga
      
      double riesgoDisponible = risk;
      
      // si estamos en profit asumo el riesgo un poco mayor (le sumamos la mitad de lo ganado hasta ahora)
      if (profitTodayPercent > 0)
         riesgoDisponible = (profitTodayPercent / 2) + risk; // (guardamos la mitad para no quemarnos todo el profit de una)
      
      int useIntentos = intentos; // intentaremos operar en las siguientes X velas
      int velasQueRestanOperar = ArraySize(horas) - velasYaOperadas; // cantidad de velas que aun tenemos que operar (contando la actual)
      if (velasQueRestanOperar < intentos)  // pero si no quedan tantas velas, intentaremos operar en las que queden
         useIntentos = velasQueRestanOperar;
         
      double velaRisk = (riesgoDisponible / useIntentos);
      
      if (-profitTodayPercent >= risk) return ; // por las dudas
      if (velaRisk > risk) velaRisk = risk; // por las dudas
      
      int seAbriran = iteracion * 2; // operaciones (x2 porque se pueden abrir compra y venta)
      useRisk = velaRisk / seAbriran;
   } 
   
   
   for (int i = 0; i < iteracion; i++) {
      if (combinaciones[combinacionActual][i][0]) {
      
         double mpo = combinaciones[combinacionActual][i][2] / dividirEntre;
         
         max = Ask + mpo;
         min = Bid - mpo;
         
         double volume = calculateLotSizeWithRisk(combinaciones[combinacionActual][i][0] / dividirEntre, useRisk);
         if (usarLotes) volume = lotes;
         Print("Volume: ", volume);
         double sl = NormalizeDouble(combinaciones[combinacionActual][i][0] / dividirEntre, Digits);
         double tp = NormalizeDouble(combinaciones[combinacionActual][i][1] / dividirEntre, Digits);
         double spread = MarketInfo( Symbol(), MODE_SPREAD );
         
         string comment = StringConcatenate(combinaciones[combinacionActual][i][0], ";", combinaciones[combinacionActual][i][1], ";", combinaciones[combinacionActual][i][2],  ";", spread); 
         
         ticketBuy = OrderSend(Symbol(), OP_BUYSTOP, volume, max, 0.1, NormalizeDouble(max-sl, Digits), NormalizeDouble(max+tp, Digits), comment, Magic);
         ticketSell = OrderSend(Symbol(), OP_SELLSTOP, volume, min, 0.1, NormalizeDouble(min+sl, Digits), NormalizeDouble(min-tp, Digits), comment, Magic);
         combinaciones[combinacionActual][i][3] = ticketBuy;
         combinaciones[combinacionActual][i][4] = ticketSell;
      }
   }
   
}




double calculateLotSizeWithRisk(double SL, double riskInput) {
   string baseCurr = StringSubstr(Symbol(),0,3);
   string crossCurr = StringSubstr(Symbol(),3,3);
    
   double lotSize = MarketInfo(Symbol(), MODE_LOTSIZE);
   
   double volume;
   if(crossCurr == AccountCurrency()) {
      volume = (cuenta * (riskInput / 100.0)) / (SL * lotSize);
    } else if(baseCurr == AccountCurrency()) {
      volume = (cuenta * (riskInput / 100.0)) / (SL * lotSize * Ask);
    } else {
      volume = (cuenta * (riskInput / 100.0)) / (SL * lotSize);
    }
    
    double maxLots= MarketInfo(Symbol(), MODE_MAXLOT);
    if (volume > maxLots) volume = maxLots;
    
    
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   
   int digits = 0;
   if (lotStep == 0.001) digits = 3;
   if (lotStep == 0.01) digits = 2;
   if (lotStep == 0.1) digits = 1;
   if (lotStep == 1) digits = 0;
    
   return NormalizeDouble(volume, digits);
}








void reloadTodayProfit() {

   profit = 0;
   int TotaleStorico = OrdersHistoryTotal();
   for(int i = 0; i < TotaleStorico ; i++) {
      datetime today = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day(), " 01:00:00"));
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderMagicNumber() == Magic && OrderOpenTime() > today) {
         if (OrderCloseTime() != 0 && OrderClosePrice() != 0) {
            profit += OrderProfit() + OrderSwap() + OrderCommission();
         }
      }   
   }
   Print("Profit: ", profit);
   
   
   double profitTodayPercent = (profit * 100) / cuenta;
   
   if (profit < profitMasBajo) profitMasBajo = profit;
   
   Print("% Profit: ", profitTodayPercent);
   
}


