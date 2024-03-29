//+------------------------------------------------------------------+
//|                                                       OClass.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
////////#property copyright "Copyright 2019, MetaQuotes Software Corp."
////////#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Order
  {
private:// запрещает обращаться к методам, переменным, из вне класса
      MqlTradeRequest   o_request; //структура
      MqlTradeResult    o_result;//структура

      int               OrderSL;  //Уровень StopLoss ордера
      int               OrderTP;   //Уровень TakeProfit ордера
   
      double            ord_SL; //Цена в ценах (не в пунктах)
      double            ord_TP; //Для внутренней работы

public:
                     Order() //Конструктор класса (ин-ция всех переменных для открытия позиции)
     {
      ZeroMemory(o_request); //очистка полей структуры
      o_request.action     = TRADE_ACTION_DEAL; //action(тип торговой операции)Установить торговый ордер на немедленное совершение сделки с указанными параметрами (поставить рыночный ордер)
      o_request.magic      = 0;
      o_request.symbol     = Symbol(); // текущий график валютной пары
      o_request.volume     = 0.1; // объём ордера
      o_request.price      = 0;
      o_request.sl         = 0;
      o_request.deviation  = 5; // проскальзывание
      o_request.type       = 0;
      o_request.type_filling  = ORDER_FILLING_FOK;
      o_request.type_time = ORDER_TIME_GTC;//Ордер будет находится в очереди до тех пор, пока не будет снят
      o_request.expiration = 0;

      OrderSL = 0;
      OrderTP = 0;

      ord_SL = 0;
      ord_TP = 0;
     }
     
   double            GetSL(bool IsByOrder)
     {
      if(OrderSL > 0)//если есть стоплос
        {
         if(IsByOrder)//проверка входящего параметра
           {
            return SymbolInfoDouble(o_request.symbol, SYMBOL_ASK) - OrderSL * _Point;//ордер на покупку
           }
         else
           {
            return SymbolInfoDouble(o_request.symbol, SYMBOL_BID) + OrderSL * _Point;//ордер на продажу
           }
        }
      else
        {
         return(ord_SL);
        }
      }       
      double            GetTP(bool IsByOrder)
        {
         if(OrderTP > 0)
           {
            if(IsByOrder)
              {
               return SymbolInfoDouble(o_request.symbol, SYMBOL_ASK) + OrderTP * _Point;
              }
            else
              {
               return SymbolInfoDouble(o_request.symbol, SYMBOL_BID) - OrderTP * _Point;
              }
           }
         else
           {
             return(ord_TP);
           }
         }  

         bool              Execute() //универсальный метод заполняющий 2 структуры
           {
            bool err = OrderSend(o_request, o_result);
            if(!err)//если ошибка (не удалось открыть ордер)
              {
               Print("Ошибка исполнения ордера!");
              }
            return(err);
           }
        
      bool              Buy() //метод открытия ордера на покупку
        {
         o_request.type = ORDER_TYPE_BUY; //Рыночный ордер на покупку
         o_request.price = SymbolInfoDouble(o_request.symbol, SYMBOL_ASK);// цена покупки
         o_request.sl = GetSL(true);
         o_request.tp = GetTP(true);
         return(Execute());//вызов метода Execute, возвращ. лог. знач.
        }

      bool              Sell() //метод открытия ордера на покупку
        {
         o_request.type = ORDER_TYPE_SELL; //Рыночный ордер на покупку
         o_request.price = SymbolInfoDouble(o_request.symbol, SYMBOL_BID);// цена продажи
         o_request.sl = GetSL(false);
         o_request.tp = GetTP(false);
         return(Execute());//вызов метода Execute, возвращ. лог. знач.
        }

      bool              Close() //функция закрытия ордера
        {
         bool ret;
         if(PositionSelect(o_request.symbol)) //если есть позиция в рынке
           {
            if(ENUM_POSITION_TYPE(PositionGetInteger(POSITION_TYPE)) == POSITION_TYPE_BUY)// если это покупка, открываем продажу;  int приводим его к ENUM
              {
               o_request.type = ORDER_TYPE_SELL;
               o_request.price = SymbolInfoDouble(o_request.symbol, SYMBOL_BIDHIGH);//значение цены продажи
              }
            else
              {
               o_request.type = ORDER_TYPE_BUY;
               o_request.price = SymbolInfoDouble(o_request.symbol, SYMBOL_ASK);
              }


            double vol = o_request.volume;
            o_request.sl = 0;
            o_request.tp = 0;
            o_request.volume = PositionGetDouble(POSITION_VOLUME);// какой объём будем закрывать?
            ret = Execute();
            o_request.volume=vol; //воостановим объём из значения временной переменной чтобы не потерять
           }

         else
           {
            Print("CLOSE: Не удалось выбрать позицию!");
            ret = false;
           }
         return(ret);
        }


      void SetMagic(int magic)
        {
         o_request.magic = magic;
        }

      void SetComment(string comment)
        {
         o_request.comment = comment;
        }
      void SetLots(double lots)
        {
         o_request.volume = lots;
        }
      void SetSL(int sl)
        {
         ord_SL = 0;
         OrderSL = sl;
        }
      void SetTP(int tp)
        {
         ord_TP=0;
         OrderTP = tp;
        }
     
  };
//+------------------------------------------------------------------+
