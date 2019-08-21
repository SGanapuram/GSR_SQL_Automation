CREATE TABLE [dbo].[marketable_security]
(
[mkt_security_num] [int] NOT NULL,
[mrk_sec_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_num] [int] NULL,
[doc_num] [int] NULL,
[description] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[issue_date] [datetime] NULL,
[expiry_date] [datetime] NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[face_amount] [float] NOT NULL,
[face_amt_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[percent_amount] [float] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[marketable_security_deltrg]
on [dbo].[marketable_security]
instead of delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   bigint

select @num_rows = @@rowcount
if @num_rows = 0
   return

delete marketable_security from deleted d
where marketable_security.mkt_security_num = d.mkt_security_num

/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(marketable_security) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,16,1)
   if @@trancount > 0 rollback tran

   return
end


insert dbo.aud_marketable_security
   (mkt_security_num,
    mrk_sec_status,
    acct_num,
    doc_num,
    description,
    issue_date,
    expiry_date,
    cmdty_code,
    face_amount,
    face_amt_curr_code,
    percent_amount,
    trans_id,
    resp_trans_id)
select
   d.mkt_security_num,
   d.mrk_sec_status,
   d.acct_num,
   d.doc_num,
   d.description,
   d.issue_date,
   d.expiry_date,
   d.cmdty_code,
   d.face_amount,
   d.face_amt_curr_code,
   d.percent_amount,
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

create trigger [dbo].[marketable_security_updtrg]
on [dbo].[marketable_security]
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
   raiserror ('(marketable_security) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(marketable_security) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.mkt_security_num = d.mkt_security_num )
begin
   raiserror ('(marketable_security) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(mkt_security_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.mkt_security_num = d.mkt_security_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(marketable_security) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

update marketable_security
set mrk_sec_status = i.mrk_sec_status,
    acct_num = i.acct_num,
    doc_num = i.doc_num,
    description = i.description,
    issue_date = i.issue_date,
    expiry_date = i.expiry_date,
    cmdty_code = i.cmdty_code,
    face_amount = i.face_amount,
    face_amt_curr_code = i.face_amt_curr_code,
    percent_amount = i.percent_amount,
    trans_id = i.trans_id
from deleted d, inserted i
where marketable_security.mkt_security_num = d.mkt_security_num and 
      d.mkt_security_num = i.mkt_security_num

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_marketable_security
      (mkt_security_num,
       mrk_sec_status,
       acct_num,
       doc_num,
       description,
       issue_date,
       expiry_date,
       cmdty_code,
       face_amount,
       face_amt_curr_code,
       percent_amount,
       trans_id,
       resp_trans_id)
   select
      d.mkt_security_num,
      d.mrk_sec_status,
      d.acct_num,
      d.doc_num,
      d.description,
      d.issue_date,
      d.expiry_date,
      d.cmdty_code,
      d.face_amount,
      d.face_amt_curr_code,
      d.percent_amount,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.mkt_security_num = i.mkt_security_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[marketable_security] ADD CONSTRAINT [marketable_security_pk] PRIMARY KEY CLUSTERED  ([mkt_security_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[marketable_security] ADD CONSTRAINT [marketable_security_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[marketable_security] ADD CONSTRAINT [marketable_security_fk2] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[marketable_security] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[marketable_security] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[marketable_security] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[marketable_security] TO [next_usr]
GO
