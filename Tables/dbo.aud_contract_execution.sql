CREATE TABLE [dbo].[aud_contract_execution]
(
[oid] [int] NOT NULL,
[exec_purch_sale_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[parent_exec_id] [int] NULL,
[pcnt_factor] [float] NULL,
[exec_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[real_port_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[custom_exec_num] [int] NULL,
[conc_contract_oid] [int] NULL,
[prorated_flat_amt] [float] NULL,
[flat_amt_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_contract_execution] ON [dbo].[aud_contract_execution] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_contract_execution_idx1] ON [dbo].[aud_contract_execution] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_contract_execution] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_contract_execution] TO [next_usr]
GO
