SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_get_tiddtls_for_poshist]
(
   @asof_date    datetime,
   @pos_num      int
)
as
set nocount on

   create table #tid
   (
      dist_num      int not null,
      trans_id      bigint not null
   )
   
   create clustered index xx80101_tid_idx on #tid (dist_num, trans_id)
   
   insert into #tid
   select dist_num, trans_id 
   from dbo.tid_mark_to_market 
   where mtm_pl_asof_date = @asof_date and
	       pos_num = @pos_num

   select    
	    accum_num, 
 	    alloc_qty,
	    bus_date,
	    commkt_key,
	    delivered_qty,
	    discount_qty,
	    tid.dist_num,
	    dist_qty,
	    dist_type,
	    estimate_qty,
	    is_equiv_ind,
	    item_num,
	    order_num,
	    p_s_ind,
	    pos_num,
	    price_curr_code_conv_to,
	    price_curr_conv_rate,
	    price_uom_code_conv_to,
	    price_uom_conv_rate,
	    priced_qty,
	    qpp_num,
	    qty_uom_code,                   
	    qty_uom_code_conv_to,           
	    qty_uom_conv_rate,              
	    real_port_num,                  
	    real_synth_ind,                 
	    resp_trans_id=NULL,                  
	    sec_conversion_factor,
	    sec_qty_uom_code,
	    spread_pos_group_num,           
	    trade_num,                      
	    trading_prd,
	    tid.trans_id,                       
	    what_if_ind   
   from dbo.aud_trade_item_dist tid
          join #tid 
             on tid.dist_num = #tid.dist_num and 
	              tid.trans_id <= #tid.trans_id and 
	              tid.resp_trans_id > #tid.trans_id
   union
   select 
	    accum_num, 
	    alloc_qty,
	    bus_date,
  	  commkt_key,
	    delivered_qty,
	    discount_qty,
	    tid.dist_num,
	    dist_qty,
	    dist_type,
	    estimate_qty,
	    is_equiv_ind,
	    item_num,
	    order_num,
	    p_s_ind,
	    pos_num,
	    price_curr_code_conv_to,
	    price_curr_conv_rate,
	    price_uom_code_conv_to,
	    price_uom_conv_rate,
	    priced_qty,
	    qpp_num,
	    qty_uom_code,                   
	    qty_uom_code_conv_to,           
	    qty_uom_conv_rate,              
	    real_port_num,                  
	    real_synth_ind,                 
	    resp_trans_id=NULL,                  
	    sec_conversion_factor,
	    sec_qty_uom_code,
	    spread_pos_group_num,           
	    trade_num,                      
	    trading_prd,
	    tid.trans_id,                       
	    what_if_ind   
   from dbo.trade_item_dist tid
           join #tid 
              on tid.dist_num = #tid.dist_num and 
                 tid.trans_id <= #tid.trans_id 
   order by tid.dist_num

   drop table #tid
return
GO
GRANT EXECUTE ON  [dbo].[usp_get_tiddtls_for_poshist] TO [next_usr]
GO
