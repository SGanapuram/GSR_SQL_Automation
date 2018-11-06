CREATE TABLE [dbo].[SAP_file]
(
[file_id] [int] NOT NULL,
[file_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[interface] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[num_inserts] [int] NOT NULL,
[num_updates] [int] NOT NULL,
[num_deletes] [int] NOT NULL,
[creation_time] [datetime] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[SAP_file_updtrg]
on [dbo].[SAP_file]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

/* RECORD_STAMP_END */

if update(file_id)   
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.file_id = d.file_id )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(SAP_file) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[SAP_file] ADD CONSTRAINT [SAP_file_pk] PRIMARY KEY CLUSTERED  ([file_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SAP_file] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[SAP_file] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[SAP_file] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[SAP_file] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'SAP_file', NULL, NULL
GO
