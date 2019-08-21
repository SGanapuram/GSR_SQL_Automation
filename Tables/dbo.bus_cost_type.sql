CREATE TABLE [dbo].[bus_cost_type]
(
[bc_type_num] [smallint] NOT NULL,
[bc_type_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bc_type_full_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bc_type_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_children_type_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_num_children_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_child_gen_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_parent_type_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_init_fate_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_owner_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_sub_owner_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_init_leaf_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_matriarch_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[bus_cost_type_deltrg]
on [dbo].[bus_cost_type]
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
   select @errmsg = '(bus_cost_type) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_bus_cost_type
   (bc_type_num,
    bc_type_code,
    bc_type_full_name,
    bc_type_desc,
    bc_children_type_code,
    bc_num_children_code,
    bc_child_gen_code,
    bc_parent_type_code,
    bc_init_fate_code,
    bc_owner_code,
    bc_sub_owner_code,
    bc_init_leaf_code,
    bc_matriarch_code,
    trans_id,
    resp_trans_id)
select
   d.bc_type_num,
   d.bc_type_code,
   d.bc_type_full_name,
   d.bc_type_desc,
   d.bc_children_type_code,
   d.bc_num_children_code,
   d.bc_child_gen_code,
   d.bc_parent_type_code,
   d.bc_init_fate_code,
   d.bc_owner_code,
   d.bc_sub_owner_code,
   d.bc_init_leaf_code,
   d.bc_matriarch_code,
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

create trigger [dbo].[bus_cost_type_updtrg]
on [dbo].[bus_cost_type]
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
   raiserror ('(bus_cost_type) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(bus_cost_type) New trans_id must be larger than original trans_id.'
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
   raiserror ('(bus_cost_type) new trans_id must not be older than current trans_id.',16,1)
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
      raiserror ('(bus_cost_type) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_bus_cost_type
      (bc_type_num,
       bc_type_code,
       bc_type_full_name,
       bc_type_desc,
       bc_children_type_code,
       bc_num_children_code,
       bc_child_gen_code,
       bc_parent_type_code,
       bc_init_fate_code,
       bc_owner_code,
       bc_sub_owner_code,
       bc_init_leaf_code,
       bc_matriarch_code,
       trans_id,
       resp_trans_id)
   select
      d.bc_type_num,
      d.bc_type_code,
      d.bc_type_full_name,
      d.bc_type_desc,
      d.bc_children_type_code,
      d.bc_num_children_code,
      d.bc_child_gen_code,
      d.bc_parent_type_code,
      d.bc_init_fate_code,
      d.bc_owner_code,
      d.bc_sub_owner_code,
      d.bc_init_leaf_code,
      d.bc_matriarch_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.bc_type_num = i.bc_type_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[bus_cost_type] ADD CONSTRAINT [bus_cost_type_pk] PRIMARY KEY CLUSTERED  ([bc_type_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[bus_cost_type] ADD CONSTRAINT [bus_cost_type_fk1] FOREIGN KEY ([bc_child_gen_code]) REFERENCES [dbo].[bus_cost_child_gen] ([bc_child_gen_code])
GO
ALTER TABLE [dbo].[bus_cost_type] ADD CONSTRAINT [bus_cost_type_fk2] FOREIGN KEY ([bc_init_leaf_code]) REFERENCES [dbo].[bus_cost_leaf] ([bc_leaf_code])
GO
ALTER TABLE [dbo].[bus_cost_type] ADD CONSTRAINT [bus_cost_type_fk3] FOREIGN KEY ([bc_matriarch_code]) REFERENCES [dbo].[bus_cost_matriarch] ([bc_matriarch_code])
GO
ALTER TABLE [dbo].[bus_cost_type] ADD CONSTRAINT [bus_cost_type_fk4] FOREIGN KEY ([bc_num_children_code]) REFERENCES [dbo].[bus_cost_num_children] ([bc_num_children_code])
GO
GRANT DELETE ON  [dbo].[bus_cost_type] TO [admin_group]
GO
GRANT INSERT ON  [dbo].[bus_cost_type] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[bus_cost_type] TO [admin_group]
GO
GRANT UPDATE ON  [dbo].[bus_cost_type] TO [admin_group]
GO
GRANT DELETE ON  [dbo].[bus_cost_type] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[bus_cost_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[bus_cost_type] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[bus_cost_type] TO [next_usr]
GO
