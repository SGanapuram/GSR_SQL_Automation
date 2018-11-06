CREATE TABLE [dbo].[cash_collateral]
(
[cash_coll_num] [int] NOT NULL,
[mca_num] [int] NOT NULL,
[acct_num] [int] NOT NULL,
[cash_coll_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cash_amt] [float] NOT NULL,
[cash_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rec_date] [datetime] NULL,
[doc_num] [int] NULL,
[cmnt_text] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cash_collateral_deltrg]
on [dbo].[cash_collateral]
instead of delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   int

select @num_rows = @@rowcount
if @num_rows = 0
   return

delete dbo.cash_collateral 
from deleted d
where cash_collateral.cash_coll_num = d.cash_coll_num

/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(cash_collateral) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_cash_collateral
   (cash_coll_num,
    mca_num,
    acct_num,
    cash_coll_status,
    cash_amt,
    cash_curr_code,
    rec_date,
    doc_num,
    cmnt_text,
    trans_id,
    resp_trans_id)
select
   d.cash_coll_num,
   d.mca_num,
   d.acct_num,
   d.cash_coll_status,
   d.cash_amt,
   d.cash_curr_code,
   d.rec_date,
   d.doc_num,
   d.cmnt_text,
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

create trigger [dbo].[cash_collateral_updtrg]
on [dbo].[cash_collateral]
instead of update
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
   raiserror ('(cash_collateral) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(cash_collateral) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.cash_coll_num = d.cash_coll_num )
begin
   raiserror ('(cash_collateral) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(cash_coll_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.cash_coll_num = d.cash_coll_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(cash_collateral) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

update dbo.cash_collateral
set mca_num = i.mca_num,
    acct_num = i.acct_num,
    cash_coll_status = i.cash_coll_status,
    cash_amt = i.cash_amt,
    cash_curr_code = i.cash_curr_code,
    rec_date = i.rec_date,
    doc_num = i.doc_num,
    cmnt_text = i.cmnt_text,
    trans_id = i.trans_id
from deleted d, inserted i
where cash_collateral.cash_coll_num = d.cash_coll_num and
      d.cash_coll_num = i.cash_coll_num

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_cash_collateral
      (cash_coll_num,
       mca_num,
       acct_num,
       cash_coll_status,
       cash_amt,
       cash_curr_code,
       rec_date,
       doc_num,
       cmnt_text,
       trans_id,
       resp_trans_id)
   select
      d.cash_coll_num,
      d.mca_num,
      d.acct_num,
      d.cash_coll_status,
      d.cash_amt,
      d.cash_curr_code,
      d.rec_date,
      d.doc_num,
      d.cmnt_text,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.cash_coll_num = i.cash_coll_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[cash_collateral] ADD CONSTRAINT [cash_collateral_pk] PRIMARY KEY CLUSTERED  ([cash_coll_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cash_collateral] ADD CONSTRAINT [cash_collateral_fk2] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[cash_collateral] ADD CONSTRAINT [cash_collateral_fk3] FOREIGN KEY ([cash_coll_status]) REFERENCES [dbo].[cash_coll_status] ([cash_coll_status_code])
GO
GRANT DELETE ON  [dbo].[cash_collateral] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cash_collateral] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cash_collateral] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cash_collateral] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'cash_collateral', NULL, NULL
GO
