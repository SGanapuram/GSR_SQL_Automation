CREATE TABLE [dbo].[aud_var_limit]
(
[oid] [int] NOT NULL,
[port_num_list] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[limit_type] [char] (5) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[confidence_level] [numeric] (20, 8) NOT NULL,
[horizon] [int] NULL,
[var_limit] [float] NOT NULL,
[var_limit_curr_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[last_update_date] [datetime] NOT NULL,
[operation] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[userid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[date_op] [datetime] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_var_limit] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_var_limit] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_var_limit] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_var_limit] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_var_limit] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_var_limit', NULL, NULL
GO
