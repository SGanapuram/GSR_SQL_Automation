CREATE TABLE [dbo].[aud_var_output]
(
[oid] [numeric] (32, 0) NOT NULL,
[var_run_id] [int] NOT NULL,
[bucket_type] [int] NOT NULL,
[bucket_tag] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[confidence_level] [numeric] (20, 8) NOT NULL,
[var_period] [datetime] NULL,
[var_amount] [numeric] (20, 8) NULL,
[port_run_list] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cvar_amount] [numeric] (20, 8) NULL,
[operation] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[userid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[date_op] [datetime] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_var_output] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_var_output] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_var_output] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_var_output] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_var_output] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_var_output', NULL, NULL
GO
