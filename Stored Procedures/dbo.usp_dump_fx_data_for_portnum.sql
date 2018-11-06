SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_dump_fx_data_for_portnum]
(
   @root_port_num    int,
   @debugon          bit = 0
)
as 
set nocount on
declare @my_top_port_num   int
declare @smsg              varchar(255)
declare @status            int
declare @errcode           int

	 if not exists (select 1
		              from dbo.portfolio
		              where port_num = @root_port_num)
	 begin
	    print '=> You must provide a valid port # for the argument @root_port_num!'
	    print 'Usage: exec dbo.usp_dump_fx_data_for_portnum @root_port_num = ? [, @debugon = ?]'
	    return 2
	 end 

	 set @my_top_port_num = isnull(@root_port_num, 0)
	 set @status = 0
	 set @errcode = 0

	 create table #children
	 (
	    port_num int PRIMARY KEY,
	    port_type char(2),
	 )

   create table #fx_dump
   (
	    trade_number        varchar(40) null,
	    fx_exp_num          int null,
	    real_port_num       int null,
	    fx_type             varchar(15) null, 
	    fx_sub_type         varchar(15) null,
	    fx_currency	        char(8) null,
	    pl_currency	        char(8) null,
	    trading_prd	        varchar(15) null,
	    exp_date            varchar(15) null,
	    year	              char(4) null,
	    quarter             char(4) null,
	    month               char(4) null,
	    day                 char(4) null,
	    total_exp_by_id     decimal(20,8) null,
	    fx_amount           decimal(20,8) null,
	    fx_source           varchar(15) null,
	    cost_num            int null,
      trade_num           int null,
	    order_num           smallint null,
	    item_num            smallint null
   )

	 begin try    
		 exec dbo.usp_get_child_port_nums @my_top_port_num, 1
	 end try
	 begin catch
		 print '=> Failed to execute the ''usp_get_child_port_nums'' sp due to the following error:'
		 print '==> ERROR: ' + ERROR_MESSAGE()
		 set @errcode = ERROR_NUMBER()
		 goto errexit
	 end catch

   exec @status = dbo.usp_dump_fx_data @debugon
   if @status > 0
      goto endofsp
   
	 select 
	    trade_number,
	    fx_exp_num,
	    cost_num,
	    real_port_num,
	    fx_type,
	    exp_date,
	    year,
	    quarter,
	    month,
	    day,
	    fx_currency,
	    fx_amount,
	    fx_sub_type,
	    pl_currency,
	    trading_prd,
	    total_exp_by_id,
	    fx_source,
	    tag_name
	 from #fx_dump fd
	         join dbo.portfolio_tag pt 
	            on fd.real_port_num = pt.port_num and 
	               tag_name = 'PRFTCNTR'
	 where fx_amount <> 0.0
	 order by real_port_num, trade_number, exp_date
	 
errexit:
   if @errcode > 0
      set @status = 1
   
endofsp:
if object_id('tempdb.dbo.#children') is not null
   exec('drop table #children')
if object_id('tempdb.dbo.#fx_dump') is not null
   exec('drop table #fx_dump')
return @status
GO
GRANT EXECUTE ON  [dbo].[usp_dump_fx_data_for_portnum] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_dump_fx_data_for_portnum', NULL, NULL
GO
