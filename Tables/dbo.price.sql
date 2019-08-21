CREATE TABLE [dbo].[price]
(
[commkt_key] [int] NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_quote_date] [datetime] NOT NULL,
[low_bid_price] [float] NULL,
[high_asked_price] [float] NULL,
[avg_closed_price] [float] NULL,
[open_interest] [float] NULL,
[vol_traded] [float] NULL,
[creation_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[low_bid_creation_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[high_asked_creation_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[avg_closed_creation_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[price] ADD CONSTRAINT [price_pk] PRIMARY KEY CLUSTERED  ([commkt_key], [price_source_code], [trading_prd], [price_quote_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [price_idx3] ON [dbo].[price] ([commkt_key], [trading_prd], [price_quote_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [price_quote_date_idx] ON [dbo].[price] ([price_quote_date], [commkt_key], [price_source_code], [trading_prd]) INCLUDE ([avg_closed_price], [high_asked_price], [low_bid_price], [open_interest], [vol_traded]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [price_idx2] ON [dbo].[price] ([price_source_code], [price_quote_date], [trading_prd], [creation_type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [price_idx4] ON [dbo].[price] ([trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[price] ADD CONSTRAINT [price_fk1] FOREIGN KEY ([price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[price] ADD CONSTRAINT [price_fk2] FOREIGN KEY ([commkt_key], [trading_prd]) REFERENCES [dbo].[trading_period] ([commkt_key], [trading_prd])
GO
GRANT DELETE ON  [dbo].[price] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[price] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[price] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[price] TO [next_usr]
GO
