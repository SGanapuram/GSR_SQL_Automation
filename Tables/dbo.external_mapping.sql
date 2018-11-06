CREATE TABLE [dbo].[external_mapping]
(
[oid] [int] NOT NULL,
[external_trade_source_oid] [int] NOT NULL,
[mapping_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__external___mappi__4DB4832C] DEFAULT ('T'),
[external_value1] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_value2] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_value3] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_value4] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alias_value] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[external_mapping_deltrg]
on [dbo].[external_mapping]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   int

select @num_rows = @@rowcount
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
   select @errmsg = '(external_mapping) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   if @@trancount > 0 rollback tran

   return
end


insert dbo.aud_external_mapping
   (oid,
    external_trade_source_oid,
    mapping_type,
    external_value1,
    external_value2,
    external_value3, 
    external_value4, 
    alias_value, 
    trans_id,
    resp_trans_id)
select
   d.oid,
   d.external_trade_source_oid,
   d.mapping_type,
   d.external_value1,
   d.external_value2,
   d.external_value3, 
   d.external_value4, 
   d.alias_value, 
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

create trigger [dbo].[external_mapping_updtrg]
on [dbo].[external_mapping]
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
   raiserror ('(external_mapping) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(external_mapping) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   raiserror ('(external_mapping) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(oid) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(external_mapping) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_external_mapping
      (oid,
       external_trade_source_oid,
       mapping_type,
       external_value1,
       external_value2,
       external_value3, 
       external_value4, 
       alias_value, 
       trans_id,
       resp_trans_id)
   select
      d.oid,
      d.external_trade_source_oid,
      d.mapping_type,
      d.external_value1,
      d.external_value2,
      d.external_value3, 
      d.external_value4, 
      d.alias_value, 
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[external_mapping] ADD CONSTRAINT [CK__external___mappi__31EE03D4] CHECK (([mapping_type]='O' OR [mapping_type]='Q' OR [mapping_type]='U' OR [mapping_type]='S' OR [mapping_type]='P' OR [mapping_type]='K' OR [mapping_type]='B' OR [mapping_type]='M' OR [mapping_type]='N' OR [mapping_type]='C' OR [mapping_type]='T'))
GO
ALTER TABLE [dbo].[external_mapping] ADD CONSTRAINT [external_mapping_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[external_mapping] ADD CONSTRAINT [external_mapping_fk1] FOREIGN KEY ([external_trade_source_oid]) REFERENCES [dbo].[external_trade_source] ([oid])
GO
GRANT DELETE ON  [dbo].[external_mapping] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[external_mapping] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[external_mapping] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[external_mapping] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'external_mapping', NULL, NULL
GO
