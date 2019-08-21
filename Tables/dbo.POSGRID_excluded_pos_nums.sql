CREATE TABLE [dbo].[POSGRID_excluded_pos_nums]
(
[pos_num] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[POSGRID_excluded_pos_nums] ADD CONSTRAINT [POSGRID_excluded_pos_nums_pk] PRIMARY KEY CLUSTERED  ([pos_num]) ON [PRIMARY]
GO
