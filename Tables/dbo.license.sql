CREATE TABLE [dbo].[license]
(
[license_num] [int] NOT NULL,
[issuing_tax_authority_num] [int] NOT NULL,
[license_id] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_num] [int] NULL,
[license_eff_date] [datetime] NULL,
[license_exp_date] [datetime] NULL,
[license_short_cmnt] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[license_deltrg]
on [dbo].[license]
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
   select @errmsg = '(license) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_license
   (license_num,
    issuing_tax_authority_num,
    license_id,
    acct_num,
    license_eff_date,
    license_exp_date,
    license_short_cmnt,
    cmnt_num,
    trans_id,
    resp_trans_id)
select
   d.license_num,
   d.issuing_tax_authority_num,
   d.license_id,
   d.acct_num,
   d.license_eff_date,
   d.license_exp_date,
   d.license_short_cmnt,
   d.cmnt_num,
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

create trigger [dbo].[license_updtrg]
on [dbo].[license]
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
   raiserror ('(license) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(license) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.license_num = d.license_num )
begin
   raiserror ('(license) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(license_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.license_num = d.license_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(license) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_license
      (license_num,
       issuing_tax_authority_num,
       license_id,
       acct_num,
       license_eff_date,
       license_exp_date,
       license_short_cmnt,
       cmnt_num,
       trans_id,
       resp_trans_id)
   select
      d.license_num,
      d.issuing_tax_authority_num,
      d.license_id,
      d.acct_num,
      d.license_eff_date,
      d.license_exp_date,
      d.license_short_cmnt,
      d.cmnt_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.license_num = i.license_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[license] ADD CONSTRAINT [license_pk] PRIMARY KEY CLUSTERED  ([license_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[license] ADD CONSTRAINT [license_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[license] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[license] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[license] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[license] TO [next_usr]
GO
