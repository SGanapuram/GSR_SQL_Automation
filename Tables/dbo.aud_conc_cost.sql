CREATE TABLE [dbo].[aud_conc_cost]
(
[oid] [int] NOT NULL,
[owner_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[conc_contract_oid] [int] NULL,
[contract_execution_oid] [int] NULL,
[contract_exec_detail_oid] [int] NULL,
[strategy_execution_oid] [int] NULL,
[strategy_execution_detail_oid] [int] NULL,
[conc_ref_cost_item_oid] [int] NULL,
[cost_basis] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exp_rev_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_unit_price] [float] NULL,
[cost_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_cmnt_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[comment] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_conc_cost] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_conc_cost] TO [next_usr]
GO
