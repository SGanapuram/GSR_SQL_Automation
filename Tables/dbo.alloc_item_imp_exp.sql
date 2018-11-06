CREATE TABLE [dbo].[alloc_item_imp_exp]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[imp_exp_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[license_num] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[product_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[consignee] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[imp_exp_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pos_designation] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[imp_exp_qty] [decimal] (20, 8) NULL,
[imp_exp_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_type_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price] [decimal] (20, 8) NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[freight_cost] [decimal] (20, 8) NULL,
[freight_cost_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pos_county] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[preparer_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[preparer_contact_info] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[alloc_item_imp_exp_deltrg]
on [dbo].[alloc_item_imp_exp]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
        @atrans_id int

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
   select @errmsg = '(alloc_item_imp_exp) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_alloc_item_imp_exp
(  
   alloc_num,
   alloc_item_num,
   imp_exp_ind,
   license_num,
   cmdty_code,
   product_code,
   consignee,
   imp_exp_country_code,
   pos_designation,
   imp_exp_qty,
   imp_exp_qty_uom_code,
   mot_type_code,
   price,
   price_curr_code,
   price_uom_code,
   freight_cost,
   freight_cost_curr_code,
   pos_county,
   preparer_name,
   preparer_contact_info,
   trans_id,
   resp_trans_id
)
select
   d.alloc_num,
   d.alloc_item_num,
   d.imp_exp_ind,
   d.license_num,
   d.cmdty_code,
   d.product_code,
   d.consignee,
   d.imp_exp_country_code,
   d.pos_designation,
   d.imp_exp_qty,
   d.imp_exp_qty_uom_code,
   d.mot_type_code,
   d.price,
   d.price_curr_code,
   d.price_uom_code,
   d.freight_cost,
   d.freight_cost_curr_code,
   d.pos_county,
   d.preparer_name,
   d.preparer_contact_info,
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

create trigger [dbo].[alloc_item_imp_exp_updtrg]
on [dbo].[alloc_item_imp_exp]
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
   raiserror ('(alloc_item_imp_exp) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(alloc_item_imp_exp) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.alloc_num = d.alloc_num and
                 i.alloc_item_num = d.alloc_item_num)
begin
   select @errmsg = '(alloc_item_imp_exp) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.alloc_num) + ','
                               + convert(varchar, i.alloc_item_num) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(alloc_num) or
   update(alloc_item_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.alloc_num = d.alloc_num and
                                   i.alloc_item_num = d.alloc_item_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(alloc_item_imp_exp) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_alloc_item_imp_exp
      (alloc_num,
       alloc_item_num,
       imp_exp_ind,
       license_num,
       cmdty_code,
       product_code,
       consignee,
       imp_exp_country_code,
       pos_designation,
       imp_exp_qty,
       imp_exp_qty_uom_code,
       mot_type_code,
       price,
       price_curr_code,
       price_uom_code,
       freight_cost,
       freight_cost_curr_code,
       pos_county,
       preparer_name,
       preparer_contact_info,
       trans_id,
       resp_trans_id)
   select
       d.alloc_num,
       d.alloc_item_num,
       d.imp_exp_ind,
       d.license_num,
       d.cmdty_code,
       d.product_code,
       d.consignee,
       d.imp_exp_country_code,
       d.pos_designation,
       d.imp_exp_qty,
       d.imp_exp_qty_uom_code,
       d.mot_type_code,
       d.price,
       d.price_curr_code,
       d.price_uom_code,
       d.freight_cost,
       d.freight_cost_curr_code,
       d.pos_county,
       d.preparer_name,
       d.preparer_contact_info,
       d.trans_id,
       i.trans_id
   from deleted d, inserted i
   where d.alloc_num = i.alloc_num and
         d.alloc_item_num = i.alloc_item_num

return
GO
ALTER TABLE [dbo].[alloc_item_imp_exp] ADD CONSTRAINT [alloc_item_imp_exp_pk] PRIMARY KEY CLUSTERED  ([alloc_num], [alloc_item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[alloc_item_imp_exp] ADD CONSTRAINT [alloc_item_imp_exp_fk1] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[alloc_item_imp_exp] ADD CONSTRAINT [alloc_item_imp_exp_fk2] FOREIGN KEY ([product_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[alloc_item_imp_exp] ADD CONSTRAINT [alloc_item_imp_exp_fk3] FOREIGN KEY ([imp_exp_country_code]) REFERENCES [dbo].[country] ([country_code])
GO
ALTER TABLE [dbo].[alloc_item_imp_exp] ADD CONSTRAINT [alloc_item_imp_exp_fk4] FOREIGN KEY ([imp_exp_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[alloc_item_imp_exp] ADD CONSTRAINT [alloc_item_imp_exp_fk5] FOREIGN KEY ([mot_type_code]) REFERENCES [dbo].[mot_type] ([mot_type_code])
GO
ALTER TABLE [dbo].[alloc_item_imp_exp] ADD CONSTRAINT [alloc_item_imp_exp_fk6] FOREIGN KEY ([price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[alloc_item_imp_exp] ADD CONSTRAINT [alloc_item_imp_exp_fk7] FOREIGN KEY ([price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[alloc_item_imp_exp] ADD CONSTRAINT [alloc_item_imp_exp_fk8] FOREIGN KEY ([freight_cost_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[alloc_item_imp_exp] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[alloc_item_imp_exp] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[alloc_item_imp_exp] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[alloc_item_imp_exp] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'alloc_item_imp_exp', NULL, NULL
GO
