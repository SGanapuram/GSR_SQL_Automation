SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[locate_allocation]
(
   @by_type0    varchar(40),
   @by_ref0     varchar(255)
)
as
begin
set nocount on
declare @rowcount int
declare @ref_num0 int

	 if @by_type0 = 'alloc_num'
	 begin
		  set @ref_num0 = convert(int, @by_ref0)
		  
		  select
			   /* :LOCATE: Allocation  */
			   a.alloc_num,                           /* :IS_KEY: 1 */
			   a.alloc_type_code,
         a.mot_code,
         a.sch_init,
         a.alloc_status,
         a.cmnt_num,
         a.ppl_comp_num,
         a.ppl_comp_cont_num,
         a.sch_prd,
         a.ppl_batch_num,
         a.ppl_pump_date,
         a.compr_trade_num,
         a.initiator_acct_num,
         a.deemed_bl_date,
         a.alloc_pay_date,
         a.alloc_base_price,
         a.alloc_disc_rate,
         a.transportation,
         a.netout_gross_qty,
         a.netout_net_qty,
         a.netout_qty_uom_code,
         a.ppl_batch_given_date,
         a.ppl_batch_received_date,
         a.ppl_origin_given_date,
         a.ppl_origin_received_date,
         a.ppl_timing_cycle_num,
         a.ppl_split_cycle_opt,
         a.alloc_short_cmnt,
         a.creation_type,
         a.netout_parcel_num,
         a.alloc_cmdty_code,
         a.bookout_pay_date,
         a.bookout_rec_date,
         a.alloc_match_ind,
         a.alloc_loc_code,
         a.alloc_begin_date,
         a.alloc_end_date,
         a.alloc_load_loc_code,
         a.book_net_price_ind,
         a.trans_id 
      from dbo.allocation a
      where a.alloc_num = @ref_num0
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
GRANT EXECUTE ON  [dbo].[locate_allocation] TO [next_usr]
GO
