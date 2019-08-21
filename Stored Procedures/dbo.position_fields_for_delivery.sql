SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[position_fields_for_delivery]
(
	 @pos_type                       char(1) output,
	 @commkt_key                     int output,
	 @formula_num                    int output,
	 @formula_name                   varchar(40) output,
	 @opt_source_code                char(8) output,
	 @dist_type                      char(1),
	 @order_num	                     smallint,
	 @item_num                       smallint,
	 @accum_num                      smallint,
	 @qpp_num                        smallint,
	 @is_equiv_ind                   char(1),
	 @real_synth_ind                 char(1),
	 @order_type_code                char(8),
	 @trading_prd                    char(8),
	 @mkt_code                       char(8),
	 @cmdty_code                     char(8),
	 @item_type                      char(1),
	 @option_type                    char(1),
	 @settlement_type                char(1),
	 @strike_price                   float,
	 @strike_price_curr_code         char(8),
	 @strike_price_uom_code          char(8),
	 @put_call_ind                   char(1),
	 @opt_exp_date                   datetime
)
as
begin
set nocount on
declare @formula_body_num	tinyint,
	    	@formula_comp_num	smallint

	 /*
	  *	Initialize all output parameters
	  */
	 select	@commkt_key = NULL,
          @formula_name = NULL,
          @opt_source_code = NULL

	 /*
	  *	Cases are indexed by the tuple
	  *	(order type,item type,is_equiv_ind,accum,qpp)
	 */

	 /*
	  * currently merges Fix, Simple Formula, and Complex Formula
	 */
	 if (@order_type_code = 'PHYSICAL'
       or @order_type_code = 'PARTIAL'
		   or @order_type_code = 'PHYSBYSL'
	     or @order_type_code = 'RACKBYSL'
	     or @order_type_code = 'RACKEXCH'
	     or @order_type_code = 'RACKPHYS'
	     or @order_type_code = 'PHYSEXCH'
	     or (@order_type_code = 'EFPEXCH' and 
	         ((@item_type = 'C') or 
	          (@item_type = 'W')
	         )
	        ))
	 begin
	    if (@dist_type = 'D')
	    begin
		     if (@real_synth_ind = 'R')
            set @pos_type = 'P'
         else	/* synthetic */
            set @pos_type = 'S'
            
		     select @commkt_key = commkt_key 
		     from dbo.commodity_market
         where mkt_code = @mkt_code and
               cmdty_code = @cmdty_code
      end
	    else if (@dist_type = 'U')
	    begin
         select @pos_type = 'Q'
         if (@accum_num IS NOT NULL	and	/* simple formula trade */
		         @qpp_num IS NOT NULL)
            select @commkt_key = commkt_key 
            from dbo.commodity_market
            where mkt_code = @mkt_code and
			            cmdty_code = @cmdty_code
		     else				/* complex formula trade */
			      select @formula_name = formula_name
			      from dbo.formula
			      where formula_num = @formula_num
	       end
	       else /* @dist_type = 'C' */
		        set @pos_type = 'C'
	    end

	    if (@order_type_code = 'FUTURE'
	       or (@order_type_code = 'EFPEXCH' and 
	           @item_type = 'F'))
	    begin
	       set @pos_type = 'F'
	       select @commkt_key = commkt_key 
	       from dbo.commodity_market
	    	 where mkt_code = @mkt_code and
		           cmdty_code = @cmdty_code
	    end
	    else if (@order_type_code = 'EXCHGOPT')
	    begin
	       if (@dist_type = 'D')
	         	if (@is_equiv_ind = 'Y')
               set @pos_type = 'F'
		        else
		           set @pos_type = 'X'
	       select @commkt_key = commkt_key 
	       from dbo.commodity_market
	    	 where mkt_code = @mkt_code and
		           cmdty_code = @cmdty_code
	    end
	    else if (@order_type_code = 'EFPEXCH')
	    begin
	       if (@item_type = 'W' or @item_type = 'C')
	       begin
		        if (@dist_type = 'D')
		           set @pos_type = 'P'
		        else if (@dist_type = 'C')
		           set @pos_type = 'C'
		        else /* @dist_type = 'U' */
		           set @pos_type = 'Q'
	       end
	       else /* @item_type = 'X' */
		        set @pos_type = 'F'

	       select @commkt_key = commkt_key 
	       from dbo.commodity_market
		     where mkt_code = @mkt_code and
			         cmdty_code = @cmdty_code
	    end
	    else if (@order_type_code = 'OTCAPO' or @order_type_code = 'OTCCASH')
	    begin
	       if (@is_equiv_ind = 'N')	/* distribution to option position */
	       begin
		        set @pos_type = 'O'

		        /* special assignments if a single underlying */
		        select @formula_body_num = formula_body_num
		        from dbo.formula_body
		        where formula_num = @formula_num and
		              formula_body_type = 'Q'
		        if (@@rowcount = 1)
		        begin				/* one underlying */
		           select @commkt_key = commkt_key 
		           from dbo.commodity_market
		           where mkt_code = @mkt_code and
			               cmdty_code = @cmdty_code
			               
		           select @opt_source_code = price_source_code
		           from dbo.formula_component
		           where formula_num = @formula_num and
			               formula_body_num = @formula_body_num and
		                 formula_comp_type = 'G'
		           select @formula_num = NULL,
			                @formula_name = NULL
		        end
		        else				/* underlying spread */
		           select @formula_name = formula_name
		           from dbo.formula
		           where formula_num = @formula_num
	       end
	       else			/* distribution to quote position */
	       begin
		        select @pos_type = 'F',
		               @formula_num = NULL
	    	    select @commkt_key = commkt_key 
	    	    from dbo.commodity_market
	    	    where mkt_code = @mkt_code  and
		              cmdty_code = @cmdty_code
	       end
	    end
	    else if (@order_type_code = 'OTCPHYS')
	    begin
	       set @pos_type = 'O'
	    end
	    else if (@order_type_code = 'SWAP' or @order_type_code = 'SWAPFLT')
	    begin
	       if (@dist_type = 'D')
		        set @pos_type = 'W'
	       else if (@dist_type = 'U')
	       begin
		        set @pos_type = 'Q'
	    	    select @commkt_key = commkt_key 
	    	    from dbo.commodity_market
	    	    where mkt_code = @mkt_code and
		              cmdty_code = @cmdty_code
	       end
	    end

	return 0
end
GO
GRANT EXECUTE ON  [dbo].[position_fields_for_delivery] TO [next_usr]
GO
