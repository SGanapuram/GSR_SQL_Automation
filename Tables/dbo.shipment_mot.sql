CREATE TABLE [dbo].[shipment_mot]
(
[shipment_num] [int] NOT NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[shipment_mot] ADD CONSTRAINT [shipment_mot_pk] PRIMARY KEY CLUSTERED  ([shipment_num], [mot_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[shipment_mot] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[shipment_mot] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[shipment_mot] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[shipment_mot] TO [next_usr]
GO
