SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_compare_tid_mtm_vol]
(  
   @resp_trans_id_NEW      int,  
   @resp_trans_id_OLD      int,  
   @portnum                int = null,  
   @digits_for_scale4      tinyint = 4,  
   @digits_for_scale7      tinyint = 7
)    
as  
set nocount on  
  
   print ' '  
   print '==================================================='  
   print ' DATA : tid_mtm_volatility'  
   print '==================================================='  
   print ' '        
  
   select resp_trans_id,   
          real_port_num,  
          dist_num,   
          mtm_pl_asof_date,   
          vol_num,   
          str(strike_price, 38, @digits_for_scale4) as strike_price,  
          str(skew_price, 38, @digits_for_scale7) as skew_price,  
          curr_code,   
          uom_code,   
          str(volatility, 38, @digits_for_scale7) as volatility,  
          use_option_skew,   
          trans_id   
      into #tidmtmvol  
   from dbo.aud_tid_mtm_volatility a,   
       (select dist_num as distnum,   
               real_port_num   
        from dbo.trade_item_dist) d  
   where a.dist_num = d.distnum and  
         resp_trans_id in (@resp_trans_id_NEW, @resp_trans_id_OLD) and   
         1 = case when @portnum is null then 1  
                  when real_port_num = @portnum then 1  
                  else 0  
             end  
        
   select   
      min(resp_trans_id) as resp_trans_id,   
      min(real_port_num) as real_port_num,  
      dist_num,   
      mtm_pl_asof_date,   
      vol_num,   
      strike_price,   
      skew_price,   
      curr_code,   
      uom_code,   
      volatility,   
      use_option_skew,   
      min(trans_id) as trans_id1   
       into #tidmtmvol1  
   from #tidmtmvol  
   group by dist_num, mtm_pl_asof_date, vol_num, strike_price, skew_price,   
            curr_code, uom_code, volatility, use_option_skew  
   having count(*) = 1  
   order by dist_num, mtm_pl_asof_date, resp_trans_id  
   drop table #tidmtmvol  
       
   select   
      'NEW' as PASS,  
      resp_trans_id,   
      dist_num,   
      convert(varchar, mtm_pl_asof_date, 101) as mtm_pl_asof_date,   
      vol_num,  
      strike_price,  
      skew_price,  
      volatility,  
      curr_code,  
      uom_code,  
      use_option_skew,  
      trans_id1  
   from #tidmtmvol1  
   where resp_trans_id = @resp_trans_id_NEW  
   union        
   select   
      'OLD' as PASS,  
      b.resp_trans_id,  
      b.dist_num,   
      convert(varchar, b.mtm_pl_asof_date, 101) as mtm_pl_asof_date,   
      b.vol_num,  
      case when isnull(a.strike_price, '@@@') <> isnull(b.strike_price, '@@@')   
              then b.strike_price  
           else ' '  
      end as strike_price,   
      case when isnull(a.skew_price, '@@@') <> isnull(b.skew_price, '@@@')   
              then b.skew_price  
           else ' '  
      end as skew_price,   
      case when isnull(a.volatility, '@@@') <> isnull(b.volatility, '@@@')   
              then b.volatility  
           else ' '  
      end as volatility,   
      case when isnull(a.curr_code, '@@@') <> isnull(b.curr_code, '@@@')   
              then b.curr_code  
           else ' '  
      end as curr_code,   
      case when isnull(a.uom_code, '@@@') <> isnull(b.uom_code, '@@@')   
              then b.uom_code  
           else ' '  
      end as uom_code,   
      case when isnull(a.use_option_skew, '@') <> isnull(b.use_option_skew, '@')   
              then b.use_option_skew  
           else ' '  
      end as use_option_skew,   
      b.trans_id1    
   from (select *  
         from #tidmtmvol1  
         where resp_trans_id = @resp_trans_id_NEW) a,  
        (select  *  
         from #tidmtmvol1  
         where resp_trans_id = @resp_trans_id_OLD) b   
   where a.dist_num = b.dist_num and  
         a.mtm_pl_asof_date = b.mtm_pl_asof_date and  
         a.vol_num = b.vol_num  
   order by dist_num, mtm_pl_asof_date, resp_trans_id  
  
   drop table #tidmtmvol1  
GO
GRANT EXECUTE ON  [dbo].[usp_compare_tid_mtm_vol] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_compare_tid_mtm_vol', NULL, NULL
GO
