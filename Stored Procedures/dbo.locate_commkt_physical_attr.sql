SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[locate_commkt_physical_attr]
(
   @by_type0   varchar(40),
   @by_ref0    varchar(255)
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
			   /* :LOCATE: CommktPhysicalAttr  */
		     cpa.commkt_key,               /* :IS_KEY: 1 */
		     cpa.commkt_phy_attr_status,
		     cpa.commkt_dflt_qty,          /* :IS_QUANTITY_AMOUNT: commktDfltQty */
		     cpa.commkt_qty_uom_code,      /* :IS_QUANTITY_UOM: commktDfltQty */
		     cpa.commkt_price_uom_code,
		     cpa.commkt_curr_code,
		     cpa.commkt_price_fmt,
		     cpa.commkt_min_price_var,
		     cpa.commkt_max_price_var,
		     cpa.commkt_spot_prd,
		     cpa.commkt_price_freq,
		     cpa.commkt_price_freq_as_of,
		     cpa.commkt_price_series,
		     cpa.commkt_formula_type,
		     cpa.commkt_interpol_type,
		     cpa.commkt_num_mth_out,
		     cpa.commkt_support_price_type,
		     cpa.commkt_same_as_mkt_code,
		     cpa.commkt_same_as_cmdty_code,
		     cpa.commkt_forex_mkt_code,
		     cpa.commkt_forex_cmdty_code,
		     cpa.commkt_price_div_mul_ind,
		     cpa.user_init,
		     cpa.commkt_point_conv_num,
		     cpa.sec_price_source_code,
		     cpa.sec_alias_source_code,
		     cpa.trans_id,
			 cpa.lot_size_periodicity,
	         cpa.calendar_day_lot_size,
			 cpa.calendar_code,
			 cpa.non_calendar_day_lot_size,
			 cpa.dst_zone
      from dbo.commkt_physical_attr cpa with (nolock)
		  where cpa.commkt_key = @ref_num0
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
GRANT EXECUTE ON  [dbo].[locate_commkt_physical_attr] TO [next_usr]
GO
