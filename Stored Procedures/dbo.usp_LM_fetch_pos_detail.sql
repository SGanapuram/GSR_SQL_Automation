SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_LM_fetch_pos_detail]   
(
   @asofday        datetime,    
   @clr_brkr_num   int = null,    
   @commkt_key     int,    
   @debugon        bit = 0,    
   @item_type      char(1),      
   @put_call_ind   char(1) = null,     
   @strike_price   float = null,    
   @trading_prd    char(8) = null 
)   
as    
set nocount on    
declare @asofday1           datetime,    
        @cmdty_code         char(8),    
        @mkt_code           char(8),    
        @same_day_flag      bit,    
        @rows_affected      int,    
        @errcode            int,    
        @smsg               varchar(512)    
    
   -- 'F' for future, 'E' for exchange option, 'C' for cleared swap    
   if @item_type not in ('F', 'E', 'C')    
   begin    
      select @smsg = '=> Must pass a valid value (''F'', ''E'', ''C'') for the argument @item_type!'    
      goto usage    
   end    
    
   if @item_type = 'F'    
   begin    
      if @clr_brkr_num is null    
      begin    
         select @smsg = '=> Must pass a non-null value for the argument @clr_brkr_num for the futures!'    
         goto usage    
      end    
          
      if not exists (select 1    
                     from dbo.account    
                     where acct_num = @clr_brkr_num)    
      begin    
         select @smsg = '=> Must pass a valid acct_num for the argument @clr_brkr_num for the futures!'    
         goto usage    
      end    
   end    
       
   if not exists (select 1    
                  from dbo.commodity_market    
                  where commkt_key = @commkt_key)    
   begin    
      select @smsg = '=> Must pass a valid commkt_key for the argument @commkt_key!'    
      goto usage    
   end    
        
   if @item_type = 'E'    
   begin    
      if @put_call_ind not in ('P', 'C')    
      begin    
         select @smsg = '=> Must pass a valid value (''P'', ''C'') for the argument @put_call_ind for the option!'    
         goto usage    
      end    
          
      if @strike_price is null    
      begin    
         select @smsg = '=> Must pass a non-null value for the argument @strike_price for the option!'    
         goto usage    
      end    
   end    
   else    
      select @strike_price = null    
              
   select @cmdty_code = cmdty_code,    
          @mkt_code = mkt_code    
   from dbo.commodity_market    
   where commkt_key = @commkt_key    
    
   if @cmdty_code is null or @mkt_code is null    
   begin    
      select @smsg = 'You must provide a valid value for the argument @commkt_key!'    
      goto usage     
   end    
       
   if @debugon = 1
   begin
      print 'DEBUG: cmdty_code = ' + @cmdty_code + ', mkt_code = ' + @mkt_code
   end
   
   create table #trade_items     
   (    
      trade_num                 int            NOT NULL,    
      order_num                 smallint       NOT NULL,    
      item_num                  smallint       NOT NULL,    
      p_s_ind                   char(1)        NULL,    
      contr_qty                 float          NULL,    
      contr_qty_uom_code        char(4)        NULL,    
      avg_price                 float          NULL,    
      price_curr_code           char(8)        NULL,    
      price_uom_code            char(4)        NULL,      
      is_cleared_ind            char(1)        NULL,    
      exch_brkr_num             int            NULL    
  )     
    
  create nonclustered index xx614621_ti_idx     
     on #trade_items (trade_num, order_num, item_num)    
  create nonclustered index xx614621_ti_idx1     
     on #trade_items (exch_brkr_num, is_cleared_ind)    
    
   create table #futures    
   (    
      trade_num                 int            NOT NULL,    
      order_num                 smallint       NOT NULL,    
      item_num                  smallint       NOT NULL,    
      clr_brkr_num              int            NULL    
   )    
      
  create nonclustered index xx614621_futures_idx     
     on #futures (trade_num, order_num, item_num)    
    
   create table #exchopts    
   (    
      trade_num                 int            NOT NULL,    
      order_num                 smallint       NOT NULL,    
      item_num                  smallint       NOT NULL,    
      clr_brkr_num              int            NULL,    
      put_call_ind              char(1)        NULL,    
      strike_price              float          NULL    
  )    
      
  create nonclustered index xx614621_exchopts_idx     
     on #exchopts (trade_num, order_num, item_num, clr_brkr_num, put_call_ind, strike_price)    
    
       
   select @same_day_flag = 0    
   if convert(varchar, getdate(), 101) = convert(varchar, @asofday, 101)    
      select @same_day_flag = 1    
          
   select @asofday1 = dateadd(day, 1, @asofday)   
   
   if @debugon = 1    
   begin  
      print 'DEBUG: Copying records into #trade_items ...'
      print 'TIME: ' + convert(varchar, getdate(), 109)  
   end
    
   insert into #trade_items    
      (trade_num,    
       order_num,    
       item_num,    
       p_s_ind,    
       contr_qty,    
       contr_qty_uom_code,    
       avg_price,    
       price_curr_code,    
       price_uom_code,
       is_cleared_ind,    
       exch_brkr_num    
      )    
   select     
      trade_num,    
      order_num,    
      item_num,    
      p_s_ind,    
      contr_qty,    
      contr_qty_uom_code,    
      avg_price,    
      price_curr_code,    
      price_uom_code,
      isnull(is_cleared_ind, 'N'),    
      exch_brkr_num      
   from dbo.trade_item ti with (nolock)    
   where item_type = @item_type and    
         cmdty_code = @cmdty_code and    
         risk_mkt_code = @mkt_code and    
         1 = (case when @trading_prd is not null 
                      then 
                         case when isnull(trading_prd, '@@@') = @trading_prd
                                 then 1
                              else 0
                         end
                   else 1 
              end) and
         exists (select 1    
                 from dbo.icts_transaction t with (nolock)    
                 where t.tran_date < @asofday1 and    
                       ti.trans_id = t.trans_id)     
   select @rows_affected = @@rowcount,    
          @errcode = @@error    
   if @errcode > 0    
   begin    
      print '=> Error occurred while retrieving the trade_item records'    
      goto endofsp    
   end    
       
   if @debugon = 1    
   begin    
      select @smsg = 'DEBUG: ' + cast(@rows_affected as varchar) + ' trade_item records were copied to temp. table'    
      print @smsg    
      print 'TIME: ' + convert(varchar, getdate(), 109)  
   end    
    
   if @same_day_flag = 0    
   begin    
      insert into #trade_items    
         (trade_num,    
          order_num,    
          item_num,    
          p_s_ind,    
          contr_qty,    
          contr_qty_uom_code,    
          avg_price,    
          price_curr_code,    
          price_uom_code,
	  is_cleared_ind,    
          exch_brkr_num    
         )    
      select     
         trade_num,    
         order_num,    
         item_num,    
         p_s_ind,    
         contr_qty,    
         contr_qty_uom_code,    
         avg_price,    
         price_curr_code,    
         price_uom_code,
	 isnull(is_cleared_ind, 'N'),    
         exch_brkr_num      
      from dbo.aud_trade_item ti with (nolock)    
            INNER JOIN dbo.icts_transaction rt with (nolock)     
               ON ti.resp_trans_id = rt.trans_id     
            INNER JOIN dbo.icts_transaction t with (nolock)     
               ON ti.trans_id = t.trans_id     
      where item_type = @item_type and    
            cmdty_code = @cmdty_code and    
            risk_mkt_code = @mkt_code and    
            1 = (case when @trading_prd is not null 
                         then 
                            case when isnull(trading_prd, '@@@') = @trading_prd
                                    then 1
                                 else 0
                            end
                      else 1 
                 end) and
            rt.tran_date >= @asofday1 and    
            t.tran_date < @asofday1    
      select @rows_affected = @@rowcount,    
             @errcode = @@error    
      if @errcode > 0    
      begin    
         print '=> Error occurred while retrieving the aud_trade_item records'    
         goto endofsp    
      end    
       
      if @debugon = 1    
      begin    
         select @smsg = 'DEBUG: ' + cast(@rows_affected as varchar) + ' aud_trade_item records were copied to temp. table'    
         print @smsg    
      end    
   end    

/* ********************************************************************** */                  
future:    
   if @item_type <> 'F'    
      goto exchopt    

   if @debugon = 1    
   begin  
      print 'DEBUG: filtering unwanted records in #exchopts (trade_item_fut) ...'
      print 'TIME: ' + convert(varchar, getdate(), 109)  
   end
          
   insert into #futures    
   select    
      fut.trade_num,    
      fut.order_num,    
      fut.item_num,    
      fut.clr_brkr_num   
   from dbo.trade_item_fut fut with (nolock)
   where exists (select 1
                 from #trade_items ti 
                 where ti.trade_num = fut.trade_num and    
                       ti.order_num = fut.order_num and    
                       ti.item_num = fut.item_num) and    
         exists (select 1    
                 from dbo.icts_transaction t with (nolock)    
                 where t.tran_date < @asofday1 and    
                       fut.trans_id = t.trans_id)    
   select @rows_affected = @@rowcount,    
          @errcode = @@error    
   if @errcode > 0    
  begin    
      print '=> Error occurred while retrieving the trade_item_fut records'    
      goto endofsp    
   end    
       
   if @debugon = 1    
   begin    
      select @smsg = 'DEBUG: ' + cast(@rows_affected as varchar) + ' trade_item_fut records were copied to temp. table'    
      print @smsg    
      print 'TIME: ' + convert(varchar, getdate(), 109)  
   end    

   if @debugon = 1    
   begin  
      print 'DEBUG: filtering unwanted records in #exchopts (aud_trade_item_fut) ...'
      print 'TIME: ' + convert(varchar, getdate(), 109)  
   end

   insert into #futures    
   select    
      fut.trade_num,    
      fut.order_num,    
      fut.item_num,    
      fut.clr_brkr_num   
   from dbo.aud_trade_item_fut fut with (nolock)
           INNER JOIN dbo.icts_transaction rt with (nolock)     
              ON fut.resp_trans_id = rt.trans_id     
           INNER JOIN dbo.icts_transaction t with (nolock)   
              ON fut.trans_id = t.trans_id                            
   where exists (select 1
                 from #trade_items ti 
                 where ti.trade_num = fut.trade_num and    
                       ti.order_num = fut.order_num and    
                       ti.item_num = fut.item_num) and    
         rt.tran_date >= @asofday1 and    
         t.tran_date < @asofday1
   select @rows_affected = @@rowcount,    
          @errcode = @@error    
   if @errcode > 0    
   begin    
      print '=> Error occurred while retrieving the aud_trade_item_fut records'    
      goto endofsp    
   end    
       
   if @debugon = 1    
   begin    
      select @smsg = 'DEBUG: ' + cast(@rows_affected as varchar) + ' aud_trade_item_fut records were copied to temp. table'    
      print @smsg    
      print 'TIME: ' + convert(varchar, getdate(), 109)  
   end    

   if @debugon = 1    
   begin  
      print 'DEBUG: Returning result data set (FUTURES) ...'
      print 'TIME: ' + convert(varchar, getdate(), 109)  
   end
       
   select     
      trade_num,    
      order_num,    
      item_num,    
      p_s_ind,    
      contr_qty,    
      contr_qty_uom_code,    
      avg_price,    
      price_curr_code,    
      price_uom_code,
      contr_qty as open_qty,
      contr_qty_uom_code as open_qty_uom_code
   from #trade_items ti   
   where exists (select 1    
                 from #futures f    
                 where f.clr_brkr_num = @clr_brkr_num and    
                       ti.trade_num = f.trade_num and    
                       ti.order_num = f.order_num and    
                       ti.item_num = f.item_num)    
   order by trade_num, order_num, item_num    
   select @rows_affected = @@rowcount  
   if @debugon = 1    
   begin    
      select @smsg = 'DEBUG: ' + cast(@rows_affected as varchar) + ' records (FUTURES) outputed'    
      print @smsg    
      print 'TIME: ' + convert(varchar, getdate(), 109)  
   end    
             
   goto endofsp    

/* ********************************************************************** */  
exchopt:    
   if @item_type <> 'E'    
      goto swap    

   if @debugon = 1    
   begin  
      print 'DEBUG: filtering unwanted records in #exchopts (trade_item_exch_opt) ...'
      print 'TIME: ' + convert(varchar, getdate(), 109)  
   end
    
   insert into #exchopts    
   select    
      opt.trade_num,    
      opt.order_num,    
      opt.item_num,    
      opt.clr_brkr_num,    
      opt.put_call_ind,    
      opt.strike_price 
   from dbo.trade_item_exch_opt opt with (nolock)   
   where exists (select 1
                 from #trade_items ti 
                 where ti.trade_num = opt.trade_num and    
                       ti.order_num = opt.order_num and    
                       ti.item_num = opt.item_num) and    
         exists (select 1    
                 from dbo.icts_transaction t with (nolock)  
                 where t.tran_date < @asofday1 and    
                       opt.trans_id = t.trans_id)     
   select @rows_affected = @@rowcount,    
          @errcode = @@error    
   if @errcode > 0    
   begin    
      print '=> Error occurred while retrieving the trade_item_exch_opt records'    
      goto endofsp    
   end    
       
   if @debugon = 1    
   begin    
      select @smsg = 'DEBUG: ' + cast(@rows_affected as varchar) + ' trade_item_exch_opt records were copied to temp. table'    
      print @smsg    
      print 'TIME: ' + convert(varchar, getdate(), 109)  
   end    

   if @debugon = 1    
   begin  
      print 'DEBUG: filtering unwanted records in #exchopts (aud_trade_item_exch_opt) ...'
      print 'TIME: ' + convert(varchar, getdate(), 109)  
   end
          
   insert into #exchopts    
   select    
      opt.trade_num,    
      opt.order_num,    
      opt.item_num,    
      opt.clr_brkr_num,    
      opt.put_call_ind,    
      opt.strike_price  
   from dbo.aud_trade_item_exch_opt opt with (nolock)
           INNER JOIN dbo.icts_transaction rt with (nolock)    
              ON opt.resp_trans_id = rt.trans_id     
           INNER JOIN dbo.icts_transaction t with (nolock)   
              ON opt.trans_id = t.trans_id                            
   where exists (select 1
                 from #trade_items ti 
                 where ti.trade_num = opt.trade_num and    
                       ti.order_num = opt.order_num and    
                       ti.item_num = opt.item_num) and    
         rt.tran_date >= @asofday1 and    
         t.tran_date < @asofday1   
   select @rows_affected = @@rowcount,    
          @errcode = @@error    
   if @errcode > 0    
   begin    
      print '=> Error occurred while retrieving the aud_trade_item_exch_opt records'    
      goto endofsp    
   end    
       
   if @debugon = 1    
   begin    
      select @smsg = 'DEBUG: ' + cast(@rows_affected as varchar) + ' aud_trade_item_exch_opt records were copied to temp. table'    
      print @smsg    
      print 'TIME: ' + convert(varchar, getdate(), 109)  
   end    

   if @debugon = 1    
   begin  
      print 'DEBUG: Returning result data set (EXCHANGE) ...'
      print 'TIME: ' + convert(varchar, getdate(), 109)  
   end
    
   select     
      trade_num,    
      order_num,    
      item_num,    
      p_s_ind,    
      contr_qty,    
      contr_qty_uom_code,    
      avg_price,    
      price_curr_code,    
      price_uom_code,
      contr_qty as open_qty,
      contr_qty_uom_code as open_qty_uom_code
   from #trade_items ti    
   where exists (select 1    
                 from #exchopts e    
                 where e.clr_brkr_num = @clr_brkr_num and    
                       e.put_call_ind = @put_call_ind and    
                       e.strike_price = @strike_price and    
                       ti.trade_num = e.trade_num and    
                       ti.order_num = e.order_num and    
                       ti.item_num = e.item_num)    
   order by trade_num, order_num, item_num    
   select @rows_affected = @@rowcount  
   if @debugon = 1    
   begin    
      select @smsg = 'DEBUG: ' + cast(@rows_affected as varchar) + ' records (EXCHANGE) outputed'    
      print @smsg    
      print 'TIME: ' + convert(varchar, getdate(), 109)  
   end    
       
   goto endofsp    

/* ********************************************************************** */      
swap:    
   if @debugon = 1    
   begin  
      print 'DEBUG: Returning result data set (SWAP) ...'
      print 'TIME: ' + convert(varchar, getdate(), 109)  
   end
   
   select     
      trade_num,    
      order_num,    
      item_num,    
      p_s_ind,    
      contr_qty,    
      contr_qty_uom_code,    
      avg_price,    
      price_curr_code,    
      price_uom_code,
      contr_qty as open_qty,
      contr_qty_uom_code as open_qty_uom_code
   from #trade_items ti    
   where exch_brkr_num = @clr_brkr_num and    
         is_cleared_ind = 'Y'    
   order by trade_num, order_num, item_num    
   select @rows_affected = @@rowcount,    
          @errcode = @@error    
   if @errcode > 0    
   begin    
      print '=> Error occurred while retrieving the trade_item records (SWAP)'    
      goto endofsp    
   end    
       
   if @debugon = 1    
   begin    
      select @smsg = 'DEBUG: ' + cast(@rows_affected as varchar) + ' trade_item records (SWAP) were retrieved'    
      print @smsg    
      print 'TIME: ' + convert(varchar, getdate(), 109)  
   end    
             
   goto endofsp    
    
usage:    
   print ' '    
   print @smsg    
   print 'Usage: exec dbo.usp_LM_fetch_pos_detail'    
   print '               @asofday = ''mm/dd/yyyy'','    
   print '               @item_type = ''?'','      
   print '               @commkt_key = ?,'    
   print '               @trading_prd = ''?'''    
   print '               [, @clr_brkr_num = ?]'    
   print '               [, @put_call_ind = ''?'']'     
   print '               [, @strike_price = ?]'    
   print ' '    
   return 2    
       
endofsp:    
   drop table #trade_items    
   drop table #futures    
   drop table #exchopts    
   if @errcode > 0    
      return 1    
          
return 0    
GO
GRANT EXECUTE ON  [dbo].[usp_LM_fetch_pos_detail] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_LM_fetch_pos_detail', NULL, NULL
GO
