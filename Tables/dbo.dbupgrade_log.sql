CREATE TABLE [dbo].[dbupgrade_log]
(
[oid] [numeric] (32, 0) NOT NULL IDENTITY(1, 1),
[owner_code] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[major_revnum] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[minor_revnum] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_touch_date] [datetime] NULL,
[data_source] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[usage] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[script_reference] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[upgrade_date] [datetime] NOT NULL,
[upgraded_by] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[hostname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[opcode] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dbupgrade_log] ADD CONSTRAINT [CK__dbupgrade__opcod__76EBA2E9] CHECK (([opcode]='U' OR [opcode]='I'))
GO
ALTER TABLE [dbo].[dbupgrade_log] ADD CONSTRAINT [PK__dbupgrad__C2FFCF1375035A77] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[dbupgrade_log] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[dbupgrade_log] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'dbupgrade_log', NULL, NULL
GO
