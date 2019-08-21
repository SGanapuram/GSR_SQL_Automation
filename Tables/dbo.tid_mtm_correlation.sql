CREATE TABLE [dbo].[tid_mtm_correlation]
(
[dist_num1] [int] NOT NULL,
[dist_num2] [int] NOT NULL,
[mtm_pl_asof_date] [datetime] NOT NULL,
[correlation] [numeric] (20, 8) NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[tid_mtm_correlation_deltrg]
on [dbo].[tid_mtm_correlation]
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
   select @errmsg = '(tid_mtm_correlation) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_tid_mtm_correlation
   (dist_num1,
    dist_num2,
    mtm_pl_asof_date,
    correlation,
    trans_id,
    resp_trans_id)
select
   d.dist_num1,
   d.dist_num2,
   d.mtm_pl_asof_date,
   d.correlation,
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

create trigger [dbo].[tid_mtm_correlation_updtrg]
on [dbo].[tid_mtm_correlation]
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
   raiserror ('(tid_mtm_correlation) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(tid_mtm_correlation) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.dist_num1 = d.dist_num1 and
                 i.dist_num2 = d.dist_num2 and
                 i.mtm_pl_asof_date = d.mtm_pl_asof_date )
begin
   raiserror ('(tid_mtm_correlation) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(dist_num1) or
   update(dist_num2) or
   update(mtm_pl_asof_date)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.dist_num1 = d.dist_num1 and
                                   i.dist_num2 = d.dist_num2 and
                                   i.mtm_pl_asof_date = d.mtm_pl_asof_date )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(tid_mtm_correlation) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_tid_mtm_correlation
      (dist_num1,
       dist_num2,
       mtm_pl_asof_date,
       correlation,
       trans_id,
       resp_trans_id)
   select
      d.dist_num1,
      d.dist_num2,
      d.mtm_pl_asof_date,
      d.correlation,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.dist_num1 = i.dist_num1 and
         d.dist_num2 = i.dist_num2 and
         d.mtm_pl_asof_date = i.mtm_pl_asof_date

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[tid_mtm_correlation] ADD CONSTRAINT [tid_mtm_correlation_pk] PRIMARY KEY CLUSTERED  ([dist_num1], [dist_num2], [mtm_pl_asof_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tid_mtm_correlation] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tid_mtm_correlation] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tid_mtm_correlation] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tid_mtm_correlation] TO [next_usr]
GO
