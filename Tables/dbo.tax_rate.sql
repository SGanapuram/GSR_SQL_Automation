CREATE TABLE [dbo].[tax_rate]
(
[tax_rate_num] [int] NOT NULL,
[tax_num] [int] NOT NULL,
[product_usage_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tax_rate_eff_date] [datetime] NOT NULL,
[tax_rate_exp_date] [datetime] NULL,
[taxable_lower_range] [float] NULL,
[taxable_upper_range] [float] NULL,
[tax_rate_amt] [float] NULL,
[pass_thru_tax_rate] [float] NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[tax_rate_deltrg]
on [dbo].[tax_rate]
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
   select @errmsg = '(tax_rate) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_tax_rate
   (tax_rate_num,
    tax_num,
    product_usage_code,
    tax_rate_eff_date,
    tax_rate_exp_date,
    taxable_lower_range,
    taxable_upper_range,
    tax_rate_amt,
    pass_thru_tax_rate,
    loc_code,
    trans_id,
    resp_trans_id)
select
   d.tax_rate_num,
   d.tax_num,
   d.product_usage_code,
   d.tax_rate_eff_date,
   d.tax_rate_exp_date,
   d.taxable_lower_range,
   d.taxable_upper_range,
   d.tax_rate_amt,
   d.pass_thru_tax_rate,
   d.loc_code,
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

create trigger [dbo].[tax_rate_updtrg]
on [dbo].[tax_rate]
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
   raiserror ('(tax_rate) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(tax_rate) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.tax_rate_num = d.tax_rate_num )
begin
   raiserror ('(tax_rate) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(tax_rate_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.tax_rate_num = d.tax_rate_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(tax_rate) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_tax_rate
      (tax_rate_num,
       tax_num,
       product_usage_code,
       tax_rate_eff_date,
       tax_rate_exp_date,
       taxable_lower_range,
       taxable_upper_range,
       tax_rate_amt,
       pass_thru_tax_rate,
       loc_code,
       trans_id,
       resp_trans_id)
   select
      d.tax_rate_num,
      d.tax_num,
      d.product_usage_code,
      d.tax_rate_eff_date,
      d.tax_rate_exp_date,
      d.taxable_lower_range,
      d.taxable_upper_range,
      d.tax_rate_amt,
      d.pass_thru_tax_rate,
      d.loc_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.tax_rate_num = i.tax_rate_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[tax_rate] ADD CONSTRAINT [tax_rate_pk] PRIMARY KEY CLUSTERED  ([tax_rate_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tax_rate] ADD CONSTRAINT [tax_rate_fk1] FOREIGN KEY ([loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[tax_rate] ADD CONSTRAINT [tax_rate_fk2] FOREIGN KEY ([product_usage_code]) REFERENCES [dbo].[product_usage] ([product_usage_code])
GO
GRANT DELETE ON  [dbo].[tax_rate] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tax_rate] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tax_rate] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tax_rate] TO [next_usr]
GO
