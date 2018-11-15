CREATE TABLE [dbo].[aud_conc_contract_prior_version]
(
[oid] [int] NOT NULL,
[conc_contract_oid] [int] NULL,
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
[real_port_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[formula_num] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_contract_prior_version] ON [dbo].[aud_conc_contract_prior_version] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_contract_prior_version_idx1] ON [dbo].[aud_conc_contract_prior_version] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_conc_contract_prior_version] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_conc_contract_prior_version] TO [next_usr]
GO
