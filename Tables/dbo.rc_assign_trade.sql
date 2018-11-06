CREATE TABLE [dbo].[rc_assign_trade]
(
[assign_num] [int] NOT NULL,
[risk_cover_num] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[cargo_value] [decimal] (20, 8) NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[rc_assign_trade_deltrg]
on [dbo].[rc_assign_trade]
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
   select @errmsg = '(rc_assign_trade) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_rc_assign_trade
   (assign_num,
    risk_cover_num,
    trade_num,
    order_num,
    item_num,
    cargo_value,
    trans_id,
    resp_trans_id)
select
    d.assign_num,
    d.risk_cover_num,
    d.trade_num,
    d.order_num,
    d.item_num,
    d.cargo_value,
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

create trigger [dbo].[rc_assign_trade_updtrg]
on [dbo].[rc_assign_trade]
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
   raiserror ('(rc_assign_trade) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(rc_assign_trade) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.assign_num = d.assign_num)
begin
   raiserror ('(rc_assign_trade) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(assign_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.assign_num = d.assign_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(rc_assign_trade) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_rc_assign_trade
   (assign_num,
    risk_cover_num,
    trade_num,
    order_num,
    item_num,
    cargo_value,
    trans_id,
    resp_trans_id)
 select
    d.assign_num,
    d.risk_cover_num,
    d.trade_num,
    d.order_num,
    d.item_num,
    d.cargo_value,
    d.trans_id,
    i.trans_id
 from deleted d, inserted i
 where d.assign_num = i.assign_num

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[rc_assign_trade] ADD CONSTRAINT [rc_assign_trade_pk] PRIMARY KEY CLUSTERED  ([assign_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rc_assign_trade] ADD CONSTRAINT [rc_assign_trade_fk1] FOREIGN KEY ([risk_cover_num]) REFERENCES [dbo].[risk_cover] ([risk_cover_num])
GO
ALTER TABLE [dbo].[rc_assign_trade] ADD CONSTRAINT [rc_assign_trade_fk2] FOREIGN KEY ([trade_num], [order_num], [item_num]) REFERENCES [dbo].[trade_item] ([trade_num], [order_num], [item_num])
GO
GRANT DELETE ON  [dbo].[rc_assign_trade] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[rc_assign_trade] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[rc_assign_trade] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[rc_assign_trade] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'rc_assign_trade', NULL, NULL
GO
