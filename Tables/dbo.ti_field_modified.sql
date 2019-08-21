CREATE TABLE [dbo].[ti_field_modified]
(
[oid] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[attr_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ti_field_modified_updtrg]
on [dbo].[ti_field_modified]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(ti_field_modified) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(ti_field_modified) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   raiserror ('(ti_field_modified) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(oid)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid)
   if (@count_num_rows <> @num_rows)
   begin
      raiserror ('(ti_field_modified) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[ti_field_modified] ADD CONSTRAINT [ti_field_modified_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ti_field_modified_idx1] ON [dbo].[ti_field_modified] ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ti_field_modified] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ti_field_modified] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ti_field_modified] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ti_field_modified] TO [next_usr]
GO
