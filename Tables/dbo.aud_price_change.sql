CREATE TABLE [dbo].[aud_price_change]
(
[price_change_num] [int] NOT NULL,
[commkt_key] [int] NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_quote_date] [datetime] NOT NULL,
[price_changed_on] [datetime] NOT NULL,
[is_fully_repriced_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_price_change] ON [dbo].[aud_price_change] ([price_change_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_price_change_idx1] ON [dbo].[aud_price_change] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_price_change] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_price_change] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_price_change] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_price_change] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_price_change] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_price_change', NULL, NULL
GO
