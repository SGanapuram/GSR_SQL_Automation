CREATE TABLE [dbo].[aud_trade_default]
(
[dflt_num] [int] NOT NULL,
[acct_num] [int] NULL,
[cmdty_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_loc_code_key] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[order_type_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[risk_mkt_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[title_mkt_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_qty] [float] NULL,
[contr_qty_uom_code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[booking_comp_num] [int] NULL,
[gtc_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_term_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_loc_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[min_qty] [float] NULL,
[min_qty_uom_code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_qty] [float] NULL,
[max_qty_uom_code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_qty] [float] NULL,
[tol_qty_uom_code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_sign] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_opt] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_precision] [tinyint] NULL,
[brkr_num] [int] NULL,
[brkr_cont_num] [int] NULL,
[brkr_comm_amt] [float] NULL,
[brkr_comm_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[brkr_comm_uom_code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[brkr_ref_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_default] ON [dbo].[aud_trade_default] ([dflt_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_default_idx1] ON [dbo].[aud_trade_default] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_trade_default] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_default] TO [next_usr]
GO
