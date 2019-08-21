CREATE TABLE [dbo].[allocation_item_vat]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [int] NOT NULL,
[origin_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[title_transfer_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[destination_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[vat_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[booking_comp_vat_number_id] [int] NULL,
[booking_comp_fiscal_rep] [int] NULL,
[counterparty_vat_number_id] [int] NULL,
[counterparty_fiscal_rep] [int] NULL,
[vat_trans_nature_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[vat_declaration_id] [int] NULL,
[cmdty_nomenclature_id] [int] NULL,
[aad] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[warehouse_permit_holder] [int] NULL,
[wph_vat_number_id] [int] NULL,
[vat_type_code] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[excise_num] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ready_for_accounting_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[vat_applies_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[warehouse_permit_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[excise_number_id] [int] NULL,
[tank_num] [int] NULL,
[wph_excise_num] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[allocation_item_vat_deltrg]
on [dbo].[allocation_item_vat]
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
   select @errmsg = '(allocation_item_vat) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_allocation_item_vat
   (alloc_num, 
    alloc_item_num,
    origin_country_code, 
    title_transfer_country_code, 
    destination_country_code, 
    vat_country_code, 
    booking_comp_vat_number_id,     
    booking_comp_fiscal_rep,     
    counterparty_vat_number_id,     
    counterparty_fiscal_rep,     
    vat_trans_nature_code, 
    vat_declaration_id,     
    cmdty_nomenclature_id,     
    aad,
    warehouse_permit_holder,     
    wph_vat_number_id,    
    vat_type_code,
    excise_num,
    ready_for_accounting_ind,
    vat_applies_ind,
    warehouse_permit_loc_code,
    excise_number_id,
    tank_num,
    wph_excise_num,
    trans_id,
    resp_trans_id)
select
   d.alloc_num, 
   d.alloc_item_num,
   d.origin_country_code, 
   d.title_transfer_country_code, 
   d.destination_country_code, 
   d.vat_country_code, 
   d.booking_comp_vat_number_id,     
   d.booking_comp_fiscal_rep,     
   d.counterparty_vat_number_id,     
   d.counterparty_fiscal_rep,     
   d.vat_trans_nature_code, 
   d.vat_declaration_id,     
   d.cmdty_nomenclature_id,     
   d.aad,
   d.warehouse_permit_holder,     
   d.wph_vat_number_id,    
   d.vat_type_code,
   d.excise_num,
   d.ready_for_accounting_ind,
   d.vat_applies_ind,
   d.warehouse_permit_loc_code,
   d.excise_number_id,
   d.tank_num,
   d.wph_excise_num,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'AllocationItemVat',
       'DIRECT',
       convert(varchar(40), d.alloc_num),
       convert(varchar(40), d.alloc_item_num),
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

create trigger [dbo].[allocation_item_vat_instrg]
on [dbo].[allocation_item_vat]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

   /* BEGIN_TRANSACTION_TOUCH */
   insert dbo.transaction_touch
   select 'INSERT',
          'AllocationItemVat',
          'DIRECT',
          convert(varchar(40), i.alloc_num),
          convert(varchar(40), i.alloc_item_num),
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

create trigger [dbo].[allocation_item_vat_updtrg]
on [dbo].[allocation_item_vat]
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
   raiserror ('(allocation_item_vat) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(allocation_item_vat) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.alloc_num = d.alloc_num and
                 i.alloc_item_num = d.alloc_item_num ) 
begin
   raiserror ('(allocation_item_vat) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(alloc_num) or
   update(alloc_item_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.alloc_num = d.alloc_num and
                                   i.alloc_item_num = d.alloc_item_num ) 
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(allocation_item_vat) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_allocation_item_vat
      (alloc_num, 
       alloc_item_num,
       origin_country_code, 
       title_transfer_country_code, 
       destination_country_code, 
       vat_country_code, 
       booking_comp_vat_number_id,     
       booking_comp_fiscal_rep,     
       counterparty_vat_number_id,     
       counterparty_fiscal_rep,     
       vat_trans_nature_code, 
       vat_declaration_id,     
       cmdty_nomenclature_id,     
       aad,
       warehouse_permit_holder,     
       wph_vat_number_id,    
       vat_type_code,
       excise_num,
       ready_for_accounting_ind,
       vat_applies_ind,
       warehouse_permit_loc_code,
       excise_number_id,
       tank_num,
       wph_excise_num,
       trans_id,
       resp_trans_id)
   select
      d.alloc_num, 
      d.alloc_item_num,
      d.origin_country_code, 
      d.title_transfer_country_code, 
      d.destination_country_code, 
      d.vat_country_code, 
      d.booking_comp_vat_number_id,     
      d.booking_comp_fiscal_rep,     
      d.counterparty_vat_number_id,     
      d.counterparty_fiscal_rep,     
      d.vat_trans_nature_code, 
      d.vat_declaration_id,     
      d.cmdty_nomenclature_id,     
      d.aad,
      d.warehouse_permit_holder,     
      d.wph_vat_number_id,    
      d.vat_type_code,
      d.excise_num,
      d.ready_for_accounting_ind,
      d.vat_applies_ind,
      d.warehouse_permit_loc_code,
      d.excise_number_id,
      d.tank_num,
      d.wph_excise_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.alloc_num = i.alloc_num and
         d.alloc_item_num = i.alloc_item_num

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'AllocationItemVat',
       'DIRECT',
       convert(varchar(40), i.alloc_num),
       convert(varchar(40), i.alloc_item_num),
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
ALTER TABLE [dbo].[allocation_item_vat] ADD CONSTRAINT [allocation_item_vat_pk] PRIMARY KEY CLUSTERED  ([alloc_num], [alloc_item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[allocation_item_vat] ADD CONSTRAINT [allocation_item_vat_fk10] FOREIGN KEY ([vat_trans_nature_code]) REFERENCES [dbo].[vat_trans_nature] ([trans_nature_code])
GO
ALTER TABLE [dbo].[allocation_item_vat] ADD CONSTRAINT [allocation_item_vat_fk11] FOREIGN KEY ([vat_declaration_id]) REFERENCES [dbo].[vat_declaration] ([vat_declaration_id])
GO
ALTER TABLE [dbo].[allocation_item_vat] ADD CONSTRAINT [allocation_item_vat_fk12] FOREIGN KEY ([cmdty_nomenclature_id]) REFERENCES [dbo].[cmdty_nomenclature] ([cmdty_nomenclature_id])
GO
ALTER TABLE [dbo].[allocation_item_vat] ADD CONSTRAINT [allocation_item_vat_fk13] FOREIGN KEY ([wph_vat_number_id]) REFERENCES [dbo].[acct_vat_number] ([acct_vat_num])
GO
ALTER TABLE [dbo].[allocation_item_vat] ADD CONSTRAINT [allocation_item_vat_fk14] FOREIGN KEY ([warehouse_permit_holder]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[allocation_item_vat] ADD CONSTRAINT [allocation_item_vat_fk15] FOREIGN KEY ([vat_type_code]) REFERENCES [dbo].[vat_type] ([vat_type_code])
GO
ALTER TABLE [dbo].[allocation_item_vat] ADD CONSTRAINT [allocation_item_vat_fk16] FOREIGN KEY ([warehouse_permit_loc_code]) REFERENCES [dbo].[location_ext_info] ([loc_code])
GO
ALTER TABLE [dbo].[allocation_item_vat] ADD CONSTRAINT [allocation_item_vat_fk17] FOREIGN KEY ([excise_number_id]) REFERENCES [dbo].[acct_vat_number] ([acct_vat_num])
GO
ALTER TABLE [dbo].[allocation_item_vat] ADD CONSTRAINT [allocation_item_vat_fk18] FOREIGN KEY ([tank_num]) REFERENCES [dbo].[location_tank_info] ([tank_num])
GO
ALTER TABLE [dbo].[allocation_item_vat] ADD CONSTRAINT [allocation_item_vat_fk2] FOREIGN KEY ([origin_country_code]) REFERENCES [dbo].[country] ([country_code])
GO
ALTER TABLE [dbo].[allocation_item_vat] ADD CONSTRAINT [allocation_item_vat_fk3] FOREIGN KEY ([title_transfer_country_code]) REFERENCES [dbo].[country] ([country_code])
GO
ALTER TABLE [dbo].[allocation_item_vat] ADD CONSTRAINT [allocation_item_vat_fk4] FOREIGN KEY ([destination_country_code]) REFERENCES [dbo].[country] ([country_code])
GO
ALTER TABLE [dbo].[allocation_item_vat] ADD CONSTRAINT [allocation_item_vat_fk5] FOREIGN KEY ([vat_country_code]) REFERENCES [dbo].[country] ([country_code])
GO
ALTER TABLE [dbo].[allocation_item_vat] ADD CONSTRAINT [allocation_item_vat_fk6] FOREIGN KEY ([booking_comp_vat_number_id]) REFERENCES [dbo].[acct_vat_number] ([acct_vat_num])
GO
ALTER TABLE [dbo].[allocation_item_vat] ADD CONSTRAINT [allocation_item_vat_fk7] FOREIGN KEY ([booking_comp_fiscal_rep]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[allocation_item_vat] ADD CONSTRAINT [allocation_item_vat_fk8] FOREIGN KEY ([counterparty_vat_number_id]) REFERENCES [dbo].[acct_vat_number] ([acct_vat_num])
GO
ALTER TABLE [dbo].[allocation_item_vat] ADD CONSTRAINT [allocation_item_vat_fk9] FOREIGN KEY ([counterparty_fiscal_rep]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[allocation_item_vat] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[allocation_item_vat] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[allocation_item_vat] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[allocation_item_vat] TO [next_usr]
GO
