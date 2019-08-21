CREATE TABLE [dbo].[rg_staging_acct_address]
(
[oid] [int] NOT NULL,
[feed_data_id] [int] NOT NULL,
[feed_detail_data_id] [int] NOT NULL,
[acct_addr_line_1] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_addr_line_2] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_line_3] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_line_4] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_city] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[state_code] [nchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[country_code] [nchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_addr_zip_code] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_ph_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_telex_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_fax_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_telex_ansback] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_fax_ansback] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_rg_staging_acct_address_acct_addr_status] DEFAULT ('A'),
[acct_addr_email] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[accounting_system_id] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[acct_instr_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[action_code] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[rg_staging_acct_address_updtrg]
on [dbo].[rg_staging_acct_address]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

/* RECORD_STAMP_BEGIN */
--if not update(trans_id) 
--begin
--   raiserror ('(rg_staging_acct_address) The change needs to be attached with a new trans_id.',16,1)
--   if @@trancount > 0 rollback tran

--   return
--end

/* added by Peter Lo  Sep-4-2002 */
/*
if exists (select 1
           from master.dbo.sysprocesses
           where spid = @@spid and
                (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                 program_name like 'Microsoft SQL Server Management Studio%') )
begin
   if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0
   begin
      select @errmsg = '(rg_staging_acct_address) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   select @errmsg = '(rg_staging_acct_address) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.oid) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end
*/

/* RECORD_STAMP_END */

if update(oid)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(rg_staging_acct_address) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[rg_staging_acct_address] ADD CONSTRAINT [chk_rg_staging_acct_address_acct_addr_status] CHECK (([acct_addr_status]='I' OR [acct_addr_status]='A'))
GO
ALTER TABLE [dbo].[rg_staging_acct_address] ADD CONSTRAINT [rg_staging_acct_address_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rg_staging_acct_address] ADD CONSTRAINT [rg_staging_acct_address_fk1] FOREIGN KEY ([feed_data_id]) REFERENCES [dbo].[feed_data] ([oid])
GO
ALTER TABLE [dbo].[rg_staging_acct_address] ADD CONSTRAINT [rg_staging_acct_address_fk2] FOREIGN KEY ([feed_detail_data_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
GRANT DELETE ON  [dbo].[rg_staging_acct_address] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[rg_staging_acct_address] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[rg_staging_acct_address] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[rg_staging_acct_address] TO [next_usr]
GO
