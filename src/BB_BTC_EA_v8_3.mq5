//+------------------------------------------------------------------+
//| BB_BTC_EA_v8_3 - Institutional Hardening Edition (Production Ready) |
//+------------------------------------------------------------------+
#property version   "8.3"

#include <Trade/Trade.mqh>
CTrade trade;

//=========================== INPUTS =================================
input double RiskPercent              = 1.0;
input int    BB_Period                = 19;
input double BB_UpperDeviation        = 2.2;
input double BB_LowerDeviation        = 2.0;

input double StopLossPercent          = 3.0;
input bool   UseRecentLowStop         = false;
input int    RecentLowBars            = 3;
input bool   UseUpperBandTakeProfit   = true;

input int    MaxRetriesPerBar         = 3;
input int    MaxSpreadPoints          = 300;
input int    SlippagePoints           = 50;

input int    MaxConsecutiveLosses     = 3;
input double MaxDailyDrawdownPercent  = 5.0;

input ulong  MagicNumber              = 888888;

//=========================== GLOBALS =================================
int      maHandle      = INVALID_HANDLE;
int      stdDevHandle  = INVALID_HANDLE;

datetime lastBarTime = 0;
datetime observedBarTime = 0;

int      retryCount = 0;
int      consecutiveLosses = 0;

double   dailyStartEquity = 0.0;
int      currentDay = -1;
bool     dailyLock = false;

//+------------------------------------------------------------------+
int OnInit()
{
   if(_Period != PERIOD_D1)
   {
      Print("ERROR: La estrategia solo es compatible en temporalidad diaria (D1).");
      return INIT_FAILED;
   }

   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
   {
      Print("ERROR: Terminal no conectado.");
      return INIT_FAILED;
   }

   if(SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_FULL)
   {
      Print("ERROR: No es posible operar en modo de solo precios.");
      return INIT_FAILED;
   }

   maHandle = iMA(_Symbol,_Period,BB_Period,0,MODE_SMA,PRICE_CLOSE);
   stdDevHandle = iStdDev(_Symbol,_Period,BB_Period,0,MODE_SMA,PRICE_CLOSE);

   if(maHandle == INVALID_HANDLE || stdDevHandle == INVALID_HANDLE)
   {
      Print("ERROR: No se pudieron inicializar los indicadores de Bollinger.");
      return INIT_FAILED;
   }

   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetAsyncMode(false);
   trade.SetDeviationInPoints(SlippagePoints);

   ConfigureFillingMode();
   ResetDailyTracking();

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(maHandle != INVALID_HANDLE)
      IndicatorRelease(maHandle);
   if(stdDevHandle != INVALID_HANDLE)
      IndicatorRelease(stdDevHandle);
}

//====================== DAILY RESET ROBUSTO ==========================
void ResetDailyTracking()
{
   MqlDateTime dt;
   TimeToStruct(TimeTradeServer(),dt);

   currentDay = dt.day;
   dailyStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   dailyLock = false;
}

//+------------------------------------------------------------------+
void CheckDailyReset()
{
   MqlDateTime dt;
   TimeToStruct(TimeTradeServer(),dt);

   if(dt.day != currentDay)
      ResetDailyTracking();
}

//====================== TRADE TRANSACTION TRACKING (CORREGIDO) =======
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
{
   // AUDITORÍA: El evento DEAL_ADD solo provee de forma segura el trans.deal (ticket)
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD)
      return;

   ulong dealTicket = trans.deal;
   if(dealTicket <= 0) return;

   // Seleccionar explícitamente el trato desde la base de datos del terminal
   bool selected = false;
   for(int attempt = 0; attempt < 3; attempt++)
   {
      if(HistoryDealSelect(dealTicket))
      {
         selected = true;
         break;
      }
      Sleep(5);
   }
   if(!selected)
      return;

   long  dealMagic  = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
   string dealSymbol = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
   long  dealType   = HistoryDealGetInteger(dealTicket, DEAL_TYPE);

      if(dealMagic != MagicNumber || dealSymbol != _Symbol)
         return;

      // Filtrar únicamente tratos que cierren o modifiquen posición (DEAL_ENTRY_OUT / DEAL_ENTRY_INOUT)
      long dealEntry = HistoryDealGetInteger(dealTicket, DEAL_ENTRY);
      if(dealEntry == DEAL_ENTRY_OUT || dealEntry == DEAL_ENTRY_INOUT)
      {
         double profit = HistoryDealDouble(dealTicket, DEAL_PROFIT) + 
                         HistoryDealDouble(dealTicket, DEAL_COMMISSION) + 
                         HistoryDealDouble(dealTicket, DEAL_SWAP);

         if(profit < 0)
            consecutiveLosses++;
         else if(profit > 0)
            consecutiveLosses = 0;
      }
   }
}

//====================== CORE LOGIC ==================================
void OnTick()
{
   CheckDailyReset();

   if(dailyLock) return;

   if(!MQLInfoInteger(MQL_TRADE_ALLOWED) || !AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
      return;

   if(!CheckDailyDrawdown())
      return;

   if(consecutiveLosses >= MaxConsecutiveLosses)
   {
      Print("EA BLOQUEADO: Máximo de pérdidas consecutivas alcanzado.");
      return;
   }

   datetime currentBar = iTime(_Symbol,_Period,0);
   if(currentBar <= 0) return;

   if(currentBar != observedBarTime)
   {
      observedBarTime = currentBar;
      retryCount = 0;
   }

   if(currentBar == lastBarTime)
      return;

   if(BarsCalculated(maHandle) < BB_Period || BarsCalculated(stdDevHandle) < BB_Period)
      return;

   double closePrev = iClose(_Symbol,_Period,1);
   if(closePrev <= 0) return;

   double ma, upper, lower;
   if(!GetBollingerBands(ma, upper, lower, 1))
      return;

   if(PositionExists())
   {
      if(ClosePositionIfNeeded(closePrev, ma, upper))
         lastBarTime = currentBar;
      return;
   }

   if(closePrev <= lower)
   {
      if(ExecuteTrade(ORDER_TYPE_BUY, ma, upper))
         lastBarTime = currentBar;
   }
}

//====================== EXECUTION ===================================
bool ExecuteTrade(ENUM_ORDER_TYPE type,double ma,double upper)
{
   if(retryCount >= MaxRetriesPerBar)
      return true; // Bloqueo de la vela por exceso de reintentos

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick))
      return false;

   double spread = (tick.ask - tick.bid) / _Point;
   if(spread > MaxSpreadPoints)
      return false; // Spread inválido, revalúa en el siguiente tick

   if(PositionExists())
      return true;

   long stopLevel   = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   long freezeLevel = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   long executionLimit = MathMax(stopLevel, freezeLevel);

   double entryPrice = tick.ask;
   double sl;
   if(UseRecentLowStop)
   {
      double recentLow = GetRecentLow(RecentLowBars);
      if(recentLow <= 0)
      {
         Print("ERROR: No se pudo calcular el mínimo reciente para el SL.");
         return true;
      }
      sl = NormalizeDouble(recentLow - _Point * 10, _Digits);
   }
   else
   {
      sl = NormalizeDouble(entryPrice * (1.0 - StopLossPercent/100.0), _Digits);
   }

   double tp = 0;

   if(sl >= entryPrice)
   {
      Print("ERROR: SL no válido. SL=", sl, " precio=", entryPrice);
      return true;
   }

   if((entryPrice - sl)/_Point < executionLimit)
   {
      Print("ERROR: SL dentro de la zona de restricción del broker.");
      return true;
   }

   double lot = CalculateLotSize(entryPrice, sl);
   if(lot <= 0)
      return true;

   bool sent = trade.Buy(lot, _Symbol, entryPrice, sl, tp);
   uint ret = trade.ResultRetcode();

   if(sent && (ret == TRADE_RETCODE_DONE || ret == TRADE_RETCODE_PLACED))
   {
      retryCount = 0;
      return true;
   }

   if(ret == TRADE_RETCODE_REQUOTE || ret == TRADE_RETCODE_PRICE_CHANGED)
   {
      retryCount++;
      Print("RETRY: Requote detectado. Intento: ", retryCount);
      return false;
   }

   Print("ERROR: Orden de compra rechazada. Código: ", ret);
   return true;
}

//====================== LOT CALC ====================================
double CalculateLotSize(double price,double stopLoss)
{
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double riskMoney = equity * RiskPercent / 100.0;

   double lossPerUnit = MathAbs(price - stopLoss);
   if(lossPerUnit <= 0)
      return 0;

   double tickValue = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);

   if(tickValue <= 0 || tickSize <= 0)
      return 0;

   double valuePerLot = lossPerUnit / tickSize * tickValue;
   if(valuePerLot <= 0)
      return 0;

   double rawLot = riskMoney / valuePerLot;

   double minLot  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double stepLot = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(stepLot <= 0)
      return 0;

   if(rawLot < minLot)
      return 0;

   double lot = MathFloor(rawLot/stepLot) * stepLot;
   lot = MathMin(lot,maxLot);

   double marginReq;
   if(!OrderCalcMargin(ORDER_TYPE_BUY,_Symbol,lot,price,marginReq))
      return 0;

   if(marginReq > AccountInfoDouble(ACCOUNT_MARGIN_FREE))
   {
      Print("CRÍTICO: Margen insuficiente para el lote calculado.");
      return 0;
   }

   return lot;
}

bool GetBollingerBands(double &ma,double &upper,double &lower,int shift)
{
   double maArray[1];
   double stdDevArray[1];

   if(CopyBuffer(maHandle,0,shift,1,maArray) <= 0)
      return false;
   if(CopyBuffer(stdDevHandle,0,shift,1,stdDevArray) <= 0)
      return false;

   ma = maArray[0];
   double stdDev = stdDevArray[0];

   upper = ma + BB_UpperDeviation * stdDev;
   lower = ma - BB_LowerDeviation * stdDev;
   return true;
}

double GetRecentLow(int bars)
{
   int available = Bars(_Symbol,_Period);
   if(available < 2)
      return 0;

   int count = MathMin(bars, available - 1);
   if(count <= 0)
      return 0;

   double lows[];
   ArrayResize(lows,count);

   int copied = CopyLow(_Symbol,_Period,1,count,lows);
   if(copied <= 0)
      return 0;

   int index = ArrayMinimum(lows);
   if(index < 0 || index >= copied)
      return 0;

   double recentLow = lows[index];
   return (recentLow <= 0) ? 0 : recentLow;
}

bool CloseCurrentPosition()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == MagicNumber)
         {
            if(trade.PositionClose(ticket))
               return true;
            Print("ERROR: No se pudo cerrar la posición. Código: ", trade.ResultRetcode());
            return false;
         }
      }
   }
   return false;
}

bool ClosePositionIfNeeded(double closePrice,double ma,double upper)
{
   if(!PositionExists())
      return false;

   if(UseUpperBandTakeProfit)
   {
      if(closePrice > upper)
      {
         Print("Cierre por objetivo agresivo: cierre sobre banda superior.");
         return CloseCurrentPosition();
      }
   }
   else
   {
      if(closePrice > ma)
      {
         Print("Cierre por objetivo conservador: cierre sobre media móvil central.");
         return CloseCurrentPosition();
      }
   }

   return false;
}

//====================== POSITION CHECK ===============================
bool PositionExists()
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket==0) continue;
      // Select position explicitly by ticket before reading properties
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetString(POSITION_SYMBOL)==_Symbol &&
            PositionGetInteger(POSITION_MAGIC)==MagicNumber)
            return true;
      }
   }
   return false;
}

//====================== DAILY DD ====================================
bool CheckDailyDrawdown()
{
   if(dailyStartEquity <= 0)
      return true;

   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double dd = (dailyStartEquity - equity) / dailyStartEquity * 100.0;

   if(dd >= MaxDailyDrawdownPercent)
   {
      dailyLock = true;
      Print("ALERTA: Filtro de protección diario activo. Drawdown: ", DoubleToString(dd, 2), "%");
      return false;
   }

   return true;
}

//====================== FILLING MODE =================================
void ConfigureFillingMode()
{
   long filling = SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE);

   if((filling & SYMBOL_FILLING_FOK) == SYMBOL_FILLING_FOK)
      trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if((filling & SYMBOL_FILLING_IOC) == SYMBOL_FILLING_IOC)
      trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      trade.SetTypeFilling(ORDER_FILLING_RETURN);
}
