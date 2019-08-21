CREATE TABLE [dbo].[event]
(
[event_num] [int] NOT NULL,
[event_time] [datetime] NULL,
[event_owner] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_code] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_asof_date] [datetime] NULL,
[event_owner_key1] [int] NULL,
[event_owner_key2] [int] NULL,
[event_description] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_controller] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL CONSTRAINT [df_event_trans_id] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[event] ADD CONSTRAINT [event_pk] PRIMARY KEY NONCLUSTERED  ([event_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [event_idx1] ON [dbo].[event] ([event_description], [event_asof_date]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [event] ON [dbo].[event] ([event_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[event] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[event] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[event] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[event] TO [next_usr]
GO
