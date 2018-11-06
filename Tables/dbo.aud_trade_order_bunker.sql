CREATE TABLE [dbo].[aud_trade_order_bunker]
(
[trade_num] [int] NOT NULL,
[order_num] [int] NOT NULL,
[bunker_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[duty_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[vat_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[auto_alloc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[not_to_vouch_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[brkr_num] [int] NULL,
[brkr_cont_num] [int] NULL,
[brkr_ref_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[brkr_tel_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comm_amt] [float] NULL,
[comm_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comm_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transp_price_comp_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transp_price_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transp_price_amt] [float] NULL,
[transp_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[fiscal_class_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_order_bunker_idx1] ON [dbo].[aud_trade_order_bunker] ([trade_num], [order_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_order_bunker_idx2] ON [dbo].[aud_trade_order_bunker] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_trade_order_bunker] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_trade_order_bunker] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_trade_order_bunker] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_trade_order_bunker] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_order_bunker] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_trade_order_bunker', NULL, NULL
GO
