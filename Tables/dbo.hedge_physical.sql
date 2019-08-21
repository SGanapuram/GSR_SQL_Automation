CREATE TABLE [dbo].[hedge_physical]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[hedge_num] [smallint] NOT NULL,
[phys_trade_num] [int] NOT NULL,
[phys_order_num] [smallint] NOT NULL,
[phys_item_num] [smallint] NOT NULL,
[weight_pcnt] [float] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[hedge_physical_deltrg]
on [dbo].[hedge_physical]
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
   select @errmsg = '(hedge_physical) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_hedge_physical
   (trade_num,
    order_num,
    item_num,
    hedge_num,
    phys_trade_num,
    phys_order_num,
    phys_item_num, 
    weight_pcnt, 
    trans_id,
    resp_trans_id)
select
   d.trade_num,
   d.order_num,
   d.item_num,
   d.hedge_num,
   d.phys_trade_num,
   d.phys_order_num,
   d.phys_item_num, 
   d.weight_pcnt, 
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

create trigger [dbo].[hedge_physical_updtrg]
on [dbo].[hedge_physical]
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
   raiserror ('(hedge_physical) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(hedge_physical) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.trade_num = d.trade_num and 
                 i.order_num = d.order_num and
                 i.item_num = d.item_num and
                 i.hedge_num = d.hedge_num )
begin
   raiserror ('(hedge_physical) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(trade_num) or  
   update(order_num) or
   update(item_num) or
   update(hedge_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.trade_num = d.trade_num and 
                                   i.order_num = d.order_num and
                                   i.item_num = d.item_num and
                                   i.hedge_num = d.hedge_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(hedge_physical) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_hedge_physical
      (trade_num,
       order_num,
       item_num,
       hedge_num,
       phys_trade_num,
       phys_order_num,
       phys_item_num, 
       weight_pcnt, 
       trans_id,
       resp_trans_id)
   select
      d.trade_num,
      d.order_num,
      d.item_num,
      d.hedge_num,
      d.phys_trade_num,
      d.phys_order_num,
      d.phys_item_num, 
      d.weight_pcnt, 
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.trade_num = i.trade_num and
         d.order_num = i.order_num and
         d.item_num = i.item_num and
         d.hedge_num = i.hedge_num

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[hedge_physical] ADD CONSTRAINT [hedge_physical_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num], [hedge_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[hedge_physical] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[hedge_physical] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[hedge_physical] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[hedge_physical] TO [next_usr]
GO
