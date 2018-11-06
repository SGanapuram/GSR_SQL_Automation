CREATE TABLE [dbo].[POSGRID_excluded_pos_nums]
(
[pos_num] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[POSGRID_excluded_pos_nums] ADD CONSTRAINT [PK__POSGRID___5F20217C4F495C91] PRIMARY KEY CLUSTERED  ([pos_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[POSGRID_excluded_pos_nums] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[POSGRID_excluded_pos_nums] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[POSGRID_excluded_pos_nums] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[POSGRID_excluded_pos_nums] TO [next_usr]
GO
