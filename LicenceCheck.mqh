/*
   LicenceCheck.mqh
   Copyright 2021, Orchard Forex
*/

#property copyright "Copyright 2013-2020, Orchard Forex"
#property link      "https://orchardforex.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  LicenceCheck(string licence="", string key = "")
  { 

   bool  valid =  true;
   
   // CHECKEO DE SIMBOLOS HABILITADOS
   // deberia ser algo como #define  LIC_SYMBOLS {  "GBPUSD", "USDCAD"   }
   #ifdef LIC_SYMBOLS
      valid =  false;
      string   validSymbols[] =  LIC_SYMBOLS;
      for(int i=ArraySize(validSymbols)-1; i>=0; i--)
        {
         if(Symbol()==validSymbols[i])
           {
            valid =  true;
            break;
           }
        }
      if(!valid)
        {
         Print("This is a limited trial version, it will not work with symbol " + Symbol());
         return(false);
        }
   #endif
   
   
   // CHECKEO DE MODOS DE CUENTA (demo o real)
   // deberia ser algo como #define  LIC_TRADE_MODES      {  ACCOUNT_TRADE_MODE_CONTEST, ACCOUNT_TRADE_MODE_DEMO, ACCOUNT_TRADE_MODE_REAL }
   #ifdef LIC_TRADE_MODES
      valid =  false;
      int   validModes[]   =  LIC_TRADE_MODES;
      long  accountTradeMode  =  AccountInfoInteger(ACCOUNT_TRADE_MODE);
      for(int i=ArraySize(validModes)-1; i>=0; i--)
        {
         if(accountTradeMode==validModes[i])
           {
            valid =  true;
            break;
           }
        }
      if(!valid)
        {
         Print("Esta version es limitada y no aplica sobre tu tipo de cuenta");
         return(false);
        }
   #endif
   
   
   // CHECKEO DE FECHA DE VENCIMIENTO
   // EN EL EXPERT:
   //
   // #define  LIC_EXPIRES_DAYS  30
   // #define  LIC_EXPIRES_START D'2021.03.01'
   
   #ifdef LIC_EXPIRES_DAYS
   #ifndef LIC_EXPIRES_START
   #define LIC_EXPIRES_START  __DATETIME__
   #endif
   
      datetime expiredDate =  LIC_EXPIRES_START + (LIC_EXPIRES_DAYS*86400);
      PrintFormat("La licencia expira el %s", TimeToString(expiredDate));
      if(TimeCurrent()>expiredDate)
        {
         Print("Licencia expirada");
         return(false);
        }
   #endif
   
   
   
   long  account  =  AccountInfoInteger(ACCOUNT_LOGIN);
   string result  =  KeyGen(IntegerToString(account), key );

   if(result!=licence)
     {
      Print("Clave inválida");
      return(false);
     }
   return(true);

  }


string KeyGen(string account, string privateKey)
  {

   uchar accountChar[];
   StringToCharArray(account+privateKey, accountChar);

   uchar keyChar[];
   StringToCharArray(privateKey, keyChar);

   uchar resultChar[];
   CryptEncode(CRYPT_HASH_SHA256, accountChar, keyChar, resultChar);
   CryptEncode(CRYPT_BASE64, resultChar, resultChar, resultChar);

   string result  =  CharArrayToString(resultChar);
   return(result);

  }
//+------------------------------------------------------------------+
