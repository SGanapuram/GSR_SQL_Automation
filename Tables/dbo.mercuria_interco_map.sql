CREATE TABLE [dbo].[mercuria_interco_map]
(
[interco_num] [int] NULL,
[interco_name] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[mercuria_interco_map] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[mercuria_interco_map] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[mercuria_interco_map] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[mercuria_interco_map] TO [next_usr]
GO
