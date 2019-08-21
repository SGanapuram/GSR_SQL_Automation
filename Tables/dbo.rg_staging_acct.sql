CREATE TABLE [dbo].[rg_staging_acct]
(
[feed_data_id] [int] NOT NULL,
[feed_detail_data_id] [int] NOT NULL,
[acct_short_name] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_full_name] [nvarchar] (510) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_rg_staging_acct_acct_status] DEFAULT ('A'),
[acct_parent_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_rg_staging_acct_acct_parent_ind] DEFAULT ('N'),
[acct_sub_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_rg_staging_acct_acct_sub_ind] DEFAULT ('N'),
[acct_vat_code] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_fiscal_code] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_sub_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_cmnt_num] [int] NULL,
[man_input_sec_qty_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[legal_entity_num] [int] NULL,
[risk_transfer_ind_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[govt_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[allows_netout] [bit] NOT NULL CONSTRAINT [df_rg_staging_acct_allows_netout] DEFAULT ((0)),
[allows_bookout] [bit] NOT NULL CONSTRAINT [df_rg_staging_acct_allows_bookout] DEFAULT ((0)),
[company_id] [int] NOT NULL,
[company_code] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[company_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[account_code] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[action_code] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[rg_staging_acct_updtrg]
on [dbo].[rg_staging_acct]
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
--   raiserror ('(rg_staging_acct) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(rg_staging_acct) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.feed_detail_data_id = d.feed_detail_data_id)
begin
   select @errmsg = '(rg_staging_acct) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.feed_detail_data_id) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end
*/

/* RECORD_STAMP_END */

if update(feed_detail_data_id)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.feed_detail_data_id = d.feed_detail_data_id)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(rg_staging_acct) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[rg_staging_acct] ADD CONSTRAINT [chk_rg_staging_acct_acct_parent_ind] CHECK (([acct_parent_ind]='N' OR [acct_parent_ind]='Y'))
GO
ALTER TABLE [dbo].[rg_staging_acct] ADD CONSTRAINT [chk_rg_staging_acct_acct_status] CHECK (([acct_status]='I' OR [acct_status]='A'))
GO
ALTER TABLE [dbo].[rg_staging_acct] ADD CONSTRAINT [chk_rg_staging_acct_acct_sub_ind] CHECK (([acct_sub_ind]='N' OR [acct_sub_ind]='Y'))
GO
ALTER TABLE [dbo].[rg_staging_acct] ADD CONSTRAINT [rg_staging_acct_pk] PRIMARY KEY CLUSTERED  ([feed_detail_data_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rg_staging_acct] ADD CONSTRAINT [rg_staging_acct_fk1] FOREIGN KEY ([feed_data_id]) REFERENCES [dbo].[feed_data] ([oid])
GO
ALTER TABLE [dbo].[rg_staging_acct] ADD CONSTRAINT [rg_staging_acct_fk2] FOREIGN KEY ([feed_detail_data_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
GRANT DELETE ON  [dbo].[rg_staging_acct] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[rg_staging_acct] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[rg_staging_acct] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[rg_staging_acct] TO [next_usr]
GO
