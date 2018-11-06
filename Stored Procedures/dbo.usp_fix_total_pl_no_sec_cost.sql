SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_fix_total_pl_no_sec_cost]
( 
   @port_num        int, 
   @asofdate        datetime
)
as
set nocount on
set xact_abort on
declare @errcode           int,
        @trans_id          int,
        @rows_affected     int,
        @smsg              varchar(512)
        
   if not exists (select 1
                  from dbo.portfolio
                  where port_num = @port_num)
   begin
      print '=> Invalid port_num passed to the argument @port_num!'
      return 2
   end

   select @errcode = 0
   create table #children (port_num int PRIMARY KEY, port_type char(2))

   exec dbo.port_children @top_portfolio = @port_num, @port_type = 'R'
   if (select count(*) from #children) = 0
   begin
      print '=> No REAL portfolios found for the port_num passed to the argument @port_num!'     
      goto endofsp
   end
   
   begin tran
   exec dbo.gen_new_transaction_NOI
   select @trans_id = last_num 
   from dbo.icts_trans_sequence 
   where oid = 1

   if @trans_id is null
   begin
      if @@trancount > 0
         rollback tran
      print '=> Failed to obtain a new trans_id for the update operation!'
      select @errcode = 1
      goto endofsp
   end
   
   update dbo.portfolio_profit_loss 
   set total_pl_no_sec_cost = (isnull(open_phys_pl, 0) + 
                               isnull(open_hedge_pl, 0) + 
                               isnull(closed_phys_pl, 0) + 
                               isnull(closed_hedge_pl, 0) + 
                               isnull(other_pl, 0) + 
                               isnull(liq_open_phys_pl, 0) + 
                               isnull(liq_open_hedge_pl, 0) + 
                               isnull(liq_closed_phys_pl, 0) + 
                               isnull(liq_closed_hedge_pl, 0)) - 
                               (select isnull(sum(pl_amt), 0) 
                                from dbo.pl_history pl 
                                where pl.real_port_num = ppl.port_num and 
                                      pl.pl_asof_date = ppl.pl_asof_date and 
                                      pl.pl_owner_code = 'C' and 
                                      pl.pl_type not in ('I', 'W') and 
                                      pl.pl_cost_prin_addl_ind = 'A'), 
       trans_id = @trans_id
   from dbo.portfolio_profit_loss ppl
           INNER JOIN #children c 
              ON ppl.port_num = c.port_num
           INNER JOIN dbo.portfolio prt 
              ON prt.port_num = c.port_num
   where prt.port_locked = 1 and 
         ppl.pl_asof_date = @asofdate 
   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0
   begin
      if @@trancount > 0
         rollback tran
      print '=> Failed to update the portfolio_profit_loss table!'
      goto endofsp
   end
   commit tran
   if @rows_affected > 0
      select @smsg = '=> ' + cast(@rows_affected as varchar) + ' portfolio_profit_loss records were updated!'
   else
      select @smsg = '=> No portfolio_profit_loss records were updated!'
   print @smsg 
   print ' '

endofsp:
   drop table #children
   if @errcode = 0
      return 0
    
    return 1
GO
GRANT EXECUTE ON  [dbo].[usp_fix_total_pl_no_sec_cost] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_fix_total_pl_no_sec_cost', NULL, NULL
GO
