CREATE TABLE [dbo].[lc_special_condition]
(
[lc_num] [int] NOT NULL,
[special_cond_num] [int] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[lc_special_condition_deltrg]
on [dbo].[lc_special_condition]
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
   select @errmsg = '(lc_special_condition) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_lc_special_condition
   (lc_num,
    special_cond_num,
    trans_id,
    resp_trans_id)
select
   d.lc_num,
   d.special_cond_num,
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

create trigger [dbo].[lc_special_condition_updtrg]
on [dbo].[lc_special_condition]
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
   raiserror ('(lc_special_condition) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(lc_special_condition) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.lc_num = d.lc_num  and i.special_cond_num = d.special_cond_num )
begin
   raiserror ('(lc_special_condition) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(lc_num) or  
   update(special_cond_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.lc_num = d.lc_num and 
                                   i.special_cond_num = d.special_cond_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(lc_special_condition) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_lc_special_condition
      (lc_num,
       special_cond_num,
       trans_id,
       resp_trans_id)
   select
      d.lc_num,
      d.special_cond_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.lc_num = i.lc_num and
         d.special_cond_num = i.special_cond_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[lc_special_condition] ADD CONSTRAINT [lc_special_condition_pk] PRIMARY KEY CLUSTERED  ([lc_num], [special_cond_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[lc_special_condition] ADD CONSTRAINT [lc_special_condition_fk2] FOREIGN KEY ([special_cond_num]) REFERENCES [dbo].[special_condition] ([special_cond_num])
GO
GRANT DELETE ON  [dbo].[lc_special_condition] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[lc_special_condition] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[lc_special_condition] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[lc_special_condition] TO [next_usr]
GO
