CREATE TABLE [dbo].[aud_mot_type_for_order]
(
[mot_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[virtual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_mot_type_for_order_idx1] ON [dbo].[aud_mot_type_for_order] ([mot_type_code], [order_type_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_mot_type_for_order_idx2] ON [dbo].[aud_mot_type_for_order] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_mot_type_for_order] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_mot_type_for_order] TO [next_usr]
GO
