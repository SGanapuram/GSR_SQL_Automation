CREATE TABLE [dbo].[position_group_eod]
(
[pos_group_num] [int] NOT NULL,
[is_spread_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[position_group_eod_updtrg]
on [dbo].[position_group_eod]
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
   raiserror ('(position_group_eod) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(position_group_eod) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.pos_group_num = d.pos_group_num )
begin
   raiserror ('(position_group_eod) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(pos_group_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.pos_group_num = d.pos_group_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(position_group_eod) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[position_group_eod] ADD CONSTRAINT [position_group_eod_pk] PRIMARY KEY CLUSTERED  ([pos_group_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[position_group_eod] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[position_group_eod] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[position_group_eod] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[position_group_eod] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'position_group_eod', NULL, NULL
GO
