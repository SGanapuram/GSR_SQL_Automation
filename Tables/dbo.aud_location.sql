CREATE TABLE [dbo].[aud_location]
(
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[office_loc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[del_loc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[inv_loc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_num] [smallint] NOT NULL,
[loc_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[latitude] [numeric] (9, 6) NULL,
[longitude] [numeric] (9, 6) NULL,
[warehouse_agp_num] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_location] ON [dbo].[aud_location] ([loc_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_location_idx1] ON [dbo].[aud_location] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_location] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_location] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_location] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_location] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_location] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_location', NULL, NULL
GO
