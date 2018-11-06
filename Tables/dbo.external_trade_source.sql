CREATE TABLE [dbo].[external_trade_source]
(
[oid] [int] NOT NULL,
[external_trade_src_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[external_trade_system_oid] [int] NOT NULL,
[alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[external_trade_source_deltrg]
on [dbo].[external_trade_source]
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
   select @errmsg = '(external_trade_source) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_external_trade_source
   (oid,
    external_trade_src_name,
    external_trade_system_oid,
    alias_source_code,
    trans_id,
    resp_trans_id)
select
   d.oid,
   d.external_trade_src_name,
   d.external_trade_system_oid,
   d.alias_source_code,
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

create trigger [dbo].[external_trade_source_updtrg]
on [dbo].[external_trade_source]
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
   raiserror ('(external_trade_source) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(external_trade_source) New trans_id must be larger than original trans_id.'
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
   raiserror ('(external_trade_source) new trans_id must not be older than current trans_id.',10,1)
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
      raiserror ('(external_trade_source) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_external_trade_source
      (oid,
       external_trade_src_name,
       external_trade_system_oid,
       alias_source_code,
       trans_id,
       resp_trans_id)
   select
      d.oid,
      d.external_trade_src_name,
      d.external_trade_system_oid,
      d.alias_source_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[external_trade_source] ADD CONSTRAINT [external_trade_source_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [external_trade_source_idx1] ON [dbo].[external_trade_source] ([external_trade_src_name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[external_trade_source] ADD CONSTRAINT [external_trade_source_fk1] FOREIGN KEY ([alias_source_code]) REFERENCES [dbo].[alias_source] ([alias_source_code])
GO
ALTER TABLE [dbo].[external_trade_source] ADD CONSTRAINT [external_trade_source_fk2] FOREIGN KEY ([external_trade_system_oid]) REFERENCES [dbo].[external_trade_system] ([oid])
GO
GRANT DELETE ON  [dbo].[external_trade_source] TO [admin_group]
GO
GRANT INSERT ON  [dbo].[external_trade_source] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[external_trade_source] TO [admin_group]
GO
GRANT UPDATE ON  [dbo].[external_trade_source] TO [admin_group]
GO
GRANT DELETE ON  [dbo].[external_trade_source] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[external_trade_source] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[external_trade_source] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[external_trade_source] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'external_trade_source', NULL, NULL
GO
