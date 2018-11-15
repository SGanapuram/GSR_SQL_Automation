CREATE TABLE [dbo].[aud_rc_rule_escalator_price_base]
(
[oid] [int] NOT NULL,
[cp_formula_oid] [int] NULL,
[price_rule_oid] [int] NULL,
[from_value] [float] NULL,
[to_value] [float] NULL,
[inc_dec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inc_dec_value] [float] NULL,
[floor_or_ceiling_value] [float] NULL,
[app_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rc_value] [float] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_rc_rule_escalator_price_base] ON [dbo].[aud_rc_rule_escalator_price_base] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_rc_rule_escalator_price_base_idx1] ON [dbo].[aud_rc_rule_escalator_price_base] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_rc_rule_escalator_price_base] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_rc_rule_escalator_price_base] TO [next_usr]
GO
