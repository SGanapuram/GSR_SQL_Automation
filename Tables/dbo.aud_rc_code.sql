CREATE TABLE [dbo].[aud_rc_code]
(
[rc_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rc_code_desc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rc_code_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_rc_code] ON [dbo].[aud_rc_code] ([rc_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_rc_code_idx1] ON [dbo].[aud_rc_code] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_rc_code] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_rc_code] TO [next_usr]
GO
