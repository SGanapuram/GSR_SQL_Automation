CREATE TABLE [dbo].[bus_cost_fate]
(
[bc_fate_num] [smallint] NOT NULL,
[bc_fate_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bc_fate_full_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bc_fate_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_fate_date_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_fate_group_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_fate_man_auto_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_fate_pay_days] [smallint] NULL,
[bc_fate_proc_spec] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[bus_cost_fate_deltrg]
on [dbo].[bus_cost_fate]
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
   select @errmsg = '(bus_cost_fate) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_bus_cost_fate
   (bc_fate_num,
    bc_fate_code,
    bc_fate_full_name,
    bc_fate_desc,
    bc_fate_date_code,
    bc_fate_group_code,
    bc_fate_man_auto_ind,
    bc_fate_pay_days,
    bc_fate_proc_spec,
    trans_id,
    resp_trans_id)
select
   d.bc_fate_num,
   d.bc_fate_code,
   d.bc_fate_full_name,
   d.bc_fate_desc,
   d.bc_fate_date_code,
   d.bc_fate_group_code,
   d.bc_fate_man_auto_ind,
   d.bc_fate_pay_days,
   d.bc_fate_proc_spec,
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

create trigger [dbo].[bus_cost_fate_updtrg]
on [dbo].[bus_cost_fate]
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
   raiserror ('(bus_cost_fate) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(bus_cost_fate) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.bc_fate_num = d.bc_fate_num )
begin
   raiserror ('(bus_cost_fate) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(bc_fate_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.bc_fate_num = d.bc_fate_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(bus_cost_fate) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_bus_cost_fate
      (bc_fate_num,
       bc_fate_code,
       bc_fate_full_name,
       bc_fate_desc,
       bc_fate_date_code,
       bc_fate_group_code,
       bc_fate_man_auto_ind,
       bc_fate_pay_days,
       bc_fate_proc_spec,
       trans_id,
       resp_trans_id)
   select
      d.bc_fate_num,
      d.bc_fate_code,
      d.bc_fate_full_name,
      d.bc_fate_desc,
      d.bc_fate_date_code,
      d.bc_fate_group_code,
      d.bc_fate_man_auto_ind,
      d.bc_fate_pay_days,
      d.bc_fate_proc_spec,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.bc_fate_num = i.bc_fate_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[bus_cost_fate] ADD CONSTRAINT [bus_cost_fate_pk] PRIMARY KEY CLUSTERED  ([bc_fate_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[bus_cost_fate] ADD CONSTRAINT [bus_cost_fate_fk1] FOREIGN KEY ([bc_fate_date_code]) REFERENCES [dbo].[bus_cost_fate_date] ([bc_fate_date_code])
GO
GRANT DELETE ON  [dbo].[bus_cost_fate] TO [admin_group]
GO
GRANT INSERT ON  [dbo].[bus_cost_fate] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[bus_cost_fate] TO [admin_group]
GO
GRANT UPDATE ON  [dbo].[bus_cost_fate] TO [admin_group]
GO
GRANT DELETE ON  [dbo].[bus_cost_fate] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[bus_cost_fate] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[bus_cost_fate] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[bus_cost_fate] TO [next_usr]
GO
