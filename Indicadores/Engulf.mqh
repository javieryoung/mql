//+------------------------------------------------------------------+
//|                                                     isEngulf.mqh |
//|                                                              plp |
//|                                         https://www.lolencio.com |
//+------------------------------------------------------------------+
#property copyright "plp"
#property link      "https://www.lolencio.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

//isEngulfing se fija si la barra en la que le pasan como primer parametro esta engulfeando a la anterior. El segundo parametro dibuja linea en engulf si se le pasa true, sino no hace nada.
bool isEngulfing (int pos, bool debug=false) {
   Print ("Aca estaria siendo utilizada la funcion isEngulfing");
   if ((Close[pos] < Open[pos] && Close[pos+1] > Open[pos+1]) || (Close[pos] > Open[pos] && Close[pos+1] < Open[pos+1])) {
      if (High[pos+1] < High[pos] && Low[pos+1] > Low[pos] && debug){
         drawVerticalLine(pos);
         Print("Como ta pa una linea ahora mismo");
         return true;
      } else {
         Print("Como ta pa no dibujarse una linea para nada ahora");
         return (High[pos+1] < High[pos] && Low[pos+1] > Low[pos]);
      }
    } else {
    Print("No sirvo para nada");
      return false;
    }
}

int lastEngulf (int pos) {
   if (isEngulfing(pos))
      return pos;
   else
      return lastEngulf(pos+1);
}

void drawVerticalLine (int pos){
   datetime time = iTime(Symbol(), NULL, pos);
   string rand = IntegerToString(MathRand());
   ObjectCreate(0,rand,OBJ_VLINE,0,time,0);
   ObjectSetInteger(0,rand,OBJPROP_STYLE,STYLE_DOT);
}