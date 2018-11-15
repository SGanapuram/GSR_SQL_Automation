CREATE TABLE [dbo].[aud_conc_assay_lab]
(
[oid] [int] NOT NULL,
[conc_contract_oid] [int] NOT NULL,
[version_num] [smallint] NULL,
[conc_prior_ver_oid] [int] NULL,
[assay_lab_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[final_binding_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[umpire_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_assay_lab] ON [dbo].[aud_conc_assay_lab] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_assay_lab_idx1] ON [dbo].[aud_conc_assay_lab] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_conc_assay_lab] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_conc_assay_lab] TO [next_usr]
GO
