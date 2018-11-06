SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_delete_fill]
(
   @tradeNum            int = null,
   @orderNum            smallint = null,
   @itemNum             smallint = null,
   @fillNum             smallint = null,
   @tradeModInit        char(3) = null,
   @fillTransId         int = null,
   @newTransId		      int = null
)
as
set nocount on
declare @temp int

   /* Update the fill with a fill_status = 'D' and then delete the fill
      Doing this, creates an audit entry into the database with the 'D'
      create_risc_file and procedures like it can easily find all the fills
      that have been deleted and send deletes to R&N appropriately.  IF this
      is not done, there is not easy and fast method of finding all deleted fills.
   */

   update dbo.trade_item_fill
   set fill_status = 'D',
       trans_id = @newTransId
   where trade_num = @tradeNum and
         order_num = @orderNum and 
         item_num = @itemNum and
         item_fill_num = @fillNum and
         trans_id = @fillTransId
        
   delete dbo.trade_item_fill 
   where trade_num = @tradeNum and
         order_num = @orderNum and
      	 item_num = @itemNum and
      	 item_fill_num = @fillNum and
         trans_id = @newTransId
   if (@@rowcount != 1)
      return -546
   return 0
GO
GRANT EXECUTE ON  [dbo].[quickfill_delete_fill] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'quickfill_delete_fill', NULL, NULL
GO
