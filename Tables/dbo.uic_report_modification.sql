CREATE TABLE [dbo].[uic_report_modification]
(
[oid] [int] NOT NULL,
[entity_id] [int] NOT NULL,
[key1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[key2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[operation_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[resp_trans_id] [int] NOT NULL,
[app_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tran_date] [datetime] NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[uic_report_modification] ADD CONSTRAINT [chk_uic_report_modification_operation_type] CHECK (([operation_type]='D' OR [operation_type]='U' OR [operation_type]='I'))
GO
ALTER TABLE [dbo].[uic_report_modification] ADD CONSTRAINT [uic_report_modification_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[uic_report_modification] ADD CONSTRAINT [uic_report_modification_fk1] FOREIGN KEY ([entity_id]) REFERENCES [dbo].[icts_entity_name] ([oid])
GO
GRANT DELETE ON  [dbo].[uic_report_modification] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[uic_report_modification] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[uic_report_modification] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[uic_report_modification] TO [next_usr]
GO
