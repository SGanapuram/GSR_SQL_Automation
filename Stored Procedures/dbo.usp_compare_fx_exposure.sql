SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
  
CREATE procedure [dbo].[usp_compare_fx_exposure]  
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
   print ' DATA : fx_exposure'    
   print '==================================================='    
   print ' '    
    
   select 
      resp_trans_id,   
      oid,  
      fx_exp_curr_oid,  
      fx_trading_prd,  
      fx_exposure_type,  
      real_port_num,  
      str(open_rate_amt, 38, @digits_for_scale7) as open_rate_amt,  
      str(fixed_rate_amt, 38, @digits_for_scale7) as fixed_rate_amt,  
      str(linked_rate_amt, 38, @digits_for_scale7) as linked_rate_amt,  
      fx_exp_sub_type,  
      status,  
      custom_column1,  
      custom_column2,  
      custom_column3,  
      custom_column4,  
      trans_id  
     into #fxexp  
   from dbo.aud_fx_exposure   
   where resp_trans_id in (@resp_trans_id_NEW, @resp_trans_id_OLD)     
       
   select     
      min(resp_trans_id) as resp_trans_id,     
      oid,  
      fx_exp_curr_oid,  
      fx_trading_prd,  
      fx_exposure_type,  
      real_port_num,  
      open_rate_amt,  
      fixed_rate_amt,  
      linked_rate_amt,  
      fx_exp_sub_type,  
      status,  
      custom_column1,  
      custom_column2,  
      custom_column3,  
      custom_column4,  
      min(trans_id) as trans_id1    
       into #fxexp1    
   from #fxexp    
   group by oid, 
            fx_exp_curr_oid,
            fx_trading_prd,
            fx_exposure_type,
            real_port_num,
            open_rate_amt,
            fixed_rate_amt,  
            linked_rate_amt,
            fx_exp_sub_type,
            status,
            custom_column1,
            custom_column2,
            custom_column3,
            custom_column4  
   having count(*) = 1    
   order by oid, resp_trans_id        
   drop table #fxexp     
    
   select     
      'NEW' as PASS,    
      resp_trans_id,     
      oid,  
      str(fx_exp_curr_oid) as fx_exp_curr_oid,  
      fx_trading_prd,  
      fx_exposure_type,  
      str(real_port_num) as real_port_num,  
      open_rate_amt,  
      fixed_rate_amt,  
      linked_rate_amt,  
      fx_exp_sub_type,  
      status,  
      custom_column1,  
      custom_column2,  
      custom_column3,  
      custom_column4,  
      trans_id1    
   from #fxexp1    
   where resp_trans_id = @resp_trans_id_NEW    
   union          
   select     
      'OLD' as PASS,    
      b.resp_trans_id,    
      b.oid,    
      case when isnull(a.fx_exp_curr_oid, -1) <> isnull(b.fx_exp_curr_oid, -1)     
              then str(b.fx_exp_curr_oid)  
           else ' '    
      end as fx_exp_curr_oid,  
      case when isnull(a.fx_trading_prd, '@@@') <> isnull(b.fx_trading_prd, '@@@')     
              then b.fx_trading_prd    
           else ' '    
      end as fx_trading_prd,  
      case when isnull(a.fx_exposure_type, '@@@') <> isnull(b.fx_exposure_type, '@@@')     
              then b.fx_exposure_type    
           else ' '    
      end as fx_exposure_type,  
      case when isnull(a.real_port_num, -1) <> isnull(b.real_port_num, -1)     
              then str(b.real_port_num)  
           else ' '    
      end as real_port_num,  
      case when isnull(a.open_rate_amt, '@@@') <> isnull(b.open_rate_amt, '@@@')     
              then b.open_rate_amt  
           else ' '    
      end as open_rate_amt,  
      case when isnull(a.fixed_rate_amt, '@@@') <> isnull(b.fixed_rate_amt, '@@@')     
              then b.fixed_rate_amt    
           else ' '    
      end as fixed_rate_amt,  
      case when isnull(a.linked_rate_amt, '@@@') <> isnull(b.linked_rate_amt, '@@@')     
              then b.linked_rate_amt    
           else ' '    
      end as linked_rate_amt,  
      case when isnull(a.fx_exp_sub_type, '@@@') <> isnull(b.fx_exp_sub_type, '@@@')     
              then b.fx_exp_sub_type    
           else ' '    
      end as fx_exp_sub_type,  
      case when isnull(a.status, '@@@') <> isnull(b.status, '@@@')     
              then b.status    
           else ' '    
      end as status,  
      case when isnull(a.custom_column1, '@@@') <> isnull(b.custom_column1, '@@@')     
              then b.custom_column1    
           else ' '    
      end as custom_column1,  
      case when isnull(a.custom_column2, '@@@') <> isnull(b.custom_column2, '@@@')     
              then b.custom_column2    
           else ' '    
      end as custom_column2,  
      case when isnull(a.custom_column3, '@@@') <> isnull(b.custom_column3, '@@@')     
              then b.custom_column3    
           else ' '    
      end as custom_column3,  
      case when isnull(a.custom_column4, '@@@') <> isnull(b.custom_column4, '@@@')     
              then b.custom_column4    
           else ' '    
      end as custom_column4,  
      b.trans_id1      
   from (select *    
         from #fxexp1    
         where resp_trans_id = @resp_trans_id_NEW) a,    
        (select  *    
         from #fxexp1    
         where resp_trans_id = @resp_trans_id_OLD) b     
   where a.oid = b.oid  
   order by oid, resp_trans_id         
    
   drop table #fxexp1  
GO
GRANT EXECUTE ON  [dbo].[usp_compare_fx_exposure] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_compare_fx_exposure', NULL, NULL
GO
