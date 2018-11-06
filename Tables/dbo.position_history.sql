CREATE TABLE [dbo].[position_history]
(
[pos_num] [int] NOT NULL,
[asof_date] [datetime] NOT NULL,
[last_frozen_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[real_port_num] [int] NOT NULL,
[pos_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[is_equiv_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[what_if_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_key] [int] NULL,
[trading_prd] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_num] [int] NULL,
[formula_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[option_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[settlement_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[strike_price] [float] NULL,
[strike_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[strike_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[put_call_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[opt_exp_date] [datetime] NULL,
[opt_start_date] [datetime] NULL,
[opt_periodicity] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[opt_price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[is_hedge_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[long_qty] [float] NOT NULL,
[short_qty] [float] NOT NULL,
[discount_qty] [float] NULL,
[priced_qty] [float] NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[avg_purch_price] [float] NULL,
[avg_sale_price] [float] NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_long_qty] [float] NULL,
[sec_short_qty] [float] NULL,
[sec_discount_qty] [float] NULL,
[sec_priced_qty] [float] NULL,
[sec_pos_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[pos_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[desired_opt_eval_method] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[desired_otc_opt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_mtm_price] [numeric] (20, 8) NULL,
[rolled_qty] [numeric] (20, 8) NULL,
[sec_rolled_qty] [numeric] (20, 8) NULL,
[is_cleared_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_body_num] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[position_history_deltrg]
on [dbo].[position_history]
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
   select @errmsg = '(position_history) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   if @@trancount > 0 rollback tran

   return
end

insert dbo.aud_position_history
   (pos_num,
    asof_date,
    last_frozen_ind,
    real_port_num,
    pos_type,
    is_equiv_ind,
    what_if_ind,
    commkt_key,
    trading_prd,
    cmdty_code,
    mkt_code,
    formula_num,
    formula_name,
    option_type,
    settlement_type,
    strike_price,
    strike_price_curr_code,
    strike_price_uom_code,
    put_call_ind,
    opt_exp_date,
    opt_start_date,
    opt_periodicity,
    opt_price_source_code,
    is_hedge_ind,
    long_qty,
    short_qty,
    discount_qty,
    priced_qty,
    qty_uom_code,
    avg_purch_price,
    avg_sale_price,
    price_curr_code,
    price_uom_code,
    sec_long_qty,
    sec_short_qty,
    sec_discount_qty,
    sec_priced_qty,
    sec_pos_uom_code,
    pos_status,
    desired_opt_eval_method,
    desired_otc_opt_code,
    last_mtm_price,
    rolled_qty,  
    sec_rolled_qty,
    is_cleared_ind,
    formula_body_num,
    trans_id,
    resp_trans_id)
select
   d.pos_num,
   d.asof_date,
   d.last_frozen_ind,
   d.real_port_num,
   d.pos_type,
   d.is_equiv_ind,
   d.what_if_ind,
   d.commkt_key,
   d.trading_prd,
   d.cmdty_code,
   d.mkt_code,
   d.formula_num,
   d.formula_name,
   d.option_type,
   d.settlement_type,
   d.strike_price,
   d.strike_price_curr_code,
   d.strike_price_uom_code,
   d.put_call_ind,
   d.opt_exp_date,
   d.opt_start_date,
   d.opt_periodicity,
   d.opt_price_source_code,
   d.is_hedge_ind,
   d.long_qty,
   d.short_qty,
   d.discount_qty,
   d.priced_qty,
   d.qty_uom_code,
   d.avg_purch_price,
   d.avg_sale_price,
   d.price_curr_code,
   d.price_uom_code,
   d.sec_long_qty,
   d.sec_short_qty,
   d.sec_discount_qty,
   d.sec_priced_qty,
   d.sec_pos_uom_code,
   d.pos_status,
   d.desired_opt_eval_method,
   d.desired_otc_opt_code,
   d.last_mtm_price,
   d.rolled_qty,  
   d.sec_rolled_qty,
   d.is_cleared_ind,
   d.formula_body_num,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[position_history_updtrg]
on [dbo].[position_history]
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
   raiserror ('(position_history) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(position_history) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.pos_num = d.pos_num and
                 i.asof_date = d.asof_date and
                 i.last_frozen_ind = d.last_frozen_ind)
begin
   select @errmsg = '(position_history) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.pos_num) + ',' +
                                 '''' + convert(varchar, i.asof_date, 101) + ''',' +
                                 '''' + i.last_frozen_ind + ''')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(pos_num) or
   update(asof_date) or
   update(last_frozen_ind)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.pos_num = d.pos_num and
                                   i.asof_date = d.asof_date and
                                   i.last_frozen_ind = d.last_frozen_ind)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(position_history) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_position_history
      (pos_num,
       asof_date,
       last_frozen_ind,
       real_port_num,
       pos_type,
       is_equiv_ind,
       what_if_ind,
       commkt_key,
       trading_prd,
       cmdty_code,
       mkt_code,
       formula_num,
       formula_name,
       option_type,
       settlement_type,
       strike_price,
       strike_price_curr_code,
       strike_price_uom_code,
       put_call_ind,
       opt_exp_date,
       opt_start_date,
       opt_periodicity,
       opt_price_source_code,
       is_hedge_ind,
       long_qty,
       short_qty,
       discount_qty,
       priced_qty,
       qty_uom_code,
       avg_purch_price,
       avg_sale_price,
       price_curr_code,
       price_uom_code,
       sec_long_qty,
       sec_short_qty,
       sec_discount_qty,
       sec_priced_qty,
       sec_pos_uom_code,
       pos_status,
       desired_opt_eval_method,
       desired_otc_opt_code,
       last_mtm_price,
       rolled_qty,  
       sec_rolled_qty,
       is_cleared_ind,
       formula_body_num,
       trans_id,
       resp_trans_id)
   select
      d.pos_num,
      d.asof_date,
      d.last_frozen_ind,
      d.real_port_num,
      d.pos_type,
      d.is_equiv_ind,
      d.what_if_ind,
      d.commkt_key,
      d.trading_prd,
      d.cmdty_code,
      d.mkt_code,
      d.formula_num,
      d.formula_name,
      d.option_type,
      d.settlement_type,
      d.strike_price,
      d.strike_price_curr_code,
      d.strike_price_uom_code,
      d.put_call_ind,
      d.opt_exp_date,
      d.opt_start_date,
      d.opt_periodicity,
      d.opt_price_source_code,
      d.is_hedge_ind,
      d.long_qty,
      d.short_qty,
      d.discount_qty,
      d.priced_qty,
      d.qty_uom_code,
      d.avg_purch_price,
      d.avg_sale_price,
      d.price_curr_code,
      d.price_uom_code,
      d.sec_long_qty,
      d.sec_short_qty,
      d.sec_discount_qty,
      d.sec_priced_qty,
      d.sec_pos_uom_code,
      d.pos_status,
      d.desired_opt_eval_method,
      d.desired_otc_opt_code,
      d.last_mtm_price,
      d.rolled_qty,  
      d.sec_rolled_qty,
      d.is_cleared_ind,
      d.formula_body_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.pos_num = i.pos_num and
         d.asof_date = i.asof_date and
         d.last_frozen_ind = i.last_frozen_ind

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [CK__position___last___1DF06171] CHECK (([last_frozen_ind]='N' OR [last_frozen_ind]='Y'))
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_pk] PRIMARY KEY CLUSTERED  ([pos_num], [asof_date], [last_frozen_ind]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_fk1] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_fk10] FOREIGN KEY ([qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_fk11] FOREIGN KEY ([price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_fk12] FOREIGN KEY ([sec_pos_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_fk13] FOREIGN KEY ([desired_otc_opt_code]) REFERENCES [dbo].[otc_option] ([otc_opt_code])
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_fk2] FOREIGN KEY ([strike_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_fk3] FOREIGN KEY ([price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_fk5] FOREIGN KEY ([mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_fk8] FOREIGN KEY ([opt_price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_fk9] FOREIGN KEY ([strike_price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[position_history] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[position_history] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[position_history] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[position_history] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'position_history', NULL, NULL
GO
