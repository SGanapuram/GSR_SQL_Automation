CREATE TABLE [dbo].[aud_mca_trade_item]
(
[mca_num] [int] NOT NULL,
[trade_num] [smallint] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [int] NOT NULL,
[mtm_amount] [float] NULL,
[mtm_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_mca_trade_item] ON [dbo].[aud_mca_trade_item] ([mca_num], [trade_num], [order_num], [item_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_mca_trade_item_idx1] ON [dbo].[aud_mca_trade_item] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_mca_trade_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_mca_trade_item] TO [next_usr]
GO
