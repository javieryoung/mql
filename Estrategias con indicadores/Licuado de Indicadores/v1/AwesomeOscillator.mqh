double SignalAwesomeOscillator = 0;

double checkAwesomeOscillator() {
   
   double ao = iAO(Symbol(), NULL, 0);
   double aoPrev = iAO(Symbol(), NULL, 1);
   if (aoPrev < 0 && ao > 0)
      SignalAwesomeOscillator = 1; // comprar
      
   if (ao < 0 && aoPrev > 0)
      SignalAwesomeOscillator = -1; // vender
      
   double toReturn = SignalAwesomeOscillator;
   SignalAwesomeOscillator = SignalAwesomeOscillator / desgasteDeSignal;
   return toReturn; 
}