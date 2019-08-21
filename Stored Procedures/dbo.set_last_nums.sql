SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[set_last_nums]
(
   @loc_num         smallint = 0,
   @show_progress   bit = 0
)
as
begin
set nocount on
set xact_abort on
-- use SET ANSI_WARNINGS OFF to avoid the following warning:
--   Warning: Null value is eliminated by an aggregate or other SET operation
--
--  Peter Lo   4/27/2006
SET ANSI_WARNINGS OFF
declare @owner_table     varchar(30),
        @owner_column    varchar(30),
        @my_loc_num      smallint,
        @audit_tablename varchar(30),
        @errcode         int,
        @pos             int,
        @sequence_name   sysname,
        @s               varchar(255)

declare @sequences       table (sequence_name    sysname)

   set @errcode = 0

   insert into @sequences
     select name
	 from sys.objects
	 where schema_id = SCHEMA_ID('dbo') and
	       type = 'SO'
		                 
   select @sequence_name = min(sequence_name)
   from @sequences 

   while @sequence_name is not null
   begin
      set @s = null
      set @s = dbo.udf_sqlserver_sequence_consumer(@sequence_name); 
      if @s is null
         goto nextseq
	
      set @pos = null
      set @pos = charindex('.', @s)
      if @pos is null
      begin
         RAISERROR('=> Failed to obtain owner_table and/or owner_column for the sequence ''%s''?', 0, 1, @sequence_name) with nowait
         goto nextseq
      end
	  
      /* @s = 'tablename.colname' */
      set @owner_table = (select substring(@s, 0, @pos))
      set @owner_column = (select rtrim(substring(@s, @pos + 1, len(@s) - 1)))
	  
      set @audit_tablename = 'aud_' + @owner_table
  
      if object_id('dbo.' + @owner_table, 'U') is null
      begin
         RAISERROR('=> The owner_table ''%s'' does not exist in current database?', 0, 1, @owner_table) with nowait
         goto nextseq
      end
	  
      if not exists (select 1
                     from sys.columns
                     where object_id = OBJECT_ID('dbo.' + @owner_table) and
                           name = @owner_column)
      begin
         RAISERROR('=> The owner_column ''%s'' does not exist in owner_table ''%s''?', 0, 1, @owner_column, @owner_table) with nowait
         goto nextseq
      end
	
      if @sequence_name = 'trade_SEQ'
      begin
         exec @errcode = dbo.refresh_a_last_num 'trade',
                                                'trade_num',
                                                'trade_num',
                                                @show_progress
         if @errcode > 0
            goto nextseq
      end
      else if @sequence_name = 'quickfill_SEQ'
      begin	  
         exec @errcode = dbo.refresh_a_last_num 'trade',
                                                'trade_num',
                                                'qf_num',
                                                @show_progress
         if @errcode > 0
            goto nextseq
      end			
      else
      begin
         exec @errcode = dbo.refresh_a_last_num @owner_table,
                                                @owner_column,
                                                null,
                                                @show_progress
         if @errcode > 0
            goto nextseq
      end  

nextseq:
      select @sequence_name = min(sequence_name)
      from @sequences 
      where sequence_name > @sequence_name
   end
end
if @errcode > 0
   return 1
return 0
GO
GRANT EXECUTE ON  [dbo].[set_last_nums] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[set_last_nums] TO [next_usr]
GO
