SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create function [dbo].[udf_event_price_string] (@trade_num int, @order_num smallint, @item_num smallint)  
returns varchar(255)  
As  
begin  
      declare @lcl_trade_num int,  
                  @lcl_order_num smallint,  
                  @lcl_item_num smallint,  
                  @event_str varchar(255),  
                  @lcl_event_name varchar(40),  
                  @lcl_event_oper char(1),  
                  @lcl_event_pricing_days smallint,  
                  @lcl_event_start_end_days smallint,  
                  @lcl_quote_type char(4)  
                    
      set @lcl_trade_num=@trade_num  
      set @lcl_order_num=@order_num  
      set @lcl_item_num=@item_num  
  
      select      @lcl_event_name=event_name,   
                  @lcl_event_oper=event_oper,   
                  @lcl_event_pricing_days=event_pricing_days,   
                  @lcl_event_start_end_days=event_start_end_days,  
                  @lcl_quote_type=quote_type  
      from trade_formula tf  
      join formula f on tf.formula_num=f.formula_num and formula_type='E'  
      join event_price_term ept on ept.formula_num=f.formula_num  
      where tf.trade_num=@lcl_trade_num and  
                  tf.order_num=@lcl_order_num and  
                  tf.item_num=@lcl_item_num  
  
      if @lcl_quote_type = 'b:B'  
      begin   
            set @event_str='Price starting '+  
                                    convert(varchar,@lcl_event_start_end_days) +  
                                    ' Business Days Before, Ending ' + convert(varchar,@lcl_event_pricing_days) +  
                                    ' Business Days After'  
      end     
      else  
      begin  
            set @event_str='Pricing For ' + convert(varchar,@lcl_event_pricing_days)  
            set @event_str = @event_str + case upper(substring(@lcl_quote_type,1,1))  
                                                                  when 'C' then ' Calendar Days'  
                                                                  when 'B' then ' Business Days'  
                                                                  when 'W' then ' Weeks'  
                                                                  when 'H' then ' Half-Months'  
                                                                  when 'M' then ' Months'  
                                                            end  
            if @lcl_event_start_end_days is null   
                  begin   
                  set @event_str = @event_str +' Starting On'  
                  end  
            else  
            begin   
                  set @event_str = @event_str + ' ,Starting ' +convert(varchar,@lcl_event_start_end_days)  
                  set @event_str = @event_str +  case upper(substring(@lcl_quote_type,3,1))  
                                                                        when 'C' then ' Calendar Days'  
                                                                        when 'B' then ' Business Days'  
                                                                        when 'W' then ' Weeks'  
                                                                        when 'H' then ' Half-Months'  
                                                                        when 'M' then ' Months'  
                                                                  end  
                  set @event_str = @event_str + ' ' +case @lcl_event_oper  
                                                                        when '+' then ' After'  
                                                                        when '-' then ' Before'  
                                                                        end  
            end  
      end  
      set @event_str = @event_str + case @lcl_event_name  
                                                            when 'B/L' then ' Bill of Lading/Ticket Date'  
                                                            when 'L-B/L' then ' Laycan Based Bill of Lading'  
                                           when 'NOR' then ' Notice of Readiness'  
                                                            when 'COL' then ' Commencement of Loading'  
                                                            when 'COD' then ' "=Commencement of Discharge'  
                                                            when 'CMPD' then ' Completion of Discharge'  
                                                            when 'CMPL' then ' Completion of Loading'  
                                                            when 'LAYDAYS' then ' Lay Days'  
                                                            when 'ACTUAL' then ' Actual Date'  
                                                            else ' Other (See Comments)'  
                                                      end  
  
      return(@event_str);  
end;  
GO
GRANT EXECUTE ON  [dbo].[udf_event_price_string] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[udf_event_price_string] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'FUNCTION', N'udf_event_price_string', NULL, NULL
GO
