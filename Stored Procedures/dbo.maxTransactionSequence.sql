SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[maxTransactionSequence]
(
   @maxSequence numeric(32, 0) output
)
as
set nocount on

   set @maxSequence = (select IDENT_CURRENT('dbo.icts_transaction'))
   return
GO
GRANT EXECUTE ON  [dbo].[maxTransactionSequence] TO [next_usr]
GO
