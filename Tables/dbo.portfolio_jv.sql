CREATE TABLE [dbo].[portfolio_jv]
(
[port_num] [int] NOT NULL,
[due_date] [datetime] NOT NULL,
[acct_num] [int] NOT NULL,
[book_comp_num] [int] NOT NULL,
[pl_percentage] [float] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_jv_deltrg]
on [dbo].[portfolio_jv]
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
   select @errmsg = '(portfolio_jv) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_portfolio_jv
   (port_num,
    due_date,
    acct_num,
    book_comp_num,
    pl_percentage,
    trans_id,
    resp_trans_id)
select
   d.port_num,
   d.due_date,
   d.acct_num,
   d.book_comp_num,
   d.pl_percentage,
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

create trigger [dbo].[portfolio_jv_updtrg]
on [dbo].[portfolio_jv]
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
   raiserror ('(portfolio_jv) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(portfolio_jv) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.port_num = d.port_num )
begin
   raiserror ('(portfolio_jv) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(port_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.port_num = d.port_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(portfolio_jv) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_portfolio_jv
      (port_num,
       due_date,
       acct_num,
       book_comp_num,
       pl_percentage,
       trans_id,
       resp_trans_id)
   select
      d.port_num,
      d.due_date,
      d.acct_num,
      d.book_comp_num,
      d.pl_percentage,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.port_num = i.port_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[portfolio_jv] ADD CONSTRAINT [portfolio_jv_pk] PRIMARY KEY CLUSTERED  ([port_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[portfolio_jv] ADD CONSTRAINT [portfolio_jv_fk2] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[portfolio_jv] ADD CONSTRAINT [portfolio_jv_fk3] FOREIGN KEY ([book_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[portfolio_jv] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[portfolio_jv] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[portfolio_jv] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[portfolio_jv] TO [next_usr]
GO
