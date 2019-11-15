//+------------------------------------------------------------------+
//|                                                     MA_Cross.mqh |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "..\ExpertSignal.mqh"   // ����� CExpertSignal ��������� � ����� ExpertSignal
#property tester_indicator "Examples\\Custom Moving Average.ex5"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=������� �� ����������� ���� �������                        |
//| Type=SignalAdvanced                                              |
//| Name=My_MA_Cross                                                 |
//| ShortName=MaCross                                                |
//| Class=MA_Cross                                                   |
//| Page=�� �����                                                    |
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
   CiCustom          m_fast_ma;        // ��������� � ���� �������
   CiCustom          m_slow_ma;        // ��������� � ���� �������
   //--- ������������� ��������� ������
   int               m_period_fast;    // ������ ������� ���������� �������
   ENUM_MA_METHOD    m_method_fast;    // ��� ����������� ������� ���������� �������
   int               m_period_slow;    // ������ ��������� ���������� �������
   ENUM_MA_METHOD    m_method_slow;    // ��� ����������� ��������� ���������� �������

public:
   //--- ����������� ������
                     MA_Cross(void);
   //--- ���������� ������
                    ~MA_Cross(void);
   //--- ������ ��� ��������� 
   void              FastPeriod(const int value)               { m_period_fast=value;                }
   void              FastMethod(const ENUM_MA_METHOD value)    { m_method_fast=value;                }
   void              SlowPeriod(const int value)               { m_period_slow=value;                }
   void              SlowMethod(const ENUM_MA_METHOD value)    { m_method_slow=value;                }
   //--- �������� ������������ ������� ������
   bool              ValidationSettings(void);
   //--- �������� ����������� � ��������� ��� ������ ������ ��������
   bool              InitIndicators(CIndicators *indicators);
   //--- ������ � ������ �����������
   double            FastMA(const int index)             const { return(m_fast_ma.GetData(0,index)); }
   double            SlowMA(const int index)             const { return(m_slow_ma.GetData(0,index)); }
   //--- �������� ������� �� ������� � �������
   virtual int       LongCondition();
   virtual int       ShortCondition();

protected:
   //--- �������� ����������� ���������� �������
   bool              CreateFastMA(CIndicators *indicators);
   bool              CreateSlowMA(CIndicators *indicators);
  };
//+------------------------------------------------------------------+
//| �����������                                                      |
//+------------------------------------------------------------------+
MA_Cross::MA_Cross(void) : m_period_fast(13),
                           m_method_fast(MODE_SMA),
                           m_period_slow(21),
                           m_method_slow(MODE_SMA)
  {
  }
//+------------------------------------------------------------------+
//| ����������                                                       |
//+------------------------------------------------------------------+
MA_Cross::~MA_Cross(void)
  {
  }
//+------------------------------------------------------------------+
//| ��������� ������� ��������� � ���������� true ���� �� OK        |
//+------------------------------------------------------------------+
bool MA_Cross::ValidationSettings(void)
  {
//--- �������� ����� �������� ������
   if(!CExpertSignal::ValidationSettings()) return(false);
//--- �������� �������, ���������� ����� ��� ������� ���������� >=1
   if(m_period_fast<1 || m_period_slow<1)
     {
      PrintFormat("������� ������ �������� ������ �� ��������! FastPeriod=%d, SlowPeriod=%d",
                  m_period_fast,m_period_slow);
      return false;
     }
//--- ������ ��������� ������ ���� ������ ������� ������� ����������
   if(m_period_fast>m_period_slow)
     {
      PrintFormat("SlowPeriod=%d ������ ���� ������ ��� FastPeriod=%d!",
                  m_period_slow,m_period_fast);
      return false;
     }
//--- ��� ����������� ������� ���������� ������ ���� ���� �� ������� �������� ������������
   if(m_method_fast!=MODE_SMA && m_method_fast!=MODE_EMA && m_method_fast!=MODE_SMMA && m_method_fast!=MODE_LWMA)
     {
      PrintFormat("������������ ��� ����������� ������� ���������� �������!");
      return false;
     }
//--- ��� ����������� ��������� ���������� ������ ���� ���� �� ������� �������� ������������
   if(m_method_slow!=MODE_SMA && m_method_slow!=MODE_EMA && m_method_slow!=MODE_SMMA && m_method_slow!=MODE_LWMA)
     {
      PrintFormat("������������ ��� ����������� ��������� ���������� �������!");
      return false;
     }
//--- ��� �������� ������, ������, �� ������
   return true;
  }
//+------------------------------------------------------------------+
//| ������� ����������                                               |
//| �� �����:  ��������� �� ���������� �����������                   |
//| �� ������: true-��� �������� ����������, ����� false             |
//+------------------------------------------------------------------+
bool MA_Cross::InitIndicators(CIndicators *indicators)
  {
//--- ����������� �������� ��������� ����������� �� NULL
   if(indicators==NULL) return(false);
//--- ������������� ����������� � ��������� � �������������� ��������
   if(!CExpertSignal::InitIndicators(indicators)) return(false);
//--- �������� ����� ����������� ���������� �������
   if(!CreateFastMA(indicators))                  return(false);
   if(!CreateSlowMA(indicators))                  return(false);
//--- ����� �� ����� �����, ������, ������� ��������� ������� - ������ true
   return(true);
  }
//+------------------------------------------------------------------+
//| ������� ��������� "������� MA"                                   |
//+------------------------------------------------------------------+
bool MA_Cross::CreateFastMA(CIndicators *indicators)
  {
//--- �������� ���������
   if(indicators==NULL) return(false);
//--- ���������� ������� � ���������
   if(!indicators.Add(GetPointer(m_fast_ma)))
     {
      printf(__FUNCTION__+": ������ ���������� ������� ������� MA");
      return(false);
     }
//--- ������� ���������� ������� MA
   MqlParam parameters[4];
//---
   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="Examples\\Custom Moving Average.ex5";
   parameters[1].type=TYPE_INT;
   parameters[1].integer_value=m_period_fast;      // ������
   parameters[2].type=TYPE_INT;
   parameters[2].integer_value=0;                  // ��������
   parameters[3].type=TYPE_INT;
   parameters[3].integer_value=m_method_fast;      // ����� ����������
//--- ������������� �������  
   if(!m_fast_ma.Create(m_symbol.Name(),m_period,IND_CUSTOM,4,parameters))
     {
      printf(__FUNCTION__+": ������ ������������� ������� ������� MA");
      return(false);
     }
//--- ���������� �������
   if(!m_fast_ma.NumBuffers(1)) return(false);
//--- ����� �� ����� �����, ������, ������� ��������� ������� - ������ true
   return(true);
  }
//+------------------------------------------------------------------+
//| ������� ��������� "��������� MA"                                 |
//+------------------------------------------------------------------+
bool MA_Cross::CreateSlowMA(CIndicators *indicators)
  {
//--- �������� ���������
   if(indicators==NULL) return(false);
//--- ���������� ������� � ���������
   if(!indicators.Add(GetPointer(m_slow_ma)))
     {
      printf(__FUNCTION__+": ������ ���������� ������� ��������� MA");
      return(false);
     }
//--- ������� ���������� ��������� MA
   MqlParam parameters[4];
//---
   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="Examples\\Custom Moving Average.ex5";
   parameters[1].type=TYPE_INT;
   parameters[1].integer_value=m_period_slow;      // ������
   parameters[2].type=TYPE_INT;
   parameters[2].integer_value=0;                  // ��������
   parameters[3].type=TYPE_INT;
   parameters[3].integer_value=m_method_slow;      // ����� ����������
//--- ������������� �������  
   if(!m_slow_ma.Create(m_symbol.Name(),m_period,IND_CUSTOM,4,parameters))
     {
      printf(__FUNCTION__+": ������ ������������� ������� ��������� MA");
      return(false);
     }
//--- ���������� �������
   if(!m_slow_ma.NumBuffers(1)) return(false);
//--- ����� �� ����� �����, ������, ������� ��������� ������� - ������ true
   return(true);
  }
//+------------------------------------------------------------------+
//| ���������� ���� ������� �� �������                               |
//+------------------------------------------------------------------+
int MA_Cross::LongCondition()
  {
   int signal=0;
//--- ��� ������ ������ �� ����� idx=0, � ������ ������ �� ���������������� ����� idx=1
   int idx=StartIndex();
//--- �������� ������� �� ��������� ���������������� ����
   double last_fast_value=FastMA(idx);
   double last_slow_value=SlowMA(idx);
//--- �������� ������� �� ������������� ���������������� ����
   double prev_fast_value=FastMA(idx+1);
   double prev_slow_value=SlowMA(idx+1);
//--- ���� ������� ���������� ������� ����� ����� ��������� �� ��������� ���� �������� �����
   if((last_fast_value>last_slow_value) && (prev_fast_value<prev_slow_value))
     {
      signal=100; // ������ �� ������� ����
     }
//--- ������ �������� �������
   return(signal);
  }
//+------------------------------------------------------------------+
//| ���������� ���� ������� �� �������                               |
//+------------------------------------------------------------------+
int MA_Cross::ShortCondition()
  {
   int signal=0;
//--- ��� ������ ������ �� ����� idx=0, � ������ ������ �� ���������������� ����� idx=1
   int idx=StartIndex();
//--- �������� ������� �� ��������� ���������������� ����
   double last_fast_value=FastMA(idx);
   double last_slow_value=SlowMA(idx);
//--- �������� ������� �� ������������� ���������������� ����
   double prev_fast_value=FastMA(idx+1);
   double prev_slow_value=SlowMA(idx+1);
//--- ���� ������� ���������� ������� ������ ���� ��������� �� ��������� ���� �������� �����
   if((last_fast_value<last_slow_value) && (prev_fast_value>prev_slow_value))
     {
      signal=100; // ������ �� �������� ����
     }
//--- ������ �������� �������
   return(signal);
  }
//+------------------------------------------------------------------+
