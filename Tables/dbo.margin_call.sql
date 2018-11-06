CREATE TABLE [dbo].[margin_call]
(
[margin_call_num] [int] NOT NULL,
[mca_num] [int] NOT NULL,
[acct_num] [int] NOT NULL,
[doc_num] [int] NULL,
[party_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[call_date] [datetime] NOT NULL,
[cost_num] [int] NULL,
[call_amount] [float] NOT NULL,
[call_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[total_mtm_exp] [float] NOT NULL,
[total_mtm_curr] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[call_status] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[due_date] [datetime] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[margin_call_deltrg]
on [dbo].[margin_call]
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
   select @errmsg = '(margin_call) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_margin_call
   (margin_call_num,
    mca_num,
    acct_num,
    doc_num,
    party_type,
    call_date,
    cost_num,
    call_amount,
    call_curr_code,
    total_mtm_exp,
    total_mtm_curr,
    call_status,
    due_date,
    trans_id,
    resp_trans_id)
select
   d.margin_call_num,
   d.mca_num,
   d.acct_num,
   d.doc_num,
   d.party_type,
   d.call_date,
   d.cost_num,
   d.call_amount,
   d.call_curr_code,
   d.total_mtm_exp,
   d.total_mtm_curr,
   d.call_status,
   d.due_date,
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

create trigger [dbo].[margin_call_updtrg]
on [dbo].[margin_call]
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
   raiserror ('(margin_call) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(margin_call) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.margin_call_num = d.margin_call_num )
begin
   raiserror ('(margin_call) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(margin_call_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.margin_call_num = d.margin_call_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(margin_call) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_margin_call
      (margin_call_num,
       mca_num,
       acct_num,
       doc_num,
       party_type,
       call_date,
       cost_num,
       call_amount,
       call_curr_code,
       total_mtm_exp,
       total_mtm_curr,
       call_status,
       due_date,
       trans_id,
       resp_trans_id)
   select
      d.margin_call_num,
      d.mca_num,
      d.acct_num,
      d.doc_num,
      d.party_type,
      d.call_date,
      d.cost_num,
      d.call_amount,
      d.call_curr_code,
      d.total_mtm_exp,
      d.total_mtm_curr,
      d.call_status,
      d.due_date,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.margin_call_num = i.margin_call_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[margin_call] ADD CONSTRAINT [margin_call_pk] PRIMARY KEY CLUSTERED  ([margin_call_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[margin_call] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[margin_call] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[margin_call] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[margin_call] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'margin_call', NULL, NULL
GO
