//+------------------------------------------------------------------+
//|                                                  SpreadWawes.mq4 |
//|                                      Copyright © 2015, MMQuants. |
//+------------------------------------------------------------------+
#property copyright "Maro - MMQuants"
#property version   "1.10"
#property indicator_chart_window
#property strict
#property description "SpreadWaves is simple indicator for MT4"
#property description "It shows current spread and also shows Min and Max spread levels"
#property description "from its initializing moment on the current chart and time-frame."
#property description "In addition you can see current swap values."

extern int GUIposX = 5;
extern int GUIposY = 35;

const int levels = 9;
color blocksColors[] = {clrDarkGreen, clrGreen, clrYellowGreen, clrLightYellow, clrYellow, clrDarkOrange, clrOrangeRed, clrRed, clrDarkRed};   
int spreadFontSize = 20;
int swapFontSize = 20;
int minSpread;
int maxSpread;
int spread;
int deviator;

//+------------------------------------------------------------------+

int init()
{   
   SetFontsSizes();
   deviator = FindDeviator();
   minSpread = 1000;
   maxSpread = 0;
   SetSpreadValues();

   DrawGraphics(GUIposX, GUIposY);
   return(0);
}
//+------------------------------------------------------------------+
int deinit()
{
   CleanUpGraphics();
   Comment("");
   return 0;
}
//+------------------------------------------------------------------+

int start() 
{
   SetSpreadValues();
   UpdateData();
   ChartRedraw();
   return 0;
}

void DrawGraphics(int posX, int posY)
{
   CreateBack("wavesBack", posX, posY, C'128,128,128',clrLightBlue,115,159);
   CreateLevelBlocks("levelBlock", posX + 82, posY + 141, blocksColors);
   //spread
   CreateRectLabel("wavesMaxSpread", posX + 4, posY + 3, C'180,180,180', clrBlack, 74, 18);
   CreateLabel("wavesMaxSpreadText", posX + 7, posY + 3, spreadFontSize, blocksColors[levels-1]);
   CreateRectLabel("wavesMinSpread", posX + 4, posY + 139, C'180,180,180', clrBlack, 74, 18);
   CreateLabel("wavesMinSpreadText", posX + 7, posY + 139, spreadFontSize, blocksColors[0]);
   CreateRectLabel("wavesCurrSpread", posX + 4, posY + 69, C'180,180,180', clrBlack, 74, 19);
   CreateLabel("wavesCurrSpreadText", posX + 6, posY + 69, spreadFontSize, clrBlack);
   ObjectSetInteger(0, "wavesCurrSpread", OBJPROP_WIDTH,2);
   //swaps
   CreateRectLabel("wavesSwapShort", posX, posY + 164, C'128,128,128', clrLightBlue, 115, 18);
   CreateLabel("wavesSwapShortText", posX + 1, posY + 164, swapFontSize, clrWhiteSmoke);
   CreateRectLabel("wavesSwapLongt", posX, posY + 187, C'128,128,128', clrLightBlue, 115, 18);
   CreateLabel("wavesSwapLongText", posX + 1, posY + 187, swapFontSize, clrWhiteSmoke); 
}

void CreateLevelBlocks(string name, int x, int y, color &colors[])
{
   for(int i=0; i < levels; i++)
     {      
         CreateRectLabel(name + IntegerToString(i), x, y, colors[i], clrWhite, 30, 14);
         y = y - 17;
     }
}

void CreateBack(string name, int x, int y, color back_clr, color line_clr, int w, int h)
{
   CreateRectLabel(name, x, y, back_clr, line_clr, w, h);
   ObjectSetInteger(0,name,OBJPROP_BACK, true);
}

void CreateRectLabel(string name, int x, int y, color back_clr, color line_clr, int w, int h)
{
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_CORNER, 0);
   ObjectSetInteger(0, name, OBJPROP_COLOR,line_clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_WIDTH,1);
}

void CreateLabel(string name, int x, int y, int font_size, color clr)
{
   ObjectCreate(0, name, OBJ_LABEL, 0,0,0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_CORNER, 0);
   ObjectSetString(0, name, OBJPROP_TEXT, "MinSpread");
   ObjectSetString(0, name, OBJPROP_FONT,"Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, font_size);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, 5);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
}

void CleanUpGraphics()
{
   ObjectDelete(0, "wavesBack");
   
   for(int i=0; i<levels; i++)
   {
      ObjectDelete(0, "levelBlock" + IntegerToString(i));
   }
     
   ObjectDelete(0, "wavesMaxSpread");
   ObjectDelete(0, "wavesMaxSpreadText");
   ObjectDelete(0, "wavesCurrSpread");
   ObjectDelete(0, "wavesCurrSpreadText");
   ObjectDelete(0, "wavesMinSpread");
   ObjectDelete(0, "wavesMinSpreadText");
   ObjectDelete(0, "wavesSwapShort");
   ObjectDelete(0, "wavesSwapShortText");
   ObjectDelete(0, "wavesSwapLongt");
   ObjectDelete(0, "wavesSwapLongText");
}

void UpdateData()
{
   if(minSpread == maxSpread)
   {
      ObjectSetString(0, "wavesCurrSpreadText", OBJPROP_TEXT, "Fixed:" + DoubleToStr((double)spread/deviator, 1));
      ObjectSetInteger(0, "wavesMaxSpreadText", OBJPROP_TIMEFRAMES,-1);
      ObjectSetInteger(0, "wavesMaxSpread", OBJPROP_TIMEFRAMES,-1);
      ObjectSetInteger(0, "wavesMinSpreadText", OBJPROP_TIMEFRAMES,-1);
      ObjectSetInteger(0, "wavesMinSpread", OBJPROP_TIMEFRAMES,-1);  
   }
   else
   {    
      ObjectSetInteger(0, "wavesMaxSpread", OBJPROP_TIMEFRAMES, 0);
      ObjectSetInteger(0, "wavesMaxSpreadText", OBJPROP_TIMEFRAMES, 0);
      ObjectSetInteger(0, "wavesMinSpread", OBJPROP_TIMEFRAMES, 0);
      ObjectSetInteger(0, "wavesMinSpreadText", OBJPROP_TIMEFRAMES, 0);
      ObjectSetInteger(0, "wavesCurrSpreadText", OBJPROP_TIMEFRAMES,-1);
      ObjectSetInteger(0, "wavesCurrSpread", OBJPROP_TIMEFRAMES,-1);
      ObjectSetInteger(0, "wavesCurrSpread", OBJPROP_TIMEFRAMES, 0);
      ObjectSetInteger(0, "wavesCurrSpreadText", OBJPROP_TIMEFRAMES, 0);
      
      ObjectSetString(0, "wavesMaxSpreadText", OBJPROP_TEXT, "Max: " + DoubleToStr((double)maxSpread/deviator, 1));
      ObjectSetString(0, "wavesCurrSpreadText", OBJPROP_TEXT, "Curr: " + DoubleToStr((double)spread/deviator, 1));
      ObjectSetString(0, "wavesMinSpreadText", OBJPROP_TEXT, "Min: " + DoubleToStr((double)minSpread/deviator, 1));
      
      MoveWaves(GUIposY);
   }
   
   ObjectSetString(0, "wavesSwapShortText", OBJPROP_TEXT, "SwapShort: " + 
      DoubleToStr(MarketInfo(Symbol(), MODE_SWAPSHORT), 2));
   ObjectSetString(0, "wavesSwapLongText", OBJPROP_TEXT, "SwapLong: " + 
      DoubleToStr(MarketInfo(Symbol(), MODE_SWAPLONG), 2));
}

void MoveWaves(int posY)
{
   int waveLevel = (int)MathRound(((double)(spread - minSpread) / (maxSpread - minSpread)) * (levels - 1));
   
   for(int i=0; i < levels; i++)
     {
         if(i > waveLevel)
         {
            ObjectSetInteger(0, "levelBlock" + (string)(i), OBJPROP_BGCOLOR, C'55,55,55');
            ObjectSetInteger(0, "levelBlock" + (string)(i), OBJPROP_BACK, true);
         }
         else
         {
            ObjectSetInteger(0, "levelBlock" + (string)(i), OBJPROP_BGCOLOR, blocksColors[i]);
            ObjectSetInteger(0, "levelBlock" + (string)(i), OBJPROP_BACK, false);
         }
     }
   
   ObjectSetInteger(0, "wavesCurrSpread", OBJPROP_YDISTANCE, posY + 139 - 17 * waveLevel);
   ObjectSetInteger(0, "wavesCurrSpread", OBJPROP_COLOR, blocksColors[waveLevel]);
   ObjectSetInteger(0, "wavesCurrSpreadText", OBJPROP_YDISTANCE, posY + 139 - 17 * waveLevel);
}

void SetSpreadValues()
{
   spread = (int)MarketInfo(Symbol(), MODE_SPREAD);
     
   if(spread < minSpread)
     {
         minSpread = spread;
     }
   if(spread > maxSpread)
     {
         maxSpread = spread;
     }
}

int FindDeviator()
{
   int calcDeviator = 0;
   int CalcDigits =  Digits();
   
   if (CalcDigits == 2 || CalcDigits == 4) 
   {
      calcDeviator = 1;
   }
   else if (CalcDigits == 3 || CalcDigits == 5 )
   {
      calcDeviator = 10;
   }
   
   if(calcDeviator == 0)
   {
      Print("Deviator calculation error", GetLastError());
      return -1;
   }
   else
   {
      return calcDeviator;
   }
}

void SetFontsSizes()
{
   uint width = 0;
   uint height = 0;
   
   while(true)
   {
      TextSetFont("Arial", -spreadFontSize * 10);
      TextGetSize("Max: 0.0", width, height);
      if(height <= 19)
      {
         break;
      }
      else
      {
         spreadFontSize--;
      }
   }
   
   while(true)
   {
      TextSetFont("Arial", -swapFontSize * 10);
      TextGetSize("SwapShort: -0.00", width, height);
      if(height <= 18 && width < 115)
      {
         break;
      }
      else
      {
         swapFontSize--;
      }
   }
}