CREATE TABLE [dbo].[fx_hedge_rate]
(
[fx_hedge_rate_num] [int] NOT NULL,
[commkt_key] [int] NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[clr_brkr_num] [int] NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[from_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[to_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[conv_rate] [numeric] (20, 8) NOT NULL,
[mul_div_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_fx_hedge_rate_mul_div_ind] DEFAULT ('M'),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fx_hedge_rate] ADD CONSTRAINT [chk_fx_hedge_rate_mul_div_ind] CHECK (([mul_div_ind]='D' OR [mul_div_ind]='M'))
GO
ALTER TABLE [dbo].[fx_hedge_rate] ADD CONSTRAINT [fx_hedge_rate_pk] PRIMARY KEY CLUSTERED  ([fx_hedge_rate_num]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [fx_hedge_rate_idx1] ON [dbo].[fx_hedge_rate] ([commkt_key], [trading_prd], [clr_brkr_num], [price_source_code], [from_curr_code], [to_curr_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fx_hedge_rate] ADD CONSTRAINT [fx_hedge_rate_fk1] FOREIGN KEY ([commkt_key], [trading_prd]) REFERENCES [dbo].[trading_period] ([commkt_key], [trading_prd])
GO
ALTER TABLE [dbo].[fx_hedge_rate] ADD CONSTRAINT [fx_hedge_rate_fk2] FOREIGN KEY ([clr_brkr_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[fx_hedge_rate] ADD CONSTRAINT [fx_hedge_rate_fk3] FOREIGN KEY ([price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[fx_hedge_rate] ADD CONSTRAINT [fx_hedge_rate_fk4] FOREIGN KEY ([from_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[fx_hedge_rate] ADD CONSTRAINT [fx_hedge_rate_fk5] FOREIGN KEY ([to_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[fx_hedge_rate] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[fx_hedge_rate] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[fx_hedge_rate] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[fx_hedge_rate] TO [next_usr]
GO
