CREATE TABLE [dbo].[bus_cost_num_children]
(
[bc_num_children_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bc_num_children_full_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bc_num_children_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[bus_cost_num_children_updtrg]
on [dbo].[bus_cost_num_children]
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
   raiserror ('(bus_cost_num_children) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(bus_cost_num_children) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.bc_num_children_code = d.bc_num_children_code )
begin
   raiserror ('(bus_cost_num_children) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(bc_num_children_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.bc_num_children_code = d.bc_num_children_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(bus_cost_num_children) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[bus_cost_num_children] ADD CONSTRAINT [bus_cost_num_children_pk] PRIMARY KEY CLUSTERED  ([bc_num_children_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[bus_cost_num_children] TO [admin_group]
GO
GRANT INSERT ON  [dbo].[bus_cost_num_children] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[bus_cost_num_children] TO [admin_group]
GO
GRANT UPDATE ON  [dbo].[bus_cost_num_children] TO [admin_group]
GO
GRANT DELETE ON  [dbo].[bus_cost_num_children] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[bus_cost_num_children] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[bus_cost_num_children] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[bus_cost_num_children] TO [next_usr]
GO
