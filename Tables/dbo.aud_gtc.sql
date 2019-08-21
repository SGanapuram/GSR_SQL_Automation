CREATE TABLE [dbo].[aud_gtc]
(
[gtc_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[gtc_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[agreement_num] [int] NULL,
[agreement_date] [datetime] NULL,
[creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[creation_date] [datetime] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_gtc] ON [dbo].[aud_gtc] ([gtc_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_gtc_idx1] ON [dbo].[aud_gtc] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_gtc] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_gtc] TO [next_usr]
GO
