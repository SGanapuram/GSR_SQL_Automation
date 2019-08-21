CREATE TABLE [dbo].[trade_item_composite]
(
[trade_item_composite_source] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[min_qty] [float] NULL,
[min_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_qty] [float] NULL,
[max_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_date_from] [datetime] NULL,
[del_date_to] [datetime] NULL,
[del_date_est_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_date_basis] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[timing_cycle_num] [smallint] NULL,
[split_cycle_opt] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_days] [int] NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_imp_rec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_exp_rec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transportation] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_qty] [float] NULL,
[tol_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_sign] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_opt] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[min_ship_qty] [float] NULL,
[min_ship_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[partial_deadline_date] [datetime] NULL,
[partial_res_inc_amt] [float] NULL,
[sch_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[total_ship_num] [smallint] NULL,
[parcel_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[taken_to_sch_pos_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[proc_deal_lifting_days] [smallint] NULL,
[proc_deal_delivery_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[proc_deal_event_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[proc_deal_event_spec] [smallint] NULL,
[load_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sublocation_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[real_port_num] [int] NULL,
[acct_ref_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_composite_updtrg]
on [dbo].[trade_item_composite]
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
   raiserror ('(trade_item_composite) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(trade_item_composite) New trans_id must be larger than original trans_id.'
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
                 i.item_num = d.item_num )
begin
   raiserror ('(trade_item_composite) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(trade_num) or 
   update(order_num) or  
   update(item_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.trade_num = d.trade_num and 
                                   i.order_num = d.order_num and 
                                   i.item_num = d.item_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(trade_item_composite) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[trade_item_composite] ADD CONSTRAINT [trade_item_composite_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_composite] ADD CONSTRAINT [trade_item_composite_fk1] FOREIGN KEY ([credit_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[trade_item_composite] ADD CONSTRAINT [trade_item_composite_fk10] FOREIGN KEY ([max_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_composite] ADD CONSTRAINT [trade_item_composite_fk11] FOREIGN KEY ([tol_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_composite] ADD CONSTRAINT [trade_item_composite_fk12] FOREIGN KEY ([min_ship_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_composite] ADD CONSTRAINT [trade_item_composite_fk2] FOREIGN KEY ([del_term_code]) REFERENCES [dbo].[delivery_term] ([del_term_code])
GO
ALTER TABLE [dbo].[trade_item_composite] ADD CONSTRAINT [trade_item_composite_fk3] FOREIGN KEY ([sch_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[trade_item_composite] ADD CONSTRAINT [trade_item_composite_fk4] FOREIGN KEY ([del_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[trade_item_composite] ADD CONSTRAINT [trade_item_composite_fk5] FOREIGN KEY ([load_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[trade_item_composite] ADD CONSTRAINT [trade_item_composite_fk6] FOREIGN KEY ([mot_code]) REFERENCES [dbo].[mot] ([mot_code])
GO
ALTER TABLE [dbo].[trade_item_composite] ADD CONSTRAINT [trade_item_composite_fk7] FOREIGN KEY ([pay_term_code]) REFERENCES [dbo].[payment_term] ([pay_term_code])
GO
ALTER TABLE [dbo].[trade_item_composite] ADD CONSTRAINT [trade_item_composite_fk9] FOREIGN KEY ([min_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[trade_item_composite] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_composite] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_composite] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_composite] TO [next_usr]
GO
