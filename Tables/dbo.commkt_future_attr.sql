CREATE TABLE [dbo].[commkt_future_attr]
(
[commkt_key] [int] NOT NULL,
[commkt_fut_attr_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_lot_size] [float] NOT NULL,
[commkt_lot_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_settlement_ind] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_price_fmt] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_trading_mth_ind] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_nearby_mask] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_min_price_var] [float] NULL,
[commkt_max_price_var] [float] NULL,
[commkt_spot_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_price_freq] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_price_freq_as_of] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_price_series] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_spot_mth_qty] [float] NULL,
[commkt_fwd_mth_qty] [float] NULL,
[commkt_total_open_qty] [float] NULL,
[commkt_formula_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_interpol_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_num_mth_out] [smallint] NULL,
[commkt_support_price_type] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_same_as_mkt_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_same_as_cmdty_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_forex_mkt_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_forex_cmdty_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_price_div_mul_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_limit_move_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_point_conv_num] [float] NULL,
[sec_price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[lot_size_periodicity] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[calendar_day_lot_size] [float] NULL,
[calendar_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[non_calendar_day_lot_size] [float] NULL,
[dst_zone] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[commkt_future_attr_deltrg]
on [dbo].[commkt_future_attr]
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
   select @errmsg = '(commkt_future_attr) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_commkt_future_attr
   (commkt_key,
    commkt_fut_attr_status,
    commkt_lot_size,
    commkt_lot_uom_code,
    commkt_price_uom_code,
    commkt_settlement_ind,
    commkt_curr_code,
    commkt_price_fmt,
    commkt_trading_mth_ind,
    commkt_nearby_mask,
    commkt_min_price_var,
    commkt_max_price_var,
    commkt_spot_prd,
    commkt_price_freq,
    commkt_price_freq_as_of,
    commkt_price_series,
    commkt_spot_mth_qty,
    commkt_fwd_mth_qty,
    commkt_total_open_qty,
    commkt_formula_type,
    commkt_interpol_type,
    commkt_num_mth_out,
    commkt_support_price_type,
    commkt_same_as_mkt_code,
    commkt_same_as_cmdty_code,
    commkt_forex_mkt_code,
    commkt_forex_cmdty_code,
    commkt_price_div_mul_ind,
    user_init,
    commkt_limit_move_ind,
    commkt_point_conv_num,
    sec_price_source_code,
    sec_alias_source_code,
    trans_id,
    resp_trans_id,
	lot_size_periodicity,
	calendar_day_lot_size,
	calendar_code,
	non_calendar_day_lot_size,
	dst_zone		
	)
select
   d.commkt_key,
   d.commkt_fut_attr_status,
   d.commkt_lot_size,
   d.commkt_lot_uom_code,
   d.commkt_price_uom_code,
   d.commkt_settlement_ind,
   d.commkt_curr_code,
   d.commkt_price_fmt,
   d.commkt_trading_mth_ind,
   d.commkt_nearby_mask,
   d.commkt_min_price_var,
   d.commkt_max_price_var,
   d.commkt_spot_prd,
   d.commkt_price_freq,
   d.commkt_price_freq_as_of,
   d.commkt_price_series,
   d.commkt_spot_mth_qty,
   d.commkt_fwd_mth_qty,
   d.commkt_total_open_qty,
   d.commkt_formula_type,
   d.commkt_interpol_type,
   d.commkt_num_mth_out,
   d.commkt_support_price_type,
   d.commkt_same_as_mkt_code,
   d.commkt_same_as_cmdty_code,
   d.commkt_forex_mkt_code,
   d.commkt_forex_cmdty_code,
   d.commkt_price_div_mul_ind,
   d.user_init,
   d.commkt_limit_move_ind,
   d.commkt_point_conv_num,
   d.sec_price_source_code,
   d.sec_alias_source_code,
   d.trans_id,
   @atrans_id,
   d.lot_size_periodicity,
   d.calendar_day_lot_size,
   d.calendar_code,
   d.non_calendar_day_lot_size,
   d.dst_zone		
from deleted d

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[commkt_future_attr_updtrg]
on [dbo].[commkt_future_attr]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errorNumber      int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(commkt_future_attr) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(commkt_future_attr) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.commkt_key = d.commkt_key )
begin
   raiserror ('(commkt_future_attr) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(commkt_key) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.commkt_key = d.commkt_key )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(commkt_future_attr) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_commkt_future_attr
      (commkt_key,
       commkt_fut_attr_status,
       commkt_lot_size,
       commkt_lot_uom_code,
       commkt_price_uom_code,
       commkt_settlement_ind,
       commkt_curr_code,
       commkt_price_fmt,
       commkt_trading_mth_ind,
       commkt_nearby_mask,
       commkt_min_price_var,
       commkt_max_price_var,
       commkt_spot_prd,
       commkt_price_freq,
       commkt_price_freq_as_of,
       commkt_price_series,
       commkt_spot_mth_qty,
       commkt_fwd_mth_qty,
       commkt_total_open_qty,
       commkt_formula_type,
       commkt_interpol_type,
       commkt_num_mth_out,
       commkt_support_price_type,
       commkt_same_as_mkt_code,
       commkt_same_as_cmdty_code,
       commkt_forex_mkt_code,
       commkt_forex_cmdty_code,
       commkt_price_div_mul_ind,
       user_init,
       commkt_limit_move_ind,
       commkt_point_conv_num,
       sec_price_source_code,
       sec_alias_source_code,
       trans_id,
       resp_trans_id,
	   lot_size_periodicity,
	   calendar_day_lot_size,
	   calendar_code,
	   non_calendar_day_lot_size,
	   dst_zone		
	   )
   select
      d.commkt_key,
      d.commkt_fut_attr_status,
      d.commkt_lot_size,
      d.commkt_lot_uom_code,
      d.commkt_price_uom_code,
      d.commkt_settlement_ind,
      d.commkt_curr_code,
      d.commkt_price_fmt,
      d.commkt_trading_mth_ind,
      d.commkt_nearby_mask,
      d.commkt_min_price_var,
      d.commkt_max_price_var,
      d.commkt_spot_prd,
      d.commkt_price_freq,
      d.commkt_price_freq_as_of,
      d.commkt_price_series,
      d.commkt_spot_mth_qty,
      d.commkt_fwd_mth_qty,
      d.commkt_total_open_qty,
      d.commkt_formula_type,
      d.commkt_interpol_type,
      d.commkt_num_mth_out,
      d.commkt_support_price_type,
      d.commkt_same_as_mkt_code,
      d.commkt_same_as_cmdty_code,
      d.commkt_forex_mkt_code,
      d.commkt_forex_cmdty_code,
      d.commkt_price_div_mul_ind,
      d.user_init,
      d.commkt_limit_move_ind,
      d.commkt_point_conv_num,
      d.sec_price_source_code,
      d.sec_alias_source_code,
      d.trans_id,
      i.trans_id,
	  d.lot_size_periodicity,
	  d.calendar_day_lot_size,
	  d.calendar_code,
	  d.non_calendar_day_lot_size,
	  d.dst_zone			
   from deleted d, inserted i
   where d.commkt_key = i.commkt_key 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[commkt_future_attr] ADD CONSTRAINT [commkt_future_attr_pk] PRIMARY KEY CLUSTERED  ([commkt_key]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [commkt_future_attr_POSGRID_idx1] ON [dbo].[commkt_future_attr] ([commkt_key]) INCLUDE ([commkt_curr_code], [commkt_lot_size], [commkt_price_uom_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commkt_future_attr] ADD CONSTRAINT [commkt_future_attr_fk1] FOREIGN KEY ([sec_price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[commkt_future_attr] ADD CONSTRAINT [commkt_future_attr_fk2] FOREIGN KEY ([sec_alias_source_code]) REFERENCES [dbo].[alias_source] ([alias_source_code])
GO
ALTER TABLE [dbo].[commkt_future_attr] ADD CONSTRAINT [commkt_future_attr_fk3] FOREIGN KEY ([commkt_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[commkt_future_attr] ADD CONSTRAINT [commkt_future_attr_fk4] FOREIGN KEY ([commkt_key]) REFERENCES [dbo].[commodity_market] ([commkt_key])
GO
ALTER TABLE [dbo].[commkt_future_attr] ADD CONSTRAINT [commkt_future_attr_fk5] FOREIGN KEY ([user_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[commkt_future_attr] ADD CONSTRAINT [commkt_future_attr_fk6] FOREIGN KEY ([commkt_lot_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[commkt_future_attr] ADD CONSTRAINT [commkt_future_attr_fk7] FOREIGN KEY ([commkt_price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[commkt_future_attr] ADD CONSTRAINT [commkt_future_attr_fk8] FOREIGN KEY ([calendar_code]) REFERENCES [dbo].[calendar] ([calendar_code])
GO
ALTER TABLE [dbo].[commkt_future_attr] ADD CONSTRAINT [commkt_future_attr_fk9] FOREIGN KEY ([dst_zone]) REFERENCES [dbo].[time_zone] ([time_zone_code])
GO
GRANT DELETE ON  [dbo].[commkt_future_attr] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[commkt_future_attr] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[commkt_future_attr] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[commkt_future_attr] TO [next_usr]
GO
