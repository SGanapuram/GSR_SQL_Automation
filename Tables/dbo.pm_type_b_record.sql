CREATE TABLE [dbo].[pm_type_b_record]
(
[fdd_id] [int] NOT NULL,
[company_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[splc_code] [char] (9) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[terminal_ctrl_num] [char] (9) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bol_number] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[exch_sale_party] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[auth_num] [char] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[comp_prod_code] [char] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fin_prod_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[gross_qty] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[gross_credit_sign] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[net_qty_temp_gravity] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[net_credit_sign] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[blnd_or_alt_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[measurement_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[temp_net_qty_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[unit_price] [char] (9) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[currency] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[billed_qty] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[billed_credit_sign] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[parcel_oid] [int] NULL,
[shipment_oid] [int] NULL,
[trans_id] [int] NOT NULL,
[type_a_record_id] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[pm_type_b_record_deltrg]
on [dbo].[pm_type_b_record]
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
   select @errmsg = '(pm_type_b_record) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_pm_type_b_record
(  
fdd_id,
company_code,
splc_code,
terminal_ctrl_num,
bol_number,
exch_sale_party,
auth_num,
comp_prod_code,
fin_prod_code,
gross_qty,
gross_credit_sign,
net_qty_temp_gravity,
net_credit_sign,
blnd_or_alt_ind,
measurement_type,
temp_net_qty_flag,
unit_price,
currency,
billed_qty,
billed_credit_sign,
parcel_oid,
shipment_oid,
type_a_record_id,
trans_id,
resp_trans_id
)
select
d.fdd_id,
d.company_code,
d.splc_code,
d.terminal_ctrl_num,
d.bol_number,
d.exch_sale_party,
d.auth_num,
d.comp_prod_code,
d.fin_prod_code,
d.gross_qty,
d.gross_credit_sign,
d.net_qty_temp_gravity,
d.net_credit_sign,
d.blnd_or_alt_ind,
d.measurement_type,
d.temp_net_qty_flag,
d.unit_price,
d.currency,
d.billed_qty,
d.billed_credit_sign,
d.parcel_oid,
d.shipment_oid,
d.type_a_record_id,
d.trans_id,
@atrans_id
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),             
        @the_entity_name    varchar(30)      
      
   select @the_entity_name = 'PmTypeBRecord'      
      
   if @num_rows = 1      
   begin      
      select @the_sequence = it.sequence      
      from dbo.icts_transaction it WITH (NOLOCK),      
           inserted i      
      where it.trans_id = i.trans_id      
      
      
      /* BEGIN_TRANSACTION_TOUCH */      
      
      insert dbo.transaction_touch      
      select 'INSERT',      
             @the_entity_name,      
             'DIRECT',      
             convert(varchar(40),fdd_id),      
             null,      
             null,      
             null,      
             null,      
             null,      
             null,      
             null,      
             i.trans_id,      
             @the_sequence      
      from inserted i      
      
      /* END_TRANSACTION_TOUCH */      
   end      
   else      
   begin  /* if @num_rows > 1 */      
           
      /* BEGIN_TRANSACTION_TOUCH */      
      
      insert dbo.transaction_touch      
      select 'INSERT',      
             @the_entity_name,      
             'DIRECT',      
             convert(varchar(40),fdd_id),      
             null,      
             null,      
             null,      
             null,      
             null,      
             null,      
             null,      
             i.trans_id,      
             it.sequence      
      from dbo.icts_transaction it WITH (NOLOCK),      
           inserted i      
      where i.trans_id = it.trans_id      
      
      /* END_TRANSACTION_TOUCH */      
   end      
      
return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[pm_type_b_record_instrg]  
on [dbo].[pm_type_b_record]  
for insert  
as  
declare @num_rows       int,  
        @count_num_rows int,  
        @errmsg         varchar(255)  
  
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  
  
declare @the_sequence       numeric(32, 0),  
        @the_tran_type      char(1),  
        @errcode            int,  
        @num_touch_rows     int,  
        @the_entity_name    varchar(30)  
  
   select @the_entity_name = 'PmTypeBRecord'  
   select @errcode = 0,  
          @num_touch_rows = 0  
  
   if @num_rows = 1  
   begin  
      select @the_tran_type = it.type,  
             @the_sequence = it.sequence  
      from dbo.icts_transaction it WITH (NOLOCK),  
           inserted i  
      where it.trans_id = i.trans_id  
  

         /* BEGIN_TRANSACTION_TOUCH */  
  
         insert dbo.transaction_touch  
         select 'INSERT',  
                @the_entity_name,  
                'DIRECT',  
                convert(varchar(40),fdd_id),  
                null,  
                null,  
                null,  
                null,  
                null,  
                null,  
                null,  
                i.trans_id,  
                @the_sequence  
         from inserted i  
         select @num_touch_rows = @@rowcount,  
                @errcode = @@error  
   end  
   else  
   begin  /* if @num_rows > 1 */  

      insert dbo.transaction_touch  
      select 'INSERT',  
             @the_entity_name,  
             'DIRECT',  
             convert(varchar(40),fdd_id),  
             null,  
             null,  
             null,  
             null,  
             null,  
             null,  
             null,  
             i.trans_id,  
             it.sequence  
      from dbo.icts_transaction it WITH (NOLOCK),  
           inserted i  
      where i.trans_id = it.trans_id

      /* END_TRANSACTION_TOUCH */  
   end  
  
return  
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[pm_type_b_record_updtrg]
on [dbo].[pm_type_b_record]
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
   raiserror ('(pm_type_b_record) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(pm_type_b_record) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.fdd_id = d.fdd_id)
begin
   select @errmsg = '(pm_type_b_record) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.fdd_id) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(fdd_id)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.fdd_id = d.fdd_id)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(pm_type_b_record) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
insert dbo.aud_pm_type_b_record
(
fdd_id,
company_code,
splc_code,
terminal_ctrl_num,
bol_number,
exch_sale_party,
auth_num,
comp_prod_code,
fin_prod_code,
gross_qty,
gross_credit_sign,
net_qty_temp_gravity,
net_credit_sign,
blnd_or_alt_ind,
measurement_type,
temp_net_qty_flag,
unit_price,
currency,
billed_qty,
billed_credit_sign,
parcel_oid,
shipment_oid,
type_a_record_id,
trans_id,
resp_trans_id
)
select
d.fdd_id,
d.company_code,
d.splc_code,
d.terminal_ctrl_num,
d.bol_number,
d.exch_sale_party,
d.auth_num,
d.comp_prod_code,
d.fin_prod_code,
d.gross_qty,
d.gross_credit_sign,
d.net_qty_temp_gravity,
d.net_credit_sign,
d.blnd_or_alt_ind,
d.measurement_type,
d.temp_net_qty_flag,
d.unit_price,
d.currency,
d.billed_qty,
d.billed_credit_sign,
d.parcel_oid,
d.shipment_oid,
d.type_a_record_id,
d.trans_id,
i.trans_id
from deleted d, inserted i
where d.fdd_id = i.fdd_id 

declare @the_sequence       numeric(32, 0),
        @the_entity_name    varchar(30)
      
   select @the_entity_name = 'PmTypeBRecord'
      
   if @num_rows = 1
   begin
      select @the_sequence = it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where it.trans_id = i.trans_id
      
      
      /* BEGIN_TRANSACTION_TOUCH */      
      
      insert dbo.transaction_touch      
      select 'UPDATE',      
             @the_entity_name,      
             'DIRECT',      
             convert(varchar(40),fdd_id),      
             null,      
             null,      
             null,      
             null,      
             null,      
             null,      
             null,      
             i.trans_id,      
             @the_sequence      
      from inserted i      
      
      /* END_TRANSACTION_TOUCH */      
   end      
   else      
   begin  /* if @num_rows > 1 */      
           
      /* BEGIN_TRANSACTION_TOUCH */      
      
      insert dbo.transaction_touch      
      select 'UPDATE',      
             @the_entity_name,      
             'DIRECT',      
             convert(varchar(40),fdd_id),      
             null,      
             null,      
             null,      
             null,      
             null,      
             null,      
             null,      
             i.trans_id,      
             it.sequence      
      from dbo.icts_transaction it WITH (NOLOCK),      
           inserted i      
      where i.trans_id = it.trans_id      
      
      /* END_TRANSACTION_TOUCH */      
   end      
      
return
GO
ALTER TABLE [dbo].[pm_type_b_record] ADD CONSTRAINT [pm_type_b_record_pk] PRIMARY KEY CLUSTERED  ([fdd_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pm_type_b_record_idx1] ON [dbo].[pm_type_b_record] ([company_code], [comp_prod_code], [splc_code], [bol_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pm_type_b_record_idx2] ON [dbo].[pm_type_b_record] ([trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pm_type_b_record] ADD CONSTRAINT [pm_type_b_record_fk1] FOREIGN KEY ([fdd_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
ALTER TABLE [dbo].[pm_type_b_record] ADD CONSTRAINT [pm_type_b_record_fk2] FOREIGN KEY ([parcel_oid]) REFERENCES [dbo].[parcel] ([oid])
GO
ALTER TABLE [dbo].[pm_type_b_record] ADD CONSTRAINT [pm_type_b_record_fk3] FOREIGN KEY ([shipment_oid]) REFERENCES [dbo].[shipment] ([oid])
GO
ALTER TABLE [dbo].[pm_type_b_record] ADD CONSTRAINT [pm_type_b_record_fk4] FOREIGN KEY ([type_a_record_id]) REFERENCES [dbo].[pm_type_a_record] ([fdd_id])
GO
GRANT DELETE ON  [dbo].[pm_type_b_record] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[pm_type_b_record] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[pm_type_b_record] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[pm_type_b_record] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'pm_type_b_record', NULL, NULL
GO
