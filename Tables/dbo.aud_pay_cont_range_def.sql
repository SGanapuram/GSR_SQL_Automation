CREATE TABLE [dbo].[aud_pay_cont_range_def]
(
[oid] [int] NOT NULL,
[cp_formula_oid] [int] NULL,
[price_rule_oid] [int] NULL,
[dim_num] [smallint] NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[per_spec_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_from_value] [float] NULL,
[spec_to_value] [float] NULL,
[commkt_key] [int] NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_pay_cont_range_def] ON [dbo].[aud_pay_cont_range_def] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_pay_cont_range_def_idx1] ON [dbo].[aud_pay_cont_range_def] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_pay_cont_range_def] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_pay_cont_range_def] TO [next_usr]
GO
