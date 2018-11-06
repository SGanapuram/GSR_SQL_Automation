CREATE TABLE [dbo].[mca_mat_adv_chg_clause]
(
[mca_num] [int] NOT NULL,
[macc_num] [int] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mca_mat_adv_chg_clause_deltrg]
on [dbo].[mca_mat_adv_chg_clause]
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
   select @errmsg = '(mca_mat_adv_chg_clause) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_mca_mat_adv_chg_clause
   (mca_num,
    macc_num,
    trans_id,
    resp_trans_id)
select
   d.mca_num,
   d.macc_num,
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

create trigger [dbo].[mca_mat_adv_chg_clause_updtrg]
on [dbo].[mca_mat_adv_chg_clause]
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
   raiserror ('(mca_mat_adv_chg_clause) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(mca_mat_adv_chg_clause) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.mca_num = d.mca_num and 
                 i.macc_num = d.macc_num )
begin
   raiserror ('(mca_mat_adv_chg_clause) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(mca_num) or  
   update(macc_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.mca_num = d.mca_num and 
                                   i.macc_num = d.macc_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(mca_mat_adv_chg_clause) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_mca_mat_adv_chg_clause
      (mca_num,
       macc_num,
       trans_id,
       resp_trans_id)
   select
      d.mca_num,
      d.macc_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.mca_num = i.mca_num and
         d.macc_num = i.macc_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[mca_mat_adv_chg_clause] ADD CONSTRAINT [mca_mat_adv_chg_clause_pk] PRIMARY KEY CLUSTERED  ([mca_num], [macc_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[mca_mat_adv_chg_clause] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[mca_mat_adv_chg_clause] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[mca_mat_adv_chg_clause] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[mca_mat_adv_chg_clause] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'mca_mat_adv_chg_clause', NULL, NULL
GO
