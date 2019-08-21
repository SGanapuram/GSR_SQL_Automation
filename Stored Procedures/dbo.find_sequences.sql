SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[find_sequences] as select getdate()
GO
GRANT EXECUTE ON  [dbo].[find_sequences] TO [next_usr]
GO
