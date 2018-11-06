CREATE TABLE [dbo].[fx_cost_draw_down_hist]
(
[oid] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[from_fx_pl_asof_date] [datetime] NULL,
[cost_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_rec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[from_cost_num] [int] NULL,
[to_cost_num] [int] NULL,
[draw_down_up_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__fx_cost_d__draw___52442E1F] DEFAULT ('D'),
[fx_pl_roll_date] [datetime] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[fx_cost_draw_down_hist_deltrg]
on [dbo].[fx_cost_draw_down_hist]
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
   select @errmsg = '(fx_cost_draw_down_hist) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_fx_cost_draw_down_hist
   (oid,
    trade_num,
    order_num,
    item_num,
    from_fx_pl_asof_date,
    cost_code,
    pay_rec_ind,
    cost_type_code,
    from_cost_num,
    to_cost_num,
    draw_down_up_ind,
    fx_pl_roll_date,
    trans_id,
    resp_trans_id)
select
    d.oid,
    d.trade_num,
    d.order_num,
    d.item_num,
    d.from_fx_pl_asof_date,
    d.cost_code,
    d.pay_rec_ind,
    d.cost_type_code,
    d.from_cost_num,
    d.to_cost_num,
    d.draw_down_up_ind,
    d.fx_pl_roll_date,
    d.trans_id,
    @atrans_id 
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'FxCostDrawDownHist',
       'DIRECT',
       convert(varchar(40), d.oid),
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

create trigger [dbo].[fx_cost_draw_down_hist_instrg]
on [dbo].[fx_cost_draw_down_hist]
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
       'FxCostDrawDownHist',
       'DIRECT',
       convert(varchar(40), i.oid),
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

create trigger [dbo].[fx_cost_draw_down_hist_updtrg]
on [dbo].[fx_cost_draw_down_hist]
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
   raiserror ('(fx_cost_draw_down_hist) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(fx_cost_draw_down_hist) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid )
begin
   raiserror ('(fx_cost_draw_down_hist) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(oid) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(fx_cost_draw_down_hist) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_fx_cost_draw_down_hist
      (oid,
       trade_num,
       order_num,
       item_num,
       from_fx_pl_asof_date,
       cost_code,
       pay_rec_ind,
       cost_type_code,
       from_cost_num,
       to_cost_num,
       draw_down_up_ind,
       fx_pl_roll_date,
       trans_id,
       resp_trans_id)
   select
       d.oid,
       d.trade_num,
       d.order_num,
       d.item_num,
       d.from_fx_pl_asof_date,
       d.cost_code,
       d.pay_rec_ind,
       d.cost_type_code,
       d.from_cost_num,
       d.to_cost_num,
       d.draw_down_up_ind,
       d.fx_pl_roll_date,
       d.trans_id,
       i.trans_id 
   from deleted d, inserted i
   where d.oid = i.oid 

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'FxCostDrawDownHist',
       'DIRECT',
       convert(varchar(40), i.oid),
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
ALTER TABLE [dbo].[fx_cost_draw_down_hist] ADD CONSTRAINT [CK__fx_cost_d__draw___53385258] CHECK (([draw_down_up_ind]='R' OR [draw_down_up_ind]='D'))
GO
ALTER TABLE [dbo].[fx_cost_draw_down_hist] ADD CONSTRAINT [fx_cost_draw_down_hist_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fx_cost_draw_down_hist] ADD CONSTRAINT [fx_cost_draw_down_hist_fk1] FOREIGN KEY ([trade_num], [order_num], [item_num]) REFERENCES [dbo].[trade_item] ([trade_num], [order_num], [item_num])
GO
ALTER TABLE [dbo].[fx_cost_draw_down_hist] ADD CONSTRAINT [fx_cost_draw_down_hist_fk3] FOREIGN KEY ([cost_type_code]) REFERENCES [dbo].[cost_type] ([cost_type_code])
GO
GRANT DELETE ON  [dbo].[fx_cost_draw_down_hist] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[fx_cost_draw_down_hist] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[fx_cost_draw_down_hist] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[fx_cost_draw_down_hist] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'fx_cost_draw_down_hist', NULL, NULL
GO
