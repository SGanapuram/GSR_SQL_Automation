CREATE TABLE [dbo].[lic_tax_implication]
(
[license_num] [int] NOT NULL,
[license_covers_num] [int] NOT NULL,
[tax_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tax_exempt_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tax_rate_discount] [float] NULL,
[product_usage_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[lic_tax_implication_deltrg]
on [dbo].[lic_tax_implication]
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
   select @errmsg = '(lic_tax_implication) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_lic_tax_implication
   (license_num,
    license_covers_num,
    tax_code,
    tax_exempt_ind,
    tax_rate_discount,
    product_usage_code,
    trans_id,
    resp_trans_id)
select
   d.license_num,
   d.license_covers_num,
   d.tax_code,
   d.tax_exempt_ind,
   d.tax_rate_discount,
   d.product_usage_code,
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

create trigger [dbo].[lic_tax_implication_updtrg]
on [dbo].[lic_tax_implication]
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
   raiserror ('(lic_tax_implication) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(lic_tax_implication) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.license_num = d.license_num and 
                 i.license_covers_num = d.license_covers_num and 
                 i.tax_code = d.tax_code )
begin
   raiserror ('(lic_tax_implication) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(license_num) or  
   update(license_covers_num) or  
   update(tax_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.license_num = d.license_num and 
                                   i.license_covers_num = d.license_covers_num and 
                                   i.tax_code = d.tax_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(lic_tax_implication) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_lic_tax_implication
      (license_num,
       license_covers_num,
       tax_code,
       tax_exempt_ind,
       tax_rate_discount,
       product_usage_code,
       trans_id,
       resp_trans_id)
   select
      d.license_num,
      d.license_covers_num,
      d.tax_code,
      d.tax_exempt_ind,
      d.tax_rate_discount,
      d.product_usage_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.license_num = i.license_num and
         d.license_covers_num = i.license_covers_num and
         d.tax_code = i.tax_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[lic_tax_implication] ADD CONSTRAINT [lic_tax_implication_pk] PRIMARY KEY CLUSTERED  ([license_num], [license_covers_num], [tax_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[lic_tax_implication] ADD CONSTRAINT [lic_tax_implication_fk1] FOREIGN KEY ([tax_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[lic_tax_implication] ADD CONSTRAINT [lic_tax_implication_fk3] FOREIGN KEY ([product_usage_code]) REFERENCES [dbo].[product_usage] ([product_usage_code])
GO
GRANT DELETE ON  [dbo].[lic_tax_implication] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[lic_tax_implication] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[lic_tax_implication] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[lic_tax_implication] TO [next_usr]
GO
