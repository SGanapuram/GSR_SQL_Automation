CREATE TABLE [dbo].[aud_facility_type]
(
[facility_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[facility_type_long_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_facility_type] ON [dbo].[aud_facility_type] ([facility_type_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_facility_type_idx1] ON [dbo].[aud_facility_type] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_facility_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_facility_type] TO [next_usr]
GO
