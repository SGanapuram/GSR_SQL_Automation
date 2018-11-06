CREATE TABLE [dbo].[commodity_rollup_type]
(
[rollup_type_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rollup_type_desc] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[commodity_rollup_type_updtrg]
on [dbo].[commodity_rollup_type]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errorNumber      int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(commodity_rollup_type) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(commodity_rollup_type) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.rollup_type_code = d.rollup_type_code )
begin
   raiserror ('(commodity_rollup_type) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(rollup_type_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.rollup_type_code = d.rollup_type_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(commodity_rollup_type) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[commodity_rollup_type] ADD CONSTRAINT [commodity_rollup_type_pk] PRIMARY KEY CLUSTERED  ([rollup_type_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[commodity_rollup_type] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[commodity_rollup_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[commodity_rollup_type] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[commodity_rollup_type] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'commodity_rollup_type', NULL, NULL
GO
