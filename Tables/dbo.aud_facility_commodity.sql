CREATE TABLE [dbo].[aud_facility_commodity]
(
[facility_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[capacity] [decimal] (20, 8) NULL,
[capacity_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_facility_commodity] ON [dbo].[aud_facility_commodity] ([facility_code], [cmdty_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_facility_commodity_idx1] ON [dbo].[aud_facility_commodity] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_facility_commodity] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_facility_commodity] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_facility_commodity] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_facility_commodity] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_facility_commodity] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_facility_commodity', NULL, NULL
GO
