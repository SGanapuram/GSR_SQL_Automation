CREATE TABLE [dbo].[aud_tax]
(
[tax_num] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tax_authority_num] [int] NOT NULL,
[tax_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tax_calc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tax_gross_net_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tax_flat_fee_basis] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tax_tiered_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tax_range_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tax_rate_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tax_rate_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tax_eff_date] [datetime] NULL,
[tax_exp_date] [datetime] NULL,
[order_type_group] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_type_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[override_exemptions_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tax_exports_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[use_additional_primary_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[override_pass_through_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_tax] ON [dbo].[aud_tax] ([tax_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_tax_idx1] ON [dbo].[aud_tax] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_tax] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_tax] TO [next_usr]
GO
