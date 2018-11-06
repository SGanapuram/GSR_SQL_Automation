CREATE TABLE [dbo].[tmp_position]
(
[pos_num] [int] NOT NULL,
[real_port_num] [int] NOT NULL,
[pos_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[is_equiv_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[what_if_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_key] [int] NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_num] [int] NULL,
[formula_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[option_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[settlement_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[strike_price] [float] NULL,
[strike_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[strike_price_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[put_call_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[opt_exp_date] [datetime] NULL,
[opt_start_date] [datetime] NULL,
[opt_periodicity] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[opt_price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[desired_opt_eval_method] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[desired_otc_opt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[is_hedge_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[long_qty] [float] NULL,
[short_qty] [float] NULL,
[discount_qty] [float] NULL,
[priced_qty] [float] NULL,
[qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[avg_purch_price] [float] NULL,
[avg_sale_price] [float] NULL,
[rt_avg_purch_price] [float] NULL,
[rt_avg_sale_price] [float] NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[tmp_position_updtrg]
on [dbo].[tmp_position]
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

GO
ALTER TABLE [dbo].[tmp_position] ADD CONSTRAINT [tmp_position_pk] PRIMARY KEY CLUSTERED  ([pos_num]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [tmp_position_idx1] ON [dbo].[tmp_position] ([pos_type], [real_port_num], [is_equiv_ind], [what_if_ind], [commkt_key], [trading_prd], [formula_num], [option_type], [settlement_type], [strike_price], [strike_price_curr_code], [strike_price_uom_code], [put_call_ind], [opt_start_date], [opt_exp_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tmp_position] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tmp_position] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tmp_position] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tmp_position] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'tmp_position', NULL, NULL
GO
