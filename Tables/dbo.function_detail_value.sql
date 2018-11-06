CREATE TABLE [dbo].[function_detail_value]
(
[fdv_id] [int] NOT NULL,
[fd_id] [int] NOT NULL,
[data_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__function___data___4E739D3B] DEFAULT ('S'),
[attr_value] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[function_detail_value_deltrg]
on [dbo].[function_detail_value]
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
   select @errmsg = '(function_detail_value) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_function_detail_value
   (fdv_id,
    fd_id,
    data_type,
    attr_value,
    trans_id,
    resp_trans_id)
select
   d.fdv_id,
   d.fd_id,
   d.data_type,
   d.attr_value,
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

create trigger [dbo].[function_detail_value_updtrg]
on [dbo].[function_detail_value]
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
   raiserror ('(function_detail_value) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(function_detail_value) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.fdv_id = d.fdv_id)
begin
   raiserror ('(function_detail_value) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(fdv_id) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.fdv_id = d.fdv_id)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(function_detail_value) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_function_detail_value
      (fdv_id,
       fd_id,
       data_type,
       attr_value,
       trans_id,
       resp_trans_id)
   select
      d.fdv_id,
      d.fd_id,
      d.data_type,
      d.attr_value,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.fdv_id = i.fdv_id 

/* AUDIT_CODE_END */
return
GO
ALTER TABLE [dbo].[function_detail_value] ADD CONSTRAINT [CK__function___data___4F67C174] CHECK (([data_type]='S' OR [data_type]='F' OR [data_type]='D' OR [data_type]='I'))
GO
ALTER TABLE [dbo].[function_detail_value] ADD CONSTRAINT [function_detail_value_pk] PRIMARY KEY CLUSTERED  ([fdv_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[function_detail_value] ADD CONSTRAINT [function_detail_value_fk1] FOREIGN KEY ([fd_id]) REFERENCES [dbo].[function_detail] ([fd_id])
GO
GRANT DELETE ON  [dbo].[function_detail_value] TO [admin_group]
GO
GRANT INSERT ON  [dbo].[function_detail_value] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[function_detail_value] TO [admin_group]
GO
GRANT UPDATE ON  [dbo].[function_detail_value] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[function_detail_value] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'function_detail_value', NULL, NULL
GO
