//+------------------------------------------------------------------+
//|                                              X-bars_Fractals.mq5 |
//|                                            Copyright 2011, Rone. |
//|                                            rone.sergey@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, Rone."
#property link      "rone.sergey@gmail.com"
#property version   "1.00"
#property description "The indicator allows to set the number of bars on the left and on the right sides of the fractal separately. Is suitable for "
#property description "both local and global extremums."
//--- indicator buffers
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot UpFractals
#property indicator_label1  "Up Fractals"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DnFractals
#property indicator_label2  "Down Fractals"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrTomato
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input int      InpLeftSide = 3;          // Number of bars to the left of the fractal
input int      InpRightSide = 3;         // Number of bars to the right of the fractal
//--- indicator buffers
double         UpFractalsBuffer[];
double         DnFractalsBuffer[];
//--- global variables
int            minRequiredBars;
int            leftSide, rightSide;
int            maxSide;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//---
   if ( InpLeftSide < 1 ) {
      leftSide = 2;
      printf("Invalid parameter value \"Number of bars to the left of the fractal\": %d. The value used: %d.",
         InpLeftSide, leftSide);
   } else {
      leftSide = InpLeftSide;
   }
   if ( InpRightSide < 1 ) {
      rightSide = 2;
      printf("Invalid parameter value \"Number of bars to the right of the fractal\": %d. The value used: %d.",
         InpRightSide, rightSide);
   } else {
      rightSide = InpRightSide;
   }
//---
   minRequiredBars = leftSide + rightSide + 1;
   maxSide = int(MathMax(leftSide, rightSide));
//---
   SetIndexBuffer(0, UpFractalsBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, DnFractalsBuffer, INDICATOR_DATA);
//---
   PlotIndexSetInteger(0, PLOT_ARROW, 217);
   PlotIndexSetInteger(1, PLOT_ARROW, 218);
//---
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, -10);  
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, 10);
//---
   for ( int i = 0; i < 2; i++ ) {
      PlotIndexSetInteger(i, PLOT_DRAW_BEGIN, minRequiredBars);
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0.0);
   }
//---
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
//---
   IndicatorSetString(INDICATOR_SHORTNAME, "X-bars Fractals ("+(string)leftSide+", "+(string)rightSide+")");
//---
   return(0);
}
//+------------------------------------------------------------------+
//| Check if is Up Fractal function                                  |
//+------------------------------------------------------------------+
bool isUpFractal(int bar, int max, const double &High[]) {
//---
   for ( int i = 1; i <= max; i++ ) {
      if ( i <= leftSide && High[bar] < High[bar-i] ) {
         return(false);
      }
      if ( i <= rightSide && High[bar] <= High[bar+i] ) {
         return(false);
      }
   }
//---
   return(true);  
}
//+------------------------------------------------------------------+
//| Check if is Down Fractal function                                |
//+------------------------------------------------------------------+
bool isDnFractal(int bar, int max, const double &Low[]) {
//---
   for ( int i = 1; i <= max; i++ ) {
      if ( i <= leftSide && Low[bar] > Low[bar-i] ) {
         return(false);
      }
      if ( i <= rightSide && Low[bar] >= Low[bar+i] ) {
         return(false);
      }
   }
//---
   return(true);  
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
//---
   int startBar, lastBar;
//---
   if ( rates_total < minRequiredBars ) {
      Print("Not enough data for calculation");
      return(0);
   }
//---
   if (prev_calculated < minRequiredBars) {
      startBar = leftSide;
      ArrayInitialize(UpFractalsBuffer, 0.0);
      ArrayInitialize(DnFractalsBuffer, 0.0);
   }        
   else {
      startBar = rates_total - minRequiredBars;
   }
//---
   lastBar = rates_total - rightSide;
   for ( int bar = startBar; bar < lastBar && !IsStopped(); bar++ ) {
      //---
      if ( isUpFractal(bar, maxSide, high) ) {
         UpFractalsBuffer[bar] = high[bar];
      } else {
         UpFractalsBuffer[bar] = 0.0;
      }
      //---
      if ( isDnFractal(bar, maxSide, low) ) {
         DnFractalsBuffer[bar] = low[bar];
      } else {
         DnFractalsBuffer[bar] = 0.0;
      }
   }  
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
