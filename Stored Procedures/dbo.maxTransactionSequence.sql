SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[maxTransactionSequence]
(
   @maxSequence numeric(32,0) output
)
as
set nocount on

   if exists (select 1 from dbo.icts_transaction where trans_id = 1)
   begin
      select @maxSequence = max(sequence) from dbo.icts_transaction
   end
   else
   begin
      print 'Please have your Database Administrator populate the'
      print 'icts_transaction table with an initial record.'
   end
return
GO
GRANT EXECUTE ON  [dbo].[maxTransactionSequence] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'maxTransactionSequence', NULL, NULL
GO
