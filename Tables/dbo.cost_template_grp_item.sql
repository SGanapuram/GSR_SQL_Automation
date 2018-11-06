CREATE TABLE [dbo].[cost_template_grp_item]
(
[cost_template_group_oid] [int] NOT NULL,
[cost_template_oid] [int] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cost_template_grp_item_deltrg]
on [dbo].[cost_template_grp_item]
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
   select @errmsg = '(cost_template_grp_item) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_cost_template_grp_item
(
   cost_template_group_oid,
   cost_template_oid,
   trans_id,
   resp_trans_id
)
select
   d.cost_template_group_oid,
   d.cost_template_oid,
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
create trigger [dbo].[cost_template_grp_item_updtrg]
on [dbo].[cost_template_grp_item]
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
   raiserror ('(cost_template_grp_item) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(cost_template_grp_item) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.cost_template_group_oid = d.cost_template_group_oid )
begin
   raiserror ('(cost_template_grp_item) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(cost_template_group_oid) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.cost_template_group_oid = d.cost_template_group_oid )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(cost_template_grp_item) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_cost_template_grp_item
   (
      cost_template_group_oid,
      cost_template_oid,
      trans_id,
      resp_trans_id
   )
   select 
      d.cost_template_group_oid,
      d.cost_template_oid,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.cost_template_group_oid = i.cost_template_group_oid 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[cost_template_grp_item] ADD CONSTRAINT [cost_template_grp_item_pk] PRIMARY KEY CLUSTERED  ([cost_template_group_oid], [cost_template_oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cost_template_grp_item] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cost_template_grp_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cost_template_grp_item] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cost_template_grp_item] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'cost_template_grp_item', NULL, NULL
GO
