CREATE TABLE [dbo].[aud_pay_cont_range_value]
(
[oid] [int] NOT NULL,
[cp_formula_oid] [int] NULL,
[price_rule_oid] [int] NULL,
[pay_range_def_oid1] [int] NULL,
[pay_range_def_oid2] [int] NULL,
[percentage] [float] NULL,
[deduction] [float] NULL,
[application] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_pay_cont_range_value] ON [dbo].[aud_pay_cont_range_value] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_pay_cont_range_value_idx1] ON [dbo].[aud_pay_cont_range_value] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_pay_cont_range_value] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_pay_cont_range_value] TO [next_usr]
GO
