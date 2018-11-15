CREATE TABLE [dbo].[aud_conc_contract]
(
[oid] [int] NOT NULL,
[custom_contract_num] [int] NOT NULL,
[version_num] [int] NOT NULL,
[custom_contract_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_reference] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contractual_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_year] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[book_comp_num] [int] NULL,
[acct_num] [int] NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[conc_brand_id] [int] NULL,
[workflow_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trader_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[traffic_operator] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cargo_conditioning] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[weighing_method_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[orig_contr_qty] [float] NULL,
[total_contr_qty] [float] NULL,
[total_execution_qty] [float] NULL,
[totoal_open_contr_qty] [float] NULL,
[total_contr_min] [float] NULL,
[total_contr_max] [float] NULL,
[main_formula_num] [int] NULL,
[market_formula_num] [int] NULL,
[real_port_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[risk_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fixed_price_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_fixed_price] [float] NULL,
[contract_fixed_price_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_fixed_curr_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[wsmd_settlement_basis] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[wsmd_insp_acct_num] [int] NULL,
[sample_lot_size] [float] NULL,
[sample_lot_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_date] [datetime] NULL,
[contract_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[origin_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_contract] ON [dbo].[aud_conc_contract] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_contract_idx1] ON [dbo].[aud_conc_contract] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_conc_contract] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_conc_contract] TO [next_usr]
GO
