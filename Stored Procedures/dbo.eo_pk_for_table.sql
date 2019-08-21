SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[eo_pk_for_table]
( 
   @tname VARCHAR(32) 
)
AS
BEGIN
set nocount on
set xact_abort on            

  begin tran
  UPDATE dbo.eo_sequence_table
  SET counter = counter + 1
  WHERE table_name = @tname

  SELECT counter
  FROM dbo.eo_sequence_table 
  WHERE table_name = @tname
  commit tran
END
GO
GRANT EXECUTE ON  [dbo].[eo_pk_for_table] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[eo_pk_for_table] TO [next_usr]
GO
