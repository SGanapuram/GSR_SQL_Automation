CREATE TABLE [dbo].[position]
(
[pos_num] [int] NOT NULL,
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
[acct_short_name] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[desired_opt_eval_method] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[desired_otc_opt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
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
[last_mtm_price] [numeric] (20, 8) NULL,
[rolled_qty] [numeric] (20, 8) NULL,
[sec_rolled_qty] [numeric] (20, 8) NULL,
[is_cleared_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_body_num] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[position_deltrg]
on [dbo].[position]
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
   select @errmsg = '(position) Failed to obtain a valid responsible trans_id. '
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


/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'DELETE',
       'Position',
       'DIRECT',
       convert(varchar(40), d.pos_num),
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

/* AUDIT_CODE_BEGIN */

insert dbo.aud_position
   (pos_num,
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
    acct_short_name,
    desired_opt_eval_method,
    desired_otc_opt_code,
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
    last_mtm_price,
    rolled_qty,  
    sec_rolled_qty,
    is_cleared_ind,
    trans_id,
    resp_trans_id,
    formula_body_num)
select
   d.pos_num,
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
   d.acct_short_name,
   d.desired_opt_eval_method,
   d.desired_otc_opt_code,
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
   d.last_mtm_price,
   d.rolled_qty,  
   d.sec_rolled_qty,
   d.is_cleared_ind,
   d.trans_id,
   @atrans_id,
   d.formula_body_num
from deleted d

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[position_instrg]
on [dbo].[position]
for insert
as
declare @num_rows        int,
        @count_num_rows  int,
        @errmsg          varchar(255),
        @duplicate_found bit

select @num_rows = @@rowcount
if @num_rows = 0
   return

   /* The following logic is used to replace the index which was created for making sure
      the records added into the position table do not carry the same key value
   */

   select @duplicate_found = 0
   /* For Q-type positions, the formula_num and formula_name can have the values shown as follows:
   
         formula_num           formula_name
         --------------------- -----------------------
         NULL                  NULL
         24837                 Naphtha Paraffins Escalator
         24534                 Formula
   */            
   if exists (select * 
              from dbo.position p, inserted i
              where i.pos_type in ('Q', 'T', 'M', 'K') and                 
                    p.pos_type = i.pos_type and
                    p.real_port_num = i.real_port_num and
                    p.commkt_key = i.commkt_key and
                    isnull(p.trading_prd, '@') = isnull(i.trading_prd, '@') and 
                    isnull(p.formula_num, 0) = isnull(i.formula_num, 0) and
                    isnull(p.formula_name, 'Formula') = isnull(i.formula_name, 'Formula') and 
                    isnull(p.option_type, '@') = isnull(i.option_type, '@') and
                    p.is_equiv_ind = i.is_equiv_ind and
                    p.is_hedge_ind = i.is_hedge_ind and
		                isnull(p.is_cleared_ind, 'N') = isnull(i.is_cleared_ind, 'N') and
                    p.trans_id <> i.trans_id)
      select @duplicate_found = 1

   
   /* For O-type positions, the formula_num and formula_name can have the values shown as follows:
   
         formula_num           formula_name
         --------------------- -----------------------
         220038                Formula
         NULL                  144229/1/1
   */            
   if @duplicate_found = 0
   begin
      if exists (select * 
                 from dbo.position p, inserted i
                 where i.pos_type = 'O' and
                       p.pos_type = i.pos_type and
                       p.real_port_num = i.real_port_num and
                       p.commkt_key = i.commkt_key and
                       isnull(p.trading_prd, '@') = isnull(i.trading_prd, '@') and
		       isnull(p.option_type, '@') = isnull(i.option_type, '@') and
                       isnull(p.formula_num, 0) = isnull(i.formula_num, 0) and
                       isnull(p.formula_name, 'Formula') = isnull(i.formula_name, 'Formula') and
                       p.is_equiv_ind = i.is_equiv_ind and
                       p.is_hedge_ind = i.is_hedge_ind and
                       isnull(p.strike_price, 0) = isnull(i.strike_price, 0) and
                       isnull(p.strike_price_curr_code, '@@@@@@@@') = isnull(i.strike_price_curr_code, '@@@@@@@@') and
                       isnull(p.strike_price_uom_code, '@@@@') = isnull(i.strike_price_uom_code, '@@@@') and
                       isnull(p.settlement_type, '@') = isnull(i.settlement_type, '@') and
                       isnull(p.opt_exp_date, '01/01/1980') = isnull(i.opt_exp_date, '01/01/1980') and
                       isnull(p.put_call_ind, '@') = isnull(i.put_call_ind, '@') and
                       isnull(p.desired_opt_eval_method, '@') = isnull(i.desired_opt_eval_method, '@') and
                       isnull(p.desired_otc_opt_code, '@@@@@@@@') = isnull(i.desired_otc_opt_code, '@@@@@@@@') and
                       isnull(p.opt_start_date, '01/01/1980') = isnull(i.opt_start_date, '01/01/1980') and
		                   isnull(p.is_cleared_ind, 'N') = isnull(i.is_cleared_ind, 'N') and
                       p.trans_id <> i.trans_id)
         select @duplicate_found = 1
   end


   if @duplicate_found = 0
   begin
      if exists (select * 
                 from dbo.position p, inserted i
                 where i.pos_type = 'W' and
                       p.pos_type = i.pos_type and
                       p.real_port_num = i.real_port_num and
                       p.commkt_key = i.commkt_key and
                       isnull(p.trading_prd, '@') = isnull(i.trading_prd, '@') and
                       isnull(p.option_type, '@') = isnull(i.option_type, '@') and
                       p.is_equiv_ind = i.is_equiv_ind and
                       p.is_hedge_ind = i.is_hedge_ind and
		                   isnull(p.is_cleared_ind, 'N') = isnull(i.is_cleared_ind, 'N') and
                       p.trans_id <> i.trans_id)
         select @duplicate_found = 1
   end

   if @duplicate_found = 0
   begin
      if exists (select * 
                 from dbo.position p, inserted i
                 where i.pos_type = 'X' and
                       p.pos_type = i.pos_type and
                       p.real_port_num = i.real_port_num and
                       p.commkt_key = i.commkt_key and
                       isnull(p.trading_prd, '@') = isnull(i.trading_prd, '@') and
                       isnull(p.option_type, '@') = isnull(i.option_type, '@') and
                       p.is_equiv_ind = i.is_equiv_ind and
                       p.is_hedge_ind = i.is_hedge_ind and
		                   isnull(p.is_cleared_ind, 'N') = isnull(i.is_cleared_ind, 'N') and
                       isnull(p.strike_price, 0) = isnull(i.strike_price, 0) and
                       isnull(p.strike_price_curr_code, '@@@@@@@@') = isnull(i.strike_price_curr_code, '@@@@@@@@') and
                       isnull(p.strike_price_uom_code, '@@@@') = isnull(i.strike_price_uom_code, '@@@@') and
                       isnull(p.settlement_type, '@') = isnull(i.settlement_type, '@') and
                       isnull(p.opt_exp_date, '01/01/1980') = isnull(i.opt_exp_date, '01/01/1980') and
                       isnull(p.put_call_ind, '@') = isnull(i.put_call_ind, '@') and
                       p.trans_id <> i.trans_id)
         select @duplicate_found = 1         
   end

   if @duplicate_found = 0
   begin
      if exists (select * 
                 from dbo.position p, inserted i
                 where i.pos_type not in ('X', 'W', 'Q', 'O', 'M', 'T', 'K') and
                       p.pos_type = i.pos_type and
                       p.real_port_num = i.real_port_num and
                       p.commkt_key = i.commkt_key and
                       isnull(p.trading_prd, '@') = isnull(i.trading_prd, '@') and
                       p.is_equiv_ind = i.is_equiv_ind and
                       p.is_hedge_ind = i.is_hedge_ind and
		                   isnull(p.is_cleared_ind, 'N') = isnull(i.is_cleared_ind, 'N') and
                       p.trans_id <> i.trans_id)
         select @duplicate_found = 1
   end

   if @duplicate_found = 1
   begin
      raiserror ('Combination of certain columns for the new position record(s) is not unique. Duplicate is not allowed!',10,1)
      if @@trancount > 0 rollback tran

      return
   end
   
   /* BEGIN_TRANSACTION_TOUCH */
 
   insert dbo.transaction_touch
   select 'INSERT',
          'Position',
          'DIRECT',
          convert(varchar(40), i.pos_num),
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

create trigger [dbo].[position_updtrg]
on [dbo].[position]
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
   raiserror ('(position) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(position) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.pos_num = d.pos_num )
begin
   raiserror ('(position) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(pos_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.pos_num = d.pos_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(position) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'UPDATE',
       'Position',
       'DIRECT',
       convert(varchar(40), i.pos_num),
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

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_position
      (pos_num,
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
       acct_short_name,
       desired_opt_eval_method,
       desired_otc_opt_code,
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
       last_mtm_price,
       rolled_qty,  
       sec_rolled_qty,
       is_cleared_ind,
       trans_id,
       resp_trans_id,
       formula_body_num)
   select
      d.pos_num,
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
      d.acct_short_name,
      d.desired_opt_eval_method,
      d.desired_otc_opt_code,
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
      d.last_mtm_price,
      d.rolled_qty,  
      d.sec_rolled_qty,
      d.is_cleared_ind,
      d.trans_id,
      i.trans_id,
      d.formula_body_num
   from deleted d, inserted i
   where d.pos_num = i.pos_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[position] ADD CONSTRAINT [position_pk] PRIMARY KEY CLUSTERED  ([pos_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [position_idx5] ON [dbo].[position] ([commkt_key], [trading_prd]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [position_POSGRID_idx1] ON [dbo].[position] ([pos_status], [real_port_num], [cmdty_code], [commkt_key], [trading_prd], [pos_num], [pos_type]) INCLUDE ([is_equiv_ind], [is_hedge_ind], [option_type], [trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [position_idx3] ON [dbo].[position] ([pos_type], [opt_exp_date], [cmdty_code], [mkt_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [position_idx4] ON [dbo].[position] ([pos_type], [settlement_type], [pos_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [position_idx1] ON [dbo].[position] ([real_port_num], [is_equiv_ind]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [position_idx2] ON [dbo].[position] ([real_port_num], [pos_type]) ON [PRIMARY]
GO
CREATE STATISTICS [position_POSGRID_stat3] ON [dbo].[position] ([cmdty_code], [pos_type], [pos_status], [real_port_num], [commkt_key], [trading_prd], [pos_num])
GO
CREATE STATISTICS [position_POSGRID_stat1] ON [dbo].[position] ([commkt_key], [pos_type], [pos_status], [real_port_num])
GO
CREATE STATISTICS [position_POSGRID_stat4] ON [dbo].[position] ([commkt_key], [trading_prd], [pos_type], [pos_status], [real_port_num])
GO
CREATE STATISTICS [position_POSGRID_stat5] ON [dbo].[position] ([pos_num], [pos_type], [pos_status], [real_port_num], [cmdty_code], [commkt_key])
GO
CREATE STATISTICS [position_POSGRID_stat2] ON [dbo].[position] ([pos_type], [pos_status], [commkt_key])
GO
CREATE STATISTICS [position_POSGRID_stat6] ON [dbo].[position] ([pos_type], [pos_status], [real_port_num])
GO
CREATE STATISTICS [position_POSGRID_stat7] ON [dbo].[position] ([real_port_num], [cmdty_code], [commkt_key], [trading_prd], [pos_num], [pos_type])
GO
ALTER TABLE [dbo].[position] ADD CONSTRAINT [position_fk1] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[position] ADD CONSTRAINT [position_fk10] FOREIGN KEY ([qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[position] ADD CONSTRAINT [position_fk11] FOREIGN KEY ([price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[position] ADD CONSTRAINT [position_fk12] FOREIGN KEY ([sec_pos_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[position] ADD CONSTRAINT [position_fk2] FOREIGN KEY ([strike_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[position] ADD CONSTRAINT [position_fk3] FOREIGN KEY ([price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[position] ADD CONSTRAINT [position_fk5] FOREIGN KEY ([mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
ALTER TABLE [dbo].[position] ADD CONSTRAINT [position_fk6] FOREIGN KEY ([desired_otc_opt_code]) REFERENCES [dbo].[otc_option] ([otc_opt_code])
GO
ALTER TABLE [dbo].[position] ADD CONSTRAINT [position_fk8] FOREIGN KEY ([opt_price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[position] ADD CONSTRAINT [position_fk9] FOREIGN KEY ([strike_price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[position] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[position] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[position] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[position] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'position', NULL, NULL
GO
