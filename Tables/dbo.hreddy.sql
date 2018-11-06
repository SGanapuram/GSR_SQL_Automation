CREATE TABLE [dbo].[hreddy]
(
[oid] [int] NOT NULL,
[domain_id] [int] NOT NULL,
[desk_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[culture] [char] (5) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[res_type] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[res_key] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[res_value] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[sub_fieldname_0] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sub_fieldname_1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sub_fieldname_2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sub_fieldname_3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sub_fieldname_4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sub_fieldname_5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[oid_new] [int] NOT NULL IDENTITY(546, 1)
) ON [PRIMARY]
GO
