CREATE TABLE [dbo].[credit_alarm]
(
[credit_limit_num] [int] NOT NULL,
[alarm_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alarm_percent_amt] [float] NULL,
[alarm_notify_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[notify_email_group] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alarm_cmnt_num] [int] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[credit_alarm_deltrg]
on [dbo].[credit_alarm]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   bigint

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
   select @errmsg = '(credit_alarm) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_credit_alarm
   (credit_limit_num,
    alarm_type,
    alarm_percent_amt,
    alarm_notify_ind,
    notify_email_group,
    alarm_cmnt_num,
    trans_id,
    resp_trans_id)
select
   d.credit_limit_num,
   d.alarm_type,
   d.alarm_percent_amt,
   d.alarm_notify_ind,
   d.notify_email_group,
   d.alarm_cmnt_num,
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

create trigger [dbo].[credit_alarm_updtrg]
on [dbo].[credit_alarm]
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
   raiserror ('(credit_alarm) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(credit_alarm) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.credit_limit_num = d.credit_limit_num )
begin
   raiserror ('(credit_alarm) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(credit_limit_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.credit_limit_num = d.credit_limit_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(credit_alarm) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_credit_alarm
      (credit_limit_num,
       alarm_type,
       alarm_percent_amt,
       alarm_notify_ind,
       notify_email_group,
       alarm_cmnt_num,
       trans_id,
       resp_trans_id)
   select
      d.credit_limit_num,
      d.alarm_type,
      d.alarm_percent_amt,
      d.alarm_notify_ind,
      d.notify_email_group,
      d.alarm_cmnt_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.credit_limit_num = i.credit_limit_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[credit_alarm] ADD CONSTRAINT [credit_alarm_pk] PRIMARY KEY CLUSTERED  ([credit_limit_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[credit_alarm] ADD CONSTRAINT [credit_alarm_fk2] FOREIGN KEY ([credit_limit_num]) REFERENCES [dbo].[credit_limit] ([credit_limit_num])
GO
GRANT DELETE ON  [dbo].[credit_alarm] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[credit_alarm] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[credit_alarm] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[credit_alarm] TO [next_usr]
GO
