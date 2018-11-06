CREATE TABLE [dbo].[bank_exposure]
(
[bank_exp_num] [int] NOT NULL,
[bank_exp_date] [datetime] NOT NULL,
[bank_exp_amt] [float] NULL,
[bank_exp_lc_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_num] [int] NOT NULL,
[book_comp_num] [int] NOT NULL,
[bank_exp_imp_exp_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[bank_exposure_deltrg]
on [dbo].[bank_exposure]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   int

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(bank_exposure) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   if @@trancount > 0 rollback tran

   return
end


insert dbo.aud_bank_exposure
   (bank_exp_num,
    bank_exp_date,
    bank_exp_amt,
    bank_exp_lc_type_code,
    acct_num,
    book_comp_num,
    bank_exp_imp_exp_ind,
    cmdty_code,
    trans_id,
    resp_trans_id)
select
   d.bank_exp_num,
   d.bank_exp_date,
   d.bank_exp_amt,
   d.bank_exp_lc_type_code,
   d.acct_num,
   d.book_comp_num,
   d.bank_exp_imp_exp_ind,
   d.cmdty_code,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[bank_exposure_updtrg]
on [dbo].[bank_exposure]
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
   raiserror ('(bank_exposure) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(bank_exposure) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.bank_exp_num = d.bank_exp_num )
begin
   raiserror ('(bank_exposure) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(bank_exp_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.bank_exp_num = d.bank_exp_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(bank_exposure) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_bank_exposure
      (bank_exp_num,
       bank_exp_date,
       bank_exp_amt,
       bank_exp_lc_type_code,
       acct_num,
       book_comp_num,
       bank_exp_imp_exp_ind,
       cmdty_code,
       trans_id,
       resp_trans_id)
   select
      d.bank_exp_num,
      d.bank_exp_date,
      d.bank_exp_amt,
      d.bank_exp_lc_type_code,
      d.acct_num,
      d.book_comp_num,
      d.bank_exp_imp_exp_ind,
      d.cmdty_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.bank_exp_num = i.bank_exp_num 


/* AUDIT_CODE_END */
return
GO
ALTER TABLE [dbo].[bank_exposure] ADD CONSTRAINT [bank_exposure_pk] PRIMARY KEY CLUSTERED  ([bank_exp_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[bank_exposure] ADD CONSTRAINT [bank_exposure_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[bank_exposure] ADD CONSTRAINT [bank_exposure_fk2] FOREIGN KEY ([book_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[bank_exposure] ADD CONSTRAINT [bank_exposure_fk3] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[bank_exposure] ADD CONSTRAINT [bank_exposure_fk4] FOREIGN KEY ([bank_exp_lc_type_code]) REFERENCES [dbo].[lc_type] ([lc_type_code])
GO
GRANT DELETE ON  [dbo].[bank_exposure] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[bank_exposure] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[bank_exposure] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[bank_exposure] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'bank_exposure', NULL, NULL
GO