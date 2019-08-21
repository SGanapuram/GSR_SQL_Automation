CREATE TABLE [dbo].[aud_trade_group]
(
[trade_group_num] [int] NOT NULL,
[trade_group_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trade_group_desc] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_group] ON [dbo].[aud_trade_group] ([trade_group_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_group_idx1] ON [dbo].[aud_trade_group] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_trade_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_group] TO [next_usr]
GO
