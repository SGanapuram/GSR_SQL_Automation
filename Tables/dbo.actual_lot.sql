CREATE TABLE [dbo].[actual_lot]
(
[actual_lot_num] [int] NOT NULL,
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[ai_est_actual_num] [smallint] NOT NULL,
[source_alloc_num] [int] NOT NULL,
[source_alloc_item_num] [smallint] NOT NULL,
[source_ai_est_actual_num] [smallint] NOT NULL,
[gross_qty] [numeric] (20, 8) NULL,
[net_qty] [numeric] (20, 8) NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[secondary_gross_qty] [numeric] (20, 8) NULL,
[secondary_net_qty] [numeric] (20, 8) NULL,
[secondary_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_num] [int] NULL,
[tax_qualification_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lot_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[source_actual_lot_num] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[actual_lot_deltrg]
on [dbo].[actual_lot]
for delete
as
declare @num_rows   int,
        @errmsg     varchar(255),
        @atrans_id  int

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
   select @errmsg = '(actual_lot) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_actual_lot
   (actual_lot_num, 
    alloc_num,
    alloc_item_num,
    ai_est_actual_num,
    source_alloc_num,
    source_alloc_item_num,
    source_ai_est_actual_num,
    gross_qty,
    net_qty,
    qty_uom_code,
    secondary_gross_qty,
    secondary_net_qty,
    secondary_qty_uom_code,
    inv_num,
    tax_qualification_code,
    lot_type,
    source_actual_lot_num,
    trans_id,
    resp_trans_id)
select
   d.actual_lot_num, 
   d.alloc_num,
   d.alloc_item_num,
   d.ai_est_actual_num,
   d.source_alloc_num,
   d.source_alloc_item_num,
   d.source_ai_est_actual_num,
   d.gross_qty,
   d.net_qty,
   d.qty_uom_code,
   d.secondary_gross_qty,
   d.secondary_net_qty,
   d.secondary_qty_uom_code,
   d.inv_num,
   d.tax_qualification_code,
   d.lot_type,
   d.source_actual_lot_num,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'ActualLot',
       'DIRECT',
       convert(varchar(40),d.actual_lot_num),
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

create trigger [dbo].[actual_lot_instrg]
on [dbo].[actual_lot]
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
       'ActualLot',
       'DIRECT',
       convert(varchar(40),actual_lot_num),
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

create trigger [dbo].[actual_lot_updtrg]
on [dbo].[actual_lot]
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
   raiserror ('(actual_lot) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(actual_lot) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.actual_lot_num = d.actual_lot_num)
begin
   raiserror ('(actual_lot) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(actual_lot_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.actual_lot_num = d.actual_lot_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(actual_lot) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_actual_lot
      (actual_lot_num, 
       alloc_num,
       alloc_item_num,
       ai_est_actual_num,
       source_alloc_num,
       source_alloc_item_num,
       source_ai_est_actual_num,
       gross_qty,
       net_qty,
       qty_uom_code,
       secondary_gross_qty,
       secondary_net_qty,
       secondary_qty_uom_code,
       inv_num,
       tax_qualification_code,
       lot_type,
       source_actual_lot_num,
       trans_id,
       resp_trans_id
      )
   select
      d.actual_lot_num, 
      d.alloc_num,
      d.alloc_item_num,
      d.ai_est_actual_num,
      d.source_alloc_num,
      d.source_alloc_item_num,
      d.source_ai_est_actual_num,
      d.gross_qty,
      d.net_qty,
      d.qty_uom_code,
      d.secondary_gross_qty,
      d.secondary_net_qty,
      d.secondary_qty_uom_code,
      d.inv_num,
      d.tax_qualification_code,
      d.lot_type,
      d.source_actual_lot_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.actual_lot_num = i.actual_lot_num 

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'ActualLot',
       'DIRECT',
       convert(varchar(40),actual_lot_num),
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
ALTER TABLE [dbo].[actual_lot] ADD CONSTRAINT [actual_lot_pk] PRIMARY KEY CLUSTERED  ([actual_lot_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [actual_lot_idx2] ON [dbo].[actual_lot] ([alloc_num], [alloc_item_num], [ai_est_actual_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [actual_lot_idx3] ON [dbo].[actual_lot] ([source_alloc_num], [source_alloc_item_num], [source_ai_est_actual_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[actual_lot] ADD CONSTRAINT [actual_lot_fk3] FOREIGN KEY ([qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[actual_lot] ADD CONSTRAINT [actual_lot_fk4] FOREIGN KEY ([secondary_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[actual_lot] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[actual_lot] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[actual_lot] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[actual_lot] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'actual_lot', NULL, NULL
GO
