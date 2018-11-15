CREATE TABLE [dbo].[interco_map]
(
[interco_num] [int] NULL,
[interco_name] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[interco_map] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[interco_map] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[interco_map] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[interco_map] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'interco_map', NULL, NULL
GO
