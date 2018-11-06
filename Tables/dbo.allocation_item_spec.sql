CREATE TABLE [dbo].[allocation_item_spec]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_actual_value] [float] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[allocation_item_spec_deltrg]
on [dbo].[allocation_item_spec]
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
   select @errmsg = '(allocation_item_spec) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_allocation_item_spec
   (alloc_num,
    alloc_item_num,
    spec_code,
    spec_actual_value,
    trans_id,
    resp_trans_id)
select
   d.alloc_num,
   d.alloc_item_num,
   d.spec_code,
   d.spec_actual_value,
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

create trigger [dbo].[allocation_item_spec_updtrg]
on [dbo].[allocation_item_spec]
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
   raiserror ('(allocation_item_spec) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(allocation_item_spec) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.alloc_num = d.alloc_num and 
                 i.alloc_item_num = d.alloc_item_num and 
                 i.spec_code = d.spec_code )
begin
   raiserror ('(allocation_item_spec) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(alloc_num) or 
   update(alloc_item_num) or
   update(spec_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.alloc_num = d.alloc_num and 
                                   i.alloc_item_num = d.alloc_item_num and 
                                   i.spec_code = d.spec_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(allocation_item_spec) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_allocation_item_spec
      (alloc_num,
       alloc_item_num,
       spec_code,
       spec_actual_value,
       trans_id,
       resp_trans_id)
   select
      d.alloc_num,
      d.alloc_item_num,
      d.spec_code,
      d.spec_actual_value,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.alloc_num = i.alloc_num and
         d.alloc_item_num = i.alloc_item_num and
         d.spec_code = i.spec_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[allocation_item_spec] ADD CONSTRAINT [allocation_item_spec_pk] PRIMARY KEY CLUSTERED  ([alloc_num], [alloc_item_num], [spec_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[allocation_item_spec] ADD CONSTRAINT [allocation_item_spec_fk2] FOREIGN KEY ([spec_code]) REFERENCES [dbo].[specification] ([spec_code])
GO
GRANT DELETE ON  [dbo].[allocation_item_spec] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[allocation_item_spec] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[allocation_item_spec] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[allocation_item_spec] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'allocation_item_spec', NULL, NULL
GO
