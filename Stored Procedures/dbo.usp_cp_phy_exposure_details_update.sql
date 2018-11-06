SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_cp_phy_exposure_details_update]
(
	 @DateRange_From     datetime,
	 @DateRange_To       datetime,
	 @fromDate           datetime,
	 @toDate             datetime,
	 @TOI                varchar(3000),
	 @Amount             decimal(20, 8),
	 @LC_CoveredAmt      decimal(20, 8),	 
	 @cost_pay_rec_ind   char(1),
	 @credit_term_code   char(8),
	 @credit_secure_ind  char(1),
	 @Limit_amount       decimal(20, 8)
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
		     from #cp_phy_exposure 
		     where TOI = @TOI and 
 	             ExpDate = CONVERT(VARCHAR(10),@fromDate,101)
		     print @rows_match
				
		     if @rows_match = 0 
		     begin 					
		  	    insert into #cp_phy_exposure
                 (ExpDate, TOI, credit_term_code, credit_secure_ind, 
                  cost_pay_rec_ind, Amount, LC_CoveredAmt, credit_limit_amt) 
               values(CONVERT(VARCHAR(10),@fromDate,101), @TOI, @credit_term_code, 
                      @credit_secure_ind, @cost_pay_rec_ind, @Amount, @LC_CoveredAmt,@Limit_amount)
		     end
		     else if @rows_match > 0
		     begin 					
            update #cp_phy_exposure
            set cost_pay_rec_ind = @cost_pay_rec_ind,
			          TOI = @TOI,
			          Amount = Amount + @Amount
			      where ExpDate = @fromDate and 
			            TOI = @TOI and
			            cost_pay_rec_ind = @cost_pay_rec_ind 
		     end				
 		     set @DateRange_From = dateadd(d, 1, @DateRange_From) 					
		     set @fromDate = dateadd(d, 1, @fromDate) 						
	    end 	
   end
GO
GRANT EXECUTE ON  [dbo].[usp_cp_phy_exposure_details_update] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_cp_phy_exposure_details_update', NULL, NULL
GO
