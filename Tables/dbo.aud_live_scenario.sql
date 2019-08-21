CREATE TABLE [dbo].[aud_live_scenario]
(
[oid] [int] NOT NULL,
[scenario_id] [int] NULL,
[live_scenario_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[creation_date] [datetime] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_live_scenario] ON [dbo].[aud_live_scenario] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_live_scenario_idx1] ON [dbo].[aud_live_scenario] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_live_scenario] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_live_scenario] TO [next_usr]
GO
