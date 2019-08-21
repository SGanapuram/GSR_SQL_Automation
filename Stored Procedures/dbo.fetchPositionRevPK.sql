SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchPositionRevPK]
(
   @asof_trans_id      bigint,
   @pos_num            int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.position
where pos_num = @pos_num
 
if @trans_id <= @asof_trans_id
begin
   select
      /* acct_short_name, */
      asof_trans_id = @asof_trans_id,
      avg_purch_price,
      avg_sale_price,
      cmdty_code,
      commkt_key,
      desired_opt_eval_method,
      desired_otc_opt_code,
      discount_qty,
      equiv_source_ind,
      formula_body_num,
      formula_name,
      formula_num,
      is_cleared_ind,
      is_equiv_ind,
      is_hedge_ind,
      last_mtm_price,
      long_qty,
      mkt_code,
      mkt_long_qty,
      mkt_short_qty,
      opt_exp_date,
      opt_periodicity,
      opt_price_source_code,
      opt_start_date,
      option_type,
      pos_num,
      pos_status,
      pos_type,
      price_curr_code,
      price_uom_code,
      priced_qty,
      put_call_ind,
      qty_uom_code,
      real_port_num,
      resp_trans_id = null,
      rolled_qty,
      sec_discount_qty,
      sec_long_qty,
      sec_mkt_long_qty,
      sec_mkt_short_qty,
      sec_pos_uom_code,
      sec_priced_qty,
      sec_rolled_qty,
      sec_short_qty,
      settlement_type,
      short_qty,
      strike_price,
      strike_price_curr_code,
      strike_price_uom_code,
      trading_prd,
      trans_id,
      what_if_ind
   from dbo.position
   where pos_num = @pos_num
end
else
begin
   select top 1
      /* acct_short_name, */
      asof_trans_id = @asof_trans_id,
      avg_purch_price,
      avg_sale_price,
      cmdty_code,
      commkt_key,
      desired_opt_eval_method,
      desired_otc_opt_code,
      discount_qty,
      equiv_source_ind,
      formula_body_num,
      formula_name,
      formula_num,
      is_cleared_ind,
      is_equiv_ind,
      is_hedge_ind,
      last_mtm_price,
      long_qty,
      mkt_code,
      mkt_long_qty,
      mkt_short_qty,
      opt_exp_date,
      opt_periodicity,
      opt_price_source_code,
      opt_start_date,
      option_type,
      pos_num,
      pos_status,
      pos_type,
      price_curr_code,
      price_uom_code,
      priced_qty,
      put_call_ind,
      qty_uom_code,
      real_port_num,
      resp_trans_id,
      rolled_qty,
      sec_discount_qty,
      sec_long_qty,
      sec_mkt_long_qty,
      sec_mkt_short_qty,
      sec_pos_uom_code,
      sec_priced_qty,
      sec_rolled_qty,
      sec_short_qty,
      settlement_type,
      short_qty,
      strike_price,
      strike_price_curr_code,
      strike_price_uom_code,
      trading_prd,
      trans_id,
      what_if_ind
   from dbo.aud_position
   where pos_num = @pos_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchPositionRevPK] TO [next_usr]
GO
