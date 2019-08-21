CREATE TABLE [dbo].[risk_value_history]
(
[as_of_date] [datetime] NOT NULL,
[book_num] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[accum_num] [smallint] NOT NULL,
[trade_leg_number] [smallint] NOT NULL,
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[internal_counterparty_id] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_counterparty_id] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[counterparty_legal_num] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rxm_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[deal_date] [datetime] NULL,
[ti_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[deal_nature_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[call_put_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[deal_end_date] [datetime] NULL,
[buy_sell_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pos_qty] [numeric] (20, 8) NULL,
[price_amt] [numeric] (20, 8) NULL,
[rv_amt] [numeric] (20, 8) NULL,
[cont_nominal_amt] [numeric] (20, 8) NULL,
[cp_console] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[booking_entity] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[target_entity] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[accrual] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commodity_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[market_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trading_period] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[market_price_amt] [numeric] (20, 8) NULL,
[strike_price_amt] [numeric] (20, 8) NULL,
[premium_amt] [numeric] (20, 8) NULL,
[unrealised_realised] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[allocation_num] [int] NULL,
[pl_type] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_status] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_price_currency] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_price_uom] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[strike_price_currency] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[strike_price_uom] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[premium_currency] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[premium_uom] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bill_of_lading_date] [datetime] NULL,
[storage_location] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[from_location] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[to_location] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[delivery_start_date] [datetime] NULL,
[delivery_end_date] [datetime] NULL,
[euro_bank_status] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[opening_imp_vol_rate] [numeric] (20, 8) NULL,
[closing_imp_vol_rate] [numeric] (20, 8) NULL,
[opening_int_rate] [numeric] (20, 8) NULL,
[closing_int_rate] [numeric] (20, 8) NULL,
[opening_days_to_settl] [int] NULL,
[closing_days_to_settl] [int] NULL,
[opening_discount_factor_amt] [numeric] (20, 8) NULL,
[closing_discount_factor_amt] [numeric] (20, 8) NULL,
[opening_market_price_amt] [numeric] (20, 8) NULL,
[closing_market_price_amt] [numeric] (20, 8) NULL,
[market_price_currency] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[market_price_uom] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[opening_trade_price_amt] [numeric] (20, 8) NULL,
[closing_trade_price_amt] [numeric] (20, 8) NULL,
[opening_trade_value_amt] [numeric] (20, 8) NULL,
[closing_trade_value_amt] [numeric] (20, 8) NULL,
[opening_market_value_amt] [numeric] (20, 8) NULL,
[closing_market_value_amt] [numeric] (20, 8) NULL,
[opening_fx_rate] [numeric] (20, 8) NULL,
[closing_fx_rate] [numeric] (20, 8) NULL,
[opening_delta] [numeric] (20, 8) NULL,
[closing_delta] [numeric] (20, 8) NULL,
[opening_gamma] [numeric] (20, 8) NULL,
[closing_gamma] [numeric] (20, 8) NULL,
[opening_vega] [numeric] (20, 8) NULL,
[closing_vega] [numeric] (20, 8) NULL,
[opening_theta] [numeric] (20, 8) NULL,
[closing_theta] [numeric] (20, 8) NULL,
[opening_rho] [numeric] (20, 8) NULL,
[closing_rho] [numeric] (20, 8) NULL,
[opening_drift] [numeric] (20, 8) NULL,
[closing_drift] [numeric] (20, 8) NULL,
[average_corr_n_factor] [numeric] (20, 8) NULL,
[opening_delta_pos_qty] [numeric] (20, 8) NULL,
[closing_delta_pos_qty] [numeric] (20, 8) NULL,
[opening_gamma_pos_qty] [numeric] (20, 8) NULL,
[closing_gamma_pos_qty] [numeric] (20, 8) NULL,
[opening_vega_pos_qty] [numeric] (20, 8) NULL,
[closing_vega_pos_qty] [numeric] (20, 8) NULL,
[opening_theta_pos_qty] [numeric] (20, 8) NULL,
[closing_theta_pos_qty] [numeric] (20, 8) NULL,
[opening_rho_pos_qty] [numeric] (20, 8) NULL,
[closing_rho_pos_qty] [numeric] (20, 8) NULL,
[opening_drift_pos_qty] [numeric] (20, 8) NULL,
[closing_drift_pos_qty] [numeric] (20, 8) NULL,
[opening_sec_order] [numeric] (20, 8) NULL,
[closing_sec_order] [numeric] (20, 8) NULL,
[total_change_day_pl] [numeric] (20, 8) NULL,
[fx_pl] [numeric] (20, 8) NULL,
[delta_pl] [numeric] (20, 8) NULL,
[gamma_pl] [numeric] (20, 8) NULL,
[vega_pl] [numeric] (20, 8) NULL,
[theta_pl] [numeric] (20, 8) NULL,
[rho_pl] [numeric] (20, 8) NULL,
[drift_pl] [numeric] (20, 8) NULL,
[sec_order_pl] [numeric] (20, 8) NULL,
[liquidate_pl] [numeric] (20, 8) NULL,
[new_trade_pl] [numeric] (20, 8) NULL,
[broker_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[brokerage_amt] [numeric] (20, 8) NULL,
[other_sec_costs] [numeric] (20, 8) NULL,
[symbol_x_t] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[units_per_contr] [numeric] (20, 8) NULL,
[future_contr_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_qty_in_lots] [numeric] (20, 8) NULL,
[trade_modified_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[secondary_cost_modified_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[open_underlying] [numeric] (20, 8) NULL,
[close_underlying] [numeric] (20, 8) NULL,
[cash_due_date] [datetime] NULL,
[underlying_cmdty_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[underlying_mkt_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_pricing_ratio] [numeric] (20, 8) NULL,
[formula_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[opt_delta] [numeric] (20, 8) NULL,
[risk_period] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[risk_value_history_updtrg]
on [dbo].[risk_value_history]
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
   raiserror ('(risk_value_history) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(risk_value_history) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.as_of_date = d.as_of_date and 
                 i.book_num = d.book_num and
                 i.trade_num = d.trade_num and
                 i.order_num = d.order_num and
                 i.item_num = d.item_num and
                 i.accum_num = d.accum_num and
                 i.trade_leg_number = d.trade_leg_number)
begin
   select @errmsg = '(risk_value_history) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (''' + convert(varchar, i.as_of_date, 101) + ''',' + 
                                        convert(varchar, i.book_num) + ',' +
                                        convert(varchar, i.trade_num) + ',' +
                                        convert(varchar, i.order_num) + ',' +
                                        convert(varchar, i.item_num) + ',' +
                                        convert(varchar, i.accum_num) + ',' +
                                        convert(varchar, i.trade_leg_number) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end

/* RECORD_STAMP_END */

if update(as_of_date) or  
   update(book_num) or 
   update(trade_num) or 
   update(order_num) or 
   update(item_num) or 
   update(accum_num) or 
   update(trade_leg_number)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.as_of_date = d.as_of_date and 
                                   i.book_num = d.book_num and
                                   i.trade_num = d.trade_num and
                                   i.order_num = d.order_num and
                                   i.item_num = d.item_num and
                                   i.accum_num = d.accum_num and
                                   i.trade_leg_number = d.trade_leg_number)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(risk_value_history) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[risk_value_history] ADD CONSTRAINT [risk_value_history_pk] PRIMARY KEY CLUSTERED  ([as_of_date], [book_num], [trade_num], [order_num], [item_num], [accum_num], [trade_leg_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[risk_value_history] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[risk_value_history] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[risk_value_history] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[risk_value_history] TO [next_usr]
GO
