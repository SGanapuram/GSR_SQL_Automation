CREATE TABLE [dbo].[custom_voucher_range]
(
[oid] [int] NOT NULL,
[booking_comp_num] [int] NULL,
[initial_pay_receive_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[year] [smallint] NULL,
[ps_group_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prefix_string] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_num] [int] NOT NULL CONSTRAINT [df_custom_voucher_range_last_num] DEFAULT ((0)),
[max_num] [int] NOT NULL CONSTRAINT [df_custom_voucher_range_max_num] DEFAULT ((0)),
[trans_id] [int] NOT NULL,
[vat_country_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[invoice_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[reset_date] [datetime] NULL,
[reset_to_year] [smallint] NULL,
[reset_to_num] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[custom_voucher_range_deltrg]
on [dbo].[custom_voucher_range]
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
   select @errmsg = '(custom_voucher_range) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_custom_voucher_range
   (oid,
    booking_comp_num,
    initial_pay_receive_ind,
    year,
    ps_group_code,
    prefix_string,
    last_num,
    max_num,
    vat_country_code,
    invoice_type,
    reset_date,
    reset_to_year,
    reset_to_num,
    trans_id,
    resp_trans_id)
select
   d.oid,
   d.booking_comp_num,
   d.initial_pay_receive_ind,
   d.year,
   d.ps_group_code,
   d.prefix_string,
   d.last_num,
   d.max_num,
   d.vat_country_code,
   d.invoice_type,
   d.reset_date,
   d.reset_to_year,
   d.reset_to_num,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */


/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'CustomVoucherRange',
       'DIRECT',
       convert(varchar(40), d.oid),
       null,
       null,
       null,
       null,
       null,
       null,
       null,
       @atrans_id,
       it.sequence
from deleted d, dbo.icts_transaction it
where it.trans_id = @atrans_id and
      it.type != 'E'

/* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[custom_voucher_range_instrg]
on [dbo].[custom_voucher_range]
for insert
as
declare @num_rows        int,
        @count_num_rows  int,
        @errmsg          varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'INSERT',
       'CustomVoucherRange',
       'DIRECT',
       convert(varchar(40), i.oid),
       null,
       null,
       null,
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from inserted i, dbo.icts_transaction it
where i.trans_id = it.trans_id and
      it.type != 'E'

/* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[custom_voucher_range_updtrg]
on [dbo].[custom_voucher_range]
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
   raiserror ('(custom_voucher_range) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(custom_voucher_range) New trans_id must be larger than original trans_id.'
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
   select @errmsg = '(custom_voucher_range) new trans_id must not be older than current trans_id.'   
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
      raiserror ('(custom_voucher_range) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_custom_voucher_range
      (oid,
       booking_comp_num,
       initial_pay_receive_ind,
       year,
       ps_group_code,
       prefix_string,
       last_num,
       max_num,
       vat_country_code,
       invoice_type,
       reset_date,
       reset_to_year,
       reset_to_num,
       trans_id,
       resp_trans_id)
   select
      d.oid,
      d.booking_comp_num,
      d.initial_pay_receive_ind,
      d.year,
      d.ps_group_code,
      d.prefix_string,
      d.last_num,
      d.max_num,
      d.vat_country_code,
      d.invoice_type,
      d.reset_date,
      d.reset_to_year,
      d.reset_to_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'CustomVoucherRange',
       'DIRECT',
       convert(varchar(40), i.oid),
       null,
       null,
       null,
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from inserted i, dbo.icts_transaction it
where i.trans_id = it.trans_id and
      it.type != 'E'

/* END_TRANSACTION_TOUCH */

return
GO
ALTER TABLE [dbo].[custom_voucher_range] ADD CONSTRAINT [custom_voucher_range_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [custom_voucher_range_idx1] ON [dbo].[custom_voucher_range] ([booking_comp_num], [initial_pay_receive_ind], [year], [ps_group_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[custom_voucher_range] ADD CONSTRAINT [custom_voucher_range_fk1] FOREIGN KEY ([booking_comp_num]) REFERENCES [dbo].[booking_company_info] ([acct_num])
GO
ALTER TABLE [dbo].[custom_voucher_range] ADD CONSTRAINT [custom_voucher_range_fk2] FOREIGN KEY ([ps_group_code]) REFERENCES [dbo].[ps_group_code_ref] ([purchase_sale_group_code])
GO
GRANT DELETE ON  [dbo].[custom_voucher_range] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[custom_voucher_range] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[custom_voucher_range] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[custom_voucher_range] TO [next_usr]
GO
