CREATE TABLE [dbo].[aud_department]
(
[dept_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dept_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[profit_center_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[manager_init] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_cont_fld1_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_cont_fld2_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_cont_fld3_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_cont_fld4_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_cont_fld5_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_cont_fld6_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_acct_fld1_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_acct_fld2_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_acct_fld3_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_acct_fld4_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_acct_fld5_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_acct_fld6_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dept_num] [smallint] NULL,
[trading_entity_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_department] ON [dbo].[aud_department] ([dept_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_department_idx1] ON [dbo].[aud_department] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_department] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_department] TO [next_usr]
GO
