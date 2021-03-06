CREATE TABLE [dbo].[aud_lm_net_position_history]
(
[oid] [int] NOT NULL,
[margin_asof_day] [datetime] NOT NULL,
[clr_brkr_num] [int] NOT NULL,
[item_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[put_call_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[strike] [decimal] (20, 8) NULL,
[net_position] [decimal] (20, 8) NOT NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lm_net_position_history] ON [dbo].[aud_lm_net_position_history] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lm_net_pos_history_idx1] ON [dbo].[aud_lm_net_position_history] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_lm_net_position_history] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_lm_net_position_history] TO [next_usr]
GO
