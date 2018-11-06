CREATE TABLE [dbo].[aud_order_term_evergreen]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[contr_qty] [float] NULL,
[contr_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[term_prd_start_date] [datetime] NULL,
[term_prd_end_date] [datetime] NULL,
[del_date_from] [datetime] NULL,
[del_date_to] [datetime] NULL,
[buyer_seller_opt] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[term_min_qty] [float] NULL,
[term_max_qty] [float] NULL,
[term_qty_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[term_end_action] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[evergrn_cancel_notice] [int] NULL,
[evergrn_cancel_notice_prd] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[evergrn_start_date] [datetime] NULL,
[evergrn_end_date] [datetime] NULL,
[evergrn_future_dlvs] [int] NULL,
[dlv_buyer_seller_opt] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dlv_risk_vol_det] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_order_term_evergreen] ON [dbo].[aud_order_term_evergreen] ([trade_num], [order_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_order_term_evergreen_idx1] ON [dbo].[aud_order_term_evergreen] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_order_term_evergreen] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_order_term_evergreen] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_order_term_evergreen] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_order_term_evergreen] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_order_term_evergreen] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_order_term_evergreen', NULL, NULL
GO
