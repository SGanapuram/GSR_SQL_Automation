CREATE TABLE [dbo].[account_group]
(
[related_acct_num] [int] NOT NULL,
[acct_num] [int] NOT NULL,
[acct_group_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[parent_acct_own_pcnt] [float] NULL,
[acct_group_relation] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[account_group] ADD CONSTRAINT [account_group_pk] PRIMARY KEY CLUSTERED  ([related_acct_num], [acct_num], [acct_group_type_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[account_group] ADD CONSTRAINT [account_group_fk1] FOREIGN KEY ([related_acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[account_group] ADD CONSTRAINT [account_group_fk2] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[account_group] ADD CONSTRAINT [account_group_fk3] FOREIGN KEY ([acct_group_type_code]) REFERENCES [dbo].[account_group_type] ([acct_group_type_code])
GO
GRANT DELETE ON  [dbo].[account_group] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[account_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[account_group] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[account_group] TO [next_usr]
GO
