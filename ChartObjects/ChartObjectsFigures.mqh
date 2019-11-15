//+------------------------------------------------------------------+
//|                                          ChartObjectsFigures.mqh |
//|                        Copyright 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
//| ��� ������.                                                      |
//+------------------------------------------------------------------+
#include "ChartObject.mqh"
//+------------------------------------------------------------------+
//| ����� CChartObjectRectangle.                                     |
//| ����������: ����� ������������ ������� "�������������".          |
//+------------------------------------------------------------------+
class CChartObjectRectangle : public CChartObject
  {
public:
   //--- ����� �������� �������
   bool              Create(long chart_id,string name,int window,datetime time1,double price1,datetime time2,double price2);
   //--- ����� ������������� �������
   virtual int       Type() { return(OBJ_RECTANGLE); };
  };
//+------------------------------------------------------------------+
//| �������� ������� "�������������".                                |
//| INPUT:  chart_id-������������� �������,                          |
//|         name    -��� �������,                                    |
//|         window  -����� ������� �������,                          |
//|         time1   -������ ���������� �������,                      |
//|         price1  -������ ���������� ����,                         |
//|         time2   -������ ���������� �������,                      |
//|         price2  -������ ���������� ����.                         |
//| OUTPUT: true ��� ������� ��������, ����� - false.                |
//| REMARK: ���.                                                     |
//+------------------------------------------------------------------+
bool CChartObjectRectangle::Create(long chart_id,string name,int window,datetime time1,double price1,datetime time2,double price2)
  {
   bool result=ObjectCreate(chart_id,name,OBJ_RECTANGLE,window,time1,price1,time2,price2);
//---
   if(result) result&=Attach(chart_id,name,window,2);
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| ����� CChartObjectTriangle.                                      |
//| ����������: ����� ������������ ������� "�����������".            |
//+------------------------------------------------------------------+
class CChartObjectTriangle : public CChartObject
  {
public:
   //--- ����� �������� �������
   bool              Create(long chart_id,string name,int window,datetime time1,double price1,datetime time2,double price2,datetime time3,double price3);
   //--- ����� ������������� �������
   virtual int       Type() { return(OBJ_TRIANGLE); };
  };
//+------------------------------------------------------------------+
//| �������� ������� "�����������".                                  |
//| INPUT:  chart_id-������������� �������,                          |
//|         name    -��� �������,                                    |
//|         window  -����� ������� �������,                          |
//|         time1   -������ ���������� �������,                      |
//|         price1  -������ ���������� ����,                         |
//|         time2   -������ ���������� �������,                      |
//|         price2  -������ ���������� ����,                         |
//|         time3   -������ ���������� �������,                      |
//|         price3  -������ ���������� ����.                         |
//| OUTPUT: true ��� ������� ��������, ����� - false.                |
//| REMARK: ���.                                                     |
//+------------------------------------------------------------------+
bool CChartObjectTriangle::Create(long chart_id,string name,int window,datetime time1,double price1,datetime time2,double price2,datetime time3,double price3)
  {
   bool result=ObjectCreate(chart_id,name,OBJ_TRIANGLE,window,time1,price1,time2,price2,time3,price3);
//---
   if(result) result&=Attach(chart_id,name,window,3);
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| ����� CChartObjectEllipse.                                       |
//| ����������: ����� ������������ ������� "������".                 |
//+------------------------------------------------------------------+
class CChartObjectEllipse : public CChartObject
  {
public:
   //--- ����� �������� �������
   bool              Create(long chart_id,string name,int window,datetime time1,double price1,datetime time2,double price2,datetime time3,double price3);
   //--- ����� ������������� �������
   virtual int       Type() { return(OBJ_ELLIPSE); };
  };
//+------------------------------------------------------------------+
//| �������� ������� "������".                                       |
//| INPUT:  chart_id-������������� �������,                          |
//|         name    -��� �������,                                    |
//|         window  -����� ������� �������,                          |
//|         time1   -������ ���������� �������,                      |
//|         price1  -������ ���������� ����,                         |
//|         time2   -������ ���������� �������,                      |
//|         price2  -������ ���������� ����,                         |
//|         time3   -������ ���������� �������,                      |
//|         price3  -������ ���������� ����.                         |
//| OUTPUT: true ��� ������� ��������, ����� - false.                |
//| REMARK: ���.                                                     |
//+------------------------------------------------------------------+
bool CChartObjectEllipse::Create(long chart_id,string name,int window,datetime time1,double price1,datetime time2,double price2,datetime time3,double price3)
  {
   bool result=ObjectCreate(chart_id,name,OBJ_ELLIPSE,window,time1,price1,time2,price2,time3,price3);
//---
   if(result) result&=Attach(chart_id,name,window,3);
//---
   return(result);
  }
//+------------------------------------------------------------------+
