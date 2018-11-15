CREATE TABLE [dbo].[parser_field]
(
[id] [int] NOT NULL,
[conversion_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[start_index] [int] NULL,
[end_index] [int] NULL,
[field_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[field_number] [int] NULL,
[field_numbers] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[line_number] [int] NULL,
[parser_format] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[parser_version_id] [int] NOT NULL,
[regex] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[result_concatenator] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[static_field_value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[format_string] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[parser_field_deltrg]
on [dbo].[parser_field]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
        @atrans_id int
 
set @num_rows = @@rowcount
if @num_rows = 0
   return
 
/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)
 
if @atrans_id is null
begin
   set @errmsg = '(parser_field) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      set @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror(@errmsg, 16, 1)
   if @@trancount > 0 rollback tran
   return
end
 
insert dbo.aud_parser_field
(
   id,
   conversion_name,
   start_index,
   end_index,
   field_name,
   field_number,
   field_numbers,
   line_number,
   parser_format,
   parser_version_id,
   regex,
   result_concatenator,
   static_field_value,
   alias_source_code,
   format_string,
   trans_id,
   resp_trans_id
)
select
   d.id,
   d.conversion_name,
   d.start_index,
   d.end_index,
   d.field_name,
   d.field_number,
   d.field_numbers,
   d.line_number,
   d.parser_format,
   d.parser_version_id,
   d.regex,
   d.result_concatenator,
   d.static_field_value,
   d.alias_source_code,
   d.format_string,
   d.trans_id,
   @atrans_id
from deleted d
 
/* AUDIT_CODE_END */
return

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
create trigger [dbo].[parser_field_updtrg]
on [dbo].[parser_field]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errmsg           varchar(255)
 
set @num_rows = @@rowcount
if @num_rows = 0
   return
 
set @dummy_update = 0
 
/* RECORD_STAMP_BEGIN */
if not update(trans_id)
begin
   raiserror('(parser_field) The change needs to be attached with a new trans_id.', 16, 1)
   if @@trancount > 0 rollback tran
   return
end
 
if exists (select 1
           from master.dbo.sysprocesses
           where spid = @@spid and
                (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                 program_name like 'Microsoft SQL Server Management Studio%') )
begin
   if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0
   begin
      set @errmsg = '(parser_field) New trans_id must be larger than original trans_id.'
      set @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg, 16, 1)
      if @@trancount > 0 rollback tran
      return
   end
end
 
if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.id = d.id)
begin
   raiserror ('(parser_field) new trans_id must not be older than current trans_id.', 16, 1)
   if @@trancount > 0 rollback tran
   return
end
 
/* RECORD_STAMP_END */
if update(id)
begin
   set @count_num_rows = (select count(*) from inserted i, deleted d
                          where i.id = d.id)
   if (@count_num_rows = @num_rows)
      set @dummy_update = 1
   else
   begin
      raiserror ('(parser_field) primary key can not be changed.', 16, 1)
      if @@trancount > 0 rollback tran
      return
   end
end
 
if @dummy_update = 0
   insert dbo.aud_parser_field
 	    (id,
 	     conversion_name,
 	     start_index,
 	     end_index,
 	     field_name,
 	     field_number,
 	     field_numbers,
 	     line_number,
 	     parser_format,
 	     parser_version_id,
 	     regex,
 	     result_concatenator,
 	     static_field_value,
 	     alias_source_code,
		 format_string,
		 trans_id,
		 resp_trans_id)
   select
 	    d.id,
 	    d.conversion_name,
 	    d.start_index,
 	    d.end_index,
 	    d.field_name,
 	    d.field_number,
 	    d.field_numbers,
 	    d.line_number,
 	    d.parser_format,
 	    d.parser_version_id,
 	    d.regex,
 	    d.result_concatenator,
 	    d.static_field_value,
		d.alias_source_code,
		d.format_string,
 	    d.trans_id,
 	    i.trans_id		
   from deleted d, inserted i
   where d.id = i.id
return
GO
ALTER TABLE [dbo].[parser_field] ADD CONSTRAINT [parser_field_pk] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[parser_field] ADD CONSTRAINT [parser_field_fk1] FOREIGN KEY ([parser_version_id]) REFERENCES [dbo].[parser_version] ([oid])
GO
GRANT DELETE ON  [dbo].[parser_field] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[parser_field] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[parser_field] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[parser_field] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'parser_field', NULL, NULL
GO
