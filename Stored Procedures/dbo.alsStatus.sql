SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[alsStatus]
(
   @maxSequence INT OUTPUT,
   @maxTransId  INT OUTPUT
)
AS 
BEGIN
set nocount on
set xact_abort on

   BEGIN TRAN
      SELECT @maxTransId = MAX(trans_id)
      FROM dbo.icts_transaction
    
      SELECT @maxSequence = MAX(sequence)
      FROM dbo.icts_transaction
    
      SELECT S.name,
             @maxTransId - IT.trans_id
      FROM dbo.icts_transaction IT,
           dbo.server S
      WHERE IT.sequence = S.last_sequence AND
            @maxTransId - IT.trans_id > 0
   COMMIT TRAN
END
return                                                                                                                                                                                    
GO
GRANT EXECUTE ON  [dbo].[alsStatus] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'alsStatus', NULL, NULL
GO
