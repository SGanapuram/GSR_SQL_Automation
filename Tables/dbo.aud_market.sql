CREATE TABLE [dbo].[aud_market]
(
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_full_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_market] ON [dbo].[aud_market] ([mkt_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_market_idx1] ON [dbo].[aud_market] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_market] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_market] TO [next_usr]
GO
