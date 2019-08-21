CREATE TABLE [dbo].[aud_var_run_detail]
(
[oid] [int] NOT NULL,
[var_run_id] [int] NOT NULL,
[key1] [char] (5) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[key2] [numeric] (20, 8) NULL,
[key3] [int] NULL,
[detail_value1] [float] NULL,
[detail_value2] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[detail_value3] [datetime] NOT NULL,
[operation] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[userid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[date_op] [datetime] NOT NULL
) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_var_run_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_var_run_detail] TO [next_usr]
GO
