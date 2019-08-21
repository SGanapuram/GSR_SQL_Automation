SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[delivery_position_for_item]
(
	 @order_num_ref			      varchar(32),
	 @item_num_ref			      varchar(32),
	 @accum_num_ref			      varchar(32),
	 @qpp_num_ref			        varchar(32),
	 @is_equiv_ind			      char(1),
 	 @real_synth_ind          char(1),
	 @what_if_ind	            char(1),
	 @real_port_num_ref	      varchar(32),
	 @dist_type               char(1),
	 @order_type_code         char(8),
	 @trading_prd	            char(8),
	 @mkt_code			          char(8),
	 @cmdty_code			        char(8),
	 @item_type			          char(1),
	 @formula_num_ref		      varchar(32),
	 @opt_periodicity		      char(8),
	 @opt_start_date			    datetime,
	 @option_type			        char(1),
	 @settlement_type		      char(1),
	 @strike_price_ref		    varchar(32),
	 @strike_price_curr_code  char(8),
	 @strike_price_uom_code		char(8),
	 @put_call_ind            char(1),
	 @opt_exp_date            datetime
)
as
begin
set nocount on
declare @order_num		          smallint
declare @item_num		            smallint
declare @accum_num		          smallint
declare @qpp_num		            smallint
declare @real_port_num		      int
declare @formula_num		        int
declare @strike_price		        float
declare @rowcount		            int
declare @pos_type		            char(1)
declare @commkt_key		          int
declare @formula_name		        varchar(40)
declare @opt_price_source_code	char(8)

	 /* dereference parameters */
	 select @order_num = convert(smallint,@order_num_ref),
          @item_num = convert(smallint,@item_num_ref),
          @accum_num = convert(smallint,@accum_num_ref),
          @qpp_num = convert(smallint,@qpp_num_ref),
          @formula_num = convert(int,@formula_num_ref),
          @real_port_num = convert(int,@real_port_num_ref),
          @strike_price = convert(float,@strike_price_ref)

	 /*
	  *	Compute position type and fields
	 */
	 exec dbo.position_fields_for_delivery
	         	   @pos_type output,
		           @commkt_key output,
		           @formula_num	output,
		           @formula_name output,
		           @opt_price_source_code output,
	 	           @dist_type, 
		           @order_num,
		           @item_num,
		           @accum_num,
		           @qpp_num,
 		           @is_equiv_ind,
 		           @real_synth_ind,
		           @order_type_code,
		           @trading_prd,
		           @mkt_code,
		           @cmdty_code,
		           @item_type,
		           @option_type,
		           @settlement_type,
		           @strike_price,
		           @strike_price_curr_code,
		           @strike_price_uom_code,
		           @put_call_ind,
		           @opt_exp_date

	 /*
	  *	Determine whether position is in database
	 */
	 select mkt_code, qty_uom_code, price_uom_code, price_curr_code
	 from position
	 where real_port_num = @real_port_num
		     and pos_type = @pos_type
		     and is_equiv_ind = @is_equiv_ind
		     and commkt_key = @commkt_key
		     and trading_prd = @trading_prd
		     and mkt_code = @mkt_code
		     and cmdty_code = @cmdty_code
		     and formula_name = @formula_name
		     and formula_num = @formula_num
		     and what_if_ind = @what_if_ind
		     and option_type = @option_type
		     and settlement_type = @settlement_type
		     and strike_price = @strike_price
		     and strike_price_curr_code = @strike_price_curr_code
		     and strike_price_uom_code = @strike_price_uom_code
		     and put_call_ind = @put_call_ind
		     and opt_start_date = @opt_start_date
         and opt_exp_date = @opt_exp_date
         and opt_periodicity = @opt_periodicity
         and opt_price_source_code = @opt_price_source_code
	 set @rowcount = @@rowcount
	 if (@rowcount = 1)
	    return 0
	 else if (@rowcount = 0)
	    return 1
	 else
	    return @rowcount
end
GO
GRANT EXECUTE ON  [dbo].[delivery_position_for_item] TO [next_usr]
GO
