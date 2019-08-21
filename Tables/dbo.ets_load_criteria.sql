CREATE TABLE [dbo].[ets_load_criteria]
(
[instance_num] [smallint] NOT NULL,
[load_criteria] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ets_load_criteria] ADD CONSTRAINT [ets_load_criteria_pk] PRIMARY KEY CLUSTERED  ([instance_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ets_load_criteria] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ets_load_criteria] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ets_load_criteria] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ets_load_criteria] TO [next_usr]
GO
