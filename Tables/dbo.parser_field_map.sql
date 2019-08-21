CREATE TABLE [dbo].[parser_field_map]
(
[id] [int] NOT NULL,
[map_key] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[map_value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[parser_field_id] [int] NULL,
[trans_id] [int] NOT NULL,
[default_map] [bit] NOT NULL CONSTRAINT [df_parser_field_map_default_map] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
create trigger [dbo].[parser_field_map_deltrg]
on [dbo].[parser_field_map]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
        @atrans_id   bigint
 
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
   set @errmsg = '(parser_field_map) Failed to obtain a valid responsible trans_id.'
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
 
insert dbo.aud_parser_field_map
(
   id,
   map_key,
   map_value,
   parser_field_id,
   default_map,
   trans_id,
   resp_trans_id
)
select
   d.id,
   d.map_key,
   d.map_value,
   d.parser_field_id,
   d.default_map,
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
 
create trigger [dbo].[parser_field_map_updtrg]
on [dbo].[parser_field_map]
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
 
/* RECORD_STAMP_BEGIN */
if not update(trans_id)
begin
   raiserror('(parser_field_map) The change needs to be attached with a new trans_id.', 16, 1)
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
      set @errmsg = '(parser_field_map) New trans_id must be larger than original trans_id.'
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
   raiserror ('(parser_field_map) new trans_id must not be older than current trans_id.', 16, 1)
   if @@trancount > 0 rollback tran
   return
end
 
/* RECORD_STAMP_END */
if update(id)
begin
   set @count_num_rows = (select count(*) from inserted i, deleted d
                          where i.id = d.id)
   if (@count_num_rows = @num_rows)
   begin
      set @dummy_update = 1
   end
   else
   begin
      raiserror ('(parser_field_map) primary key can not be changed.', 16, 1)
      if @@trancount > 0 rollback tran
      return
   end
end
 
if @dummy_update = 0
   insert dbo.aud_parser_field_map
 	    (id,
 	     map_key,
 	     map_value,
 	     parser_field_id,
		 default_map,
 	     trans_id,
         resp_trans_id)
   select
 	    d.id,
 	    d.map_key,
 	    d.map_value,
 	    d.parser_field_id,
		d.default_map,
 	    d.trans_id,
 	    i.trans_id
   from deleted d, inserted i
   where d.id = i.id
return
GO
ALTER TABLE [dbo].[parser_field_map] ADD CONSTRAINT [parser_field_map_pk] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[parser_field_map] ADD CONSTRAINT [parser_field_map_uk1] UNIQUE NONCLUSTERED  ([map_key], [parser_field_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[parser_field_map] ADD CONSTRAINT [parser_field_map_fk1] FOREIGN KEY ([parser_field_id]) REFERENCES [dbo].[parser_field] ([id])
GO
GRANT DELETE ON  [dbo].[parser_field_map] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[parser_field_map] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[parser_field_map] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[parser_field_map] TO [next_usr]
GO
