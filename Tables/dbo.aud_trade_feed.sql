CREATE TABLE [dbo].[aud_trade_feed]
(
[fdd_id] [int] NOT NULL,
[icts_trade_num] [int] NULL,
[econfirm_status] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_submitted_time] [datetime] NULL,
[resubmit_count] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_feed] ON [dbo].[aud_trade_feed] ([fdd_id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_feed_idx1] ON [dbo].[aud_trade_feed] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_trade_feed] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_feed] TO [next_usr]
GO
