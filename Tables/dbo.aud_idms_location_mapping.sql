CREATE TABLE [dbo].[aud_idms_location_mapping]
(
[idms_loc_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[idms_loc_initial] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[idms_board_name] [char] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[newsgrazer_loc_name] [char] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_idms_location_mapping] ON [dbo].[aud_idms_location_mapping] ([idms_loc_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_idms_location_mappin_idx1] ON [dbo].[aud_idms_location_mapping] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_idms_location_mapping] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_idms_location_mapping] TO [next_usr]
GO
