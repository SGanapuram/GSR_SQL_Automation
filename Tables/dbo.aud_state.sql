CREATE TABLE [dbo].[aud_state]
(
[state_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[state_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[state_num] [smallint] NOT NULL,
[calendar_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_state] ON [dbo].[aud_state] ([state_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_state_idx1] ON [dbo].[aud_state] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_state] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_state] TO [next_usr]
GO
