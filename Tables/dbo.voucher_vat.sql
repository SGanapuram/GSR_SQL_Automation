CREATE TABLE [dbo].[voucher_vat]
(
[voucher_num] [int] NOT NULL,
[tax_point] [datetime] NULL,
[belgian_inv_num] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[primary_invoice_ref_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[vat_invoice_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[duty] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[equiv_invoice_amt] [numeric] (20, 6) NULL,
[equiv_invoice_amt_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exch_rate] [numeric] (12, 6) NULL,
[exch_rate_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exposition_of_vat_calc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[voucher_vat_deltrg]
on [dbo].[voucher_vat]
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
   select @errmsg = '(voucher_vat) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_voucher_vat
   (voucher_num,   
    tax_point,
    belgian_inv_num,
    primary_invoice_ref_number,
    vat_invoice_comment,
    duty,
    equiv_invoice_amt,  
    equiv_invoice_amt_curr_code,      
    exch_rate,
    exch_rate_curr_code,   
    exposition_of_vat_calc,
    trans_id,
    resp_trans_id)
select
   d.voucher_num,
   d.tax_point,
   d.belgian_inv_num,
   d.primary_invoice_ref_number,
   d.vat_invoice_comment,
   d.duty,
   d.equiv_invoice_amt,  
   d.equiv_invoice_amt_curr_code,      
   d.exch_rate,
   d.exch_rate_curr_code,   
   d.exposition_of_vat_calc,
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

create trigger [dbo].[voucher_vat_updtrg]
on [dbo].[voucher_vat]
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
   raiserror ('(voucher_vat) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(voucher_vat) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.voucher_num = d.voucher_num ) 
begin
   raiserror ('(voucher_vat) new trans_id must not be older than current trans_id.',10,1)
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
      raiserror ('(voucher_vat) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_voucher_vat
      (voucher_num,   
       tax_point,
       belgian_inv_num,
       primary_invoice_ref_number,
       vat_invoice_comment,
       duty,
       equiv_invoice_amt,  
       equiv_invoice_amt_curr_code,      
       exch_rate,
       exch_rate_curr_code,   
       exposition_of_vat_calc,
       trans_id,
       resp_trans_id)
   select
      d.voucher_num,
      d.tax_point,
      d.belgian_inv_num,
      d.primary_invoice_ref_number,
      d.vat_invoice_comment,
      d.duty,
      d.equiv_invoice_amt,  
      d.equiv_invoice_amt_curr_code,      
      d.exch_rate,
      d.exch_rate_curr_code,   
      d.exposition_of_vat_calc,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.voucher_num = i.voucher_num

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[voucher_vat] ADD CONSTRAINT [voucher_vat_pk] PRIMARY KEY CLUSTERED  ([voucher_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[voucher_vat] ADD CONSTRAINT [voucher_vat_fk2] FOREIGN KEY ([equiv_invoice_amt_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[voucher_vat] ADD CONSTRAINT [voucher_vat_fk3] FOREIGN KEY ([exch_rate_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[voucher_vat] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[voucher_vat] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[voucher_vat] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[voucher_vat] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'voucher_vat', NULL, NULL
GO
