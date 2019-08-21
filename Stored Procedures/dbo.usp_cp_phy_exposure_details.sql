SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_cp_phy_exposure_details]
(
	 @booking_comp_nums	varchar(8000),    
	 @exp_acct_num		  bigint,    
	 @from_date			    datetime,    
	 @to_date			      datetime,
	 @debugon           bit = 0 
)
as
set nocount on
declare @rows_affected				int, 
        @smsg						      varchar(255), 
        @status						    int, 
        @oid						      numeric(18, 0), 
        @stepid						    smallint, 
        @session_started			varchar(30), 
        @session_ended				varchar(30), 
        @my_booking_comp_nums varchar(8000),    
		    @my_exp_acct_num			bigint,    
		    @my_from_date				  datetime,    
		    @my_to_date					  datetime

   select @my_booking_comp_nums = @booking_comp_nums, 
          @my_exp_acct_num = @exp_acct_num,
          @my_from_date = @from_date,
          @my_to_date = @to_date

	 create table #cp_phy_exposure
	 (
	    SlNo		              int identity(1,1),
	    ExpDate		            datetime null,
	    TOI			              varchar(3000) null,
	    credit_term_code      char(8) null,
      credit_secure_ind	    char(1) null,
	    cost_pay_rec_ind      char(1) null,
	    Amount                decimal(20, 8) null,
	    LC_CoveredAmt	        decimal(20, 8) null,
      credit_limit_amt	    decimal(20, 8) null
	 )

	 declare @cash_from_date    datetime 
	 declare @cash_to_date      datetime
	 declare @TOI               varchar(3000) 
	 declare @Amount            decimal(20, 8)
	 declare @LC_CoveredAmt     decimal(20, 8)
	 declare @cost_pay_rec_ind  char(1)
	 declare @credit_term_code  char(8)
	 declare @credit_secure_ind char(1)
	 declare @Limit_amount	    decimal(20, 8)

   declare cp_phy_cursor cursor for 
	    select cash_from_date, cash_to_date,
	       cast(cost_owner_key6 as varchar) + '/' + 
	       cast(cost_owner_key7 as varchar) + '/' + 
	       cast(cost_owner_key8 as varchar) as TOI,
	       c.credit_term_code,
               credit_secure_ind,
	       cost_pay_rec_ind,
	       isnull(lc_covered_amt, 0) 'LC_CoveredAmt',
	       SUM(cash_exp_amt),
               isnull(cl.limit_amt, 0) as limit_amt
	    from dbo.exposure e
	            join dbo.exposure_detail ed 
	               on ed.exposure_num = e.exposure_num
	            left outer join dbo.credit_limit cl 
	               on cl.acct_num = e.exp_acct_num and 
		                cl.order_type_code = e.exp_order_type_group and  
	                  cl.book_comp_num = e.exp_booking_comp_num and 
		                cl.limit_direction = 'O'
              join dbo.cost c 
                 on c.cost_num = ed.cost_num
              join dbo.credit_term ct						
                 on c.credit_term_code = ct.credit_term_code
              left outer join (select trade_num, 
                                      order_num, 
                                      item_num, 
                                      isnull(alloc_num, trade_num) as AllocNum, 
                                      isnull(alloc_item_num, order_num) as AllocItemNum,
                                      sum(isnull(covered_amt, 0)) as lc_covered_amt
	                             from dbo.assign_trade 
	                             where ct_doc_num in (select lc_num 
                                                    from dbo.lc 
	                                                  where (lc_exp_imp_ind = 'E' and 
	                                                         lc_beneficiary in (select * 
	                                                                            from dbo.fnToSplit(@my_booking_comp_nums, ',')) and 
	                                                         lc_applicant = @my_exp_acct_num) or 
	                                                        (lc_exp_imp_ind = 'I' and 
	                                                         lc_beneficiary = @my_exp_acct_num and 
	                                                         lc_applicant in (select * 
	                                                                          from dbo.fnToSplit(@my_booking_comp_nums, ',')) )) 
	                             group by trade_num, order_num, item_num, alloc_num, alloc_item_num) ast
                 on ast.trade_num = c.cost_owner_key6 and 
	                  ast.order_num = c.cost_owner_key7 and 
	                  ast.item_num = c.cost_owner_key8 and 
	                  ast.AllocNum = c.cost_owner_key1 and 
	                  ast.AllocItemNum = c.cost_owner_key2
	    where exp_booking_comp_num in (select * 
	                                   from dbo.fnToSplit(@my_booking_comp_nums, ',')) AND 
            exp_acct_num = @my_exp_acct_num AND 
            exp_order_type_group = 'PHYSICAL' AND 
			      ((cash_from_date >= @my_from_date AND cash_to_date <= @my_to_date) OR
			       (cash_from_date BETWEEN @my_from_date AND @my_to_date) OR
			       (cash_to_date BETWEEN @my_from_date AND @my_to_date) OR
			       (cash_from_date <= @my_from_date AND cash_to_date >= @my_to_date))      
			group by cash_from_date, 
			         cash_to_date, 
			         cast(cost_owner_key6 as varchar) + '/' + 
			             cast(cost_owner_key7 as varchar) + '/' + 
			             cast(cost_owner_key8 as varchar), 
			         lc_covered_amt, 
			         cost_pay_rec_ind, 
			         c.credit_term_code,
               credit_secure_ind,cl.limit_amt
					
		open cp_phy_cursor 
		fetch NEXT from cp_phy_cursor into @cash_from_date, 
		                                   @cash_to_date, 
		                                   @TOI, 
		                                   @credit_term_code, 
                                       @credit_secure_ind,
		                                   @cost_pay_rec_ind, 
		                                   @LC_CoveredAmt, 
		                                   @Amount,
                                       @Limit_amount
		while @@FETCH_STATUS = 0
		begin
   	   exec dbo.usp_cp_phy_exposure_details_update 
   	                                          @my_from_date, 
	                                            @my_to_date, 
	                                            @cash_from_date,
	                                            @cash_to_date, 
	                                            @TOI, 
	                                            @Amount, 
	                                            @LC_CoveredAmt, 
	                                            @cost_pay_rec_ind, 
	                                            @credit_term_code,	 	
                                              @credit_secure_ind,
                                              @Limit_amount

		   fetch NEXT from cp_phy_cursor into @cash_from_date, 
		                                      @cash_to_date, 
		                                      @TOI, 
		                                      @credit_term_code, 
                                          @credit_secure_ind,
		                                      @cost_pay_rec_ind, 
		                                      @LC_CoveredAmt, 
		                                      @Amount,
                                          @Limit_amount
		end
		close cp_phy_cursor
		deallocate cp_phy_cursor
		 
		select SlNo,
		       ExpDate AS 'exp_date',
		       TOI,
		       cost_pay_rec_ind,
		       credit_term_code,
           credit_secure_ind,
		       Amount 'ExposureAmt',
		       CASE WHEN cost_pay_rec_ind = 'R' THEN Amount 
		       END AS 'ExposureAmt_Rec',
		       CASE WHEN cost_pay_rec_ind = 'P' THEN Amount 
		       END AS 'ExposureAmt_Pay',
		       CASE WHEN cost_pay_rec_ind = 'R' THEN 
			          (CASE WHEN (LC_CoveredAmt = 0 OR (LC_CoveredAmt < Amount)) 
			                THEN (Amount - LC_CoveredAmt) 
				         END) 
			     END AS 'ReceivableOpen',
		       CASE WHEN cost_pay_rec_ind = 'P' 
		               THEN (CASE WHEN (LC_CoveredAmt = 0 OR (LC_CoveredAmt < Amount)) 
	                               THEN (Amount + LC_CoveredAmt) 
				                 END) 
		       END AS 'PaybleOpen',
   		     LC_CoveredAmt, 
           credit_limit_amt
		from #cp_phy_exposure
    drop table #cp_phy_exposure

endofsp: 
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_cp_phy_exposure_details] TO [next_usr]
GO
