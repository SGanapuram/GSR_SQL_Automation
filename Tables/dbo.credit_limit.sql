CREATE TABLE [dbo].[credit_limit]
(
[credit_limit_num] [int] NOT NULL,
[limit_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[limit_direction] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[limit_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cr_analyst_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[limit_amt] [float] NOT NULL,
[curr_exp_amt] [float] NULL,
[limit_alarm_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[review_email_group] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[limit_cmnt_num] [int] NULL,
[acct_num] [int] NULL,
[lc_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_country_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[gross_net_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exposure_method_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[include_subsidiary_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[limit_amt_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[res_exp_amt] [float] NULL,
[trans_id] [int] NOT NULL,
[limit_line_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[limit_sub_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[book_comp_num] [int] NULL,
[prev_review_date] [datetime] NULL,
[next_review_date] [datetime] NULL,
[review_adv_notice_days] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[credit_limit] ADD CONSTRAINT [credit_limit_pk] PRIMARY KEY CLUSTERED  ([credit_limit_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[credit_limit] ADD CONSTRAINT [credit_limit_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[credit_limit] ADD CONSTRAINT [credit_limit_fk10] FOREIGN KEY ([book_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[credit_limit] ADD CONSTRAINT [credit_limit_fk2] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[credit_limit] ADD CONSTRAINT [credit_limit_fk3] FOREIGN KEY ([limit_amt_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[credit_limit] ADD CONSTRAINT [credit_limit_fk4] FOREIGN KEY ([country_code]) REFERENCES [dbo].[country] ([country_code])
GO
ALTER TABLE [dbo].[credit_limit] ADD CONSTRAINT [credit_limit_fk6] FOREIGN KEY ([cr_analyst_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[credit_limit] ADD CONSTRAINT [credit_limit_fk7] FOREIGN KEY ([lc_type_code]) REFERENCES [dbo].[lc_type] ([lc_type_code])
GO
ALTER TABLE [dbo].[credit_limit] ADD CONSTRAINT [credit_limit_fk9] FOREIGN KEY ([limit_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[credit_limit] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[credit_limit] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[credit_limit] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[credit_limit] TO [next_usr]
GO
