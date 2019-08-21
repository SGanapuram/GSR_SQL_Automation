SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[inhouse_post_trades]
(
   @risc_location varchar(40) = null
)
as
set nocount on
set xact_abort on
declare @count        int,
        @update_count int,
        @delete_count int,
        @result       int,
        @aTransId     int

   /* update all the trades that are in the inhouse_post table and
      have risc_date = @feed_date as posted.  The post indicator is located
      in trade_order.order_strategy_name char(15)
   */

   select @count = count(*) 
   from dbo.inhouse_post 
   where risc_location = @risc_location

   if (@count > 0) 
   begin
      exec @result = dbo.gen_new_trans_qf @aTransId output
      while (@aTransId = 0) 
      begin
	       exec dbo.gen_new_trans_qf @aTransId output
	       if (@aTransId = 0)
	          continue
	       else 
	          break
      end
      begin transaction
      update dbo.trade_order
      set order_strategy_name = replicate(' ',14) + 'Y',
	        trans_id = @aTransId
      where order_strategy_name is null and
	          trade_num in (select trade_num 
                          from dbo.inhouse_post 
                          where risc_location = @risc_location)

      select @update_count = @@rowcount
	
      update dbo.trade_order
      set order_strategy_name = substring(order_strategy_name, 1, 14) + 
		                               replicate(' ',(14 - len(order_strategy_name))) + 'Y',
	        trans_id = @aTransId
      where order_strategy_name is not null and
            trade_num in (select trade_num 
                          from dbo.inhouse_post 
			                    where risc_location = @risc_location)

      select @update_count = @update_count + @@rowcount

      if (@update_count <> @count) 
      begin
	       select 'rolling back transaction because counts dont match'
	       rollback transaction
      end
      else 
      begin
	       delete from dbo.inhouse_post 
         where risc_location = @risc_location
	       select @delete_count = @@rowcount

	       if (@update_count = @delete_count)
	          commit transaction
	       else
	          rollback transaction
      end
   end
GO
GRANT EXECUTE ON  [dbo].[inhouse_post_trades] TO [next_usr]
GO
