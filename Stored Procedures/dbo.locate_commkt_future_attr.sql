SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[locate_commkt_future_attr]
(
   @by_type0  varchar(40),
   @by_ref0   varchar(255)
)
as
begin
set nocount on
declare @rowcount int
declare @ref_num0 int

	if @by_type0 = 'commkt_key'
	begin
		 set @ref_num0 = convert(int, @by_ref0)

		 select
			  /* :LOCATE: CommktFutureAttr  */
		    cfa.commkt_key,                          /* :IS_KEY: 1 */
		    cfa.commkt_fut_attr_status,
		    cfa.commkt_lot_size,         /* :IS_QUANTITY_AMOUNT: commktLotSize */
		    cfa.commkt_lot_uom_code,     /* :IS_QUANTITY_UOM: commktLotSize, commktSpotMthQty, commktFwdMthQty, commktTotalOpenQty */
		    cfa.commkt_price_uom_code,
		    cfa.commkt_settlement_ind,
		    cfa.commkt_curr_code,
		    cfa.commkt_price_fmt,
		    cfa.commkt_trading_mth_ind,
        cfa.commkt_nearby_mask,
		    cfa.commkt_min_price_var,
		    cfa.commkt_max_price_var,
		    cfa.commkt_spot_prd,
		    cfa.commkt_price_freq,
		    cfa.commkt_price_freq_as_of,
		    cfa.commkt_price_series,
		    cfa.commkt_spot_mth_qty,    /* :IS_QUANTITY_AMOUNT: commktSpotMthQty */
		    cfa.commkt_fwd_mth_qty,     /* :IS_QUANTITY_AMOUNT: commktFwdMthQty */
		    cfa.commkt_total_open_qty,  /* :IS_QUANTITY_AMOUNT: commktTotalOpenQty */
		    cfa.commkt_formula_type,
		    cfa.commkt_interpol_type,
		    cfa.commkt_num_mth_out,
		    cfa.commkt_support_price_type,
		    cfa.commkt_same_as_mkt_code,
		    cfa.commkt_same_as_cmdty_code,
		    cfa.commkt_forex_mkt_code,
		    cfa.commkt_forex_cmdty_code,
		    cfa.commkt_price_div_mul_ind,
		    cfa.user_init,
		    cfa.commkt_limit_move_ind,
		    cfa.commkt_point_conv_num,
		    cfa.sec_price_source_code,
		    cfa.sec_alias_source_code,
		    cfa.trans_id 
		 from dbo.commkt_future_attr cfa with (nolock)
		 where cfa.commkt_key = @ref_num0
	end
	else
		 return 4

	set @rowcount = @@rowcount
	if @rowcount = 1
		 return 0
	else if @rowcount = 0
		 return 1
	else
		 return 2
end
GO
GRANT EXECUTE ON  [dbo].[locate_commkt_future_attr] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'locate_commkt_future_attr', NULL, NULL
GO
