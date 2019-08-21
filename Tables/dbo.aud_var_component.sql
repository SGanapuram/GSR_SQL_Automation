CREATE TABLE [dbo].[aud_var_component]
(
[rowid] [int] NOT NULL,
[var_run_id] [int] NOT NULL,
[port_num_list] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_key] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[component_amt] [float] NULL,
[annual_volatility] [float] NULL,
[var_pct] [float] NULL,
[var_amt] [float] NULL,
[open_qty] [float] NULL,
[open_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[settl_price] [float] NULL,
[settl_exch_rate] [float] NULL,
[settl_price_curr_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[time_hor_price] [float] NULL,
[time_hor_exch_rate] [float] NULL,
[time_hor_price_curr_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[time_hor_component_amt] [float] NULL,
[time_hor_price_date] [datetime] NULL,
[time_hor_calc_date] [datetime] NULL,
[time_hor_calc_user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[operation] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[userid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[date_op] [datetime] NOT NULL
) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_var_component] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_var_component] TO [next_usr]
GO
