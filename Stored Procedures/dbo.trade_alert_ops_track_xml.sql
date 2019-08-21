SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[trade_alert_ops_track_xml]
(
	 @ticket int  
)   
as   
set nocount on
begin     
declare @cdty_code char(8),     
        @booking_company_short_name varchar(15), 
        @cpty_short_name varchar(15),     
        @broker_short_name varchar(15), 
        @trade_dt datetime, 
        @inception_dt datetime, 
        @trade_type_code char(8),     
        @trade_stat_code char(8), 
        @book char(8), 
        @qty_tot float, 
        @qty float, 
        @buy_sell_ind char(1),     
        @location_sn char(8), 
        @record_count int, 
        @order_count int, 
        @uom_dur_code char(20), 
        @price_desc varchar(50),     
        @start_dt datetime, 
        @end_dt datetime, 
        @sttl_type char(10), 
        @comm char(20), 
        @pay_price varchar(60),     
        @rec_price varchar(60), 
        @is_formula char(1), 
        @fixed_price char(20), 
        @formula_num int,     
        @formula_body_num int, 
        @formula_comp_num int, 
        @pricing_str varchar(60),     
        @formula_body_string varchar(255), 
        @diff_index int, 
        @formula_iteration tinyint,   
        @strike_price char(60), 
        @optn_prem char(60), 
        @broker_rate char(60), 
        @put_call_ind char(1),   
        @broker_fee float, 
        @broker_fee_curr_code varchar(8), 
        @broker_fee_uom_code varchar(4),   
        @strike_price_amount float, 
        @strike_price_curr_code varchar(8), 
        @strike_price_uom_code varchar(4),   
        @premium_amount float, 
        @premium_curr_code varchar(8), 
        @premium_uom_code varchar(4)   
   
declare @xml as xml  
declare @xml_val varchar(max) 
     
   select @record_count = count(distinct cmdty_code) 
   from dbo.trade_item     
   where trade_num = @ticket     
   if (@record_count > 1)     
      select @cdty_code = 'VARIOUS'     
   else     
   begin     
      select @cdty_code = cmdty_code 
      from dbo.trade_item 
      where trade_num = @ticket     
   end     
     
   select @record_count = count(distinct p_s_ind) 
   from dbo.trade_item 
   where trade_num = @ticket     
   if (@record_count > 1)     
      set @buy_sell_ind = '?'     
   else     
      select @buy_sell_ind = p_s_ind 
      from dbo.trade_item 
      where trade_num = @ticket   
        
   if @buy_sell_ind = 'P'     
      set @buy_sell_ind = 'B'     
     
   select @record_count = count(distinct booking_comp_num) 
   from dbo.trade_item     
   where trade_num = @ticket     
   if (@record_count > 1)     
      set @booking_company_short_name = 'VARIOUS'     
   else     
   begin     
      select @booking_company_short_name = acct_short_name     
      from dbo.trade_item i, 
           dbo.account a     
      where i.trade_num = @ticket and 
            i.booking_comp_num = a.acct_num     
   end     
     
   select @order_count = count(distinct order_type_code) 
   from dbo.trade_order     
   where trade_num = @ticket     
   if (@order_count > 1)     
      select @trade_type_code = 'VARIOUS'     
   else     
      select @trade_type_code = order_type_code 
      from dbo.trade_order     
      where trade_num = @ticket     
     
   if (@cdty_code != 'VARIOUS' and 
       @buy_sell_ind != '?' and 
       @trade_type_code != 'VARIOUS')     
   begin     
      /* fill in quantity information */     
      if (@trade_type_code like 'SWAP%')     
      begin     
         select @qty_tot = sum(accum_qty) 
         from dbo.accumulation 
         where trade_num = @ticket  
            
         set @qty = @qty_tot    
          
         select @uom_dur_code = accum_qty_uom_code 
         from dbo.accumulation 
         where trade_num = @ticket     
      end     
      else     
      begin     
         select @qty_tot = sum(dist_qty) 
         from dbo.trade_item_dist 
         where trade_num = @ticket and 
               dist_type = 'D' and 
               real_synth_ind = 'R' and 
               is_equiv_ind = 'N'  
                  
         select @qty = contr_qty, 
                @uom_dur_code = rtrim(contr_qty_uom_code) + '/' + contr_qty_periodicity     
         from dbo.trade_item 
         where trade_num = @ticket     
      end     
   end     
     
   if (@trade_type_code = 'PHYSICAL' or 
       @trade_type_code = 'PARTIAL')     
   begin     
      select @location_sn = del_loc_code 
      from dbo.trade_item_wet_phy 
      where trade_num = @ticket
           
      select @start_dt = min(del_date_from), 
             @end_dt = max(del_date_to)     
      from dbo.trade_item_wet_phy 
      where trade_num = @ticket     
   end     
   else if (@trade_type_code like 'SWAP%')     
      select @start_dt = min(accum_start_date), 
             @end_dt = max(accum_end_date)     
      from dbo.accumulation 
      where trade_num = @ticket     
     
   if (@trade_type_code in ('PHYSICAL', 'PARTIAL', 'FUTURE', 'EFPEXCH', 'OTCPHYS', 'STORAGE', 'EXCHGOPT'))     
      set @sttl_type = 'PHYSICAL'     
   else     
      set @sttl_type = 'FINANCIAL'     
     
   select @cpty_short_name = a.acct_short_name, 
          @trade_dt = t.contr_date, 
          @inception_dt = t.creation_date,     
          @trade_stat_code = t.trade_status_code 
   from dbo.trade t, 
        dbo.account a  
   where t.trade_num = @ticket and 
         t.acct_num = a.acct_num  
     
   select @record_count = count(distinct brkr_num) 
   from dbo.trade_item 
   where trade_num = @ticket     
   if (@record_count > 1)     
      set @broker_short_name = 'VARIOUS'     
   else     
   begin     
      select @broker_short_name = acct_short_name     
      from dbo.trade_item i, 
           dbo.account a     
      where i.trade_num = @ticket and 
            i.brkr_num = a.acct_num     
      if (@broker_short_name is not null)     
         select @comm = convert(char(10), convert(numeric(10, 4), brkr_comm_amt)) + ' ' + rtrim(brkr_comm_curr_code) + '/' + brkr_comm_uom_code     
         from dbo.trade_item 
         where trade_num = @ticket     
   end     
     
   select @book = j.group_code 
   from dbo.trade_item i, 
        dbo.jms_reports j     
   where j.port_num = i.real_port_num and 
         i.trade_num = @ticket    
    
   select @record_count = count(distinct brkr_comm_amt) 
   from dbo.trade_item 
   where trade_num = @ticket   
   if (@record_count > 1)   
      set @broker_rate = 'VARIOUS'   
   else   
   begin   
      select @record_count = count(distinct brkr_comm_curr_code) 
      from dbo.trade_item 
      where trade_num = @ticket   
      if (@record_count > 1)   
         set @broker_rate = 'VARIOUS'   
      else   
      begin   
         select @record_count = count(distinct brkr_comm_uom_code) 
         from dbo.trade_item 
         where trade_num = @ticket   
         if (@record_count > 1)   
            set @broker_rate = 'VARIOUS'   
         else   
         begin   
            select @broker_fee = brkr_comm_amt, 
                   @broker_fee_curr_code = brkr_comm_curr_code,   
                   @broker_fee_uom_code = brkr_comm_uom_code   
            from dbo.trade_item 
            where trade_num = @ticket   
            if (@broker_fee is not null and 
                @broker_fee_curr_code is not null and   
                @broker_fee_uom_code is not null)   
               select @broker_rate = rtrim(convert(char(25), convert(numeric(20, 4), @broker_fee))) + ' ' +   
                                              rtrim(@broker_fee_curr_code) + '/' + rtrim(@broker_fee_uom_code)   
         end   
      end   
   end  /* brkr_comm_amt count */   
    
   if @trade_type_code in ('OTCPHYS', 'EXCHGOPT', 'OTCAPO', 'OTCCASH')   
   begin   
      if (@trade_type_code = 'EXCHGOPT')   
         select @record_count = count(distinct strike_price) 
         from dbo.trade_item_exch_opt 
         where trade_num = @ticket   
      else   
         select @record_count = count(distinct strike_price) 
         from dbo.trade_item_otc_opt 
         where trade_num = @ticket   
      if (@record_count > 1)   
         set @strike_price = 'VARIOUS'   
      else   
      begin   
         if (@trade_type_code = 'EXCHGOPT')   
            select @record_count = count(distinct strike_price_curr_code) 
            from dbo.trade_item_exch_opt 
            where trade_num = @ticket   
         else   
            select @record_count = count(distinct strike_price_curr_code) 
            from dbo.trade_item_otc_opt 
            where trade_num = @ticket   
         if (@record_count > 1)   
            select @strike_price = 'VARIOUS'   
         else   
         begin   
            if (@trade_type_code = 'EXCHGOPT')   
               select @record_count = count(distinct strike_price_uom_code) 
               from dbo.trade_item_exch_opt 
               where trade_num = @ticket   
            else   
               select @record_count = count(distinct strike_price_uom_code) 
               from dbo.trade_item_otc_opt 
               where trade_num = @ticket   
            if (@record_count > 1)   
               set @strike_price = 'VARIOUS'   
            else   
            begin   
               if (@trade_type_code = 'EXCHGOPT')   
                  select @strike_price_amount = strike_price, 
                         @strike_price_curr_code = strike_price_curr_code,   
                         @strike_price_uom_code = strike_price_uom_code   
                  from dbo.trade_item_exch_opt 
                  where trade_num = @ticket   
               else   
                  select @strike_price_amount = strike_price, 
                         @strike_price_curr_code = strike_price_curr_code,   
                         @strike_price_uom_code = strike_price_uom_code   
                  from dbo.trade_item_otc_opt 
                  where trade_num = @ticket   
               if (@strike_price_amount is not null and 
                   @strike_price_curr_code is not null and   
                   @strike_price_uom_code is not null)   
                  set @strike_price = rtrim(convert(char(25), convert(numeric(20, 4), @strike_price_amount))) + ' ' +   
                                               rtrim(@strike_price_curr_code) + '/' + rtrim(@strike_price_uom_code)   
            end   
         end   
      end   
     
      if (@trade_type_code = 'EXCHGOPT')   
         select @record_count = count(distinct avg_fill_price) 
         from dbo.trade_item_exch_opt 
         where trade_num = @ticket   
      else   
         select @record_count = count(distinct premium) 
         from dbo.trade_item_otc_opt 
         where trade_num = @ticket   
      if (@record_count > 1)   
         select @strike_price = 'VARIOUS'   
      else   
      begin   
         if (@trade_type_code = 'EXCHGOPT')   
            select @record_count = count(distinct strike_price_curr_code) 
            from dbo.trade_item_exch_opt 
            where trade_num = @ticket   
         else   
            select @record_count = count(distinct premium_curr_code) 
            from dbo.trade_item_otc_opt 
            where trade_num = @ticket   
         if (@record_count > 1)   
            set @strike_price = 'VARIOUS'   
         else   
         begin   
            if (@trade_type_code = 'EXCHGOPT')   
               select @record_count = count(distinct strike_price_uom_code) 
               from dbo.trade_item_exch_opt 
               where trade_num = @ticket   
            else   
               select @record_count = count(distinct premium_uom_code) 
               from dbo.trade_item_otc_opt 
               where trade_num = @ticket   
            if (@record_count > 1)   
               set @strike_price = 'VARIOUS'   
            else   
            begin   
               if (@trade_type_code = 'EXCHGOPT')   
                  select @premium_amount = avg_fill_price, 
                         @premium_curr_code = strike_price_curr_code,   
                         @premium_uom_code = strike_price_uom_code   
                  from dbo.trade_item_exch_opt 
                  where trade_num = @ticket   
               else   
                  select @premium_amount = premium, 
                         @premium_curr_code = premium_curr_code,   
                         @premium_uom_code = premium_uom_code   
                  from dbo.trade_item_otc_opt 
                  where trade_num = @ticket   
               if (@premium_amount is not null and 
                   @premium_curr_code is not null and   
                   @premium_uom_code is not null)   
                  set @optn_prem = rtrim(convert(char(25), convert(numeric(20, 4), @premium_amount))) + ' ' +   
                                                rtrim(@premium_curr_code) + '/' + rtrim(@premium_uom_code)   
            end   
         end   
      end   
     
      if (@trade_type_code = 'EXCHGOPT')   
         select @record_count = count(distinct put_call_ind) 
         from dbo.trade_item_exch_opt 
         where trade_num = @ticket   
      else   
         select @record_count = count(distinct put_call_ind) 
         from dbo.trade_item_otc_opt 
         where trade_num = @ticket   
      if (@record_count != 1)   
         set @put_call_ind = ' '   
      else    
      begin   
         if (@trade_type_code = 'EXCHGOPT')   
            select @put_call_ind = put_call_ind 
            from dbo.trade_item_exch_opt   
         else   
            select @put_call_ind = put_call_ind 
            from dbo.trade_item_otc_opt   
      end   
   end   
     
   select @is_formula = formula_ind 
   from dbo.trade_item 
   where trade_num = @ticket     
   if (@is_formula = 'Y')     
   begin     
      select @record_count = count(*) 
      from dbo.quote_pricing_period 
      where trade_num = @ticket and 
            total_qty < 0.0 and 
            total_qty >= -1.0     
      if (@record_count > 0)     
         set @pricing_str = 'COMPLEX'     
      else     
      begin  /* simple formula */    
         create table #formula_body 
         (     
            formula_num int,     
            formula_body_num int,     
            formula_body_type char(1),     
            formula_qty_pcnt_val float,     
            formula_qty_uom_code char(8),     
            formula_body_string varchar(255)     
         )     
         
         create table #formula_component 
         (     
            formula_num int,     
            formula_body_num int,     
            formula_comp_num int,     
            cmdty_code char(15),     
            mkt_code char(15),     
            trading_prd char(8),     
            price_source_code char(8),     
            quote_type char(1)     
         )   
           
         set @formula_iteration = 1    
         while (@formula_iteration = 1 or 
                @formula_iteration = 2 and 
                @trade_type_code = 'SWAPFLT')    
         begin  /* one side of the formula */    
            select @formula_num = formula_num 
            from dbo.trade_formula 
            where trade_num = @ticket     
            if (@trade_type_code = 'SWAPFLT')     
            begin    
               if (@formula_iteration = 1)  /* receive quote first */    
                  select @formula_num = formula_comp_ref 
                  from dbo.formula_component     
                  where formula_num = @formula_num and 
                        formula_comp_type = 'M' and 
                        formula_comp_name = 'SwapSellFloat'    
               else    
                  select @formula_num = formula_comp_ref 
                  from dbo.formula_component     
                  where formula_num = @formula_num and 
                        formula_comp_type = 'M' and 
                        formula_comp_name = 'SwapBuyFloat'    
            end    
            insert into #formula_body     
              select formula_num, 
                     formula_body_num, 
                     formula_body_type,     
                     formula_qty_pcnt_val, 
                     formula_qty_uom_code, 
                     formula_body_string     
              from dbo.formula_body 
              where formula_num = @formula_num and 
                    formula_body_type in ('P', 'Q')     
              order by formula_num, formula_body_num     
              
            select @formula_body_num = min(formula_body_num) 
            from #formula_body     
            while @formula_body_num is not null     
            begin   /* process a formula_body */    
               insert into #formula_component     
                 select c.formula_num, 
                        c.formula_body_num, 
                        c.formula_comp_num,     
                        rtrim(o.cmdty_short_name), 
                        rtrim(m.mkt_code), 
                        rtrim(c.trading_prd),     
                        rtrim(c.price_source_code), 
                        c.formula_comp_val_type     
                 from dbo.formula_component c, 
                      dbo.commodity_market m, 
                      dbo.commodity o     
                 where c.formula_num = @formula_num and 
                       c.formula_body_num = @formula_body_num and 
                       c.commkt_key = m.commkt_key and 
                       c.formula_comp_type = 'G' and 
                       m.cmdty_code = o.cmdty_code     
                 order by c.formula_num, c.formula_body_num, c.formula_comp_num     
      
               select @formula_comp_num = min(formula_comp_num) 
               from #formula_component     
               where formula_num = @formula_num and 
                     formula_body_num = @formula_body_num     
      
               if (@formula_comp_num is not null)     
               begin     
                  select @pricing_str = convert(varchar(12), convert(numeric(22,2), b.formula_qty_pcnt_val)) + ' ' +     
                                              rtrim(b.formula_qty_uom_code) + ' ' + rtrim(c.cmdty_code) + '/' + rtrim(c.mkt_code) + '/' +     
                                                 rtrim(c.price_source_code) + '/' + rtrim(c.trading_prd) + '/' + c.quote_type     
                  from #formula_body b, 
                       #formula_component c     
                  where c.formula_num = @formula_num and 
                        c.formula_body_num = @formula_body_num and 
                        c.formula_comp_num = @formula_comp_num and 
                        b.formula_num = c.formula_num and 
                        b.formula_body_num = c.formula_body_num     
               end     
      
               select @formula_comp_num = min(formula_comp_num) 
               from #formula_component     
               where formula_num = @formula_num and 
                     formula_body_num = @formula_body_num and 
                     formula_comp_num > @formula_comp_num     
      
               while (@formula_comp_num is not null)     
               begin     
                  select @pricing_str = @pricing_str + ', ' + rtrim(cmdty_code) + '/' + rtrim(mkt_code) + '/' +     
                                             rtrim(price_source_code) + '/' + rtrim(trading_prd) + '/' + quote_type     
                  from #formula_component     
                  where formula_num = @formula_num and 
                        formula_body_num = @formula_body_num and 
                        formula_comp_num = @formula_comp_num     
      
                  select @formula_comp_num = min(formula_comp_num) 
                  from #formula_component     
                  where formula_num = @formula_num and 
                        formula_body_num = @formula_body_num and 
                        formula_comp_num > @formula_comp_num     
               end     
               /* differential */     
               select @formula_body_string = formula_body_string 
               from #formula_body     
               where formula_num = @formula_num and 
                     formula_body_num = @formula_body_num     
               set @diff_index = charindex('+', @formula_body_string)     
               if (@diff_index > 0)     
                  set @pricing_str = @pricing_str +  
                                           substring(@formula_body_string, @diff_index, len(@formula_body_string) - @diff_index + 1)     
               else     
               begin     
                  set @diff_index = charindex('-', @formula_body_string)     
                  if (@diff_index > 0)     
                     set @pricing_str = @pricing_str + 
                                                substring(@formula_body_string, @diff_index, len(@formula_body_string) - @diff_index + 1)     
               end     
               set @pricing_str = @pricing_str + ' '     
               delete #formula_component     
               select @formula_body_num = min(formula_body_num) 
               from #formula_body     
               where formula_body_num > @formula_body_num     
            end /* process a formula_body */    
         
            /* constant formula body */    
            set @formula_body_string = ''    
            select @formula_body_string = rtrim(formula_body_string) 
            from dbo.formula_body     
            where formula_num = @formula_num and 
                  formula_body_type = 'M'     
            if (@trade_type_code = 'SWAP')    
            begin    
               set @diff_index = charindex('-', @formula_body_string)    
               if (@diff_index > 0)    
                  set @fixed_price = substring(@formula_body_string, @diff_index + 1, len(@formula_body_string) - @diff_index)    
            end    
            else    
               set @pricing_str = @pricing_str + @formula_body_string         
            if (@trade_type_code = 'SWAPFLT')    
            begin    
               delete #formula_component    
               delete #formula_body    
               if (@formula_iteration = 1)    
                  set @rec_price = @pricing_str    
               else    
                  set @pay_price = @pricing_str    
            end    
            select @formula_iteration = @formula_iteration + 1    
         end   /* one side of the formula */    
         drop table #formula_body     
         drop table #formula_component     
      end  /* simple formula */    
      if (@trade_type_code != 'SWAPFLT')    
      begin    
         if (@trade_type_code = 'SWAP')    
         begin    
            if (@buy_sell_ind = 'S')     
            begin     
               set @pay_price = @pricing_str     
               set @rec_price = @fixed_price    
            end     
            else     
            begin     
               set @rec_price = @pricing_str     
               set @pay_price = @fixed_price    
            end    
         end    
         else    
         begin    
            if (@buy_sell_ind = 'B')     
               set @pay_price = @pricing_str     
            else     
               set @rec_price = @pricing_str     
         end    
      end /* swapflt */    
   end  /* formula trade*/    
   else  /* fixed price trade */    
   begin     
      select @fixed_price = convert(char(10), convert(numeric(10, 4), avg_price)) + ' ' + rtrim(price_curr_code) + '/' + price_uom_code     
      from dbo.trade_item 
      where trade_num = @ticket     
      if (@buy_sell_ind = 'B')     
      begin     
         set @pay_price = @fixed_price     
      end     
      else     
      begin     
         set @rec_price = @fixed_price     
      end     
   end     

   set @xml_val = (select 
                     (select rtrim(@ticket) as '*' for xml path ('')) as id,     
                     (select rtrim(@ticket) as '*' for xml path ('')) as trade_id,     
                     (select rtrim(convert(char(16), @inception_dt, 120)) as '*' for xml path ('')) inception_dt,     
                     (select rtrim(@cdty_code) as '*' for xml path ('')) as cdty_code,     
                     (select rtrim(convert(char(10), @trade_dt, 120)) as '*' for xml path ('')) trade_dt,     
                     (select null as '*' for xml path ('')) as xref,     
                     (select rtrim(@cpty_short_name) as '*' for xml path ('')) as cpty_sn,     
                     (select rtrim(@qty_tot) as '*' for xml path ('')) as qty_tot,     
                     (select rtrim(@qty) as '*' for xml path ('')) as qty,     
                     (select rtrim(@uom_dur_code) as '*' for xml path ('')) as uom_dur_code,     
                     (select rtrim(@location_sn) as '*' for xml path ('')) as location_sn,     
                     (select rtrim(@price_desc) as '*' for xml path ('')) as price_desc,     
                     (select rtrim(convert(char(10), @start_dt, 120)) as '*' for xml path ('')) as start_dt,     
                     (select rtrim(convert(char(10), @end_dt, 120)) as '*' for xml path ('')) as end_dt,     
                     (select rtrim(@book) as '*' for xml path ('')) as book,     
                     (select rtrim(@trade_type_code) as '*' for xml path ('')) as trade_type_code,     
                     (select rtrim(@sttl_type) as '*' for xml path ('')) as sttl_type,     
                     (select rtrim(@broker_short_name) as '*' for xml path ('')) as broker_short_name,     
                     (select rtrim(@comm) as '*' for xml path ('')) as comm,     
                     (select rtrim(@buy_sell_ind) as '*' for xml path ('')) as buy_sell_ind,     
                     (select null as '*' for xml path ('')) as ref_sn,     
                     (select rtrim(@pay_price) as '*' for xml path ('')) as pay_price,     
                     (select rtrim(@rec_price) as '*' for xml path ('')) as rec_price,     
                     (select rtrim(@booking_company_short_name) as '*' for xml path ('')) as se_cpty_sn,     
                     (select rtrim(@trade_stat_code) as '*' for xml path ('')) as trade_stat_code,   
                     (select rtrim(@strike_price) as '*' for xml path ('')) as optn_strike_price,    
                     (select rtrim(@optn_prem) as '*' for xml path ('')) as optn_prem_price,    
                     (select rtrim(@broker_rate) as '*' for xml path ('')) as broker_price,    
                     (select rtrim(@put_call_ind) as '*' for xml path ('')) as optn_put_call_ind    
                      for xml path ('TradeData'))
  
   select @xml_val as XML_VAL
end  
GO
GRANT EXECUTE ON  [dbo].[trade_alert_ops_track_xml] TO [next_usr]
GO
