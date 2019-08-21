CREATE TABLE [dbo].[aud_limit_type]
(
[limit_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[limit_type_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[limit_type_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[limit_type_num] [smallint] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_limit_type] ON [dbo].[aud_limit_type] ([limit_type_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_limit_type_idx1] ON [dbo].[aud_limit_type] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_limit_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_limit_type] TO [next_usr]
GO
