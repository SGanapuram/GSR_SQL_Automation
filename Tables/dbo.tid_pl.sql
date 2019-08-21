CREATE TABLE [dbo].[tid_pl]
(
[dist_num] [int] NOT NULL,
[open_pl] [float] NULL,
[closed_pl] [float] NULL,
[pl_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[addl_cost_sum] [float] NULL,
[pl_asof_date] [datetime] NULL,
[trans_id] [bigint] NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
ALTER TABLE [dbo].[tid_pl] ADD CONSTRAINT [tid_pl_pk] PRIMARY KEY CLUSTERED  ([dist_num]) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tid_pl] ADD CONSTRAINT [tid_pl_fk2] FOREIGN KEY ([pl_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[tid_pl] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tid_pl] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tid_pl] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tid_pl] TO [next_usr]
GO
