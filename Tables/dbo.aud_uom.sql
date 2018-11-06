CREATE TABLE [dbo].[aud_uom]
(
[uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uom_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uom_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uom_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uom_full_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uom_num] [smallint] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_uom_idx1] ON [dbo].[aud_uom] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_uom] ON [dbo].[aud_uom] ([uom_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_uom] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_uom] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_uom] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_uom] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_uom] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_uom', NULL, NULL
GO
