SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[add_allocation]
(
	 @alloc_num                           int,
	 @alloc_type_code                     char(1),
	 @mot_code                            char(8),
	 @sch_init                            char(3),
	 @alloc_status                        char(1),
	 @cmnt_num                            int,
	 @ppl_comp_num                        int,
	 @ppl_comp_cont_num                   int,
	 @sch_prd                             char(8),
	 @ppl_batch_num                       varchar(15),
	 @ppl_pump_date                       datetime,
	 @compr_trade_num                     int,
	 @initiator_acct_num                  int,
	 @deemed_bl_date                      datetime,
	 @alloc_pay_date                      datetime,
	 @alloc_base_price                    float,
	 @alloc_disc_rate                     float,
	 @transportation                      varchar(40),
	 @netout_gross_qty                    float,
	 @netout_net_qty                      float,
	 @netout_qty_uom_code                 char(4),
	 @ppl_batch_given_date                datetime,
	 @ppl_batch_received_date             datetime,
	 @ppl_origin_given_date               datetime,
	 @ppl_origin_received_date            datetime,
	 @ppl_timing_cycle_num                smallint,
	 @ppl_split_cycle_opt                 varchar(8),
	 @alloc_short_cmnt                    varchar(40),
	 @creation_type                       char(1),
	 @netout_parcel_num                   varchar(15),
	 @alloc_cmdty_code                    char(8),
	 @bookout_pay_date                    datetime,
	 @bookout_rec_date                    datetime,
	 @alloc_match_ind                     char(1),
	 @alloc_loc_code                      char(8),
	 @alloc_begin_date					          datetime,
	 @alloc_end_date						          datetime,
	 @alloc_load_loc_code        		      char(8),
	 @book_net_price_ind					        char(1),
	 @creation_date                       datetime,
	 @multiple_cmdty_ind                  char(1),
	 @price_precision                     smallint,
	 @pay_for_del                         char(1),
	 @pay_for_weight                      char(1),
	 @max_alloc_item_num                  smallint,
	 @voyage_code                         char(20),
	 @release_doc_num                     int,
	 @bookout_brkr_num                    int,
	 @base_port_num                       int,
	 @transfer_price                      numeric(20, 8),
	 @transfer_price_uom_code             char(4),
	 @transfer_price_curr_code            char(8),
	 @trans_id                            int
)
as
begin
declare @rowcount int

	insert into dbo.allocation
	(
		alloc_num,
		alloc_type_code,
		mot_code,
		sch_init,
		alloc_status,
		cmnt_num,
		ppl_comp_num,
		ppl_comp_cont_num,
		sch_prd,
		ppl_batch_num,
		ppl_pump_date,
		compr_trade_num,
		initiator_acct_num,
		deemed_bl_date,
		alloc_pay_date,
		alloc_base_price,
		alloc_disc_rate,
		transportation,
		netout_gross_qty,
		netout_net_qty,
		netout_qty_uom_code,
		ppl_batch_given_date,
		ppl_batch_received_date,
		ppl_origin_given_date,
		ppl_origin_received_date,
		ppl_timing_cycle_num,
		ppl_split_cycle_opt,
		alloc_short_cmnt,
		creation_type,
		netout_parcel_num,
		alloc_cmdty_code,
		bookout_pay_date,
		bookout_rec_date,
		alloc_match_ind,
		alloc_loc_code,
		alloc_begin_date,
		alloc_end_date,
		alloc_load_loc_code,
		book_net_price_ind,
	  creation_date,
	  multiple_cmdty_ind,
	  price_precision,
	  pay_for_del,
	  pay_for_weight,
	  max_alloc_item_num,
	  voyage_code,
	  release_doc_num,
	  bookout_brkr_num,
	  base_port_num,
	  transfer_price,
	  transfer_price_uom_code,
	  transfer_price_curr_code,
		trans_id                            
	)
	values
	(
		@alloc_num,
		@alloc_type_code,
		@mot_code,
		@sch_init,
		@alloc_status,
		@cmnt_num,
		@ppl_comp_num,
		@ppl_comp_cont_num,
		@sch_prd,
		@ppl_batch_num,
		@ppl_pump_date,
		@compr_trade_num,
		@initiator_acct_num,
		@deemed_bl_date,
		@alloc_pay_date,
		@alloc_base_price,
		@alloc_disc_rate,
		@transportation,
		@netout_gross_qty,
		@netout_net_qty,
		@netout_qty_uom_code,
		@ppl_batch_given_date,
		@ppl_batch_received_date,
		@ppl_origin_given_date,
		@ppl_origin_received_date,
		@ppl_timing_cycle_num,
		@ppl_split_cycle_opt,
		@alloc_short_cmnt,
		@creation_type,
		@netout_parcel_num,
		@alloc_cmdty_code,
		@bookout_pay_date,
		@bookout_rec_date,
		@alloc_match_ind,
		@alloc_loc_code,
		@alloc_begin_date,
		@alloc_end_date,
		@alloc_load_loc_code,
		@book_net_price_ind,
	  @creation_date,
	  @multiple_cmdty_ind,
	  @price_precision,
	  @pay_for_del,
	  @pay_for_weight,
	  @max_alloc_item_num,
	  @voyage_code,
	  @release_doc_num,
	  @bookout_brkr_num,
	  @base_port_num,
	  @transfer_price,
	  @transfer_price_uom_code,
	  @transfer_price_curr_code,
		@trans_id                            
	)
	set @rowcount = @@rowcount

	if (@rowcount = 1)
		 return 0
	else
		 return 1
end
GO
GRANT EXECUTE ON  [dbo].[add_allocation] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'add_allocation', NULL, NULL
GO