CREATE TABLE [dbo].[bus_cost_order_group]
(
[bc_type_num] [smallint] NOT NULL,
[order_type_group] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[bus_cost_order_group_deltrg]
on [dbo].[bus_cost_order_group]
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
   select @errmsg = '(bus_cost_order_group) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_bus_cost_order_group
   (bc_type_num,
    order_type_group,
    trans_id,
    resp_trans_id)
select
   d.bc_type_num,
   d.order_type_group,
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

create trigger [dbo].[bus_cost_order_group_updtrg]
on [dbo].[bus_cost_order_group]
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
   raiserror ('(bus_cost_order_group) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(bus_cost_order_group) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.bc_type_num = d.bc_type_num )
begin
   raiserror ('(bus_cost_order_group) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(bc_type_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.bc_type_num = d.bc_type_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(bus_cost_order_group) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_bus_cost_order_group
      (bc_type_num,
       order_type_group,
       trans_id,
       resp_trans_id)
   select
      d.bc_type_num,
      d.order_type_group,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.bc_type_num = i.bc_type_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[bus_cost_order_group] ADD CONSTRAINT [bus_cost_order_group_pk] PRIMARY KEY CLUSTERED  ([bc_type_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[bus_cost_order_group] ADD CONSTRAINT [bus_cost_order_group_fk1] FOREIGN KEY ([bc_type_num]) REFERENCES [dbo].[bus_cost_type] ([bc_type_num])
GO
ALTER TABLE [dbo].[bus_cost_order_group] ADD CONSTRAINT [bus_cost_order_group_fk2] FOREIGN KEY ([order_type_group]) REFERENCES [dbo].[order_type_grp_desc] ([order_type_group])
GO
GRANT DELETE ON  [dbo].[bus_cost_order_group] TO [admin_group]
GO
GRANT INSERT ON  [dbo].[bus_cost_order_group] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[bus_cost_order_group] TO [admin_group]
GO
GRANT UPDATE ON  [dbo].[bus_cost_order_group] TO [admin_group]
GO
GRANT DELETE ON  [dbo].[bus_cost_order_group] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[bus_cost_order_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[bus_cost_order_group] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[bus_cost_order_group] TO [next_usr]
GO
