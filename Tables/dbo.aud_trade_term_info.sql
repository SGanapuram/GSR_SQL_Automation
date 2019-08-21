CREATE TABLE [dbo].[aud_trade_term_info]
(
[trade_num] [int] NOT NULL,
[contr_start_date] [datetime] NULL,
[contr_end_date] [datetime] NULL,
[contr_ren_term_date] [datetime] NULL,
[warning_start_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[sap_contract_num] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_contract_item_num] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_term_info_idx] ON [dbo].[aud_trade_term_info] ([trade_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_trade_term_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_term_info] TO [next_usr]
GO
