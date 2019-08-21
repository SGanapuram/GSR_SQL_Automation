SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_new_num_qf] 
(
   @new_num        bigint  output,
   @key_name       varchar(40) = null, 
   @location       int = null
) 
as 
set nocount on 
set xact_abort on
declare @errcode        int,
        @next_num       bigint
 
   set @errcode = 0 
   set @next_num = null   
   exec @errcode = dbo.usp_get_next_sequence_num @key_name, @next_num output
   if @errcode > 0
   begin
      set @new_num = null
	  return 1
   end
   
   set @new_num = @next_num
   return 0
GO
GRANT EXECUTE ON  [dbo].[get_new_num_qf] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[get_new_num_qf] TO [next_usr]
GO
