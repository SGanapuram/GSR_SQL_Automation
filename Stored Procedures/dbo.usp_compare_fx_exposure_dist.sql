SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_compare_fx_exposure_dist] 
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
   print ' DATA : fx_exposure_dist'    
   print '==================================================='    
   print ' '    
    
   select resp_trans_id,   
          oid,  
          fx_owner_code,  
          fx_exp_num,  
          fx_owner_key1,  
          fx_owner_key2,  
          fx_owner_key3,  
          fx_owner_key4,  
          fx_owner_key5,  
          fx_owner_key6,  
          trade_num,  
          order_num,  
          item_num,  
          str(fx_qty, 38, @digits_for_scale4) as fx_qty,  
          str(fx_price, 38, @digits_for_scale7) as fx_price,  
          str(fx_amt, 38, @digits_for_scale7) as fx_amt,  
          fx_qty_uom_code,  
          fx_price_curr_code,  
          fx_price_uom_code,  
          fx_drop_date,  
          str(fx_priced_amt, 38, @digits_for_scale7) as fx_priced_amt,  
          fx_real_port_num,  
          fx_custom_column1,  
          fx_custom_column2,  
          fx_custom_column3,  
          fx_custom_column4,  
          trans_id  
      into #fxexpdist  
   from dbo.aud_fx_exposure_dist  
   where resp_trans_id in (@resp_trans_id_NEW, @resp_trans_id_OLD)     
       
   select min(resp_trans_id) as resp_trans_id,     
          oid,  
          fx_owner_code,  
          fx_exp_num,  
          fx_owner_key1,  
          fx_owner_key2,  
          fx_owner_key3,  
          fx_owner_key4,  
          fx_owner_key5,  
          fx_owner_key6,  
          trade_num,  
          order_num,  
          item_num,  
          fx_qty,  
          fx_price,  
          fx_amt,  
          fx_qty_uom_code,  
          fx_price_curr_code,  
          fx_price_uom_code,  
          fx_drop_date,  
          fx_priced_amt,  
          fx_real_port_num,  
          fx_custom_column1,  
          fx_custom_column2,  
          fx_custom_column3,  
          fx_custom_column4,  
          min(trans_id) as trans_id1    
      into #fxexpdist1    
   from #fxexpdist    
   group by oid,fx_owner_code,fx_exp_num,fx_owner_key1,fx_owner_key2,
            fx_owner_key3,fx_owner_key4,fx_owner_key5,fx_owner_key6,  
            trade_num,order_num,item_num,fx_qty,fx_price,fx_amt,
            fx_qty_uom_code,fx_price_curr_code,fx_price_uom_code,
            fx_drop_date,fx_priced_amt,fx_real_port_num,fx_custom_column1,
            fx_custom_column2,fx_custom_column3,fx_custom_column4  
   having count(*) = 1    
   order by oid, resp_trans_id        
   drop table #fxexpdist     
    
   select     
      'NEW' as PASS,    
      resp_trans_id,     
      oid,  
      fx_owner_code,  
      str(fx_exp_num) as fx_exp_num,  
      str(fx_owner_key1) as fx_owner_key1,  
      str(fx_owner_key2) as fx_owner_key2,  
      str(fx_owner_key3) as fx_owner_key3,  
      str(fx_owner_key4) as fx_owner_key4,  
      str(fx_owner_key5) as fx_owner_key5,  
      str(fx_owner_key6) as fx_owner_key6,  
      str(trade_num) as trade_num,  
      str(order_num) as order_num,  
      str(item_num) as item_num,  
      fx_qty,  
      fx_price,  
      fx_amt,  
      fx_qty_uom_code,  
      fx_price_curr_code,  
      fx_price_uom_code,  
      convert(varchar,fx_drop_date, 101) as fx_drop_date,  
      fx_priced_amt,  
      str(fx_real_port_num) as fx_real_port_num,  
      fx_custom_column1,  
      fx_custom_column2,  
      fx_custom_column3,  
      fx_custom_column4,  
      trans_id1    
   from #fxexpdist1    
   where resp_trans_id = @resp_trans_id_NEW    
   union          
   select     
      'OLD' as PASS,    
      b.resp_trans_id,    
      b.oid,    
      case when isnull(a.fx_owner_code, '@@@') <> isnull(b.fx_owner_code, '@@@')     
              then b.fx_owner_code    
           else ' '    
      end as fx_owner_code,  
      case when isnull(a.fx_exp_num, -1) <> isnull(b.fx_exp_num, -1)     
              then str(b.fx_exp_num)  
           else ' '    
      end as fx_exp_num,  
      case when isnull(a.fx_owner_key1, -1) <> isnull(b.fx_owner_key1, -1)     
              then str(b.fx_owner_key1)  
           else ' '    
      end as fx_owner_key1,  
      case when isnull(a.fx_owner_key2, -1) <> isnull(b.fx_owner_key2, -1)     
              then str(b.fx_owner_key2)  
           else ' '    
      end as fx_owner_key2,  
      case when isnull(a.fx_owner_key3, -1) <> isnull(b.fx_owner_key3, -1)     
              then str(b.fx_owner_key3)  
           else ' '    
      end as fx_owner_key3,  
      case when isnull(a.fx_owner_key4, -1) <> isnull(b.fx_owner_key4, -1)     
              then str(b.fx_owner_key4)  
           else ' '    
      end as fx_owner_key4,  
      case when isnull(a.fx_owner_key5, -1) <> isnull(b.fx_owner_key5, -1)     
              then str(b.fx_owner_key5)  
           else ' '    
      end as fx_owner_key5,  
      case when isnull(a.fx_owner_key6, -1) <> isnull(b.fx_owner_key6, -1)     
              then str(b.fx_owner_key6)  
           else ' '    
      end as fx_owner_key6,  
      case when isnull(a.trade_num, -1) <> isnull(b.trade_num, -1)     
              then str(b.trade_num)  
           else ' '    
      end as trade_num,  
      case when isnull(a.order_num, -1) <> isnull(b.order_num, -1)     
              then str(b.order_num)  
           else ' '    
      end as order_num,  
      case when isnull(a.item_num, -1) <> isnull(b.item_num, -1)     
              then str(b.item_num)  
           else ' '    
      end as item_num,  
      case when isnull(a.fx_qty, '@@@') <> isnull(b.fx_qty, '@@@')     
              then b.fx_qty    
           else ' '    
      end as fx_qty,  
      case when isnull(a.fx_qty, '@@@') <> isnull(b.fx_qty, '@@@')     
              then b.fx_qty    
           else ' '    
      end as fx_qty,  
      case when isnull(a.fx_amt, '@@@') <> isnull(b.fx_amt, '@@@')     
              then b.fx_amt    
           else ' '    
      end as fx_amt,  
      case when isnull(a.fx_qty_uom_code, '@@@') <> isnull(b.fx_qty_uom_code, '@@@')     
              then b.fx_qty_uom_code    
           else ' '    
      end as fx_qty_uom_code,  
      case when isnull(a.fx_price_curr_code, '@@@') <> isnull(b.fx_price_curr_code, '@@@')     
              then b.fx_price_curr_code    
           else ' '    
      end as fx_price_curr_code,  
      case when isnull(a.fx_price_uom_code, '@@@') <> isnull(b.fx_price_uom_code, '@@@')     
              then b.fx_price_uom_code    
           else ' '    
      end as fx_price_uom_code,  
      case when isnull(a.fx_drop_date, '01/01/1990') <> isnull(b.fx_drop_date, '01/01/1990')     
              then convert(varchar,b.fx_drop_date, 101)      
           else ' '    
      end as fx_drop_date,  
      case when isnull(a.fx_priced_amt, '@@@') <> isnull(b.fx_priced_amt, '@@@')     
              then b.fx_priced_amt    
           else ' '    
      end as fx_priced_amt,  
      case when isnull(a.fx_real_port_num, -1) <> isnull(b.fx_real_port_num, -1)     
              then str(b.fx_real_port_num)  
           else ' '    
      end as fx_real_port_num,  
      case when isnull(a.fx_custom_column1, '@@@') <> isnull(b.fx_custom_column1, '@@@')     
              then b.fx_custom_column1    
           else ' '    
      end as fx_custom_column1,  
      case when isnull(a.fx_custom_column2, '@@@') <> isnull(b.fx_custom_column2, '@@@')     
              then b.fx_custom_column2    
           else ' '    
      end as fx_custom_column2,  
      case when isnull(a.fx_custom_column3, '@@@') <> isnull(b.fx_custom_column3, '@@@')     
              then b.fx_custom_column3    
           else ' '    
      end as fx_custom_column3,  
      case when isnull(a.fx_custom_column4, '@@@') <> isnull(b.fx_custom_column4, '@@@')     
              then b.fx_custom_column4    
           else ' '    
      end as fx_custom_column4,  
      b.trans_id1      
   from (select *    
         from #fxexpdist1    
         where resp_trans_id = @resp_trans_id_NEW) a,    
        (select  *    
         from #fxexpdist1    
         where resp_trans_id = @resp_trans_id_OLD) b     
   where a.oid = b.oid  
   order by oid, resp_trans_id         
    
   drop table #fxexpdist1  
GO
GRANT EXECUTE ON  [dbo].[usp_compare_fx_exposure_dist] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_compare_fx_exposure_dist', NULL, NULL
GO
