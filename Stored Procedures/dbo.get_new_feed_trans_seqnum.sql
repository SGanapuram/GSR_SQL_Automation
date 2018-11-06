SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_new_feed_trans_seqnum]
(
   @new_num      int output
)
as 
set nocount on
set xact_abort on            
declare @next_num       int

   set @new_num = 0
   set @next_num = 0
   BEGIN TRANSACTION 
   update dbo.feed_trans_sequence
   set @next_num = isnull(last_num, 0),
       last_num = isnull(last_num, 0) + 1
   where oid = 1      
   if @next_num > 0
   begin
      COMMIT TRANSACTION 
      select @new_num = @next_num
      return 0 
   end  
	 else 
   begin 
		  ROLLBACK TRANSACTION 
      return 1 
   end  
GO
GRANT EXECUTE ON  [dbo].[get_new_feed_trans_seqnum] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[get_new_feed_trans_seqnum] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'get_new_feed_trans_seqnum', NULL, NULL
GO
