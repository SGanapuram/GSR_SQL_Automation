CREATE TABLE [dbo].[parser_version]
(
[oid] [int] NOT NULL,
[parser_id] [int] NOT NULL,
[delimiter] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lines_per_record] [int] NULL,
[has_header_row] [bit] NOT NULL CONSTRAINT [DF__parser_ve__has_h__2BD60322] DEFAULT ((1)),
[has_specs] [bit] NOT NULL CONSTRAINT [DF__parser_ve__has_s__2CCA275B] DEFAULT ((1)),
[parser_version] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[is_active] [bit] NOT NULL CONSTRAINT [DF__parser_ve__is_ac__5B500C1A] DEFAULT ((1))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE trigger [dbo].[parser_version_deltrg]
on [dbo].[parser_version]
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
   set @errmsg = '(parser_version) Failed to obtain a valid responsible trans_id.'
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
 

insert dbo.aud_parser_version
(
    oid,
	parser_id,
	delimiter,
	lines_per_record,
	has_header_row,
	has_specs,
	parser_version,
	is_active,
	trans_id,
	resp_trans_id	
)
select
    d.oid,
	d.parser_id,
	d.delimiter,
	d.lines_per_record,
	d.has_header_row,
	d.has_specs,
	d.parser_version,
	d.is_active,
	d.trans_id,
    @atrans_id
from deleted d
 
/* AUDIT_CODE_END */
return
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[parser_version_updtrg]
on [dbo].[parser_version]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errmsg           varchar(255)
 
set @num_rows = @@rowcount
if @num_rows = 0
   return
 
select @dummy_update = 0
 
/* RECORD_STAMP_BEGIN */
if not update(trans_id)
begin
   raiserror('(parser_version) The change needs to be attached with a new trans_id.', 16, 1)
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
      set @errmsg = '(parser_version) New trans_id must be larger than original trans_id.'
      set @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg, 16, 1)
      if @@trancount > 0 rollback tran
      return
   end
end
 
if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   raiserror ('(parser_version) new trans_id must not be older than current trans_id.', 16, 1)
   if @@trancount > 0 rollback tran
   return
end
 
/* RECORD_STAMP_END */
if update(oid)
begin
   set @count_num_rows = (select count(*) from inserted i, deleted d
                          where i.oid = d.oid)
   if (@count_num_rows = @num_rows)
      set @dummy_update = 1
   else
   begin
      raiserror ('(parser_version) primary key can not be changed.', 16, 1)
      if @@trancount > 0 rollback tran
      return
   end
end
 
if @dummy_update = 0
	insert dbo.aud_parser_version
	(
       oid,
       parser_id,
       delimiter,
       lines_per_record,
       has_header_row,
       has_specs,
       parser_version,
	   is_active,
       trans_id,
       resp_trans_id
	)
	select
		d.oid,
        d.parser_id,
        d.delimiter,
        d.lines_per_record,
        d.has_header_row,
        d.has_specs,
        d.parser_version,
		d.is_active,
        d.trans_id,
		i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid

/* AUDIT_CODE_END */
return
GO
ALTER TABLE [dbo].[parser_version] ADD CONSTRAINT [parser_version_PK] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[parser_version] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[parser_version] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[parser_version] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[parser_version] TO [next_usr]
GO
