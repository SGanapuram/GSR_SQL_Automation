CREATE TABLE [dbo].[aud_trade_item_rin]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[rin_impact_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rin_action_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rin_port_num] [int] NULL,
[rin_p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__aud_trade__rin_p__5C629536] DEFAULT ('P'),
[rin_impact_date] [datetime] NULL,
[rin_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[counterparty_qty] [numeric] (20, 8) NOT NULL,
[manual_settled_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__aud_trade__manua__5D56B96F] DEFAULT ('Y'),
[settled_cur_y_sqty] [numeric] (20, 8) NOT NULL,
[settled_pre_y_sqty] [numeric] (20, 8) NOT NULL,
[rin_sep_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__aud_trade__rin_s__5E4ADDA8] DEFAULT ('A'),
[rin_pcent_year] [numeric] (20, 8) NOT NULL,
[py_rin_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[manual_epa_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__aud_trade__manua__5F3F01E1] DEFAULT ('N'),
[epa_imp_prod_qty] [numeric] (20, 8) NOT NULL,
[epa_exp_qty] [numeric] (20, 8) NOT NULL,
[manual_commit_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__aud_trade__manua__6033261A] DEFAULT ('N'),
[committed_sqty] [numeric] (20, 8) NOT NULL,
[rin_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mf_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[manual_rvo_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__aud_trade__manua__61274A53] DEFAULT ('N'),
[rvo_mf_qty] [numeric] (20, 8) NOT NULL,
[rvo_mf_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rins_finalized] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__aud_trade__rins___621B6E8C] DEFAULT ('N'),
[impact_begin_year] [smallint] NOT NULL,
[impact_current_year] [smallint] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_rin_idx1] ON [dbo].[aud_trade_item_rin] ([trade_num], [order_num], [item_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_rin_idx2] ON [dbo].[aud_trade_item_rin] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_trade_item_rin] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_rin] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_trade_item_rin] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_trade_item_rin] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_rin] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_trade_item_rin', NULL, NULL
GO
