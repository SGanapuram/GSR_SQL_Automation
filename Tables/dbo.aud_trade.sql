CREATE TABLE [dbo].[aud_trade]
(
[trade_num] [int] NOT NULL,
[trader_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[conclusion_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inhouse_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_num] [int] NULL,
[acct_cont_num] [int] NULL,
[acct_short_name] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_ref_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[port_num] [int] NULL,
[concluded_date] [datetime] NULL,
[contr_approv_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_date] [datetime] NULL,
[cr_anly_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cp_gov_contr_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_exch_method] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_cnfrm_method] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_tlx_hold_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_date] [datetime] NOT NULL,
[creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trade_mod_date] [datetime] NULL,
[trade_mod_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[invoice_cap_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[internal_agreement_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_res_exp_date] [datetime] NULL,
[contr_anly_init] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_order_num] [smallint] NULL,
[is_long_term_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[special_contract_num] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cargo_id_number] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[internal_parent_trade_num] [int] NULL,
[copy_type] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[product_id] [int] NULL,
[econfirm_status] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_trade_type] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_idx2] ON [dbo].[aud_trade] ([resp_trans_id]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [aud_trade] ON [dbo].[aud_trade] ([trade_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_idx1] ON [dbo].[aud_trade] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_trade] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_trade] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_trade] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_trade] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_trade', NULL, NULL
GO
