CREATE TABLE [dbo].[aud_commodity_specification]
(
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_spec_min_val] [numeric] (20, 8) NULL,
[cmdty_spec_max_val] [numeric] (20, 8) NULL,
[cmdty_spec_typical_val] [numeric] (20, 8) NULL,
[spec_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[typical_string_value] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dflt_spec_test_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[standard_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[equiv_pay_deduct_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[equiv_del_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[equiv_del_dflt_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[typical_spec_opt_val] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prim_paydeduct_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_paydeduct_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[regulatory_value] [float] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commodity_specification] ON [dbo].[aud_commodity_specification] ([cmdty_code], [spec_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commodity_specificat_idx1] ON [dbo].[aud_commodity_specification] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_commodity_specification] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_commodity_specification] TO [next_usr]
GO
