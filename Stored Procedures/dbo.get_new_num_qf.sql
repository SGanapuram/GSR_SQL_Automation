SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_new_num_qf] 
(
   @new_num        int  output,
   @key_name       varchar(40) = null, 
   @location       int = null
) 
as 
set nocount on 
set xact_abort on
declare @rowcount    int 
declare @rowcount2   int 
declare @next_num    int 
  
   BEGIN TRANSACTION 
   update dbo.new_num 
   set last_num = last_num + 1 
   where num_col_name = @key_name and
         loc_num = @location 
   select @rowcount = @@rowcount 
   if (@rowcount = 1) 
   begin 
      select @next_num = last_num 
      from dbo.new_num 
      where num_col_name = @key_name and
            loc_num = @location 
 
      select @new_num = @next_num 
      COMMIT TRANSACTION 
      return 0 
   end 
   else 
   begin 
      ROLLBACK TRANSACTION 
      if (@rowcount = 0) 
         return 1 
      else 
         return 2 
   end 
GO
GRANT EXECUTE ON  [dbo].[get_new_num_qf] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[get_new_num_qf] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'get_new_num_qf', NULL, NULL
GO
