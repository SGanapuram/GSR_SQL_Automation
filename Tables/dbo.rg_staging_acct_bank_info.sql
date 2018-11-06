CREATE TABLE [dbo].[rg_staging_acct_bank_info]
(
[feed_data_id] [int] NOT NULL,
[feed_detail_data_id] [int] NOT NULL,
[bank_name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bank_acct_num] [int] NULL,
[addr_acct_num] [int] NULL,
[addr_acct_addr_num] [smallint] NULL,
[vc_acct_num] [int] NULL,
[gl_acct_code] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[gl_acct_descr] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[p_or_r_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__rg_stagin__p_or___7889D298] DEFAULT ('P'),
[bank_acct_no] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bank_addr] [nvarchar] (90) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[swift_code] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_method_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_send_id] [smallint] NULL,
[acct_bank_routing_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_bank_info_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__rg_stagin__acct___7A721B0A] DEFAULT ('A'),
[corresp_bank_name] [nvarchar] (160) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[corresp_bank_routing_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[further_credit_to] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[currency_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[corresp_swift_code] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[corresp_bank_acct_no] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[corresp_bank_instr_type_id] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[book_comp_num] [int] NULL,
[further_credit_to_ext_acct_key] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[selling_office_num] [smallint] NULL,
[bank_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_bank_iban_num] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_bank_city] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_bank_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[corresp_bank_iban_num] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[corresp_bank_city] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[corresp_bank_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[special_payment_instr] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[counterparty_code] [nvarchar] (510) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[suncode] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pic] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[is_default] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[action_code] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[rg_staging_acct_bank_info_updtrg]
on [dbo].[rg_staging_acct_bank_info]
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
--   raiserror ('(rg_staging_acct_bank_info) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(rg_staging_acct_bank_info) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.feed_detail_data_id = d.feed_detail_data_id)
begin
   select @errmsg = '(rg_staging_acct_bank_info) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.feed_detail_data_id) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
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
      raiserror ('(rg_staging_acct_bank_info) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[rg_staging_acct_bank_info] ADD CONSTRAINT [CK__rg_stagin__acct___7B663F43] CHECK (([acct_bank_info_status]='I' OR [acct_bank_info_status]='A'))
GO
ALTER TABLE [dbo].[rg_staging_acct_bank_info] ADD CONSTRAINT [CK__rg_stagin__p_or___797DF6D1] CHECK (([p_or_r_ind]='R' OR [p_or_r_ind]='P'))
GO
ALTER TABLE [dbo].[rg_staging_acct_bank_info] ADD CONSTRAINT [rg_staging_acct_bank_info_pk] PRIMARY KEY CLUSTERED  ([feed_detail_data_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rg_staging_acct_bank_info] ADD CONSTRAINT [rg_staging_acct_bank_info_fk1] FOREIGN KEY ([feed_data_id]) REFERENCES [dbo].[feed_data] ([oid])
GO
ALTER TABLE [dbo].[rg_staging_acct_bank_info] ADD CONSTRAINT [rg_staging_acct_bank_info_fk2] FOREIGN KEY ([feed_detail_data_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
GRANT DELETE ON  [dbo].[rg_staging_acct_bank_info] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[rg_staging_acct_bank_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[rg_staging_acct_bank_info] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[rg_staging_acct_bank_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'rg_staging_acct_bank_info', NULL, NULL
GO
