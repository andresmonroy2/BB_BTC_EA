//+------------------------------------------------------------------+
//| BB_BTC_EA_v8_1 - Institutional Hardening Edition (Audited)       |
//+------------------------------------------------------------------+
#property version   "8.1"

#include <Trade/Trade.mqh>
CTrade trade;

//=========================== INPUTS =================================
input double RiskPercent              = 1.0;
input int    BB_Period                = 20;
input double BB_Deviation             = 2.0;

input int    StopLossPoints           = 1000;
input int    TakeProfitPoints         = 1500;

input int    MaxRetriesPerBar         = 3;
input int    MaxSpreadPoints          = 300;
input int    SlippagePoints           = 50;

input int    MaxConsecutiveLosses     = 3;
input double MaxDailyDrawdownPercent  = 5.0;

input ulong  MagicNumber              = 888888;

//=========================== GLOBALS =================================
int      bbHandle = INVALID_HANDLE;

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
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
      return INIT_FAILED;

   if(SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_FULL)
      return INIT_FAILED;

   bbHandle = iBands(_Symbol,_Period,BB_Period,0,BB_Deviation,PRICE_CLOSE);
   if(bbHandle == INVALID_HANDLE)
      return INIT_FAILED;

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
   if(bbHandle != INVALID_HANDLE)
      IndicatorRelease(bbHandle);
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
   if(HistoryDealSelect(dealTicket))
   {
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

   if(BarsCalculated(bbHandle) < BB_Period)
      return;

   double upper[1], lower[1];
   if(CopyBuffer(bbHandle,1,1,1,upper) <= 0) return;
   if(CopyBuffer(bbHandle,2,1,1,lower) <= 0) return;

   double closePrev = iClose(_Symbol,_Period,1);
   if(closePrev <= 0) return;

   bool completed = false;

   if(closePrev > upper[0])
      completed = ExecuteTrade(ORDER_TYPE_SELL);
   else if(closePrev < lower[0])
      completed = ExecuteTrade(ORDER_TYPE_BUY);
   else
      completed = true;

   if(completed)
      lastBarTime = currentBar;
}

//====================== EXECUTION ===================================
bool ExecuteTrade(ENUM_ORDER_TYPE type)
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

   // AUDITORÍA: Filtro cruzado de seguridad (Stops Level + Freeze Level)
   long stopLevel   = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   long freezeLevel = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   long executionLimit = MathMax(stopLevel, freezeLevel);

   if(StopLossPoints < executionLimit || TakeProfitPoints < executionLimit)
   {
      Print("ERROR: Parámetros SL/TP dentro de la zona de restricción del broker.");
      return true;
   }

   double price = (type == ORDER_TYPE_BUY) ? tick.ask : tick.bid;

   double sl = (type == ORDER_TYPE_BUY) ?
      NormalizeDouble(price - StopLossPoints*_Point,_Digits) :
      NormalizeDouble(price + StopLossPoints*_Point,_Digits);

   double tp = (type == ORDER_TYPE_BUY) ?
      NormalizeDouble(price + TakeProfitPoints*_Point,_Digits) :
      NormalizeDouble(price - TakeProfitPoints*_Point,_Digits);

   double lot = CalculateLotSize(type,price);
   if(lot <= 0)
      return true;

   bool sent = (type == ORDER_TYPE_BUY) ?
      trade.Buy(lot,_Symbol,price,sl,tp) :
      trade.Sell(lot,_Symbol,price,sl,tp);

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
      return false; // Permite reintentar con precios frescos en el siguiente tick
   }

   return true;
}

//====================== LOT CALC ====================================
double CalculateLotSize(ENUM_ORDER_TYPE type,double price)
{
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double riskMoney = equity * RiskPercent / 100.0;

   double tickValue = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);

   if(tickValue<=0 || tickSize<=0)
      return 0;

   double valuePerLot = StopLossPoints * (_Point/tickSize) * tickValue;
   if(valuePerLot<=0)
      return 0;

   double rawLot = riskMoney / valuePerLot;

   double minLot  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double stepLot = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);

   if(rawLot < minLot)
      return 0;

   double lot = MathFloor(rawLot/stepLot) * stepLot;
   lot = MathMin(lot,maxLot);

   double marginReq;
   if(!OrderCalcMargin(type,_Symbol,lot,price,marginReq))
      return 0;

   if(marginReq > AccountInfoDouble(ACCOUNT_MARGIN_FREE))
   {
      Print("CRÍTICO: Margen insuficiente para el lote institucional calculado.");
      return 0;
   }

   return lot;
}

//====================== POSITION CHECK ===============================
bool PositionExists()
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      if(PositionGetTicket(i)>0)
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
