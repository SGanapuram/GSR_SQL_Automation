CREATE TABLE [dbo].[exch_fifo_alloc_item]
(
[exch_fifo_alloc_num] [int] NOT NULL,
[exch_fifo_alloc_item_num] [smallint] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alloc_qty] [numeric] (20, 8) NOT NULL,
[alloc_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fill_num] [smallint] NULL,
[ledger_date] [datetime] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[exch_fifo_alloc_item_deltrg]
on [dbo].[exch_fifo_alloc_item]
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
   select @errmsg = '(exch_fifo_alloc_item) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_exch_fifo_alloc_item
   (exch_fifo_alloc_num,
    exch_fifo_alloc_item_num,
    trade_num,
    order_num,
    item_num,
    p_s_ind,
    alloc_qty,
    alloc_qty_uom_code,
    fill_num,
    ledger_date,
    trans_id,
    resp_trans_id)
select
   d.exch_fifo_alloc_num,
   d.exch_fifo_alloc_item_num,
   d.trade_num,
   d.order_num,
   d.item_num,
   d.p_s_ind,
   d.alloc_qty,
   d.alloc_qty_uom_code,
   d.fill_num,
   d.ledger_date,
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

create trigger [dbo].[exch_fifo_alloc_item_updtrg]
on [dbo].[exch_fifo_alloc_item]
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
   raiserror ('(exch_fifo_alloc_item) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(exch_fifo_alloc_item) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.exch_fifo_alloc_num = d.exch_fifo_alloc_num and 
                 i.exch_fifo_alloc_item_num = d.exch_fifo_alloc_item_num )
begin
   raiserror ('(exch_fifo_alloc_item) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(exch_fifo_alloc_num) or  
   update(exch_fifo_alloc_item_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.exch_fifo_alloc_num = d.exch_fifo_alloc_num and 
                                   i.exch_fifo_alloc_item_num = d.exch_fifo_alloc_item_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(exch_fifo_alloc_item) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_exch_fifo_alloc_item
      (exch_fifo_alloc_num,
       exch_fifo_alloc_item_num,
       trade_num,
       order_num,
       item_num,
       p_s_ind,
       alloc_qty,
       alloc_qty_uom_code,
       fill_num,
       ledger_date,
       trans_id,
       resp_trans_id)
   select
      d.exch_fifo_alloc_num,
      d.exch_fifo_alloc_item_num,
      d.trade_num,
      d.order_num,
      d.item_num,
      d.p_s_ind,
      d.alloc_qty,
      d.alloc_qty_uom_code,
      d.fill_num,
      d.ledger_date,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.exch_fifo_alloc_num = i.exch_fifo_alloc_num and
         d.exch_fifo_alloc_item_num = i.exch_fifo_alloc_item_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[exch_fifo_alloc_item] ADD CONSTRAINT [exch_fifo_alloc_item_pk] PRIMARY KEY CLUSTERED  ([exch_fifo_alloc_num], [exch_fifo_alloc_item_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [exch_fifo_alloc_item_idx1] ON [dbo].[exch_fifo_alloc_item] ([trade_num], [order_num], [item_num], [fill_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[exch_fifo_alloc_item] ADD CONSTRAINT [exch_fifo_alloc_item_fk3] FOREIGN KEY ([alloc_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[exch_fifo_alloc_item] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[exch_fifo_alloc_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[exch_fifo_alloc_item] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[exch_fifo_alloc_item] TO [next_usr]
GO
