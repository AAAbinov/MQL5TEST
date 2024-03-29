//+------------------------------------------------------------------+
//|                                                  TradeSignal.mqh |
//|                                         Copyright 2019, Art Abin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Art Abin"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|Структура торговых сигналов                                       |
//+------------------------------------------------------------------+
struct sSignal
  {
   bool              Buy;//Покупка
   bool              Sell;//Продажа
                     sSignal()
     {
      Buy=false;
      Sell=false;
     }
  };
//+------------------------------------------------------------------+
//|Класс торговых сигналов                                           |
//+------------------------------------------------------------------+
class CTradeSignal
  {
private:
   int               m_period_BB;//период индикатора ББ
   int               m_handle_BB;
   sSignal           Buy_OR_Sell();

public:
   void              InitVar(int periodBB);
   bool              SignalBuy();
   bool              SignalSell();
                     CTradeSignal();
                    ~CTradeSignal();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
sSignal    CTradeSignal::Buy_OR_Sell()
  {
   sSignal res;

   double BBH[];
   ArraySetAsSeries(BBH, true);
   CopyBuffer(m_handle_BB,1,0,1,BBH); //UPPER_BAND

   double BBL[];
   ArraySetAsSeries(BBL, true);
   CopyBuffer(m_handle_BB,2,0,1,BBL); //LOWER_BAND

   MqlTick last_tick;
   SymbolInfoTick(_Symbol, last_tick);

//---BUY
   if(last_tick.bid<BBL[0])
     {
      res.Buy = true;
     }
//---SELL
   if(last_tick.bid>BBH[0])
     {
      res.Sell = true;
     }

   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTradeSignal::SignalBuy()
  {
   sSignal res = Buy_OR_Sell();

   return res.Buy;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTradeSignal::SignalSell()
  {
   sSignal res = Buy_OR_Sell();

   return res.Sell;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTradeSignal::InitVar(int periodBB)//метод инициализации входных данных
  {
   m_period_BB = periodBB;
   m_handle_BB = iBands(_Symbol, _Period, m_period_BB, 0, 2.0, PRICE_CLOSE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTradeSignal::CTradeSignal()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTradeSignal::~CTradeSignal()
  {
  }
//+------------------------------------------------------------------+
