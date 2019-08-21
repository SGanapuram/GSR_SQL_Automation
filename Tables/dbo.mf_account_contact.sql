CREATE TABLE [dbo].[mf_account_contact]
(
[acct_num] [int] NOT NULL,
[acct_cont_num] [int] NOT NULL,
[acct_cont_last_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_cont_first_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_cont_nick_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_title] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_addr_line_1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_addr_line_2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_addr_line_3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_addr_line_4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_addr_city] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[state_code] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_addr_zip_code] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_home_ph_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_off_ph_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_oth_ph_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_telex_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_fax_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_function] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_num] [smallint] NULL,
[acct_cont_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mf_account_contact_updtrg]
on [dbo].[mf_account_contact]
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
if not update(trans_id) 
begin
   raiserror ('(mf_account_contact) The change needs to be attached with a new trans_id',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* added by Peter Lo  Sep-4-2002 */
if exists (select 1
           from master.dbo.sysprocesses
           where spid = @@spid and
                (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                 program_name like 'Microsoft SQL Server Management Studio%') )
begin
   if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0
   begin
      select @errmsg = '(mf_account_contact) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.acct_num = d.acct_num and 
                 i.acct_cont_num = d.acct_cont_num )
begin
   raiserror ('(mf_account_contact) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(acct_num) or 
   update(acct_cont_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.acct_num = d.acct_num and 
                                   i.acct_cont_num = d.acct_cont_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(mf_account_contact) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[mf_account_contact] ADD CONSTRAINT [mf_account_contact_pk] PRIMARY KEY CLUSTERED  ([acct_num], [acct_cont_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[mf_account_contact] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[mf_account_contact] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[mf_account_contact] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[mf_account_contact] TO [next_usr]
GO
