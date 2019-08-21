SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
  
CREATE procedure [dbo].[usp_compare_pl_history_nonExpFutSumSwap]        
  @resp_trans_id_NEW     int,              
  @resp_trans_id_OLD     int,              
  @portnum               int = null,              
  @digits_for_scale4     tinyint = 4,              
  @digits_for_scale7     tinyint = 7                
as              
set nocount on              
              
   print ' '              
   print '==================================================='              
   print ' DATA : pl_history'              
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
  order by real_port_num, pl_record_key, pl_owner_code, pl_asof_date, pl_type, resp_trans_id              
  drop table #plhist             

-- find expired futures            
 -- pick expired futures or summary swaps for which the details do not exist in one of the runs            
  select *         
  into #plHist_EF_sum             
  from #plhist1 a            
  where pl_owner_code in ('EF', 'ES') and a.resp_trans_id=@resp_trans_id_NEW            
  and not exists (select 1 from #plhist1 b where a.pos_num=b.pos_num             
  and a.real_port_num=b.real_port_num and  b.resp_trans_id=@resp_trans_id_OLD            
   and pl_owner_code in ('EF', 'ES'))            
            
            
insert into #plHist_EF_sum            
  select *             
  from #plhist1 a            
  where pl_owner_code in ('EF', 'ES') and a.resp_trans_id=@resp_trans_id_OLD            
  and not exists (select 1 from #plhist1 b where a.pos_num=b.pos_num             
  and a.real_port_num=b.real_port_num and b.resp_trans_id=@resp_trans_id_NEW            
 and pl_owner_code in ('EF', 'ES'))            
            
   -- remove expired futures            
     delete #plhist1 where pos_num in (select distinct pos_num from #plHist_EF_sum)    
      
  -- write changed columns        
 select               
     'DIFFCOLS' as PASS,              
     b.resp_trans_id,     
     b.real_port_num,              
     b.pl_record_key,               
     b.pl_owner_code,    
  b.pl_type,               
     convert(varchar, b.pl_asof_date, 101) as pl_asof_date,              
     case when isnull(a.pl_mkt_price, '@@@') <> isnull(b.pl_mkt_price, '@@@')               
             then 'pl_mkt_price'              
          else ' ' end +                
     case when isnull(a.pl_amt, '@@@') <> isnull(b.pl_amt, '@@@')               
             then ',pl_amt'              
          else ' ' end +                 
     case when isnull(a.currency_fx_rate, '@@@') <> isnull(b.currency_fx_rate, '@@@')               
             then ',currency_fx_rate'              
          else ' ' end +               
     case when isnull(a.pl_record_qty, '@@@') <> isnull(b.pl_record_qty, '@@@')               
             then ',pl_record_qty'              
          else ' ' end +                       
     case when isnull(a.pl_owner_sub_code, '@@@') <> isnull(b.pl_owner_sub_code, '@@@')             
             then ',pl_owner_sub_code'            
          else ' ' end +                    
     case when isnull(a.pl_record_owner_key, -1) <> isnull(b.pl_record_owner_key, -1)   
   then ',pl_record_owner_key'            
          else ' ' end +                      
     case when isnull(a.pl_primary_owner_key1, -1) <> isnull(b.pl_primary_owner_key1, -1)               
             then ',pl_primary_owner_key1'             
          else ' ' end +                        
     case when isnull(a.pl_primary_owner_key2, -1) <> isnull(b.pl_primary_owner_key2, -1)               
             then str(b.pl_primary_owner_key2)              
          else ' ' end +                          
     case when isnull(a.pl_primary_owner_key3, -1) <> isnull(b.pl_primary_owner_key3, -1)               
             then ',pl_primary_owner_key3'             
          else ' ' end +                       
     case when isnull(a.pl_primary_owner_key4, -1) <> isnull(b.pl_primary_owner_key4, -1)               
             then ',pl_primary_owner_key4'             
          else ' ' end +                       
     case when isnull(a.pl_secondary_owner_key1, -1) <> isnull(b.pl_secondary_owner_key1, -1)              
             then ',pl_secondary_owner_key1'             
          else ' ' end +              
     case when isnull(a.pl_secondary_owner_key2, -1) <> isnull(b.pl_secondary_owner_key2, -1)              
             then ',pl_secondary_owner_key2'  
          else ' ' end +                       
     case when isnull(a.pl_secondary_owner_key3, -1) <> isnull(b.pl_secondary_owner_key3, -1)              
             then ',pl_secondary_owner_key3'              
     else ' ' end +             
     case when isnull(a.pl_category_type, '@@@') <> isnull(b.pl_category_type, '@@@')               
             then ',pl_category_type'              
          else ' ' end +                   
     case when isnull(a.pl_realization_date, '01/01/1990') <> isnull(b.pl_realization_date, '01/01/1990')               
             then ',pl_realization_date'  
          else ' ' end +                       
     case when isnull(a.pl_cost_status_code, '@@@') <> isnull(b.pl_cost_status_code, '@@@')               
             then ',pl_cost_status_code'             
          else ' ' end +                        
     case when isnull(a.pl_cost_prin_addl_ind, '@@@') <> isnull(b.pl_cost_prin_addl_ind, '@@@')               
             then ',pl_cost_prin_addl_ind'             
          else ' ' end +                     
     case when isnull(a.pl_record_qty_uom_code, '@@@') <> isnull(b.pl_record_qty_uom_code, '@@@')               
             then ',pl_record_qty_uom_code'               
          else ' ' end +                        
     case when isnull(a.pos_num, -1) <> isnull(b.pos_num, -1)               
   then ',pos_num'             
          else ' ' end as diffColList              
    into #diffColList       
  from (select *              
        from #plhist1              
        where resp_trans_id = @resp_trans_id_NEW) a,              
       (select  *              
        from #plhist1              
        where resp_trans_id = @resp_trans_id_OLD) b      
  where a.pl_asof_date = b.pl_asof_date and              
        a.pl_record_key = b.pl_record_key and               
        a.pl_owner_code = b.pl_owner_code and              
        a.pl_type = b.pl_type and              
        a.real_port_num = b.real_port_num            
          
  --- finish write changed columns.                  
            
  select               
     'NEW' as PASS,              
     plh.resp_trans_id,    
  diffColList,       
     plh.real_port_num,               
     plh.pl_record_key,               
     plh.pl_owner_code,               
     convert(varchar, plh.pl_asof_date, 101) as pl_asof_date,              
      pl_mkt_price,              
      pl_amt,              
      currency_fx_rate,              
      pl_record_qty,              
     plh.pl_type,                
     pl_owner_sub_code,               
     str(pl_record_owner_key) as pl_record_owner_key,               
     str(pl_primary_owner_key1) as pl_primary_owner_key1,               
     str(pl_primary_owner_key2) as pl_primary_owner_key2,               
     str(pl_primary_owner_key3) as pl_primary_owner_key3,               
     str(pl_primary_owner_key4) as pl_primary_owner_key4,               
     str(plh.pl_secondary_owner_key1) as pl_secondary_owner_key1,               
     str(pl_secondary_owner_key2) as pl_secondary_owner_key2,               
     str(pl_secondary_owner_key3) as pl_secondary_owner_key3,               
     pl_category_type,               
     convert(varchar, pl_realization_date, 101) as pl_realization_date,               
     pl_cost_status_code,               
     pl_cost_prin_addl_ind,               
     pl_record_qty_uom_code,               
     str(pos_num) as pos_num,              
     trans_id1              
   from #plhist1 plh left outer join #diffColList difc        
    on plh.pl_asof_date = difc.pl_asof_date and plh.pl_record_key = difc.pl_record_key     
 and plh.pl_owner_code = difc.pl_owner_code and plh.pl_type = difc.pl_type     
 and plh.real_port_num = difc.real_port_num    
   where plh.resp_trans_id = @resp_trans_id_NEW             
   union                    
  select               
     'OLD' as PASS,              
     b.resp_trans_id,     
     diffColList,       
     b.real_port_num,              
     b.pl_record_key,               
     b.pl_owner_code,               
     convert(varchar, b.pl_asof_date, 101) as pl_asof_date,              
     case when isnull(a.pl_mkt_price, '@@@') <> isnull(b.pl_mkt_price, '@@@')               
             then b.pl_mkt_price              
          else ' '              
     end as pl_mkt_price,               
     case when isnull(a.pl_amt, '@@@') <> isnull(b.pl_amt, '@@@')               
             then b.pl_amt              
          else ' '              
     end as pl_amt,               
     case when isnull(a.currency_fx_rate, '@@@') <> isnull(b.currency_fx_rate, '@@@')               
             then b.currency_fx_rate              
          else ' '              
     end as currency_fx_rate,               
     case when isnull(a.pl_record_qty, '@@@') <> isnull(b.pl_record_qty, '@@@')               
             then b.pl_record_qty              
          else ' '              
     end as pl_record_qty,               
     b.pl_type,              
     case when isnull(a.pl_owner_sub_code, '@@@') <> isnull(b.pl_owner_sub_code, '@@@')             
             then b.pl_owner_sub_code             
          else ' '            
     end as pl_owner_sub_code,             
     case when isnull(a.pl_record_owner_key, -1) <> isnull(b.pl_record_owner_key, -1) then               
             str(b.pl_record_owner_key)              
          else ' '              
     end as pl_record_owner_key,               
     case when isnull(a.pl_primary_owner_key1, -1) <> isnull(b.pl_primary_owner_key1, -1)               
             then str(b.pl_primary_owner_key1)              
          else ' '              
     end as pl_primary_owner_key1,               
     case when isnull(a.pl_primary_owner_key2, -1) <> isnull(b.pl_primary_owner_key2, -1)               
             then str(b.pl_primary_owner_key2)              
          else ' '              
     end as pl_primary_owner_key2,               
     case when isnull(a.pl_primary_owner_key3, -1) <> isnull(b.pl_primary_owner_key3, -1)               
             then str(b.pl_primary_owner_key3)              
          else ' '              
     end as pl_primary_owner_key3,               
     case when isnull(a.pl_primary_owner_key4, -1) <> isnull(b.pl_primary_owner_key4, -1)               
             then str(b.pl_primary_owner_key4)              
          else ' '              
     end as pl_primary_owner_key4,               
     case when isnull(a.pl_secondary_owner_key1, -1) <> isnull(b.pl_secondary_owner_key1, -1)              
             then str(b.pl_secondary_owner_key1)              
          else ' '              
     end as pl_secondary_owner_key1,               
     case when isnull(a.pl_secondary_owner_key2, -1) <> isnull(b.pl_secondary_owner_key2, -1)              
             then str(b.pl_secondary_owner_key2)               
          else ' '              
     end as pl_secondary_owner_key2,               
     case when isnull(a.pl_secondary_owner_key3, -1) <> isnull(b.pl_secondary_owner_key3, -1)              
             then str(b.pl_secondary_owner_key3)              
     else ' '              
     end as pl_secondary_owner_key3,               
     case when isnull(a.pl_category_type, '@@@') <> isnull(b.pl_category_type, '@@@')               
             then b.pl_category_type              
          else ' '              
     end as pl_category_type,               
     case when isnull(a.pl_realization_date, '01/01/1990') <> isnull(b.pl_realization_date, '01/01/1990')               
             then convert(varchar, b.pl_realization_date, 101)              
          else ' '              
     end as pl_realization_date,               
     case when isnull(a.pl_cost_status_code, '@@@') <> isnull(b.pl_cost_status_code, '@@@')               
             then b.pl_cost_status_code              
          else ' '              
     end as pl_cost_status_code,               
     case when isnull(a.pl_cost_prin_addl_ind, '@@@') <> isnull(b.pl_cost_prin_addl_ind, '@@@')               
             then b.pl_cost_prin_addl_ind              
          else ' '              
     end as pl_cost_prin_addl_ind,               
     case when isnull(a.pl_record_qty_uom_code, '@@@') <> isnull(b.pl_record_qty_uom_code, '@@@')               
             then b.pl_record_qty_uom_code               
          else ' '              
     end as pl_record_qty_uom_code,               
     case when isnull(a.pos_num, -1) <> isnull(b.pos_num, -1)               
             then str(b.pos_num)              
          else ' '              
  end as pos_num,               
     b.trans_id1               
  from (select *              
        from #plhist1              
        where resp_trans_id = @resp_trans_id_NEW) a,              
       (select  *              
        from #plhist1              
        where resp_trans_id = @resp_trans_id_OLD) b left outer join #diffColList difc        
 on b.pl_asof_date = difc.pl_asof_date and b.pl_record_key = difc.pl_record_key and               
    b.pl_owner_code = difc.pl_owner_code and b.pl_type = difc.pl_type and              
    b.real_port_num = difc.real_port_num    
  where a.pl_asof_date = b.pl_asof_date and              
        a.pl_record_key = b.pl_record_key and               
        a.pl_owner_code = b.pl_owner_code and              
        a.pl_type = b.pl_type and              
        a.real_port_num = b.real_port_num              
  order by real_port_num, pl_record_key, pl_owner_code, pl_asof_date, pl_type, resp_trans_id              
              
   drop table #plhist1    
GO
GRANT EXECUTE ON  [dbo].[usp_compare_pl_history_nonExpFutSumSwap] TO [next_usr]
GO
