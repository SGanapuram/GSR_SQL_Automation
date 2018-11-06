CREATE TABLE [dbo].[tax]
(
[tax_num] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tax_authority_num] [int] NOT NULL,
[tax_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tax_calc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tax_gross_net_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tax_flat_fee_basis] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tax_tiered_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tax_range_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tax_rate_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tax_rate_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tax_eff_date] [datetime] NULL,
[tax_exp_date] [datetime] NULL,
[order_type_group] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_type_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[override_exemptions_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tax_exports_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[use_additional_primary_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[override_pass_through_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[tax_deltrg]
on [dbo].[tax]
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
   select @errmsg = '(tax) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_tax
   (tax_num,
    cmdty_code,
    tax_authority_num,
    tax_code,
    tax_calc_ind,
    tax_gross_net_ind,
    tax_flat_fee_basis,
    tax_tiered_ind,
    tax_range_uom_code,
    tax_rate_uom_code,
    tax_rate_curr_code,
    tax_eff_date,
    tax_exp_date,
    order_type_group,
    mot_type_code,
    override_exemptions_ind,
    tax_exports_ind,
    use_additional_primary_ind,
    override_pass_through_ind,
    trans_id,
    resp_trans_id)
select
   d.tax_num,
   d.cmdty_code,
   d.tax_authority_num,
   d.tax_code,
   d.tax_calc_ind,
   d.tax_gross_net_ind,
   d.tax_flat_fee_basis,
   d.tax_tiered_ind,
   d.tax_range_uom_code,
   d.tax_rate_uom_code,
   d.tax_rate_curr_code,
   d.tax_eff_date,
   d.tax_exp_date,
   d.order_type_group,
   d.mot_type_code,
   d.override_exemptions_ind,
   d.tax_exports_ind,
   d.use_additional_primary_ind,
   d.override_pass_through_ind,
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

create trigger [dbo].[tax_updtrg]
on [dbo].[tax]
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
   raiserror ('(tax) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(tax) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.tax_num = d.tax_num )
begin
   raiserror ('(tax) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(tax_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.tax_num = d.tax_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(tax) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_tax
      (tax_num,
       cmdty_code,
       tax_authority_num,
       tax_code,
       tax_calc_ind,
       tax_gross_net_ind,
       tax_flat_fee_basis,
       tax_tiered_ind,
       tax_range_uom_code,
       tax_rate_uom_code,
       tax_rate_curr_code,
       tax_eff_date,
       tax_exp_date,
       order_type_group,
       mot_type_code,
       override_exemptions_ind,
       tax_exports_ind,
       use_additional_primary_ind,
       override_pass_through_ind,
       trans_id,
       resp_trans_id)
   select
      d.tax_num,
      d.cmdty_code,
      d.tax_authority_num,
      d.tax_code,
      d.tax_calc_ind,
      d.tax_gross_net_ind,
      d.tax_flat_fee_basis,
      d.tax_tiered_ind,
      d.tax_range_uom_code,
      d.tax_rate_uom_code,
      d.tax_rate_curr_code,
      d.tax_eff_date,
      d.tax_exp_date,
      d.order_type_group,
      d.mot_type_code,
      d.override_exemptions_ind,
      d.tax_exports_ind,
      d.use_additional_primary_ind,
      d.override_pass_through_ind,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.tax_num = i.tax_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[tax] ADD CONSTRAINT [tax_pk] PRIMARY KEY CLUSTERED  ([tax_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tax] ADD CONSTRAINT [tax_fk1] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[tax] ADD CONSTRAINT [tax_fk2] FOREIGN KEY ([tax_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[tax] ADD CONSTRAINT [tax_fk3] FOREIGN KEY ([tax_rate_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[tax] ADD CONSTRAINT [tax_fk4] FOREIGN KEY ([mot_type_code]) REFERENCES [dbo].[mot_type] ([mot_type_code])
GO
ALTER TABLE [dbo].[tax] ADD CONSTRAINT [tax_fk5] FOREIGN KEY ([order_type_group]) REFERENCES [dbo].[order_type_grp_desc] ([order_type_group])
GO
ALTER TABLE [dbo].[tax] ADD CONSTRAINT [tax_fk6] FOREIGN KEY ([tax_range_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[tax] ADD CONSTRAINT [tax_fk7] FOREIGN KEY ([tax_rate_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[tax] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tax] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tax] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tax] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'tax', NULL, NULL
GO
