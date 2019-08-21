CREATE TABLE [dbo].[aud_conc_assay_activity]
(
[oid] [int] NOT NULL,
[conc_contract_oid] [int] NOT NULL,
[version_num] [smallint] NULL,
[conc_prior_ver_oid] [int] NULL,
[assay_activity_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[target] [int] NOT NULL,
[time] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[activity_trigger] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_assay_activity] ON [dbo].[aud_conc_assay_activity] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_assay_activity_idx1] ON [dbo].[aud_conc_assay_activity] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_conc_assay_activity] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_conc_assay_activity] TO [next_usr]
GO
