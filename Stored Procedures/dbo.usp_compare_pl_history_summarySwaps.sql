SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_compare_pl_history_summarySwaps] 
( 
  @resp_trans_id_NEW     int,      
  @resp_trans_id_OLD     int,      
  @portnum               int = null,      
  @digits_for_scale4     tinyint = 4,      
  @digits_for_scale7     tinyint = 7
)        
as      
set nocount on      
      
   print ' '      
   print '==================================================='      
   print ' DATA : pl_history (Summary Swaps)'      
   print '==================================================='      
   print ' '      
      
   select resp_trans_id,       
          real_port_num,       
          pl_record_key,      
          pl_owner_code,      
          pl_asof_date,      
          pl_type,      
          pl_owner_sub_code,      
          pl_record_owner_key,      
          pl_primary_owner_key1,      
          pl_primary_owner_key2,      
          pl_primary_owner_key3,      
          pl_primary_owner_key4,      
          pl_secondary_owner_key1,      
          pl_secondary_owner_key2,      
          pl_secondary_owner_key3,      
          pl_category_type,      
          pl_realization_date,      
          pl_cost_status_code,      
          pl_cost_prin_addl_ind,      
          str(pl_mkt_price, 38, @digits_for_scale4) as pl_mkt_price,      
          str(pl_amt, 38, @digits_for_scale4) as pl_amt,      
          trans_id,       
          str(currency_fx_rate, 38, @digits_for_scale4) as currency_fx_rate,      
          str(pl_record_qty, 38, @digits_for_scale4) as pl_record_qty,      
          pl_record_qty_uom_code,      
          pos_num      
      into #plhist      
   from dbo.aud_pl_history      
   where resp_trans_id in (@resp_trans_id_NEW, @resp_trans_id_OLD) and       
         1 = case when @portnum is null then 1      
                  when real_port_num = @portnum then 1      
                  else 0      
             end      
              
   select       
      min(resp_trans_id) as resp_trans_id,       
      real_port_num,       
      pl_record_key,       
      pl_owner_code,       
      pl_asof_date,       
      pl_type,        
      pl_owner_sub_code,       
      pl_record_owner_key,       
      pl_primary_owner_key1,       
      pl_primary_owner_key2,       
      pl_primary_owner_key3,       
      pl_primary_owner_key4,       
      pl_secondary_owner_key1,       
      pl_secondary_owner_key2,       
      pl_secondary_owner_key3,       
      pl_category_type,       
      pl_realization_date,       
      pl_cost_status_code,       
      pl_cost_prin_addl_ind,       
      pl_mkt_price,       
      pl_amt,       
      min(trans_id) as trans_id1,       
      currency_fx_rate,       
      pl_record_qty,       
      pl_record_qty_uom_code,       
      pos_num      
        into #plhist1      
   from #plhist      
   group by pl_record_key, pl_owner_code, pl_asof_date, pl_type,        
            real_port_num, pl_owner_sub_code, pl_record_owner_key,       
            pl_primary_owner_key1, pl_primary_owner_key2,       
            pl_primary_owner_key3, pl_primary_owner_key4,       
            pl_secondary_owner_key1, pl_secondary_owner_key2,       
            pl_secondary_owner_key3, pl_category_type, pl_realization_date,       
            pl_cost_status_code, pl_cost_prin_addl_ind, pl_mkt_price,       
            pl_amt, currency_fx_rate, pl_record_qty, pl_record_qty_uom_code,       
            pos_num      
   having count(*) = 1      
   order by real_port_num, pl_record_key, 
            pl_owner_code, pl_asof_date, 
            pl_type, resp_trans_id      
   drop table #plhist      
      
   -- pick summary swaps for which the details do not exist in one of the runs    
   select *    
      into #plHist_ES_sum     
   from #plhist1 a    
   where pl_owner_code = 'ES' and 
         a.resp_trans_id = @resp_trans_id_NEW and 
         not exists (select 1 
                     from #plhist1 b 
                     where a.pos_num = b.pos_num and 
                           a.real_port_num = b.real_port_num and  
                           b.resp_trans_id = @resp_trans_id_OLD and 
                           pl_owner_code = 'ES')    
    
   insert into #plHist_ES_sum    
   select *     
   from #plhist1 a    
   where pl_owner_code = 'ES' and 
         a.resp_trans_id = @resp_trans_id_OLD and 
         not exists (select 1 
                     from #plhist1 b 
                     where a.pos_num = b.pos_num and 
                           a.real_port_num = b.real_port_num and 
                           b.resp_trans_id = @resp_trans_id_NEW and 
                           pl_owner_code = 'ES')    
    
   -- pick all the tid records for which summary swaps exists in one of the runs    
   select *    
      into #plHist_ES_detailFromTID    
    from #plhist1    
    where ((pl_owner_code = 'T' and 
            pl_type != 'W') or 
            pl_owner_code = 'C') and 
          pos_num in (select pos_num 
                      from #plhist1 
                      where pl_owner_code = 'ES')    
          
   create table #plHist_ES_sumFromTID 
   (
      pos_num          int, 
      real_port_num    int, 
      pl_owner_code    char(8), 
      pl_type          char(8), 
      sumPlAmt         float
   )       
      
   insert into #plHist_ES_sumFromTID    
   select pos_num, real_port_num, pl_owner_code, 'S', SUM(convert(float, pl_amt))    
   from #plHist_ES_detailFromTID 
   where pl_owner_code = 'T'    
   group by pos_num, real_port_num, pl_owner_code    
      
   insert into #plHist_ES_sumFromTID    
   select pos_num, real_port_num, pl_owner_code, 'C', SUM(convert(float, pl_amt))    
   from #plHist_ES_detailFromTID 
   where pl_owner_code = 'C' and 
         pl_owner_sub_code = 'SWAP'     
   group by pos_num, real_port_num, pl_owner_code    
        
   insert into #plHist_ES_sumFromTID    
   select pos_num, real_port_num, pl_owner_code, 'R', SUM(convert(float, pl_amt))    
   from #plHist_ES_detailFromTID 
   where pl_owner_code = 'C' and 
         pl_owner_sub_code != 'SWAP'    
   group by pos_num, real_port_num, pl_owner_code    
      
   --- compare ES against sum for C and T    
   select 'Summary Swap', 
          es_Sum.pos_num, 
          es_Sum.pl_type, 
          es_Sum.pl_amt as 'ES_Sum', 
          tid_sum.sumPlAmt as 'SWAP_Sum', 
          es_Sum.pl_amt - tid_sum.sumPlAmt as 'Diff' 
   from #plHist_ES_sum es_Sum    
           inner join #plHist_ES_sumFromTID tid_sum 
              on es_Sum.pos_num = tid_sum.pos_num and 
                 es_Sum.pl_type = tid_sum.pl_type    
   where ABS(es_Sum.pl_amt - tid_sum.sumPlAmt) > 0.001    
    
   delete #plhist1 
   where pos_num in (select distinct pos_num 
                     from #plHist_ES_sum)    
        
   drop table #plhist1      
GO
GRANT EXECUTE ON  [dbo].[usp_compare_pl_history_summarySwaps] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_compare_pl_history_summarySwaps', NULL, NULL
GO
