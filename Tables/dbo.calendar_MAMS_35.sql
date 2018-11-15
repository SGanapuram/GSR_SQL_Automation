CREATE TABLE [dbo].[calendar_MAMS_35]
(
[calendar_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[calendar_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[calendar_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[calendar_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[calendar_date_mask] [char] (7) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[calendar_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
