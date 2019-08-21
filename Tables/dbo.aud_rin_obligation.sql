CREATE TABLE [dbo].[aud_rin_obligation]
(
[oid] [int] NOT NULL,
[mf_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rin_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[obligation_ratio] [numeric] (20, 8) NOT NULL,
[mf_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rin_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_rin_obligation_idx1] ON [dbo].[aud_rin_obligation] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_rin_obligation_idx2] ON [dbo].[aud_rin_obligation] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_rin_obligation] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_rin_obligation] TO [next_usr]
GO
