CREATE TABLE [dbo].[voucher_ext_info]
(
[voucher_num] [int] NOT NULL,
[custom_field1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_field2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_field3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_field4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_field5] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_field6] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_field7] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_field8] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[voucher_ext_info_deltrg]
on [dbo].[voucher_ext_info]
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
   select @errmsg = '(voucher_ext_info) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_voucher_ext_info
   (voucher_num,
    custom_field1,
    custom_field2,
    custom_field3,
    custom_field4,
    custom_field5,
    custom_field6,
    custom_field7,
    custom_field8,
    trans_id,
    resp_trans_id)
select
   d.voucher_num,
   d.custom_field1,
   d.custom_field2,
   d.custom_field3,
   d.custom_field4,
   d.custom_field5,
   d.custom_field6,
   d.custom_field7,
   d.custom_field8,
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

create trigger [dbo].[voucher_ext_info_updtrg]
on [dbo].[voucher_ext_info]
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
   raiserror ('(voucher_ext_info) The change needs to be attached with a new trans_id',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* added by Peter Lo  Sep-4-2002 */
if exists (select 1
           from master.dbo.sysprocesses
           where spid = @@spid and
                 (rtrim(program_name) = 'isql' or rtrim(program_name) = 'ctisql') )
begin
   if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0
   begin
      select @errmsg = '(voucher_ext_info) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.voucher_num = d.voucher_num )
begin
   raiserror ('(voucher_ext_info) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(voucher_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.voucher_num = d.voucher_num ) 
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(voucher_ext_info) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_voucher_ext_info
      (voucher_num,
       custom_field1,
       custom_field2,
       custom_field3,
       custom_field4,
       custom_field5,
       custom_field6,
       custom_field7,
       custom_field8,
       trans_id,
       resp_trans_id)
   select
      d.voucher_num,
      d.custom_field1,
      d.custom_field2,
      d.custom_field3,
      d.custom_field4,
      d.custom_field5,
      d.custom_field6,
      d.custom_field7,
      d.custom_field8,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.voucher_num = i.voucher_num
 
/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[voucher_ext_info] ADD CONSTRAINT [voucher_ext_info_pk] PRIMARY KEY CLUSTERED  ([voucher_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[voucher_ext_info] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[voucher_ext_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[voucher_ext_info] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[voucher_ext_info] TO [next_usr]
GO
