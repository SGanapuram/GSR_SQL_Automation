SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [dbo].[udf_getUomConversion]
(   
   @fromUom       char(8),
	 @toUom         char(8),
	 @secConvFactor numeric(20, 8),
	 @secQtyUomCode char(8),
	 @cmdtyCode	    char(8)
)
returns numeric(20, 8)
as
BEGIN
DECLARE @uom_factor    numeric(20, 8),
		    @bbl_factor    numeric(20, 8),
		    @base_value    numeric(20, 8),
		    @gal_value     numeric(20, 8),
		    @MB_value      numeric(20, 8),
			  @rows_affected int,
				@uomConvRate   numeric(20, 8),
				@uomOper	     char(1)

   -- THis is a hack, will work with peter to make it generic
	 select @bbl_factor = 1.0,
	        @base_value = 1.0,
	        @gal_value = 42.0,
	        @MB_value = 1000.0,
	        @uom_factor = @base_value,
	        @bbl_factor = @base_value
	
   if @fromUom is not NULL OR @toUom is not NULL
   begin
      if @fromUom != @toUom 
			begin
         if @fromUom = 'BBL'
            select @bbl_factor = @base_value
         else if @fromUom = 'GAL' 
            select @bbl_factor = @base_value / @gal_value
         else if @fromUom = 'MB'
						select @bbl_factor = @MB_value
		     else if ((@secQtyUomCode is not NULL) AND 
		              (@secConvFactor is not NULL))
				 begin
						if @secQtyUomCode = 'GAL' 
							 select @bbl_factor = @secConvFactor / @gal_value
						else if @secQtyUomCode = 'BBL'
							 select @bbl_factor = @secConvFactor
						else if @secQtyUomCode = 'MB'
							select @bbl_factor = @secConvFactor * @MB_value
						else if @secQtyUomCode = @fromUom
			      begin
			         select @uom_factor = 1.0 / @secConvFactor
		           goto endoffun
						end
				 end
				 else if @cmdtyCode is not NULL
				 begin							
						select @uomConvRate = 1.0, 
						       @uomOper = 'M'

						select @uomConvRate = uom_conv_rate, 
						       @uomOper = uom_conv_oper 
						from dbo.uom_conversion 
					  where cmdty_code = @cmdtyCode AND 
									uom_code_conv_from = @fromUom AND
									uom_code_conv_to = @toUom
 						select @rows_affected = @@rowcount		
						if @rows_affected > 0	
						   goto calc1				
											
						select @uomConvRate = 1.0 / uom_conv_rate, 
							     @uomOper = uom_conv_oper 
		        from dbo.uom_conversion 
						where cmdty_code = @cmdtyCode AND 
								  uom_code_conv_from = @toUom AND
									uom_code_conv_to = @fromUom								
	 					select @rows_affected = @@rowcount		
						if @rows_affected > 0	
						   goto calc1				

					  select @uomConvRate = uom_conv_rate, 
									 @uomOper = uom_conv_oper 
						from dbo.uom_conversion 
						where cmdty_code is NULL AND 
									uom_code_conv_from = @fromUom AND
									uom_code_conv_to = @toUom
		 				select @rows_affected = @@rowcount		
						if @rows_affected > 0	
						   goto calc1				

						select @uomConvRate = 1.0 / uom_conv_rate, 
									 @uomOper = uom_conv_oper 
						from dbo.uom_conversion 
						where cmdty_code is NULL AND 
									uom_code_conv_from = @toUom AND
									uom_code_conv_to = @fromUom
calc1:							
						if @uomOper = 'D'
							 select @uom_factor = ROUND((1.0 / @uomConvRate), 4)
						else
							 select @uom_factor = ROUND(@uomConvRate, 4)

						goto endoffun
				 end
				 else
						select @bbl_factor = 1.0
			
				 if @toUom = 'GAL'
						select @uom_factor = @bbl_factor * @gal_value
				 else if @toUom = 'BBL'
						select @uom_factor = @bbl_factor
				 else if @toUom = 'MB'
						select @uom_factor = @bbl_factor / @MB_value
				 else if ((@secQtyUomCode is not NULL) AND 
				          (@toUom = @secQtyUomCode) AND 
				          (@secConvFactor is not NULL))
						select @uom_factor = @secConvFactor
			end
	 end

endoffun:
	return @uom_factor
END
GO
GRANT EXECUTE ON  [dbo].[udf_getUomConversion] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'FUNCTION', N'udf_getUomConversion', NULL, NULL
GO
