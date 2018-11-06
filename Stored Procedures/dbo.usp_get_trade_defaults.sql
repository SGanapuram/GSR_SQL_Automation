SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_get_trade_defaults]
(
   @cmdty_code              varchar(8) = null,
   @counterparty_acct_num   int = null,
   @order_type_code         varchar(8) = null,
   @del_loc_code_key        varchar(8) = null
)
as
set nocount on
declare @status       int,
        @debugon      bit

   select @status = 0,
          @debugon = 1
   
   select * into #cons_trade_default 
   from dbo.trade_default 
   where 1 = 2 
	 select @status = @@error
	 if @status > 0
	    goto errexit
   
   
   select * into #buf_trade_default 
   from dbo.trade_default 
   where 1 = 2 
	 select @status = @@error
	 if @status > 0
	    goto errexit

   -- All columns except the dflt_num column and the trans_id column in the trade_default table
   -- are nullable columns
   insert into #cons_trade_default (dflt_num, trans_id) values (0, 1)
	 select @status = @@error
	 if @status > 0
	    goto errexit

   -- NULL NULL NULL NULL
   insert into #buf_trade_default
   select * 
   from dbo.trade_default
   where cmdty_code is null and 
	       acct_num is null and 
	       order_type_code is null and 
	       del_loc_code_key is null
	 select @status = @@error
	 if @status > 0
	    goto errexit

   exec @status = dbo.usp_merge_trade_defaults
	 if @status = 1
	    goto errexit

   -- NULL NULL NULL X
   if @del_loc_code_key is not null
   begin
	    insert into #buf_trade_default
	    select * 
	    from dbo.trade_default
	    where cmdty_code is null and 
		        acct_num is null and 
		        order_type_code is null and 
		        del_loc_code_key = @del_loc_code_key
	    select @status = @@error
	    if @status > 0
	       goto errexit

      exec @status = dbo.usp_merge_trade_defaults
	    if @status = 1
	       goto errexit
   end

   -- NULL NULL X NULL
   if @order_type_code is not null
   begin
	    insert into #buf_trade_default
	    select * 
	    from dbo.trade_default
      where cmdty_code is null and 
		        acct_num is null and 
		        order_type_code = @order_type_code and 
		        del_loc_code_key is null
	    select @status = @@error
	    if @status > 0
	       goto errexit

      exec @status = dbo.usp_merge_trade_defaults
	    if @status = 1
	       goto errexit
   end

   -- NULL NULL X X
   if @order_type_code is not null and 
      @del_loc_code_key is not null
   begin
	    insert into #buf_trade_default
	    select * 
	    from dbo.trade_default
	    where cmdty_code is null and 
		        acct_num is null and 
		        order_type_code = @order_type_code and 
		        del_loc_code_key = @del_loc_code_key
	    select @status = @@error
	    if @status > 0
	       goto errexit

      exec @status = dbo.usp_merge_trade_defaults
	    if @status = 1
	       goto errexit
   end

   -- NULL X NULL NULL
   if @counterparty_acct_num is not null
   begin
	    insert into #buf_trade_default
	    select * 
	    from dbo.trade_default
	    where cmdty_code is null and 
		        acct_num = @counterparty_acct_num and
		        order_type_code is null and
		        del_loc_code_key is null
	    select @status = @@error
	    if @status > 0
	       goto errexit

      exec @status = dbo.usp_merge_trade_defaults
	    if @status = 1
	       goto errexit
   end

   -- NULL X NULL X
   if @counterparty_acct_num is not null and 
      @del_loc_code_key is not null
   begin
	    insert into #buf_trade_default
	    select * 
	    from dbo.trade_default
	    where cmdty_code is null and 
		        acct_num = @counterparty_acct_num and
		        order_type_code is null and
		        del_loc_code_key = @del_loc_code_key
	    select @status = @@error
	    if @status > 0
	       goto errexit

      exec @status = dbo.usp_merge_trade_defaults
	    if @status = 1
	       goto errexit
   end

   -- NULL X X NULL
   if @counterparty_acct_num is not null and 
      @order_type_code is not null
   begin
	    insert into #buf_trade_default
	    select * 
	    from dbo.trade_default
	    where cmdty_code is null and 
		        acct_num = @counterparty_acct_num and
		        order_type_code = @order_type_code and
		        del_loc_code_key is null
	    select @status = @@error
	    if @status > 0
	       goto errexit

      exec @status = dbo.usp_merge_trade_defaults
	    if @status = 1
	       goto errexit
   end

   -- NULL X X X
   if @counterparty_acct_num is not null and 
      @order_type_code is not null and 
      @del_loc_code_key is not null
   begin
	    insert into #buf_trade_default
	    select * 
	    from dbo.trade_default
	    where cmdty_code is null and 
		        acct_num = @counterparty_acct_num and
		        order_type_code = @order_type_code and
		        del_loc_code_key = @del_loc_code_key
	    select @status = @@error
	    if @status > 0
	       goto errexit

      exec @status = dbo.usp_merge_trade_defaults
	    if @status = 1
	       goto errexit
   end

   -- X NULL NULL NULL
   if @cmdty_code is not null
   begin
	    insert into #buf_trade_default
	    select * 
	    from dbo.trade_default
	    where cmdty_code = @cmdty_code and
		        acct_num is null and
		        order_type_code is null and
		        del_loc_code_key is null
	    select @status = @@error
	    if @status > 0
	       goto errexit

      exec @status = dbo.usp_merge_trade_defaults
	    if @status = 1
	       goto errexit
   end

   -- X NULL NULL X
   if @cmdty_code is not null and 
      @del_loc_code_key is not null
   begin
	    insert into #buf_trade_default
	    select * 
	    from dbo.trade_default
	    where cmdty_code = @cmdty_code and
		        acct_num is null and 
		        order_type_code is null and
		        del_loc_code_key = @del_loc_code_key
	    select @status = @@error
	    if @status > 0
	       goto errexit

      exec @status = dbo.usp_merge_trade_defaults
	    if @status = 1
	       goto errexit
   end

   -- X NULL X NULL
   if @cmdty_code is not null and 
      @order_type_code is not null
   begin
	    insert into #buf_trade_default
	    select * 
	    from dbo.trade_default
	    where cmdty_code = @cmdty_code and
		        acct_num is null and 
		        order_type_code = @order_type_code and
		        del_loc_code_key is null
	    select @status = @@error
	    if @status > 0
	       goto errexit

      exec @status = dbo.usp_merge_trade_defaults
	    if @status = 1
	       goto errexit
   end

   -- X NULL X X
   if @cmdty_code is not null and 
      @order_type_code is not null and 
	    @del_loc_code_key is not null
   begin
	    insert into #buf_trade_default
	    select * 
	    from dbo.trade_default
	    where cmdty_code = @cmdty_code and
		        acct_num is null and 
		        order_type_code = @order_type_code and
		        del_loc_code_key = @del_loc_code_key
	    select @status = @@error
	    if @status > 0
	       goto errexit

      exec @status = dbo.usp_merge_trade_defaults
	    if @status = 1
	       goto errexit
   end

   -- X X NULL NULL
   if @cmdty_code is not null and 
      @counterparty_acct_num is not null
   begin
	    insert into #buf_trade_default
	    select * 
	    from dbo.trade_default
		  where cmdty_code = @cmdty_code and
		       acct_num = @counterparty_acct_num and
		       order_type_code is null and
		       del_loc_code_key is null
	    select @status = @@error
	    if @status > 0
	       goto errexit

      exec @status = dbo.usp_merge_trade_defaults
	    if @status = 1
	       goto errexit
   end

   -- X X NULL X
   if @cmdty_code is not null and 
      @counterparty_acct_num is not null and
	    @del_loc_code_key is not null
   begin
	    insert into #buf_trade_default
	    select * 
	    from dbo.trade_default
	    where cmdty_code = @cmdty_code and
		        acct_num = @counterparty_acct_num and
		        order_type_code is null and
		        del_loc_code_key = @del_loc_code_key
	    select @status = @@error
	    if @status > 0
	       goto errexit

      exec @status = dbo.usp_merge_trade_defaults
	    if @status = 1
	       goto errexit
   end

   -- X X X NULL
   if @cmdty_code is not null and 
      @counterparty_acct_num is not null and
	    @order_type_code is not null
   begin
	    insert into #buf_trade_default
	    select * 
	    from dbo.trade_default
	    where cmdty_code = @cmdty_code and
		        acct_num = @counterparty_acct_num and
		        order_type_code = @order_type_code and
		        del_loc_code_key is null
	    select @status = @@error
	    if @status > 0
	       goto errexit

      exec @status = dbo.usp_merge_trade_defaults
	    if @status = 1
	       goto errexit
   end

   -- X X X X
   if @cmdty_code is not null and 
      @counterparty_acct_num is not null and
	    @order_type_code is not null and 
	    @del_loc_code_key is not null
   begin
	    insert into #buf_trade_default
	    select * 
	    from dbo.trade_default
	    where cmdty_code = @cmdty_code and
		        acct_num = @counterparty_acct_num and
		        order_type_code = @order_type_code and
		        del_loc_code_key = @del_loc_code_key
	    select @status = @@error
	    if @status > 0
	       goto errexit

      exec @status = dbo.usp_merge_trade_defaults
	    if @status = 1
	       goto errexit
   end

errexit:
   if @status = 1
      delete #cons_trade_default
      
   select *
   from #cons_trade_default
   
   drop table #cons_trade_default
   drop table #buf_trade_default
   return @status
GO
GRANT EXECUTE ON  [dbo].[usp_get_trade_defaults] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_get_trade_defaults', NULL, NULL
GO
