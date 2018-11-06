SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[refresh_feed_trans_seqnum]
as
set nocount on
set xact_abort on
declare @max_num              int,
        @rowcount             int,
        @errcode              int

   select @rowcount = 0,
          @errcode = 0
               
   select @max_num = isnull(max(oid), 0)
   from dbo.feed_transaction

   -- refresh the counter in the feed_trans_sequence table
   if @max_num > 0
   begin
      begin tran   
      update dbo.feed_trans_sequence
      set last_num = @max_num
      where oid = 1
      select @rowcount = @@rowcount,
             @errcode = @@error
      if @errcode > 0 or @rowcount = 0
         rollback tran
      else
         commit tran
   end
GO
GRANT EXECUTE ON  [dbo].[refresh_feed_trans_seqnum] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'refresh_feed_trans_seqnum', NULL, NULL
GO
