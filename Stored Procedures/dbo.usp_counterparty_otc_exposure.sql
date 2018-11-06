SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_counterparty_otc_exposure]        
(
   @booking_comp_nums            varchar(8000),
   @exp_acct_num                 varchar(8000),      
   @from_date                    datetime,      
   @to_date                      datetime,
   @debugon                      bit = 0 
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
        @my_booking_comp_nums   varchar(8000),
        @my_exp_acct_num        varchar(8000),      
        @my_from_date           datetime,      
        @my_to_date             datetime

   select @my_booking_comp_nums = @booking_comp_nums, 
          @my_exp_acct_num = @exp_acct_num,
          @my_from_date = @from_date,
          @my_to_date = @to_date

   create table #exposure_output
   ( 
      exp_booking_comp_num                    bigint,
      book_company                            varchar(50) null,
      exp_date                                datetime,
      credit_to_us_credit_limit               decimal(20,8) null,
      credit_to_counterparty_credit_limit     decimal(20,8) null,
      exposure_amt                            decimal(20,8) null
   )
   
   create table #lc_output
   ( 
      exp_booking_comp_num       bigint,
      exp_date                   datetime,
      collateral_received        decimal(20,8) null,
      collateral_paid            decimal(20,8) null
   )
   
   if (@my_booking_comp_nums = '0' or @my_booking_comp_nums is null)
   begin
      insert into #exposure_output 
         (exp_booking_comp_num,
          book_company,
          exp_date,
          credit_to_us_credit_limit,
          credit_to_counterparty_credit_limit,
          exposure_amt) 
        select exp_booking_comp_num,
               act.acct_short_name 'booking_company',
               exp_date, 
               credit_to_us_credit_limit,
               credit_to_Counterparty_credit_limit,
               sum((isnull(cash_exp_rec_amt, 0) + (isnull(cash_exp_pay_amt, 0)* -1))) 'Exposure Amt'
        from dbo.exposure e
                inner join dbo.account act 
                   on act.acct_num = e.exp_booking_comp_num
                inner join dbo.mtm_cash_exposure mce 
                   on mce.exposure_num = e.exposure_num
                left outer join (select cl1.book_comp_num, 
                                        cl1.acct_num, 
                                        credit_to_us_credit_limit, 
                                        credit_to_Counterparty_credit_limit
                                 from (select book_comp_num, 
                                              acct_num, 
                                              sum(limit_amt) as 'credit_to_us_credit_limit'
                                       from dbo.credit_limit 
                                       where order_type_code = 'DERIVATI' and 
                                             limit_direction = 'I'
                                       group by book_comp_num, acct_num) cl1,
                                      (select book_comp_num, 
                                              acct_num, 
                                              sum(limit_amt) as 'credit_to_Counterparty_credit_limit'
                                       from dbo.credit_limit 
                                       where order_type_code = 'DERIVATI' and 
                                             limit_direction = 'O'
                                       group by book_comp_num, acct_num) cl2
                                 where cl1.book_comp_num = cl2.book_comp_num and 
                                       cl1.acct_num = cl2.acct_num) cl  
                  on cl.book_comp_num = e.exp_booking_comp_num and 
                     cl.acct_num = e.exp_acct_num
        where exp_acct_num in (select * 
                               from dbo.udf_split(@my_exp_acct_num, ',')) and 
              exp_order_type_group = 'DERIV' and 
              exp_date >= @my_from_date and 
              exp_date <= @my_to_date
        group by exp_date, 
                 exp_booking_comp_num, 
                 credit_to_us_credit_limit,
                 credit_to_Counterparty_credit_limit,
                 act.acct_short_name

      insert into #lc_output 
          (exp_booking_comp_num,
           exp_date,
           collateral_received,
           collateral_paid)
        select lc_beneficiary as book_comp_num, 
               lc_exp_date as exp_date,
               sum(lc_alloc_amt_cap) as 'collateral_received',
               0 as 'collateral_paid'
        from dbo.lc
                inner join dbo.lc_allocation lca 
                   on lc.lc_num = lca.lc_num
        where lc_exp_imp_ind = 'E' 
        group by lc_beneficiary, lc_exp_date
        union
        select lc_applicant as book_comp_num, 
               lc_exp_date as exp_date,
               0 as 'collateral_received',
               sum(lc_alloc_amt_cap) as 'collateral_paid'
        from dbo.lc
                inner join dbo.lc_allocation lca 
                   on lc.lc_num = lca.lc_num
        where lc_exp_imp_ind = 'E' 
        group by lc_applicant, lc_exp_date
   end
   else
   begin
      insert into #exposure_output 
          (exp_booking_comp_num,
           book_company,
           exp_date,
           credit_to_us_credit_limit,
           credit_to_counterparty_credit_limit,
           exposure_amt) 
        select exp_booking_comp_num,
               act.acct_short_name 'booking_company',
               exp_date,
               credit_to_us_credit_limit,
               credit_to_Counterparty_credit_limit,
               sum((isnull(cash_exp_rec_amt, 0) + ( isnull(cash_exp_pay_amt, 0) * -1))) 'Exposure Amt'
        from dbo.exposure e
                inner join dbo.account act 
                   on act.acct_num = e.exp_booking_comp_num
                inner join dbo.mtm_cash_exposure mce 
                   on mce.exposure_num = e.exposure_num
                left outer join (select cl1.book_comp_num, 
                                        cl1.acct_num, 
                                        credit_to_us_credit_limit, 
                                        credit_to_Counterparty_credit_limit
                                 from (select book_comp_num, 
                                              acct_num, 
                                              sum(limit_amt) as 'credit_to_us_credit_limit'
                                       from dbo.credit_limit 
                                       where order_type_code = 'DERIVATI' and 
                                             limit_direction = 'I'
                                       group by book_comp_num, acct_num) cl1,
                                      (select book_comp_num, 
                                              acct_num, 
                                              sum(limit_amt) as 'credit_to_Counterparty_credit_limit'
                                     from dbo.credit_limit 
                                     where order_type_code = 'DERIVATI' and 
                                           limit_direction = 'O'
                                     group by book_comp_num, acct_num) cl2
                                 where cl1.book_comp_num = cl2.book_comp_num and 
                                       cl1.acct_num = cl2.acct_num) cl  
                     on cl.book_comp_num = e.exp_booking_comp_num  and 
                        cl.acct_num = e.exp_acct_num
        where book_comp_num in (select * from dbo.udf_split(@my_booking_comp_nums, ',')) and 
              exp_acct_num in (select * from dbo.udf_split(@my_exp_acct_num, ',')) and 
              exp_order_type_group = 'DERIV' and 
              exp_date >= @from_date and 
              exp_date <= @to_date
        group by exp_date, exp_booking_comp_num, credit_to_us_credit_limit,
                 credit_to_Counterparty_credit_limit,act.acct_short_name

      insert into #lc_output 
      (  
         exp_booking_comp_num,
         exp_date,
         collateral_received,
         collateral_paid
      ) 
      select lc_beneficiary as book_comp_num, 
             lc_exp_date as exp_date,
             sum(lc_alloc_amt_cap) as 'collateral_received',
             0 as 'collateral_paid'
      from dbo.lc
              inner join dbo.lc_allocation lca 
                  on lc.lc_num = lca.lc_num
      where lc_exp_imp_ind = 'E' 
      group by lc_beneficiary, lc_exp_date
      union
      select lc_applicant as book_comp_num, 
             lc_exp_date as exp_date,
             0 as 'collateral_received',
             sum(lc_alloc_amt_cap) as 'collateral_paid'
      from dbo.lc
              inner join dbo.lc_allocation lca 
                 on lc.lc_num = lca.lc_num
      where lc_exp_imp_ind = 'E'
      group by lc_applicant, lc_exp_date
   end
      
   select e.exp_booking_comp_num,
          e.book_company,
          e.exp_date,
          e.credit_to_us_credit_limit,
          e.credit_to_counterparty_credit_limit,
          e.exposure_amt,
          sum(lc.collateral_received) as 'collateral_received',
          sum(lc.collateral_paid) as 'collateral_paid'
   from #exposure_output e 
           left outer join #lc_output lc 
              on e.exp_booking_comp_num = lc.exp_booking_comp_num and 
                 e.exp_date >= lc.exp_date
   group by e.exp_booking_comp_num,
            e.book_company,
            e.exp_date,
            e.credit_to_us_credit_limit,
            e.credit_to_counterparty_credit_limit,
            e.exposure_amt

   drop table #exposure_output
   drop table #lc_output
   
endofsp: 
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_counterparty_otc_exposure] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_counterparty_otc_exposure', NULL, NULL
GO
