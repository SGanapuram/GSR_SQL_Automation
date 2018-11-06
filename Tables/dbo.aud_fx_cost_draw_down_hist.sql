CREATE TABLE [dbo].[aud_fx_cost_draw_down_hist]
(
[oid] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[from_fx_pl_asof_date] [datetime] NULL,
[cost_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_rec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[from_cost_num] [int] NULL,
[to_cost_num] [int] NULL,
[draw_down_up_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fx_pl_roll_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fx_cost_draw_down_hist] ON [dbo].[aud_fx_cost_draw_down_hist] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fx_cost_draw_dn_hist_idx1] ON [dbo].[aud_fx_cost_draw_down_hist] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_fx_cost_draw_down_hist] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_fx_cost_draw_down_hist] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_fx_cost_draw_down_hist] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_fx_cost_draw_down_hist] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_fx_cost_draw_down_hist] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_fx_cost_draw_down_hist', NULL, NULL
GO
