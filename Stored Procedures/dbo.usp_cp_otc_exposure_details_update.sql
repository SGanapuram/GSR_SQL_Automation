SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_cp_otc_exposure_details_update]
(         
	 @DateRange_From				               datetime,
	 @DateRange_To				                 datetime,
	 @fromDate				                     datetime,
	 @toDate					                     datetime,
	 @exp_booking_comp_num                 bigint,
	 @book_company				                 varchar(50),
	 @credit_to_us_credit_limit		         decimal(20, 8),	 
	 @credit_to_counterparty_credit_limit  decimal(20, 8),
	 @exposure_amt				                 decimal(20, 8),
	 @collateral_received			             decimal(20, 8),
	 @collateral_paid			                 decimal(20, 8)
)
as 
set nocount on

   if (@DateRange_From between @fromDate and @toDate) 
			set @fromDate = @DateRange_From
   else
			set @DateRange_From = @fromDate 
   if (@DateRange_To between @fromDate and @toDate)
			set @toDate = @DateRange_To
   else
      set @DateRange_To = @toDate 
   while (@DateRange_From <= @DateRange_To)
   begin
	if ((@fromDate between @DateRange_From and @DateRange_To) or 
	    (@toDate between @DateRange_From and @DateRange_To))
	begin 
		 declare @rows_match bigint
		 select @rows_match = count(1) 
		 from #exposure_output 
		 where cash_from_date = CONVERT(VARCHAR(10),@fromDate,101) and
				exp_booking_comp_num =@exp_booking_comp_num	
				 print @rows_match
				 if @rows_match = 0 
				 begin 					
				  	insert into #exposure_output
				  	     (exp_booking_comp_num, book_company, cash_from_date, cash_to_date, credit_to_us_credit_limit, credit_to_counterparty_credit_limit, exposure_amt,collateral_received,collateral_paid) 
				  	   values(@exp_booking_comp_num,@book_company,CONVERT(VARCHAR(10),@fromDate,101),CONVERT(VARCHAR(10),@toDate,101), @credit_to_us_credit_limit, @credit_to_counterparty_credit_limit, @exposure_amt, @collateral_received, @collateral_paid)
				 end
				 else if @rows_match > 0
				 begin 					
					  update #exposure_output
					  set exposure_amt = exposure_amt + @exposure_amt
					  where cash_from_date = CONVERT(VARCHAR(10),@fromDate,101) and 
					        exp_booking_comp_num =@exp_booking_comp_num
				 end				
				 set @DateRange_From = dateadd(d, 1, @DateRange_From) 					
				 set @fromDate = dateadd(d, 1, @fromDate) 						
	end 	
end
endofsp: 
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_cp_otc_exposure_details_update] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_cp_otc_exposure_details_update', NULL, NULL
GO
