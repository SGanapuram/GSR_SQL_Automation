CREATE TABLE [dbo].[dashboard_errorlog]
(
[oid] [bigint] NOT NULL IDENTITY(1, 1),
[creation_date] [datetime] NULL CONSTRAINT [DF__dashboard__creat__729298CE] DEFAULT (getdate()),
[logged_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[report_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[occurred_at] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[problem_desc] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dberror_msg] [varchar] (800) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sql_stmt] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[session_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dashboard_errorlog] ADD CONSTRAINT [PK__dashboar__C2FFCF1370AA505C] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
