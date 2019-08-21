CREATE TABLE [dbo].[aud_facility_tank_group]
(
[facility_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tank_num] [int] NOT NULL,
[connected_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_facility_tank_group] ON [dbo].[aud_facility_tank_group] ([facility_code], [tank_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_facility_tank_group_idx1] ON [dbo].[aud_facility_tank_group] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_facility_tank_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_facility_tank_group] TO [next_usr]
GO
