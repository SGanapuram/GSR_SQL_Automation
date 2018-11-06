CREATE TABLE [dbo].[aud_mot_location_tariff]
(
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_code_to] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ppl_tariff_eff_date] [datetime] NOT NULL,
[ppl_tariff_amt] [float] NULL,
[ppl_tariff_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ppl_tariff_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_mot_location_tariff] ON [dbo].[aud_mot_location_tariff] ([mot_code], [loc_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_mot_location_tariff_idx1] ON [dbo].[aud_mot_location_tariff] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_mot_location_tariff] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_mot_location_tariff] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_mot_location_tariff] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_mot_location_tariff] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_mot_location_tariff] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_mot_location_tariff', NULL, NULL
GO
