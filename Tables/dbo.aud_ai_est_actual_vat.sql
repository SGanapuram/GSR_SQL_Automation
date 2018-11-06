CREATE TABLE [dbo].[aud_ai_est_actual_vat]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [int] NOT NULL,
[ai_est_actual_num] [smallint] NOT NULL,
[origin_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[title_transfer_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[destination_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[vat_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[booking_comp_vat_number_id] [int] NULL,
[booking_comp_fiscal_rep] [int] NULL,
[counterparty_vat_number_id] [int] NULL,
[counterparty_fiscal_rep] [int] NULL,
[vat_trans_nature_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[vat_declaration_id] [int] NULL,
[cmdty_nomenclature_id] [int] NULL,
[aad] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[warehouse_permit_holder] [int] NULL,
[wph_vat_number_id] [int] NULL,
[vat_type_code] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[excise_num] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ready_for_accounting_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[vat_applies_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[warehouse_permit_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[excise_number_id] [int] NULL,
[tank_num] [int] NULL,
[wph_excise_num] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ai_est_actual_vat] ON [dbo].[aud_ai_est_actual_vat] ([alloc_num], [alloc_item_num], [ai_est_actual_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ai_est_actual_vat_idx1] ON [dbo].[aud_ai_est_actual_vat] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_ai_est_actual_vat] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_ai_est_actual_vat] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_ai_est_actual_vat] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_ai_est_actual_vat] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ai_est_actual_vat] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_ai_est_actual_vat', NULL, NULL
GO
