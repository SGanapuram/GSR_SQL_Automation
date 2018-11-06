CREATE TABLE [dbo].[aud_fifo_group]
(
[fifo_group_num] [int] NOT NULL,
[commkt_key] [int] NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[clr_brkr_num] [int] NULL,
[item_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[strike_price] [numeric] (20, 8) NULL,
[put_call_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fifo_group] ON [dbo].[aud_fifo_group] ([fifo_group_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fifo_group_idx1] ON [dbo].[aud_fifo_group] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_fifo_group] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_fifo_group] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_fifo_group] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_fifo_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_fifo_group] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_fifo_group', NULL, NULL
GO
