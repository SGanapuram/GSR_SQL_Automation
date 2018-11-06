SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_compare_tid_pl]
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
   print ' DATA : tid_pl'  
   print '==================================================='  
   print ' '  
  
   select resp_trans_id,   
          real_port_num,  
          dist_num,  
          str(open_pl, 38, @digits_for_scale4) as open_pl,  
          str(closed_pl, 38, @digits_for_scale4) as closed_pl,  
          pl_curr_code,   
          str(addl_cost_sum, 38, @digits_for_scale4) as addl_cost_sum,  
          pl_asof_date,  
          trans_id  
      into #tidpl  
   from dbo.aud_tid_pl a,   
        (select dist_num as distnum,   
                real_port_num   
         from dbo.trade_item_dist) d  
         where dist_num = distnum and  
               resp_trans_id in (@resp_trans_id_NEW, @resp_trans_id_OLD) and   
               1 = case when @portnum is null then 1  
                        when real_port_num = @portnum then 1  
                        else 0  
                   end  
  
   select   
      min(resp_trans_id) as resp_trans_id,   
      min(real_port_num) as real_port_num,  
      dist_num,  
      open_pl,  
      closed_pl,  
      pl_curr_code,   
      addl_cost_sum,  
      pl_asof_date,  
      min(trans_id) as trans_id1  
       into #tidpl1  
   from #tidpl   
   group by dist_num, open_pl, closed_pl, pl_curr_code, 
            addl_cost_sum, pl_asof_date   
   having count(*) = 1  
   order by dist_num, pl_asof_date, resp_trans_id     
   drop table #tidpl   
  
   select   
      'NEW' as PASS,  
      resp_trans_id,   
      dist_num,   
      convert(varchar, pl_asof_date, 101) as pl_asof_date,   
      open_pl,  
      closed_pl,  
      addl_cost_sum,  
      pl_curr_code,  
      trans_id1  
   from #tidpl1  
   where resp_trans_id = @resp_trans_id_NEW  
   union        
   select   
      'OLD' as PASS,  
      b.resp_trans_id,  
      b.dist_num,   
      convert(varchar, b.pl_asof_date, 101) as pl_asof_date,   
      case when isnull(a.open_pl, '@@@') <> isnull(b.open_pl, '@@@')   
              then b.open_pl  
           else ' '  
      end as open_pl,   
      case when isnull(a.closed_pl, '@@@') <> isnull(b.closed_pl, '@@@')   
              then b.closed_pl  
           else ' '  
      end as closed_pl,   
      case when isnull(a.addl_cost_sum, '@@@') <> isnull(b.addl_cost_sum, '@@@')   
              then b.addl_cost_sum  
           else ' '  
      end as addl_cost_sum,   
      case when isnull(a.pl_curr_code, '@@@') <> isnull(b.pl_curr_code, '@@@')   
              then b.pl_curr_code  
           else ' '  
      end as pl_curr_code,   
      b.trans_id1    
   from (select *  
         from #tidpl1  
         where resp_trans_id = @resp_trans_id_NEW) a,  
        (select  *  
         from #tidpl1  
         where resp_trans_id = @resp_trans_id_OLD) b   
   where a.dist_num = b.dist_num and  
         a.pl_asof_date = b.pl_asof_date  
   order by dist_num, pl_asof_date, resp_trans_id       
  
   drop table #tidpl1  
GO
GRANT EXECUTE ON  [dbo].[usp_compare_tid_pl] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_compare_tid_pl', NULL, NULL
GO
