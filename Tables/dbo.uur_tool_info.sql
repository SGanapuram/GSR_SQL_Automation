CREATE TABLE [dbo].[uur_tool_info]
(
[uurt_scope] [char] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uurt_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uurt_version] [char] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[last_updated] [datetime] NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[uur_tool_info_updtrg]  
on [dbo].[uur_tool_info]  
for update  
as  
declare @num_rows       int,  
        @count_num_rows int,  
        @dummy_update   int,  
        @errmsg         varchar(255)  
  
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  
  
select @dummy_update = 0  
  
if update(uurt_scope)   
begin  
   select @count_num_rows = (select count(*) from inserted i, deleted d  
                             where i.uurt_scope = d.uurt_scope )  
   if (@count_num_rows = @num_rows)  
   begin  
      select @dummy_update = 1  
   end  
   else  
   begin  
      raiserror ('(uur_tool_info) primary key can not be changed.'  ,16,1)
      if @@trancount > 0 rollback tran  

      return  
   end  
end  
  
/* AUDIT_CODE_BEGIN */  
  
if @dummy_update = 0  
   insert dbo.aud_uur_tool_info  
      (uurt_scope,  
       uurt_name,  
       uurt_version,  
       last_updated,  
       user_init,  
       description)  
   select  
      d.uurt_scope,  
      d.uurt_name,  
      d.uurt_version,  
      d.last_updated,  
      d.user_init,  
      d.description  
   from deleted d, inserted i  
   where d.uurt_scope = i.uurt_scope   
  
/* AUDIT_CODE_END */  

return
GO
ALTER TABLE [dbo].[uur_tool_info] ADD CONSTRAINT [uur_tool_info_pk] PRIMARY KEY CLUSTERED  ([uurt_scope]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[uur_tool_info] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[uur_tool_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[uur_tool_info] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[uur_tool_info] TO [next_usr]
GO
