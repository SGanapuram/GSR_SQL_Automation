CREATE TABLE [dbo].[bulk_voucher_queue]
(
[oid] [int] NOT NULL,
[voucher_num] [int] NOT NULL,
[action_type] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[creation_date] [datetime] NOT NULL,
[misc_col] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[bulk_voucher_queue] ADD CONSTRAINT [bulk_voucher_queue_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[bulk_voucher_queue] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[bulk_voucher_queue] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[bulk_voucher_queue] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[bulk_voucher_queue] TO [next_usr]
GO
