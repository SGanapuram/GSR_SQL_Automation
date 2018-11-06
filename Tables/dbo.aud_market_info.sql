CREATE TABLE [dbo].[aud_market_info]
(
[mkt_info_num] [int] NOT NULL,
[mkt_info_headline] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_info_concluded_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_info_type] [tinyint] NOT NULL,
[idms_board_name] [char] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[newsgrazer_dept_name] [char] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_market_info] ON [dbo].[aud_market_info] ([mkt_info_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_market_info_idx1] ON [dbo].[aud_market_info] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_market_info] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_market_info] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_market_info] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_market_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_market_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_market_info', NULL, NULL
GO
