SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_trades_with_pending_lcs]
(
   @due_date          datetime, 
   @cp_acct_num       nvarchar(4000) = null,
   @bc_acct_num       nvarchar(4000) = null,
   @trade_type        char(1) = null,
   @credit_term_code  char(8) = null,
   @days_left         varchar(3) = null,
   @debugon           bit = 0 
)
as
set nocount on
declare @rows_affected          int, 
        @smsg                   varchar(255), 
        @status                 int, 
        @stepid                 smallint, 
        @session_started        varchar(30), 
        @session_ended          varchar(30), 
        @my_due_date            datetime,
        @my_cp_acct_num		      varchar(4000),
        @my_bc_acct_num	  	    nvarchar(4000),
        @my_trade_type		      char(1),
        @my_credit_term_code	  char(8) ,
        @my_days_left		        int,
        @oid			              int,
        @my_exch_rate		        numeric(20,8),
        @my_div_mul_ind		      char(1),
        @my_exch_date           datetime,
        @my_exch_currency       char(8)

   select @my_due_date = @due_date,
          @my_cp_acct_num = @cp_acct_num,
          @my_bc_acct_num = @bc_acct_num,
          @my_trade_type  = @trade_type,
          @my_credit_term_code = @credit_term_code,
          @my_days_left  = case when @days_left = '-1' then NULL
	                              else @days_left 
	                         end

  -- Create a temp table to store results
   create table #pendinglc
   (
      oid INT IDENTITY,
      bc_acct_short_name NVARCHAR(30),
      cp_acct_short_name NVARCHAR(30),
      trade_type VARCHAR(11) NULL,
      pay_rec_ind VARCHAR(11) NULL,
      opp_internal_toi VARCHAR(200) NULL,
      contr_date VARCHAR(30) NULL,
      creation_date VARCHAR(30) NULL,
      due_date VARCHAR(30) NULL,
      cost_qty FLOAT NULL,
      cost_qty_uom CHAR(4) NULL,
      cost_amt  FLOAT NULL,
      cost_price_curr_code CHAR(8) NULL,
      usd_exp FLOAT NULL,
      exch_rate FLOAT NULL,
      days_remaining INT NULL,
      credit_term_code CHAR(8) NULL,
      ct_doc_num INT NULL      
   )
   
   create table #exchange_rate
   (
      oid INT IDENTITY,
      as_of_date DATETIME  NULL ,
      curr_code_from CHAR(8) NULL 
   )
   

  
-- Inserting required data
INSERT INTO #pendinglc 
select	bc.acct_short_name as 'Booking Company',
		cp.acct_short_name as 'Counterparty',
		case ti.item_type when 'C' then 'DERIVATIVE' else 'PHYSICAL' end as 'Trade Type',
		case c.cost_pay_rec_ind when 'P' then 'PAYABLE' else 'RECEIVABLE' end as 'Pay Rec Ind',
		convert(varchar,c.cost_owner_key6)+'/'+convert(varchar,c.cost_owner_key7)+'/'+convert(varchar,c.cost_owner_key8) AS TOI,
		convert(varchar,t.contr_date,101) as 'Contract Date',		
		convert(varchar,c.creation_date,101) as 'Creation Date',
		convert(varchar,c.cost_due_date,101) as 'Due Date',
		c.cost_qty as 'Quantity',
		c.cost_qty_uom_code as 'Quantity Uom',
		c.cost_amt as 'Base Currency Exposure',
		c.cost_price_curr_code as 'Base Currency',
		null as 'USD Exposure',
		null as 'Exch Rate',
		datediff(dd,@my_due_date,c.cost_due_date) DaysRemaining,--Use DueDate parameter instead of getDate()
		c.credit_term_code,
		ct_doc_num
from cost c
join trade_item ti on ti.trade_num=c.cost_owner_key6 and ti.order_num=c.cost_owner_key7 and ti.item_num=c.cost_owner_key8 
join trade t on ti.trade_num=t.trade_num
LEFT OUTER JOIN account cp ON cp.acct_num=c.acct_num
LEFT OUTER JOIN account bc ON bc.acct_num=c.cost_book_comp_num
left outer join assign_trade at on at.trade_num=c.cost_owner_key6 and at.order_num=c.cost_owner_key7 and at.item_num=c.cost_owner_key8
where ct_doc_num is null and
	  cost_status !='CLOSED' and 
	  cost_prim_sec_ind='P' AND
      1 = (case when @my_days_left IS NOT NULL  then 1
                   WHEN c.credit_term_code = @my_credit_term_code then 1
                   ELSE 0
              end) AND  ----Credit Term Code
      1 = (case when @my_days_left IS NOT NULL  then 1
                   WHEN  item_type = @my_trade_type then 1
                   ELSE 0
              end) AND 	--Trade Type
      1 = (case when @my_days_left IS NOT NULL  then 1
                   WHEN c.cost_due_date>= @my_due_date then 1
                   ELSE 0
              end) AND -- Date condition

         1 = (case when @my_bc_acct_num is NULL OR @my_days_left IS NOT NULL  then 1
                   when c.cost_book_comp_num IN (select * from dbo.udf_split(@my_bc_acct_num, ',')) then 1
                   else 0
              end) AND  --Booking Company
         1 = (case when @my_cp_acct_num is NULL OR @my_days_left IS NOT NULL then 1
                   when c.acct_num  IN (select * from dbo.udf_split(@my_cp_acct_num, ',')) then 1
                   else 0
              end)  AND --Counterparty
         1 = (case when @my_days_left is null then 1
                   when @my_days_left =0 then 1
                  when c.cost_due_date BETWEEN  convert(DATETIME ,convert(VARCHAR , @my_due_date,101) + ' 00:00:00')
                                          AND   convert(DATETIME ,convert(VARCHAR , DateADD(DD, @my_days_left,@my_due_date),101) + ' 23:59:59 ') 
                  then 1
                   else 0
              end)
order by cost_due_date,c.cost_owner_key6, c.cost_owner_key7, c.cost_owner_key8,at.ct_doc_num
-- Inserting records where Base Currency is not USD

			INSERT INTO #exchange_rate 
            SELECT distinct due_date,cost_price_curr_code
            FROM #pendinglc 
            WHERE cost_price_curr_code != 'USD'
            
-- looping all records in #exchange_rate table to update exchange rate and divide_multiply_ind

        SELECT  @oid = min(oid) from #exchange_rate
        
         WHILE @oid is not null
         BEGIN
         -- Calling stored procedure 
         SELECT @my_exch_date =as_of_date, @my_exch_currency =curr_code_from 
         FROM #exchange_rate WHERE oid = @oid
         EXEC usp_currency_exch_rate 
          				@asof_date = @my_exch_date, 
          				@curr_code_from = @my_exch_currency,
          				@curr_code_to = 'USD',
                        @est_final_ind = 'E',
                        @use_out_args_flag =1,
                        @conv_rate= @my_exch_rate OUTPUT, 
                        @calc_oper= @my_div_mul_ind OUTPUT
	   
		UPDATE #pendinglc SET usd_exp = case when @my_div_mul_ind = 'M' then round(cost_amt* @my_exch_rate,2)
        WHEN  @my_div_mul_ind = 'D' then round(cost_amt/ @my_exch_rate,2)
        END   
		,exch_rate = @my_exch_rate
		WHERE due_date = @my_exch_date and cost_price_curr_code = @my_exch_currency

         SELECT  @oid = min(oid) FROM  #exchange_rate where oid > @oid
        END 
update #pendinglc set usd_exp = cost_amt where usd_exp is NULL and cost_price_curr_code = 'USD'


     SELECT oid ,
      bc_acct_short_name as 'Booking Company',
      cp_acct_short_name  as 'Counterparty',
      trade_type as 'Trade Type',
      pay_rec_ind as 'Pay Rec Ind',
      opp_internal_toi  AS TOI,
      contr_date  as 'Contract Date',
      creation_date  as 'Creation Date',
      due_date  as 'Due Date',
      cost_qty  'Quantity',
      cost_qty_uom  as 'Quantity Uom',
      round(cost_amt,2)   as 'Base Currency Exposure',
      cost_price_curr_code as 'Base Currency',
      round(usd_exp,2)  as 'USD Exposure',
      exch_rate  as 'Exch Rate',
      days_remaining as 'Days Remaining',
      credit_term_code as 'Credit Term Code'
      FROM #pendinglc 
       
     
DROP TABLE #pendinglc
DROP TABLE #exchange_rate

endofsp: 
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_trades_with_pending_lcs] TO [next_usr]
GO
