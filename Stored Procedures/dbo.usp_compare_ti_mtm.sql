SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[usp_compare_ti_mtm] 
  @resp_trans_id_NEW     int,    
  @resp_trans_id_OLD       int,    
  @portnum                int = null,    
  @digits_for_scale4      tinyint = 4,    
  @digits_for_scale7      tinyint = 7      
as    
set nocount on    
    
   print ' '    
   print '==================================================='    
   print ' DATA : ti_mark_to_market'    
   print '==================================================='    
   print ' '    
    
  select resp_trans_id,    
         trade_num,    
         order_num,    
         item_num,     
         mtm_pl_asof_date,     
         acct_num,     
         real_port_num,     
         trader_init,     
         creation_date,     
         contr_date,     
         order_type_code,     
         booking_comp_num,     
         p_s_ind,     
         cmdty_code,     
         risk_mkt_code,     
         trading_prd,     
         last_trade_date,     
          str(contr_qty, 38, @digits_for_scale4) as contr_qty,    
         contr_qty_uom_code,     
         contr_qty_periodicity,     
          str(open_qty, 38, @digits_for_scale4) as open_qty,    
         trans_id    
   into #timtm    
   from dbo.aud_ti_mark_to_market    
   where resp_trans_id in (@resp_trans_id_NEW, @resp_trans_id_OLD) and     
          1 = case when @portnum is null then 1    
                   when real_port_num = @portnum then 1    
                   else 0    
              end    
    
  select     
     min(resp_trans_id) as resp_trans_id,     
     trade_num,    
     order_num,    
     item_num,     
     mtm_pl_asof_date,     
     acct_num,     
     real_port_num,     
     trader_init,     
     min(creation_date) as create_date1,     
     min(contr_date) as contr_date1,     
     order_type_code,     
     booking_comp_num,     
     p_s_ind,     
     cmdty_code,     
     risk_mkt_code,     
     trading_prd,     
     last_trade_date,     
     contr_qty,     
     contr_qty_uom_code,     
     contr_qty_periodicity,     
     open_qty,     
     min(trans_id) as trans_id1     
  into #timtm1    
   from #timtm    
  group by trade_num, order_num, item_num, mtm_pl_asof_date, acct_num,     
              real_port_num, trader_init, order_type_code, booking_comp_num,     
              p_s_ind, cmdty_code, risk_mkt_code, trading_prd, last_trade_date,     
              contr_qty, contr_qty_uom_code, contr_qty_periodicity, open_qty     
  having count(*) = 1    
  order by trade_num, order_num, item_num, mtm_pl_asof_date, resp_trans_id         
   drop table #timtm    
 
 -- write changed columns  
 select     
     'OLD' as PASS,    
     b.resp_trans_id,    
     b.trade_num,     
      b.order_num,    
      b.item_num,    
     convert(varchar, b.mtm_pl_asof_date, 101) as mtm_pl_asof_date,     
     case when isnull(a.contr_qty, '@@@') <> isnull(b.contr_qty, '@@@')     
             then 'contr_qty'
          else ' ' end +
     case when isnull(a.open_qty, '@@@') <> isnull(b.open_qty, '@@@')     
             then ',open_qty'    
          else ' ' end +
      case when isnull(a.acct_num, -1) <> isnull(b.acct_num, -1) 
			 then ',acct_num'     
           else ' ' end +
      case when isnull(a.real_port_num, -1) <> isnull(b.real_port_num, -1) 
			 then ',real_port_num'     
           else ' ' end +
     case when isnull(a.trader_init, '@@@') <> isnull(b.trader_init, '@@@')     
             then ',trader_init'   
          else ' '    
     end as trader_init,     
     case when isnull(a.create_date1, '01/01/1990') <> isnull(b.create_date1, '01/01/1990')     
             then ',create_date1'    
          else ' ' end +    
     case when isnull(a.contr_date1, '01/01/1990') <> isnull(b.contr_date1, '01/01/1990')     
             then ',contr_date1'  
          else ' ' end +   
     case when isnull(a.order_type_code, '@@@') <> isnull(b.order_type_code, '@@@')     
             then ',order_type_code'  
          else ' ' end +     
      case when isnull(a.booking_comp_num, -1) <> isnull(b.booking_comp_num, -1) 
			 then ',booking_comp_num'    
           else ' ' end +    
     case when isnull(a.p_s_ind, '@@@') <> isnull(b.p_s_ind, '@@@')     
             then ',p_s_ind'    
          else ' ' end + 
     case when isnull(a.cmdty_code, '@@@') <> isnull(b.cmdty_code, '@@@')     
             then ',cmdty_code'   
          else ' ' end + 
     case when isnull(a.risk_mkt_code, '@@@') <> isnull(b.risk_mkt_code, '@@@')     
             then ',risk_mkt_code'    
          else ' ' end +  
     case when isnull(a.trading_prd, '@@@') <> isnull(b.trading_prd, '@@@')     
             then ',trading_prd'    
          else ' ' end +     
     case when isnull(a.last_trade_date, '01/01/1990') <> isnull(b.last_trade_date, '01/01/1990')     
             then ',last_trade_date'   
          else ' ' end +    
     case when isnull(a.contr_qty_uom_code, '@@@') <> isnull(b.contr_qty_uom_code, '@@@')     
             then ',contr_qty_uom_code'    
          else ' ' end +  
     case when isnull(a.contr_qty_periodicity, '@@@') <> isnull(b.contr_qty_periodicity, '@@@')     
             then ',contr_qty_periodicity'    
          else ' ' end as diffColList    
 into #diffColList         
  from (select *    
        from #timtm1    
        where resp_trans_id = @resp_trans_id_NEW) a,    
       (select  *    
        from #timtm1    
        where resp_trans_id = @resp_trans_id_OLD) b     
  where a.trade_num = b.trade_num and    
        a.order_num = b.order_num and    
        a.item_num = b.item_num and    
        a.mtm_pl_asof_date = b.mtm_pl_asof_date
-- finish write changed columns.

  select     
     'NEW' as PASS,    
     tim.resp_trans_id, 
	 diffColList,    
     tim.trade_num,     
      tim.order_num,    
      tim.item_num,    
     convert(varchar, tim.mtm_pl_asof_date, 101) as mtm_pl_asof_date,     
      contr_qty,    
      open_qty,    
      str(acct_num) as acct_num,    
      str(real_port_num) as real_port_num,    
      tim.trader_init,    
      convert(varchar, create_date1, 101) as creation_date,    
      convert(varchar, contr_date1, 101) as contr_date,    
      order_type_code,    
      str(booking_comp_num) as booking_comp_num,    
      p_s_ind,    
      cmdty_code,    
      risk_mkt_code,    
      trading_prd,    
      convert(varchar, last_trade_date, 101) as last_trade_date,    
      contr_qty_uom_code,    
      contr_qty_periodicity,    
     trans_id1    
   from #timtm1 tim left outer join #diffColList difc    
 on tim.trade_num = difc.trade_num and tim.order_num= difc.order_num and tim.item_num=difc.item_num
 and tim.mtm_pl_asof_date = difc.mtm_pl_asof_date  
   where tim.resp_trans_id = @resp_trans_id_NEW    
   union          
  select     
     'OLD' as PASS,    
     b.resp_trans_id, 
	 diffColList,     
     b.trade_num,     
      b.order_num,    
      b.item_num,    
     convert(varchar, b.mtm_pl_asof_date, 101) as mtm_pl_asof_date,     
     case when isnull(a.contr_qty, '@@@') <> isnull(b.contr_qty, '@@@')     
             then b.contr_qty    
          else ' '    
     end as contr_qty,     
     case when isnull(a.open_qty, '@@@') <> isnull(b.open_qty, '@@@')     
             then b.open_qty    
          else ' '    
     end as open_qty,     
      case when isnull(a.acct_num, -1) <> isnull(b.acct_num, -1) then str(b.acct_num)     
           else ' '    
      end as acct_num,    
      case when isnull(a.real_port_num, -1) <> isnull(b.real_port_num, -1) then str(b.real_port_num)     
           else ' '    
      end as real_port_num,    
     case when isnull(a.trader_init, '@@@') <> isnull(b.trader_init, '@@@')     
             then b.trader_init    
          else ' '    
     end as trader_init,     
     case when isnull(a.create_date1, '01/01/1990') <> isnull(b.create_date1, '01/01/1990')     
             then convert(varchar, b.create_date1, 101)    
          else ' '    
     end as creation_date,     
     case when isnull(a.contr_date1, '01/01/1990') <> isnull(b.contr_date1, '01/01/1990')     
             then convert(varchar, b.contr_date1, 101)    
          else ' '    
     end as contr_date,     
     case when isnull(a.order_type_code, '@@@') <> isnull(b.order_type_code, '@@@')     
             then b.order_type_code    
          else ' '    
     end as order_type_code,     
      case when isnull(a.booking_comp_num, -1) <> isnull(b.booking_comp_num, -1) then str(b.booking_comp_num)     
           else ' '    
      end as booking_comp_num,    
     case when isnull(a.p_s_ind, '@@@') <> isnull(b.p_s_ind, '@@@')     
             then b.p_s_ind    
          else ' '    
     end as p_s_ind,     
     case when isnull(a.cmdty_code, '@@@') <> isnull(b.cmdty_code, '@@@')     
             then b.cmdty_code    
          else ' '    
     end as cmdty_code,     
     case when isnull(a.risk_mkt_code, '@@@') <> isnull(b.risk_mkt_code, '@@@')     
             then b.risk_mkt_code    
          else ' '    
     end as risk_mkt_code,     
     case when isnull(a.trading_prd, '@@@') <> isnull(b.trading_prd, '@@@')     
             then b.trading_prd    
          else ' '    
     end as trading_prd,     
     case when isnull(a.last_trade_date, '01/01/1990') <> isnull(b.last_trade_date, '01/01/1990')     
             then convert(varchar, b.last_trade_date, 101)    
          else ' '    
     end as last_trade_date,     
     case when isnull(a.contr_qty_uom_code, '@@@') <> isnull(b.contr_qty_uom_code, '@@@')     
             then b.contr_qty_uom_code    
          else ' '    
     end as contr_qty_uom_code,     
     case when isnull(a.contr_qty_periodicity, '@@@') <> isnull(b.contr_qty_periodicity, '@@@')     
             then b.contr_qty_periodicity    
          else ' '    
     end as contr_qty_periodicity,     
     b.trans_id1      
  from (select *    
        from #timtm1    
        where resp_trans_id = @resp_trans_id_NEW) a,    
       (select  *    
        from #timtm1    
        where resp_trans_id = @resp_trans_id_OLD) b left outer join #diffColList difc    
 on b.trade_num = difc.trade_num and b.order_num= difc.order_num and b.item_num=difc.item_num
 and b.mtm_pl_asof_date = difc.mtm_pl_asof_date     
  where a.trade_num = b.trade_num and    
        a.order_num = b.order_num and    
        a.item_num = b.item_num and    
        a.mtm_pl_asof_date = b.mtm_pl_asof_date    
   order by trade_num, order_num, item_num, mtm_pl_asof_date, resp_trans_id         
    
   drop table #timtm1    
GO
GRANT EXECUTE ON  [dbo].[usp_compare_ti_mtm] TO [next_usr]
GO
