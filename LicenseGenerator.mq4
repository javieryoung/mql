/*
   LicenceGenerator
   Copyright 2021, Orchard Forex
*/
 
#property copyright "Copyright 2013-2020, Orchard Forex"
#property link      "https://orchardforex.com"
#property version   "1.00"
 
// this is important
#property strict
 
#property script_show_inputs
 
#include <../Experts/LicenceCheck.mqh>
 
input string   InpPrivateKey  =  "";
input string   InpAccount     =  "";
 
void OnInit() {
    
   string   key   =  KeyGen(InpAccount, InpPrivateKey);
   Alert("The key is " + key);
   Print("The Key is " + key);
}