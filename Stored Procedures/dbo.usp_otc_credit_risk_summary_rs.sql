SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_otc_credit_risk_summary_rs]
(
   @exp_date           datetime = null, 
   @cp_nums            varchar(8000),
   @book_comp_nums     varchar(8000),
   @debugon            bit = 0 
)
as
set nocount on
declare @rows_affected          int, 
        @smsg                   varchar(255), 
        @status                 int, 
        @oid                    numeric(18, 0), 
        @stepid                 smallint, 
        @session_started        varchar(30), 
        @session_ended          varchar(30),  
        @my_exp_date            datetime,
        @my_cp_nums             varchar(8000),
        @my_book_comp_nums      varchar(8000)

   select @my_exp_date = @exp_date,
          @my_cp_nums = @cp_nums,
          @my_book_comp_nums = @book_comp_nums

   create table #temp1
   ( 
      exp_acct_num                        int null,
      counterparty                        nvarchar(255) null,
      book_comp_num                       int null,
      bookcompany                         nvarchar(255) null,
      isda                                char(1),
      exp_amount                          decimal(15, 5) null,
      positive_exp_amt			  decimal(15, 5) null,
      negitive_exp_amt			  decimal(15, 5) null,
      us_credit_limit                     decimal(15, 5) null,
      cp_credit_limit                     decimal(15, 5) null,
      collateral_recd                     decimal(15, 5) null,
      collateral_paid                     decimal(15, 5) null
   )
      
   insert into #temp1 
   (
 
      exp_acct_num,
      counterparty,
      book_comp_num,
      bookcompany,
      isda,
      exp_amount,
      positive_exp_amt,
      negitive_exp_amt,
      us_credit_limit,
      cp_credit_limit,
      collateral_recd,
      collateral_paid
   )

   select 
      exp_acct_num, 
      ac.acct_short_name 'counter Party', 
      exp_booking_comp_num, 
      ac1.acct_short_name 'Booking Copmany', 
      isnull(abc.isda_ind, 'N') AS 'ISDA', 
      sum(cash_exp_amt) 'Exposure Amt', 
      sum(case when cash_exp_amt>0 then cash_exp_amt else 0 end),
      sum(case when cash_exp_amt<0 then cash_exp_amt else 0 end),
      credit_to_us_credit_limit, 
      credit_to_Counterparty_credit_limit, 
      NULL AS 'collateral_received', 
      NULL AS 'collateral_paid' 
   from dbo.exposure e  
	   join dbo.exposure_detail ed
 	      on ed.exposure_num = e.exposure_num
   	   join dbo.cost c
 	      on c.cost_num = ed.cost_num
	   join dbo.trade t
		  on t.trade_num = c.cost_owner_key6
           left outer join dbo.acct_bookcomp ab 
              on ab.acct_num = e.exp_acct_num and 
                 ab.bookcomp_num = e.exp_booking_comp_num 
           left outer join dbo.acct_bookcomp_collatera abc 
              on ab.acct_bookcomp_key = abc.acct_bookcomp_key 
           left outer join dbo.account ac 
              on exp_acct_num = ac.acct_num 
           left outer join dbo.account ac1 
              on exp_booking_comp_num = ac1.acct_num 
           left outer join (select
                               cl1.book_comp_num, 
                               cl1.acct_num, 
                               credit_to_us_credit_limit, 
                               credit_to_Counterparty_credit_limit 
                            from (select 
                                     book_comp_num, 
                                     acct_num, 
                                     SUM(limit_amt) AS 'credit_to_us_credit_limit' 
                                  from dbo.credit_limit 
                                  where order_type_code = 'DERIVATI' and 
                                        limit_direction = 'I' 
                                  group by book_comp_num, acct_num) cl1, 
                                 (select 
                                     book_comp_num, 
                                     acct_num, 
                                     SUM(limit_amt) AS 'credit_to_Counterparty_credit_limit' 
                                  from dbo.credit_limit 
                                  where order_type_code = 'DERIVATI' and 
                                        limit_direction = 'O' 
                                  group by book_comp_num, acct_num) cl2 
                            where cl1.book_comp_num = cl2.book_comp_num and
                                  cl1.acct_num = cl2.acct_num) cl 
              on cl.book_comp_num = e.exp_booking_comp_num and
                 cl.acct_num = e.exp_acct_num 
where 
ac1. acct_type_code='PEICOMP'   and
1 = (case when @my_book_comp_nums is NULL then 1
     when '0' IN (select * from dbo.udf_split(@my_book_comp_nums, ',')) then 1
                   when exp_booking_comp_num IN (select * from dbo.udf_split(@my_book_comp_nums, ',')) then 1
                   else 0
              end)  

and ac. acct_type_code= 'CUSTOMER'  and 
1 = (case when @my_cp_nums is NULL then 1
     when '0' IN (select * from dbo.udf_split(@my_cp_nums, ',')) then 1
                   when exp_acct_num IN (select * from dbo.udf_split(@my_cp_nums, ',')) then 1
                   else 0
              end)  
and
exp_order_type_group = 'DERIV' and
       	(@my_exp_date >= t.contr_date  and   @my_exp_date <= c.cost_due_date)
   group by exp_acct_num, 
            exp_booking_comp_num, 
            credit_to_us_credit_limit, 
            credit_to_Counterparty_credit_limit, 
            isda_ind, 
            ac.acct_short_name, 
            ac1.acct_short_name

   order by exp_acct_num, 
            exp_booking_comp_num, 
            credit_to_us_credit_limit, 
            credit_to_Counterparty_credit_limit, 
            isda_ind


   create table #temp2
   (
      acct_num                      int null,
      book_comp_num                 int null,
      expiry_date                   datetime  null,
      collateral_received           decimal(15, 5) null,
      collateral_paid               decimal(15, 5) null
   ) 

   insert into #temp2
   (
      acct_num,
      book_comp_num,
      expiry_date,
      collateral_received,
      collateral_paid
   )  

   select
      lc_applicant AS acct_num, 
      lc_beneficiary AS book_comp_num, 
      lc_exp_date AS exp_date, 
      SUM(lc_alloc_amt_cap) AS 'collateral_received', 
      NULL AS 'collateral_paid' 
   from dbo.lc lc 
          join dbo.lc_allocation lca 
             on lc.lc_num = lca.lc_num 
   where lc_exp_imp_ind = 'E' and (@my_exp_date <= lc.lc_exp_date  and   @my_exp_date >= lc.lc_issue_date) and lc.lc_status_code='ACTIVE'
   group by lc_applicant, 
            lc_beneficiary, 
            lc_exp_date 
   union 
   select
      lc_beneficiary AS acct_num, 
      lc_applicant AS book_comp_num, 
      lc_exp_date AS exp_date, 
      NULL AS 'collateral_received', 
      SUM(lc_alloc_amt_cap) AS 'collateral_paid' 
   from dbo.lc lc 
          join lc_allocation lca 
             on lc.lc_num = lca.lc_num 
   where lc_exp_imp_ind = 'I' and (@my_exp_date <= lc.lc_exp_date  and   @my_exp_date >= lc.lc_issue_date) and lc.lc_status_code='ACTIVE'
   group by lc_applicant, 
            lc_beneficiary, 
            lc_exp_date

   select 
      
      t1.exp_acct_num,
      t1.counterparty,
      t1.book_comp_num,
      t1.bookcompany,
      t1.isda,
      t1.exp_amount,
      t1.positive_exp_amt,
      t1.negitive_exp_amt,
      t1.us_credit_limit,
      t1.cp_credit_limit,
      sum(t2.collateral_received) 'collateral_received',
      sum(t2.collateral_paid) 'collateral_paid'
   from #temp1 t1 
           left outer join #temp2 t2 
              on t1.book_comp_num = t2.book_comp_num and 
                 t1.exp_acct_num = t2.acct_num 
   group by 
            t1.exp_acct_num,
            t1.counterparty,
            t1.book_comp_num,
            t1.bookcompany,
            t1.isda,
            t1.exp_amount,
	    t1.positive_exp_amt,
            t1.negitive_exp_amt,
            t1.us_credit_limit,
            t1.cp_credit_limit

   DROP TABLE #temp1
   DROP TABLE #temp2

endofsp: 
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_otc_credit_risk_summary_rs] TO [next_usr]
GO
