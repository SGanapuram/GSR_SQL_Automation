CREATE TABLE [dbo].[function_detail]
(
[fd_id] [int] NOT NULL,
[function_num] [int] NOT NULL,
[entity_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[attr_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[operation] [char] (5) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity_ind] [bit] NOT NULL CONSTRAINT [DF__function___entit__4B973090] DEFAULT ((0)),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[function_detail_deltrg]
on [dbo].[function_detail]
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
   select @errmsg = '(function_detail) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_function_detail
   (fd_id,
    function_num,
    entity_name,
    attr_name,
    operation, 
    entity_ind,
    trans_id,
    resp_trans_id)
select
   d.fd_id,
   d.function_num,
   d.entity_name,
   d.attr_name,
   d.operation, 
   d.entity_ind,
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

create trigger [dbo].[function_detail_updtrg]
on [dbo].[function_detail]
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
   raiserror ('(function_detail) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(function_detail) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.fd_id = d.fd_id)
begin
   raiserror ('(function_detail) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(fd_id) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.fd_id = d.fd_id)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(function_detail) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_function_detail
      (fd_id,
       function_num,
       entity_name,
       attr_name,
       operation, 
       entity_ind,
       trans_id,
       resp_trans_id)
   select
      d.fd_id,
      d.function_num,
      d.entity_name,
      d.attr_name,
      d.operation, 
      d.entity_ind,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.fd_id = i.fd_id 

/* AUDIT_CODE_END */
return
GO
ALTER TABLE [dbo].[function_detail] ADD CONSTRAINT [function_detail_pk] PRIMARY KEY CLUSTERED  ([fd_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[function_detail] ADD CONSTRAINT [function_detail_fk1] FOREIGN KEY ([function_num]) REFERENCES [dbo].[icts_function] ([function_num])
GO
GRANT DELETE ON  [dbo].[function_detail] TO [admin_group]
GO
GRANT INSERT ON  [dbo].[function_detail] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[function_detail] TO [admin_group]
GO
GRANT UPDATE ON  [dbo].[function_detail] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[function_detail] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'function_detail', NULL, NULL
GO
