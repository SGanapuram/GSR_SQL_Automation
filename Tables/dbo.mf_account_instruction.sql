CREATE TABLE [dbo].[mf_account_instruction]
(
[acct_num] [int] NOT NULL,
[acct_instr_num] [smallint] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_instr_type] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_addr_num] [smallint] NOT NULL,
[acct_cont_num] [smallint] NULL,
[bank_acct_num] [char] (9) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mf_account_instruction_updtrg]
on [dbo].[mf_account_instruction]
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
   raiserror ('(mf_account_instruction) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(mf_account_instruction) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.acct_num = d.acct_num and 
                 i.acct_instr_num = d.acct_instr_num )
begin
   raiserror ('(mf_account_instruction) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(acct_num) or  
   update(acct_instr_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.acct_num = d.acct_num and 
                                   i.acct_instr_num = d.acct_instr_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(mf_account_instruction) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[mf_account_instruction] ADD CONSTRAINT [mf_account_instruction_pk] PRIMARY KEY CLUSTERED  ([acct_num], [acct_instr_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[mf_account_instruction] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[mf_account_instruction] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[mf_account_instruction] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[mf_account_instruction] TO [next_usr]
GO
