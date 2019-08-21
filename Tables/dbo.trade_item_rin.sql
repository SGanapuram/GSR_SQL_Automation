CREATE TABLE [dbo].[trade_item_rin]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[rin_impact_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rin_action_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rin_port_num] [int] NULL,
[rin_p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_trade_item_rin_rin_p_s_ind] DEFAULT ('P'),
[rin_impact_date] [datetime] NULL,
[rin_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[counterparty_qty] [numeric] (20, 8) NOT NULL,
[manual_settled_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_trade_item_rin_manual_settled_ind] DEFAULT ('Y'),
[settled_cur_y_sqty] [numeric] (20, 8) NOT NULL,
[settled_pre_y_sqty] [numeric] (20, 8) NOT NULL,
[rin_sep_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_trade_item_rin_rin_sep_status] DEFAULT ('A'),
[rin_pcent_year] [numeric] (20, 8) NOT NULL,
[py_rin_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[manual_epa_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_trade_item_rin_manual_epa_ind] DEFAULT ('N'),
[epa_imp_prod_qty] [numeric] (20, 8) NOT NULL,
[epa_exp_qty] [numeric] (20, 8) NOT NULL,
[manual_commit_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_trade_item_rin_manual_commit_ind] DEFAULT ('N'),
[committed_sqty] [numeric] (20, 8) NOT NULL,
[rin_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mf_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[manual_rvo_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_trade_item_rin_manual_rvo_ind] DEFAULT ('N'),
[rvo_mf_qty] [numeric] (20, 8) NOT NULL,
[rvo_mf_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rins_finalized] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_trade_item_rin_rins_finalized] DEFAULT ('N'),
[impact_begin_year] [smallint] NOT NULL,
[impact_current_year] [smallint] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [chk_trade_item_rin_manual_commit_ind] CHECK (([manual_commit_ind]='N' OR [manual_commit_ind]='Y'))
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [chk_trade_item_rin_manual_epa_ind] CHECK (([manual_epa_ind]='N' OR [manual_epa_ind]='Y'))
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [chk_trade_item_rin_manual_rvo_ind] CHECK (([manual_rvo_ind]='N' OR [manual_rvo_ind]='Y'))
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [chk_trade_item_rin_manual_settled_ind] CHECK (([manual_settled_ind]='N' OR [manual_settled_ind]='Y'))
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [chk_trade_item_rin_rin_action_code] CHECK (([rin_action_code]=NULL OR [rin_action_code]='N' OR [rin_action_code]='M' OR [rin_action_code]='O' OR [rin_action_code]='X' OR [rin_action_code]='R' OR [rin_action_code]='L' OR [rin_action_code]='C' OR [rin_action_code]='P' OR [rin_action_code]='E' OR [rin_action_code]='I'))
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [chk_trade_item_rin_rin_impact_type] CHECK (([rin_impact_type]=NULL OR [rin_impact_type]='R' OR [rin_impact_type]='M' OR [rin_impact_type]='B'))
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [chk_trade_item_rin_rin_p_s_ind] CHECK (([rin_p_s_ind]='S' OR [rin_p_s_ind]='P'))
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [chk_trade_item_rin_rin_sep_status] CHECK (([rin_sep_status]='S' OR [rin_sep_status]='A'))
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [chk_trade_item_rin_rins_finalized] CHECK (([rins_finalized]='N' OR [rins_finalized]='Y'))
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [trade_item_rin_pk] PRIMARY KEY CLUSTERED  ([trade_num], [item_num], [order_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [trade_item_rin_fk1] FOREIGN KEY ([rin_port_num]) REFERENCES [dbo].[portfolio] ([port_num])
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [trade_item_rin_fk2] FOREIGN KEY ([rin_cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [trade_item_rin_fk3] FOREIGN KEY ([py_rin_cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [trade_item_rin_fk4] FOREIGN KEY ([rvo_mf_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[trade_item_rin] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_rin] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_rin] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_rin] TO [next_usr]
GO
