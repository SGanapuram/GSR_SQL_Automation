CREATE TABLE [dbo].[aud_lc_type]
(
[lc_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_type_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_type_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_type_num] [tinyint] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lc_type] ON [dbo].[aud_lc_type] ([lc_type_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lc_type_idx1] ON [dbo].[aud_lc_type] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_lc_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_lc_type] TO [next_usr]
GO
