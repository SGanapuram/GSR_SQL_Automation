CREATE TABLE [dbo].[sap_confirmation]
(
[voucher_num] [int] NOT NULL,
[sap_document_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_post_datetime] [datetime] NULL,
[filename] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[icts_post_datetime] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[sap_confirmation_deltrg]
on [dbo].[sap_confirmation]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
        @atrans_id   bigint

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses with (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(sap_confirmation) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses with (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,16,1)
   if @@trancount > 0 rollback tran

   return
end

/* AUDIT_CODE_BEGIN */

insert dbo.aud_sap_confirmation
(  
   voucher_num,
   sap_document_number,
   sap_post_datetime,
   filename,
   icts_post_datetime,
   trans_id,
   resp_trans_id
)
select
   d.voucher_num,
   d.sap_document_number,
   d.sap_post_datetime,
   d.filename,
   d.icts_post_datetime,
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

create trigger [dbo].[sap_confirmation_updtrg]
on [dbo].[sap_confirmation]
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
   raiserror ('(sap_confirmation) The change needs to be attached with a new trans_id',16,1)
   if @@trancount > 0 rollback tran

   return
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.voucher_num = d.voucher_num)
begin
   raiserror ('(sap_confirmation) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(voucher_num)
begin
   select @count_num_rows = (select count(*) 
                             from inserted i, deleted d
                             where i.voucher_num = d.voucher_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      select @errmsg = '(sap_confirmation) primary key can not be changed.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_sap_confirmation
   ( 
       voucher_num,
       sap_document_number,
       sap_post_datetime,
       filename,
       icts_post_datetime,
       trans_id,
       resp_trans_id
   )
   select
      d.voucher_num,
      d.sap_document_number,
      d.sap_post_datetime,
      d.filename,
      d.icts_post_datetime,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.voucher_num = i.voucher_num

/* AUDIT_CODE_END */  
return
GO
ALTER TABLE [dbo].[sap_confirmation] ADD CONSTRAINT [sap_confirmation_pk] PRIMARY KEY CLUSTERED  ([voucher_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[sap_confirmation] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[sap_confirmation] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[sap_confirmation] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[sap_confirmation] TO [next_usr]
GO
