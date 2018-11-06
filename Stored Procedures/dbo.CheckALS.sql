SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[CheckALS]
as
begin
set nocount on

   declare @maxSequence   int
   declare @rc            int

   select @maxSequence = max(sequence)
   from dbo.icts_transaction

   select Behind=convert(varchar(10),@maxSequence - last_sequence),
          Apps=convert(varchar(10),@maxSequence),
          ALS=convert(varchar(10),last_sequence),
          Server=convert(varchar(30),name),
          Time=convert(varchar(23),getdate(),9)
   from dbo.server
   select @rc = @@rowcount
   if @rc = 0
      return 1
   return 0
end
GO
GRANT EXECUTE ON  [dbo].[CheckALS] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'CheckALS', NULL, NULL
GO
