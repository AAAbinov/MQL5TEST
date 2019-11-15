//+------------------------------------------------------------------+
//|                                                     MA_Cross.mqh |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "..\ExpertSignal.mqh"   // класс CExpertSignal находится в файле ExpertSignal
#property tester_indicator "Examples\\Custom Moving Average.ex5"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Сигналы на пересечении двух средних                        |
//| Type=SignalAdvanced                                              |
//| Name=My_MA_Cross                                                 |
//| ShortName=MaCross                                                |
//| Class=MA_Cross                                                   |
//| Page=не нужно                                                    |
//| Parameter=FastPeriod,int,13,Period of fast MA                    |
//| Parameter=FastMethod,ENUM_MA_METHOD,MODE_SMA,Method of fast MA   |
//| Parameter=SlowPeriod,int,21,Period of slow MA                    |
//| Parameter=SlowMethod,ENUM_MA_METHOD,MODE_SMA,Method of slow MA   |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MA_Cross : public CExpertSignal
  {
private:
   CiCustom          m_fast_ma;        // индикатор в виде объекта
   CiCustom          m_slow_ma;        // индикатор в виде объекта
   //--- настраиваемые параметры модуля
   int               m_period_fast;    // период быстрой скользящей средней
   ENUM_MA_METHOD    m_method_fast;    // тип сглаживания быстрой скользящей средней
   int               m_period_slow;    // период медленной скользящей средней
   ENUM_MA_METHOD    m_method_slow;    // тип сглаживания медленной скользящей средней

public:
   //--- конструктор класса
                     MA_Cross(void);
   //--- деструктор класса
                    ~MA_Cross(void);
   //--- методы для установки 
   void              FastPeriod(const int value)               { m_period_fast=value;                }
   void              FastMethod(const ENUM_MA_METHOD value)    { m_method_fast=value;                }
   void              SlowPeriod(const int value)               { m_period_slow=value;                }
   void              SlowMethod(const ENUM_MA_METHOD value)    { m_method_slow=value;                }
   //--- проверка корректности входных данных
   bool              ValidationSettings(void);
   //--- создание индикаторов и таймсерий для работы модуля сигналов
   bool              InitIndicators(CIndicators *indicators);
   //--- доступ к данным индикаторов
   double            FastMA(const int index)             const { return(m_fast_ma.GetData(0,index)); }
   double            SlowMA(const int index)             const { return(m_slow_ma.GetData(0,index)); }
   //--- проверка условий на покупку и продажу
   virtual int       LongCondition();
   virtual int       ShortCondition();

protected:
   //--- создание индикаторов скользящих средних
   bool              CreateFastMA(CIndicators *indicators);
   bool              CreateSlowMA(CIndicators *indicators);
  };
//+------------------------------------------------------------------+
//| Конструктор                                                      |
//+------------------------------------------------------------------+
MA_Cross::MA_Cross(void) : m_period_fast(13),
                           m_method_fast(MODE_SMA),
                           m_period_slow(21),
                           m_method_slow(MODE_SMA)
  {
  }
//+------------------------------------------------------------------+
//| Деструктор                                                       |
//+------------------------------------------------------------------+
MA_Cross::~MA_Cross(void)
  {
  }
//+------------------------------------------------------------------+
//| проверяет входные параметры и возвращает true если всё OK        |
//+------------------------------------------------------------------+
bool MA_Cross::ValidationSettings(void)
  {
//--- вызываем метод базового класса
   if(!CExpertSignal::ValidationSettings()) return(false);
//--- проверим периоды, количество баров для расчета скользящей >=1
   if(m_period_fast<1 || m_period_slow<1)
     {
      PrintFormat("Неверно задано значение одного из периодов! FastPeriod=%d, SlowPeriod=%d",
                  m_period_fast,m_period_slow);
      return false;
     }
//--- период медленной должен быть больше периода быстрой скользящей
   if(m_period_fast>m_period_slow)
     {
      PrintFormat("SlowPeriod=%d должен быть больше чем FastPeriod=%d!",
                  m_period_slow,m_period_fast);
      return false;
     }
//--- тип сглаживания быстрой скользящей должен быть один из четырех значений перечисления
   if(m_method_fast!=MODE_SMA && m_method_fast!=MODE_EMA && m_method_fast!=MODE_SMMA && m_method_fast!=MODE_LWMA)
     {
      PrintFormat("Недопустимый тип сглаживания быстрой скользящей средней!");
      return false;
     }
//--- тип сглаживания медленной скользящей должен быть один из четырех значений перечисления
   if(m_method_slow!=MODE_SMA && m_method_slow!=MODE_EMA && m_method_slow!=MODE_SMMA && m_method_slow!=MODE_LWMA)
     {
      PrintFormat("Недопустимый тип сглаживания медленной скользящей средней!");
      return false;
     }
//--- все проверки прошли, значит, всё хорошо
   return true;
  }
//+------------------------------------------------------------------+
//| Создает индикаторы                                               |
//| На входе:  указатель на колллекцию индикаторов                   |
//| На выходе: true-при успешном выполнении, иначе false             |
//+------------------------------------------------------------------+
bool MA_Cross::InitIndicators(CIndicators *indicators)
  {
//--- стандартная проверка коллекции индикаторов на NULL
   if(indicators==NULL) return(false);
//--- инициализация индикаторов и таймсерий в дополнительных фильтрах
   if(!CExpertSignal::InitIndicators(indicators)) return(false);
//--- создание наших индикаторов скользящих средних
   if(!CreateFastMA(indicators))                  return(false);
   if(!CreateSlowMA(indicators))                  return(false);
//--- дошли до этого места, значит, функция выполнена успешно - вернем true
   return(true);
  }
//+------------------------------------------------------------------+
//| Создает индикатор "Быстрая MA"                                   |
//+------------------------------------------------------------------+
bool MA_Cross::CreateFastMA(CIndicators *indicators)
  {
//--- проверка указателя
   if(indicators==NULL) return(false);
//--- добавление объекта в коллекцию
   if(!indicators.Add(GetPointer(m_fast_ma)))
     {
      printf(__FUNCTION__+": ошибка добавления объекта быстрой MA");
      return(false);
     }
//--- задание параметров быстрой MA
   MqlParam parameters[4];
//---
   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="Examples\\Custom Moving Average.ex5";
   parameters[1].type=TYPE_INT;
   parameters[1].integer_value=m_period_fast;      // период
   parameters[2].type=TYPE_INT;
   parameters[2].integer_value=0;                  // смещение
   parameters[3].type=TYPE_INT;
   parameters[3].integer_value=m_method_fast;      // метод усреднения
//--- инициализация объекта  
   if(!m_fast_ma.Create(m_symbol.Name(),m_period,IND_CUSTOM,4,parameters))
     {
      printf(__FUNCTION__+": ошибка инициализации объекта быстрой MA");
      return(false);
     }
//--- количество буферов
   if(!m_fast_ma.NumBuffers(1)) return(false);
//--- дошли до этого места, значит, функция выполнена успешно - вернем true
   return(true);
  }
//+------------------------------------------------------------------+
//| Создает индикатор "Медленная MA"                                 |
//+------------------------------------------------------------------+
bool MA_Cross::CreateSlowMA(CIndicators *indicators)
  {
//--- проверка указателя
   if(indicators==NULL) return(false);
//--- добавление объекта в коллекцию
   if(!indicators.Add(GetPointer(m_slow_ma)))
     {
      printf(__FUNCTION__+": ошибка добавления объекта медленной MA");
      return(false);
     }
//--- задание параметров медленной MA
   MqlParam parameters[4];
//---
   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="Examples\\Custom Moving Average.ex5";
   parameters[1].type=TYPE_INT;
   parameters[1].integer_value=m_period_slow;      // период
   parameters[2].type=TYPE_INT;
   parameters[2].integer_value=0;                  // смещение
   parameters[3].type=TYPE_INT;
   parameters[3].integer_value=m_method_slow;      // метод усреднения
//--- инициализация объекта  
   if(!m_slow_ma.Create(m_symbol.Name(),m_period,IND_CUSTOM,4,parameters))
     {
      printf(__FUNCTION__+": ошибка инициализации объекта медленной MA");
      return(false);
     }
//--- количество буферов
   if(!m_slow_ma.NumBuffers(1)) return(false);
//--- дошли до этого места, значит, функция выполнена успешно - вернем true
   return(true);
  }
//+------------------------------------------------------------------+
//| Возвращает силу сигнала на покупку                               |
//+------------------------------------------------------------------+
int MA_Cross::LongCondition()
  {
   int signal=0;
//--- для режима работы по тикам idx=0, в режиме работы по сформировавшимся барам idx=1
   int idx=StartIndex();
//--- значения средних на последнем сформировавшемся баре
   double last_fast_value=FastMA(idx);
   double last_slow_value=SlowMA(idx);
//--- значения средних на предпоследнем сформировавшемся баре
   double prev_fast_value=FastMA(idx+1);
   double prev_slow_value=SlowMA(idx+1);
//--- если быстрая скользящая пробила снизу вверх медленную на последних двух закрытых барах
   if((last_fast_value>last_slow_value) && (prev_fast_value<prev_slow_value))
     {
      signal=100; // сигнал на покупку есть
     }
//--- вернем значение сигнала
   return(signal);
  }
//+------------------------------------------------------------------+
//| Возвращает силу сигнала на продажу                               |
//+------------------------------------------------------------------+
int MA_Cross::ShortCondition()
  {
   int signal=0;
//--- для режима работы по тикам idx=0, в режиме работы по сформировавшимся барам idx=1
   int idx=StartIndex();
//--- значения средних на последнем сформировавшемся баре
   double last_fast_value=FastMA(idx);
   double last_slow_value=SlowMA(idx);
//--- значения средних на предпоследнем сформировавшемся баре
   double prev_fast_value=FastMA(idx+1);
   double prev_slow_value=SlowMA(idx+1);
//--- если быстрая скользящая пробила сверху вниз медленную на последних двух закрытых барах
   if((last_fast_value<last_slow_value) && (prev_fast_value>prev_slow_value))
     {
      signal=100; // сигнал на породажу есть
     }
//--- вернем значение сигнала
   return(signal);
  }
//+------------------------------------------------------------------+
