CREATE TABLE [dbo].[aud_pay_rule_fixprice_info]
(
[oid] [int] NOT NULL,
[cp_formula_oid] [int] NULL,
[price_rule_oid] [int] NULL,
[spec_from_value] [float] NULL,
[spec_to_value] [float] NULL,
[fixed_price] [float] NULL,
[fixed_price_basis] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_pay_rule_fixprice_info] ON [dbo].[aud_pay_rule_fixprice_info] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_pay_rule_fixprice_info_idx1] ON [dbo].[aud_pay_rule_fixprice_info] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_pay_rule_fixprice_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_pay_rule_fixprice_info] TO [next_usr]
GO
