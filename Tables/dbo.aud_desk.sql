CREATE TABLE [dbo].[aud_desk]
(
[desk_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[desk_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dept_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[manager_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_desk] ON [dbo].[aud_desk] ([desk_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_desk_idx1] ON [dbo].[aud_desk] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_desk] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_desk] TO [next_usr]
GO
