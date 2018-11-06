CREATE TABLE [dbo].[rc_status_history]
(
[rc_num] [int] NOT NULL,
[rc_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rc_status_date] [datetime] NOT NULL,
[rc_status_short_cmnt] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[rc_status_history_updtrg]
on [dbo].[rc_status_history]
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
   raiserror ('(rc_status_history) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(rc_status_history) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.rc_num = d.rc_num and
		 i.rc_status_code = d.rc_status_code and
		 i.rc_status_date = d.rc_status_date)
begin
   select @errmsg = '(rc_status_history) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.rc_num) + ',' + 
                                        i.rc_status_code + ',' +
                                        convert(varchar, i.rc_status_date) + ')'
                                   
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(rc_num) or
   update(rc_status_code) or
   update(rc_status_date)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.rc_num = d.rc_num and
                           	   i.rc_status_code = d.rc_status_code and
 		                   i.rc_status_date = d.rc_status_date)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(rc_status_history) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[rc_status_history] ADD CONSTRAINT [rc_status_history_pk] PRIMARY KEY CLUSTERED  ([rc_num], [rc_status_code], [rc_status_date]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rc_status_history] ADD CONSTRAINT [rc_status_history_fk1] FOREIGN KEY ([rc_status_code]) REFERENCES [dbo].[rc_status] ([rc_status_code])
GO
GRANT DELETE ON  [dbo].[rc_status_history] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[rc_status_history] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[rc_status_history] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[rc_status_history] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'rc_status_history', NULL, NULL
GO
