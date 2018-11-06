SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_swap_cost_report] 
(	
   @from_date				datetime,
   @to_date				  datetime,
   @cost_status			varchar(8000) = NULL,
   @acct_num	  		varchar(8000) = NULL,
   @port_num				varchar(8000) = NULL,
   @order_type_code varchar(8000),
   @cmdty_code	    varchar(8000)
)
AS
SET NOCOUNT ON;
declare @my_from_date				  datetime,
		    @my_to_date					  datetime,
		    @my_cost_status				varchar(8000),
        @my_acct_num	  			varchar(8000),
        @my_port_num				  varchar(8000),
        @my_order_type_code	  varchar(8000),
        @my_cmdty_code				varchar(8000)

   select @my_from_date = @from_date,
          @my_to_date = @to_date,
          @my_cost_status = @cost_status,
          @my_acct_num	= @acct_num,
          @my_port_num	= @port_num,
          @my_order_type_code = @order_type_code,
          @my_cmdty_code = @cmdty_code	

   -- Insert statements for procedure here
   select convert(varchar, c.cost_eff_date, 101) AS effective_date,
		      cp.acct_short_name,	
		      c.cost_amt,
		      c.cost_code,
		      c.cost_pay_rec_ind,
		      convert(varchar, c.cost_owner_key6) + '/' + 
          convert(varchar, c.cost_owner_key7) + '/' +
          convert(varchar, c.cost_owner_key8) AS trade_num,
		      c.cost_amt_type,
		      bc.acct_short_name As BookComp,
		      c.cost_num,
		      convert(varchar, c.creation_date, 101) AS creation_date,
		      convert(varchar, c.cost_due_date, 101) AS due_date,
		      c.cost_status,
		      c.port_num
   from dbo.cost c
           LEFT OUTER JOIN dbo.account cp with (nolock)
              on cp.acct_num = c.acct_num
           LEFT OUTER JOIN dbo.account bc with (nolock)
              on bc.acct_num = c.cost_book_comp_num
           JOIN dbo.trade_order tor 
              on tor.trade_num = c.cost_owner_key6 and
                 tor.order_num = c.cost_owner_key7
           LEFT OUTER JOIN dbo.commodity_group cg with (nolock)
              on cg.cmdty_code = c.cost_code
   where c.cost_price_est_actual_ind = 'A' and
         c.cost_eff_date between @my_from_date and @my_to_date and                           /* Input from the UI: Effective Date */
         tor.order_type_code in (select * from dbo.udf_split(@my_order_type_code, ',')) and  /* Input from UI : Trade Type */
         1 = (case when @my_cmdty_code ='0' then 1   
                   when cg.parent_cmdty_code IN (select * from dbo.udf_split(@my_cmdty_code, ',')) then 1  
                   else 0  
              end) and
         1 = (case when @my_acct_num = '0' then 1
                   when c.acct_num IN (select * from dbo.udf_split(@my_acct_num, ',')) then 1
                   else 0
              end) and
         1 = (case when @my_cost_status = '<NONE>' then 1
                   when c.cost_status IN (select * from dbo.udf_split(@my_cost_status, ',')) then 1
                   else 0
              end) and
         1 = (case when @my_port_num = '0' then 1
                   when c.port_num IN (select * from dbo.udf_split(@my_port_num, ',')) then 1
                   else 0
              end)
   order by cost_eff_date, cp.acct_short_name, c.cost_status
GO
GRANT EXECUTE ON  [dbo].[usp_swap_cost_report] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_swap_cost_report', NULL, NULL
GO
