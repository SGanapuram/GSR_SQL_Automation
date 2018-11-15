CREATE TABLE [dbo].[aud_conc_ref_result_type]
(
[oid] [int] NOT NULL,
[result_type] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[result_type_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_ref_result_type] ON [dbo].[aud_conc_ref_result_type] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_ref_result_type_idx1] ON [dbo].[aud_conc_ref_result_type] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_conc_ref_result_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_conc_ref_result_type] TO [next_usr]
GO
