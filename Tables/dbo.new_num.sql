CREATE TABLE [dbo].[new_num]
(
[num_col_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_num] [smallint] NOT NULL,
[last_num] [int] NOT NULL,
[owner_table] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[owner_column] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[new_num] ADD CONSTRAINT [new_num_pk] PRIMARY KEY CLUSTERED  ([num_col_name], [loc_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[new_num] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[new_num] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[new_num] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[new_num] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'new_num', NULL, NULL
GO
