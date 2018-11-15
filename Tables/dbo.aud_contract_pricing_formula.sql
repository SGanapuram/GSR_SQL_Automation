CREATE TABLE [dbo].[aud_contract_pricing_formula]
(
[oid] [int] NOT NULL,
[conc_contract_oid] [int] NULL,
[use_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_contract_pricing_formula] ON [dbo].[aud_contract_pricing_formula] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_contract_pricing_formula_idx1] ON [dbo].[aud_contract_pricing_formula] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_contract_pricing_formula] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_contract_pricing_formula] TO [next_usr]
GO
