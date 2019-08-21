SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[set_sequence_table]
as
begin
set nocount on
declare @table_name     varchar(30),
        @max_num        int

   select @table_name = min(table_name)
   from dbo.eo_sequence_table

   while @table_name is not null
   begin
      if @table_name = 'eipp_task_name'
         select @max_num = max(oid) from dbo.eipp_task_name
      if @table_name = 'eipp_task' 
         select @max_num = max(oid) from dbo.eipp_task

      select @max_num = isnull(@max_num, 0)
      update dbo.eo_sequence_table
      set counter = @max_num
      where table_name = @table_name
    
      select @table_name = min(table_name)
      from dbo.eo_sequence_table
      where table_name > @table_name
   end
end
GO
GRANT EXECUTE ON  [dbo].[set_sequence_table] TO [next_usr]
GO
