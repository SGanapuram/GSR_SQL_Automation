CREATE TABLE [dbo].[aud_commodity_location]
(
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[typical_gravity] [float] NULL,
[cmdty_delivered_scheduled] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_received_scheduled] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commodity_location] ON [dbo].[aud_commodity_location] ([cmdty_code], [loc_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commodity_location_idx1] ON [dbo].[aud_commodity_location] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_commodity_location] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_commodity_location] TO [next_usr]
GO
