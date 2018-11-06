SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_compare_portfolio_pl]  
(    
   @resp_trans_id_NEW    int,      
   @resp_trans_id_OLD    int,      
   @portnum              int = null,      
   @digits_for_scale4    tinyint = 4,      
   @digits_for_scale7    tinyint = 7  
)      
as      
set nocount on      
      
   print ' '      
   print '==================================================='      
   print ' DATA : portfolio_profit_loss'      
   print '==================================================='      
   print ' '      
      
  select port_num,       
         pl_asof_date,       
         pl_calc_date,       
         pl_curr_code,       
         str(open_phys_pl, 38, @digits_for_scale4) as open_phys_pl,      
         str(open_hedge_pl, 38, @digits_for_scale4) as open_hedge_pl,      
         str(closed_phys_pl, 38, @digits_for_scale4) as closed_phys_pl,      
         str(closed_hedge_pl, 38, @digits_for_scale4) as closed_hedge_pl,      
         str(other_pl, 38, @digits_for_scale4) as other_pl,      
         str(liq_open_phys_pl, 38, @digits_for_scale4) as liq_open_phys_pl,      
         str(liq_open_hedge_pl, 38, @digits_for_scale4) as liq_open_hedge_pl,      
         str(liq_closed_phys_pl, 38, @digits_for_scale4) as liq_closed_phys_pl,      
         str(liq_closed_hedge_pl, 38, @digits_for_scale4) as liq_closed_hedge_pl,      
         is_week_end_ind,       
         is_month_end_ind,       
         is_year_end_ind,       
         is_compyr_end_ind,       
         trans_id,       
         resp_trans_id,       
         pass_run_detail_id,       
         is_official_run_ind,      
         str(total_pl_no_sec_cost, 38, @digits_for_scale4) as total_pl_no_sec_cost      
      into #portpl      
   from dbo.aud_portfolio_profit_loss      
   where resp_trans_id in (@resp_trans_id_NEW, @resp_trans_id_OLD) and       
         1 = case when @portnum is null then 1      
                  when port_num = @portnum then 1      
                  else 0      
             end      
                          
   select       
      min(resp_trans_id) as resp_trans_id,       
      port_num,       
      'XX' as port_type,      
      pl_asof_date,       
      min(pl_calc_date) as pl_calc_date1,       
      pl_curr_code,       
      open_phys_pl,       
      open_hedge_pl,       
      closed_phys_pl,       
      closed_hedge_pl,       
      other_pl,      
      liq_open_phys_pl,      
      liq_open_hedge_pl,      
      liq_closed_phys_pl,      
      liq_closed_hedge_pl,       
      is_week_end_ind,       
      is_month_end_ind,       
      is_year_end_ind,       
      is_compyr_end_ind,       
      min(trans_id) as trans_id1,       
      min(pass_run_detail_id) as pass_run_detail_id1,       
      is_official_run_ind,      
      total_pl_no_sec_cost      
        into #portpl1      
   from #portpl                 
   group by port_num, pl_asof_date,pl_curr_code, open_phys_pl, 
            open_hedge_pl, closed_phys_pl, closed_hedge_pl, 
            other_pl,liq_open_phys_pl,liq_open_hedge_pl,
            liq_closed_phys_pl, liq_closed_hedge_pl, is_week_end_ind, 
            is_month_end_ind, is_year_end_ind,       
            is_compyr_end_ind, is_official_run_ind,      
            total_pl_no_sec_cost      
   having count(*) = 1      
   order by port_num, pl_asof_date, resp_trans_id      
   drop table #portpl      
         
   update p      
   set port_type = p1.port_type      
   from #portpl1 p      
           inner join dbo.portfolio p1      
              on p.port_num = p1.port_num      
      
   select       
      'NEW' as PASS,      
      resp_trans_id,       
      port_num,       
      port_type,      
      convert(varchar, pl_asof_date, 101) as pl_asof_date,       
      open_phys_pl,      
      open_hedge_pl,      
      closed_phys_pl,      
      closed_hedge_pl,      
      other_pl,      
      liq_open_phys_pl,      
      liq_open_hedge_pl,      
      liq_closed_phys_pl,      
      liq_closed_hedge_pl,      
      total_pl_no_sec_cost,       
      convert(varchar, pl_calc_date1, 101) as pl_calc_date,      
      pl_curr_code,      
      is_week_end_ind,      
      is_month_end_ind,      
      is_year_end_ind,      
      is_compyr_end_ind,      
      str(pass_run_detail_id1) as pass_run_detail_id,      
      is_official_run_ind,      
      trans_id1      
   from #portpl1      
   where resp_trans_id = @resp_trans_id_NEW      
   union            
   select       
      'OLD' as PASS,      
      b.resp_trans_id,      
      b.port_num,      
      b.port_type,      
      convert(varchar, b.pl_asof_date, 101) as pl_asof_date,       
      case when isnull(a.open_phys_pl, '@@@') <> isnull(b.open_phys_pl, '@@@')       
              then b.open_phys_pl      
           else ' '      
      end as open_phys_pl,       
      case when isnull(a.open_hedge_pl, '@@@') <> isnull(b.open_hedge_pl, '@@@')       
              then b.open_hedge_pl      
           else ' '      
      end as open_hedge_pl,       
      case when isnull(a.closed_phys_pl, '@@@') <> isnull(b.closed_phys_pl, '@@@')       
              then b.closed_phys_pl      
           else ' '      
      end as closed_phys_pl,       
      case when isnull(a.closed_hedge_pl, '@@@') <> isnull(b.closed_hedge_pl, '@@@')       
              then b.closed_hedge_pl      
           else ' '      
      end as closed_hedge_pl,       
      case when isnull(a.other_pl, '@@@') <> isnull(b.other_pl, '@@@')       
              then b.other_pl      
           else ' '      
      end as other_pl,       
      case when isnull(a.liq_open_phys_pl, '@@@') <> isnull(b.liq_open_phys_pl, '@@@')       
              then b.liq_open_phys_pl      
           else ' '      
      end as liq_open_phys_pl,       
      case when isnull(a.liq_open_hedge_pl, '@@@') <> isnull(b.liq_open_hedge_pl, '@@@')       
              then b.liq_open_hedge_pl      
           else ' '      
      end as liq_open_hedge_pl,       
      case when isnull(a.liq_closed_phys_pl, '@@@') <> isnull(b.liq_closed_phys_pl, '@@@')       
              then b.liq_closed_phys_pl      
           else ' '      
      end as liq_closed_phys_pl,       
      case when isnull(a.liq_closed_hedge_pl, '@@@') <> isnull(b.liq_closed_hedge_pl, '@@@')       
              then b.liq_closed_hedge_pl      
           else ' '      
      end as liq_closed_hedge_pl,       
      case when isnull(a.total_pl_no_sec_cost, '@@@') <> isnull(b.total_pl_no_sec_cost, '@@@')       
              then b.total_pl_no_sec_cost      
           else ' '      
      end as total_pl_no_sec_cost,       
      case when isnull(a.pl_calc_date1, '01/01/1990') <> isnull(b.pl_calc_date1, '01/01/1990')       
              then convert(varchar, b.pl_calc_date1, 101)      
           else ' '      
      end as pl_calc_date,       
      case when isnull(a.pl_curr_code, '@@@') <> isnull(b.pl_curr_code, '@@@')       
              then b.pl_curr_code      
           else ' '      
      end as pl_curr_code,       
      case when isnull(a.is_week_end_ind, '@@@') <> isnull(b.is_week_end_ind, '@@@')       
              then b.is_week_end_ind      
           else ' '      
      end as is_week_end_ind,       
      case when isnull(a.is_month_end_ind, '@@@') <> isnull(b.is_month_end_ind, '@@@')       
              then b.is_month_end_ind      
           else ' '      
      end as is_month_end_ind,       
      case when isnull(a.is_year_end_ind, '@@@') <> isnull(b.is_year_end_ind, '@@@')       
              then b.is_year_end_ind      
           else ' '      
      end as is_year_end_ind,       
      case when isnull(a.is_compyr_end_ind, '@@@') <> isnull(b.is_compyr_end_ind, '@@@')       
              then b.is_compyr_end_ind      
           else ' '      
      end as is_compyr_end_ind,       
      case when isnull(a.pass_run_detail_id1, -1) <> isnull(b.pass_run_detail_id1, -1)       
              then str(b.pass_run_detail_id1)      
           else ' '      
      end as pass_run_detail_id,       
      case when isnull(a.is_official_run_ind, '@@@') <> isnull(b.is_official_run_ind, '@@@')       
              then b.is_official_run_ind      
           else ' '      
      end as is_official_run_ind,            
      b.trans_id1        
   from (select *      
         from #portpl1      
         where resp_trans_id = @resp_trans_id_NEW) a,      
        (select  *      
         from #portpl1      
         where resp_trans_id = @resp_trans_id_OLD) b       
   where a.pl_asof_date = b.pl_asof_date and       
         a.port_num = b.port_num      
   order by port_num, pl_asof_date, resp_trans_id      
      
   drop table #portpl1 
GO
GRANT EXECUTE ON  [dbo].[usp_compare_portfolio_pl] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_compare_portfolio_pl', NULL, NULL
GO
