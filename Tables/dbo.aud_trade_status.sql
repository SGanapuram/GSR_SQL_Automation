CREATE TABLE [dbo].[aud_trade_status]
(
[trade_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trade_status_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_status] ON [dbo].[aud_trade_status] ([trade_status_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_status_idx1] ON [dbo].[aud_trade_status] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_trade_status] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_status] TO [next_usr]
GO
