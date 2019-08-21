CREATE TABLE [dbo].[aud_rc_assign_trade]
(
[assign_num] [int] NOT NULL,
[risk_cover_num] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[cargo_value] [decimal] (20, 8) NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_rc_assign_trade] ON [dbo].[aud_rc_assign_trade] ([assign_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_rc_assign_trade_idx1] ON [dbo].[aud_rc_assign_trade] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_rc_assign_trade] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_rc_assign_trade] TO [next_usr]
GO
