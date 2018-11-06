CREATE TABLE [dbo].[var_output]
(
[oid] [numeric] (32, 0) NOT NULL IDENTITY(1, 1),
[var_run_id] [int] NOT NULL,
[bucket_type] [int] NOT NULL,
[bucket_tag] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[confidence_level] [numeric] (20, 8) NOT NULL,
[var_period] [datetime] NULL,
[var_amount] [numeric] (20, 8) NULL,
[port_run_list] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cvar_amount] [numeric] (20, 8) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[var_output] ADD CONSTRAINT [var_output_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[var_output] ADD CONSTRAINT [var_output_fk1] FOREIGN KEY ([var_run_id]) REFERENCES [dbo].[var_run] ([oid])
GO
GRANT DELETE ON  [dbo].[var_output] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[var_output] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[var_output] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[var_output] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'var_output', NULL, NULL
GO
