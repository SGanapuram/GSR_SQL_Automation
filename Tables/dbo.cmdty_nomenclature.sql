CREATE TABLE [dbo].[cmdty_nomenclature]
(
[cmdty_nomenclature_id] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[nomenclature_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[nomenclature_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cmdty_nomenclature_deltrg]
on [dbo].[cmdty_nomenclature]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   bigint

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
   select @errmsg = '(cmdty_nomenclature) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,16,1)
   if @@trancount > 0 rollback tran

   return
end


insert dbo.aud_cmdty_nomenclature
   (cmdty_nomenclature_id,
    cmdty_code,
    nomenclature_id,
    nomenclature_desc,
    trans_id,
    resp_trans_id)
select
   d.cmdty_nomenclature_id,
   d.cmdty_code,
   d.nomenclature_id,
   d.nomenclature_desc,
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

create trigger [dbo].[cmdty_nomenclature_updtrg]
on [dbo].[cmdty_nomenclature]
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
   raiserror ('(cmdty_nomenclature) The change needs to be attached with a new trans_id',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* added by Peter Lo  Sep-4-2002 */
if exists (select 1
           from master.dbo.sysprocesses
           where spid = @@spid and
                (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                 program_name like 'Microsoft SQL Server Management Studio%') )
begin
   if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0
   begin
      select @errmsg = '(cmdty_nomenclature) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.cmdty_nomenclature_id = d.cmdty_nomenclature_id ) 
begin
   raiserror ('(cmdty_nomenclature) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(cmdty_nomenclature_id)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.cmdty_nomenclature_id = d.cmdty_nomenclature_id ) 
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(cmdty_nomenclature) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_cmdty_nomenclature
      (cmdty_nomenclature_id,
       cmdty_code,
       nomenclature_id,
       nomenclature_desc,
       trans_id,
       resp_trans_id)
   select
      d.cmdty_nomenclature_id,
      d.cmdty_code,
      d.nomenclature_id,
      d.nomenclature_desc,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.cmdty_nomenclature_id = i.cmdty_nomenclature_id

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[cmdty_nomenclature] ADD CONSTRAINT [cmdty_nomenclature_pk] PRIMARY KEY CLUSTERED  ([cmdty_nomenclature_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cmdty_nomenclature] ADD CONSTRAINT [cmdty_nomenclature_fk1] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[cmdty_nomenclature] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cmdty_nomenclature] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cmdty_nomenclature] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cmdty_nomenclature] TO [next_usr]
GO
