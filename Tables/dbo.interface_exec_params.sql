CREATE TABLE [dbo].[interface_exec_params]
(
[exec_num] [int] NOT NULL,
[interface_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[param_1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[param_2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[param_3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[param_4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[param_5] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[param_6] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[interface_exec_params_deltrg]
on [dbo].[interface_exec_params]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
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
   select @errmsg = '(interface_exec_params) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_interface_exec_params
(  
   exec_num, 
   interface_name,
   param_1,
   param_2, 
   param_3,
   param_4,
   param_5,
   param_6,
   trans_id,
   resp_trans_id)
select
   d.exec_num, 
   d.interface_name,
   d.param_1,
   d.param_2, 
   d.param_3,
   d.param_4,
   d.param_5,
   d.param_6,
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

create trigger [dbo].[interface_exec_params_updtrg]
on [dbo].[interface_exec_params]
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
   raiserror ('(interface_exec_params) The change needs to be attached with a new trans_id',16,1)
   if @@trancount > 0 rollback tran

   return
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.exec_num = d.exec_num)
begin
   raiserror ('(interface_exec_params) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(exec_num) 
begin
   select @count_num_rows = (select count(*) 
                             from inserted i, deleted d
                             where i.exec_num = d.exec_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      select @errmsg = '(interface_exec_params) primary key can not be changed.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_interface_exec_params
   (
      exec_num, 
      interface_name,
      param_1,
      param_2, 
      param_3,
      param_4,
      param_5,
      param_6,
      trans_id,
      resp_trans_id
   )
   select
      d.exec_num, 
      d.interface_name,
      d.param_1,
      d.param_2, 
      d.param_3,
      d.param_4,
      d.param_5,
      d.param_6,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.exec_num = i.exec_num

/* AUDIT_CODE_END */  
return
GO
ALTER TABLE [dbo].[interface_exec_params] ADD CONSTRAINT [interface_exec_params_pk] PRIMARY KEY CLUSTERED  ([exec_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [interface_exec_params_idx1] ON [dbo].[interface_exec_params] ([interface_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[interface_exec_params] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[interface_exec_params] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[interface_exec_params] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[interface_exec_params] TO [next_usr]
GO
