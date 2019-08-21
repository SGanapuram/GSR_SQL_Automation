CREATE TABLE [dbo].[aud_tax_rate]
(
[tax_rate_num] [int] NOT NULL,
[tax_num] [int] NOT NULL,
[product_usage_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tax_rate_eff_date] [datetime] NOT NULL,
[tax_rate_exp_date] [datetime] NULL,
[taxable_lower_range] [float] NULL,
[taxable_upper_range] [float] NULL,
[tax_rate_amt] [float] NULL,
[pass_thru_tax_rate] [float] NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_tax_rate] ON [dbo].[aud_tax_rate] ([tax_rate_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_tax_rate_idx1] ON [dbo].[aud_tax_rate] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_tax_rate] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_tax_rate] TO [next_usr]
GO
