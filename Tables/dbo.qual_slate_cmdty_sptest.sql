CREATE TABLE [dbo].[qual_slate_cmdty_sptest]
(
[oid] [int] NOT NULL,
[quality_slate_id] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_test_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[is_default_test] [bit] NOT NULL CONSTRAINT [df_qual_slate_cmdty_sptest_is_default_test] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[qual_slate_cmdty_sptest_deltrg]
on [dbo].[qual_slate_cmdty_sptest]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
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
   select @errmsg = '(qual_slate_cmdty_sptest) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_qual_slate_cmdty_sptest
(  
   oid, 
   quality_slate_id,
   cmdty_code,
   spec_code,
   spec_test_code,
   is_default_test,
   trans_id,
   resp_trans_id
)
select
   oid,
   d.quality_slate_id,
   d.cmdty_code,
   d.spec_code,
   d.spec_test_code,
   d.is_default_test,
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

create trigger [dbo].[qual_slate_cmdty_sptest_updtrg]
on [dbo].[qual_slate_cmdty_sptest]
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
   raiserror ('(qual_slate_cmdty_sptest) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(qual_slate_cmdty_sptest) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   select @errmsg = '(qual_slate_cmdty_sptest) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.oid) + ')' 
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
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
      raiserror ('(qual_slate_cmdty_sptest) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_qual_slate_cmdty_sptest
   (
      oid, 
      quality_slate_id,
      cmdty_code,
      spec_code,
      spec_test_code,
      is_default_test,
      trans_id,
      resp_trans_id
   )
   select
      d.oid, 
      d.quality_slate_id,
      d.cmdty_code,
      d.spec_code,
      d.spec_test_code,
      d.is_default_test,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid
    
return
GO
ALTER TABLE [dbo].[qual_slate_cmdty_sptest] ADD CONSTRAINT [qual_slate_cmdty_sptest_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[qual_slate_cmdty_sptest] ADD CONSTRAINT [qual_slate_cmdty_sptest_fk1] FOREIGN KEY ([quality_slate_id]) REFERENCES [dbo].[quality_slate] ([oid])
GO
ALTER TABLE [dbo].[qual_slate_cmdty_sptest] ADD CONSTRAINT [qual_slate_cmdty_sptest_fk2] FOREIGN KEY ([spec_test_code], [spec_code], [cmdty_code]) REFERENCES [dbo].[spec_test] ([spec_test_code], [spec_code], [cmdty_code])
GO
GRANT DELETE ON  [dbo].[qual_slate_cmdty_sptest] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[qual_slate_cmdty_sptest] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[qual_slate_cmdty_sptest] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[qual_slate_cmdty_sptest] TO [next_usr]
GO
