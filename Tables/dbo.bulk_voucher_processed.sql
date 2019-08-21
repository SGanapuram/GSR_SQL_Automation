CREATE TABLE [dbo].[bulk_voucher_processed]
(
[queue_id] [int] NOT NULL,
[voucher_num] [int] NOT NULL,
[action_type] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[creation_date] [datetime] NOT NULL,
[start_date] [datetime] NULL,
[end_date] [datetime] NULL,
[inst_num] [int] NOT NULL,
[status] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[misc_col] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[bulk_voucher_processed] ADD CONSTRAINT [bulk_voucher_processed_pk] PRIMARY KEY CLUSTERED  ([queue_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[bulk_voucher_processed] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[bulk_voucher_processed] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[bulk_voucher_processed] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[bulk_voucher_processed] TO [next_usr]
GO
