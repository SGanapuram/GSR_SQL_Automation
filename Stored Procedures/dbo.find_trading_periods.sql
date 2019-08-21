SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[find_trading_periods]
(
	 @by_type0 	varchar(40) = null,
	 @by_ref0	  varchar(40) = null,
	 @by_type1 	varchar(40) = null,
	 @by_ref1	  varchar(40) = null,
	 @by_type2 	varchar(40) = null,
	 @by_ref2	  varchar(40) = null
)
as 
begin
set nocount on
declare @rowcount  int
declare @temp_date datetime
declare @ref_num	 int

	 if @by_type0 = 'all'
	 begin
		  select
			   tp.commkt_key,
         tp.trading_prd,
         tp.last_trade_date,
         tp.opt_exp_date,
         tp.first_del_date,
         tp.last_del_date,
         tp.first_issue_date,
         tp.last_issue_date,
         tp.last_quote_date,
         tp.trading_prd_desc,
         tp.opt_eval_method,
         tp.trans_id 
		  from dbo.trading_period tp with (nolock)
		  order by tp.commkt_key, tp.trading_prd
	 end
	 else if (@by_type0 in ('trading_period', 'TR', 'trading_prd') and
		        @by_type1 is null)
	 begin
		  select
         tp.commkt_key,
         tp.trading_prd,
         tp.last_trade_date,
         tp.opt_exp_date,
         tp.first_del_date,
         tp.last_del_date,
         tp.first_issue_date,
         tp.last_issue_date,
         tp.last_quote_date,
         tp.trading_prd_desc,
         tp.opt_eval_method,
         tp.trans_id 
		  from dbo.trading_period tp with (nolock)
			where tp.trading_prd = @by_ref0
		  order by tp.commkt_key, tp.trading_prd
	 end
	 else if (@by_type0 in ('cmdty_mkt', 'CM', 'commodity_market', 'commkt_key') and
		        @by_type1 is null)
	 begin
		  set @ref_num = CONVERT(int, @by_ref0)
		  select
			   tp.commkt_key,
			   tp.trading_prd,
			   tp.last_trade_date,
			   tp.opt_exp_date,
			   tp.first_del_date,
			   tp.last_del_date,
			   tp.first_issue_date,
			   tp.last_issue_date,
         tp.last_quote_date,
         tp.trading_prd_desc,
         tp.opt_eval_method,
         tp.trans_id 
      from dbo.trading_period tp with (nolock)
			where tp.commkt_key = @ref_num
		  order by tp.commkt_key, tp.trading_prd
	 end
	 else if (@by_type0 in ('mkt', 'MK', 'market', 'mkt_code') and
		        @by_type1 is null)
	 begin
		  select
         tp.commkt_key,
         tp.trading_prd,
         tp.last_trade_date,
         tp.opt_exp_date,
         tp.first_del_date,
         tp.last_del_date,
         tp.first_issue_date,
         tp.last_issue_date,
         tp.last_quote_date,
         tp.trading_prd_desc,
         tp.opt_eval_method,
         tp.trans_id 
		  from dbo.trading_period tp with (nolock), 
		       dbo.commodity_market cm with (nolock)
		  where tp.commkt_key = cm.commkt_key AND
			      cm.mkt_code = @by_ref0
		  order by tp.commkt_key, tp.trading_prd
	 end
	 else if (@by_type0 in ('cmdty', 'CC', 'commodity', 'cmdty_code') and
		        @by_type1 is null)
	 begin
		  select
			   tp.commkt_key,
			   tp.trading_prd,
         tp.last_trade_date,
         tp.opt_exp_date,
         tp.first_del_date,
         tp.last_del_date,
         tp.first_issue_date,
         tp.last_issue_date,
         tp.last_quote_date,
         tp.trading_prd_desc,
         tp.opt_eval_method,
         tp.trans_id 
		  from dbo.trading_period tp with (nolock), 
		       dbo.commodity_market cm with (nolock)
		  where tp.commkt_key = cm.commkt_key AND
			      cm.cmdty_code = @by_ref0
		  order by tp.commkt_key, tp.trading_prd
	 end
	 else if (@by_type0 in ('cmdty', 'CC', 'commodity', 'cmdty_code') and
	          @by_type1 in ('mkt', 'MK', 'market', 'mkt_code'))
	 begin
		  select
			   tp.commkt_key,
			   tp.trading_prd,
			   tp.last_trade_date,
			   tp.opt_exp_date,
			   tp.first_del_date,
			   tp.last_del_date,
			   tp.first_issue_date,
			   tp.last_issue_date,
         tp.last_quote_date,
         tp.trading_prd_desc,
         tp.opt_eval_method,
         tp.trans_id 
		  from dbo.trading_period tp with (nolock), 
		       dbo.commodity_market cm with (nolock)
		  where tp.commkt_key = cm.commkt_key and   
		        cm.cmdty_code = @by_ref0 and   
		        cm.mkt_code = @by_ref1
		  order by tp.commkt_key, tp.trading_prd
	 end
	 else if (@by_type0 in ('cmdty', 'CC', 'commodity', 'cmdty_code') and
		        @by_type1 in ('mkt_status', 'MS') and
		        @by_type2 in ('mkt_status', 'MS'))
	 begin
		  select
			   tp.commkt_key,
			   tp.trading_prd,
			   tp.last_trade_date,
			   tp.opt_exp_date,
			   tp.first_del_date,
			   tp.last_del_date,
			   tp.first_issue_date,
			   tp.last_issue_date,
         tp.last_quote_date,
         tp.trading_prd_desc,
         tp.opt_eval_method,
         tp.trans_id 
		  from dbo.trading_period tp with (nolock), 
		       dbo.commodity_market cm with (nolock), 
		       market m with (nolock)
		  where tp.commkt_key = cm.commkt_key and   
		        cm.cmdty_code = @by_ref0 and   
		        m.mkt_code = cm.mkt_code and   
		        m.mkt_status in (@by_ref1, @by_ref2)
		  order by tp.commkt_key, tp.trading_prd
	 end
	 else if (@by_type0 in ('mkt_code', 'MC') and
		        @by_type1 in ('cmdty_status', 'CS') and
		        @by_type2 in ('cmdty_status', 'CS'))
	 begin
		  select
			   tp.commkt_key,
         tp.trading_prd,
         tp.last_trade_date,
         tp.opt_exp_date,
         tp.first_del_date,
         tp.last_del_date,
         tp.first_issue_date,
         tp.last_issue_date,
         tp.last_quote_date,
         tp.trading_prd_desc,
         tp.opt_eval_method,
         tp.trans_id 
		  from dbo.trading_period tp with (nolock), 
		       dbo.commodity_market cm with (nolock), 
		       dbo.commodity c with (nolock)
		  where tp.commkt_key = cm.commkt_key and   
		        cm.mkt_code = @by_ref0 and   
		        c.cmdty_code = cm.cmdty_code and   
		        c.cmdty_status in (@by_ref1, @by_ref2)
		  order by tp.commkt_key, trading_prd
	 end
	 else if (@by_type0 in ('commkt_key') and
		        @by_type1 in ('last_trade_date_from') and
		        @by_type2 in ('last_trade_date_to'))
	 begin
		  set @ref_num = CONVERT(int, @by_ref0)

		  select @temp_date = max(tp.last_trade_date)
			from dbo.trading_period tp with (nolock)
		  where tp.commkt_key = @ref_num

		  if @by_ref2 < @temp_date
		  begin
		     set @temp_date = (select top 1 tp.last_trade_date
		                       from dbo.trading_period tp with (nolock)
		                       where tp.commkt_key = @ref_num and   
		                             tp.last_trade_date >= @by_ref2
		                       order by tp.commkt_key, tp.trading_prd)
		  end
		  select
			   tp.commkt_key,
			   tp.trading_prd,
			   tp.last_trade_date,
			   tp.opt_exp_date,
			   tp.first_del_date,
			   tp.last_del_date,
			   tp.first_issue_date,
			   tp.last_issue_date,
         tp.last_quote_date,
         tp.trading_prd_desc,
         tp.opt_eval_method,
         tp.trans_id 
      from dbo.trading_period tp with (nolock)
		  where tp.commkt_key = @ref_num and   
		        tp.last_trade_date between @by_ref1 and @temp_date
		  order by tp.commkt_key, tp.trading_prd
	 end
   else if (@by_type0 in ('commkt_key') and
		        @by_type1 in ('last_trade_date_from') and
		        @by_type2 is null)
	 begin
		  set @ref_num = CONVERT(int, @by_ref0)

		  select @temp_date = max(last_trade_date)
			from dbo.trading_period tp
		  where tp.commkt_key = @ref_num

		  set rowcount 0
		  select
			   tp.commkt_key,
			   tp.trading_prd,
			   tp.last_trade_date,
			   tp.opt_exp_date,
			   tp.first_del_date,
			   tp.last_del_date,
			   tp.first_issue_date,
			   tp.last_issue_date,
         tp.last_quote_date,
         tp.trading_prd_desc,
         tp.opt_eval_method,
         tp.trans_id 
      from dbo.trading_period tp with (nolock)
		  where tp.commkt_key = @ref_num and   
		        tp.last_trade_date between @by_ref1 and @temp_date
		  order by tp.commkt_key, tp.trading_prd
	 end
	 else if (@by_type0 in ('commkt_key') and
		        @by_type1 in ('is_spot_or_nearby') and
		        @by_ref1 in ('NO', 'NULL'))
	 begin
		  set @ref_num = CONVERT(int, @by_ref0)
		  select
			   tp.commkt_key,
			   tp.trading_prd,
			   tp.last_trade_date,
			   tp.opt_exp_date,
			   tp.first_del_date,
			   tp.last_del_date,
			   tp.first_issue_date,
			   tp.last_issue_date,
         tp.last_quote_date,
         tp.trading_prd_desc,
         tp.opt_eval_method,
         tp.trans_id 
		  from dbo.trading_period tp with (nolock)
		  where tp.commkt_key = @ref_num and   
		        tp.trading_prd not like 'SPOT%'
		  order by tp.commkt_key, tp.trading_prd
	 end
	 else if (@by_type0 in ('commkt_key') and
		        @by_type1 in ('is_spot_or_nearby') and
		        @by_ref1 in ('YES'))
	 begin
		  set @ref_num = CONVERT(int, @by_ref0)
		  select
			   tp.commkt_key,
			   tp.trading_prd,
			   tp.last_trade_date,
			   tp.opt_exp_date,
			   tp.first_del_date,
			   tp.last_del_date,
			   tp.first_issue_date,
			   tp.last_issue_date,
         tp.last_quote_date,
         tp.trading_prd_desc,
			   tp.opt_eval_method,
			   tp.trans_id 
		  from dbo.trading_period tp with (nolock)
		  where tp.commkt_key = @ref_num
		  order by tp.commkt_key, tp.trading_prd
	 end
   else 
      return 4

   set @rowcount = @@rowcount
   if (@rowcount = 1)
      return 0
   else if (@rowcount = 0)
      return 1
   else 
      return 2
end
GO
GRANT EXECUTE ON  [dbo].[find_trading_periods] TO [next_usr]
GO
