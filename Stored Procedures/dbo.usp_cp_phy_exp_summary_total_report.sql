SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_cp_phy_exp_summary_total_report]
(
	 @fromDate           datetime,
	 @exp_Amount         decimal(20, 8),
	 @LC_CoveredAmt      decimal(20, 8),
	 @limit_Amount		   decimal(20, 8), 
	 @cost_pay_rec_ind   char(1),
	 @credit_term_code   char(8),
	 @credit_secure_ind  char(1)
)
as
begin 
set nocount on
declare @rows_match bigint
declare @rows_count bigint

   select @rows_match = count(1) 
   from #cp_phy_exposure_summary 
   where exp_date = @fromDate 	

   print @rows_match

   if @rows_match = 0
   begin
	    if @credit_term_code = 'OPEN' and @cost_pay_rec_ind = 'R'
	    begin
		     insert into #cp_phy_exposure_summary 
		        values(@fromDate, @limit_Amount, @exp_Amount,0,0,0,0)
	    end
	    else if @credit_term_code = 'OPEN' and @cost_pay_rec_ind = 'P'
	    begin
		     insert into #cp_phy_exposure_summary 
		        values(@fromDate, @limit_Amount, 0, @exp_Amount, 0, 0, 0)
	    end
	    else if @credit_term_code = 'LC' and @cost_pay_rec_ind = 'R'
	    begin
		     insert into #cp_phy_exposure_summary 
		        values(@fromDate, @limit_Amount, 0, 0,@exp_Amount, 0, 0)
	    end
	    else if @credit_term_code = 'LC' and @cost_pay_rec_ind = 'P'
	    begin
		     insert into #cp_phy_exposure_summary 
		        values(@fromDate, @limit_Amount, 0, 0, 0, @exp_Amount, 0)
	    end
	 end
	 else if @rows_match > 0
	 begin
	    if @credit_term_code = 'OPEN' and @cost_pay_rec_ind = 'R'
	    begin
		     update #cp_phy_exposure_summary 
		     set Open_exp_rec = Open_exp_rec + @exp_Amount 
		     where exp_date = @fromDate 
	    end
	    else if @credit_term_code = 'OPEN' and @cost_pay_rec_ind = 'P'
	    begin
		     update #cp_phy_exposure_summary 
		     set Open_exp_pay = Open_exp_pay + @exp_Amount 
		     where exp_date = @fromDate 
	    end
	    else if @credit_term_code = 'LC' and @cost_pay_rec_ind = 'R'
	    begin
		     update #cp_phy_exposure_summary 
		     set LC_exp_rec = LC_exp_rec + @exp_Amount 
		     where exp_date = @fromDate 
	    end
	    else if @credit_term_code = 'LC' and @cost_pay_rec_ind = 'P'
	    begin
		     update #cp_phy_exposure_summary 
		     set LC_exp_pay = LC_exp_pay + @exp_Amount 
		     where exp_date = @fromDate 
	    end 
	 end
			
	 if @credit_secure_ind = 'Y' and @cost_pay_rec_ind = 'R'
	 begin
	  	update #cp_phy_exposure_summary 
	  	set Net_Receivable = Net_Receivable + @exp_Amount 
	  	where exp_date = @fromDate
	 end
end
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_cp_phy_exp_summary_total_report] TO [next_usr]
GO
