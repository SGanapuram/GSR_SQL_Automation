CREATE TABLE [dbo].[cash_coll_status]
(
[cash_coll_status_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cash_col_status_short_name] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cash_coll_status_desc] [char] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cash_coll_status_updtrg]
on [dbo].[cash_coll_status]
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
   raiserror ('(cash_coll_status) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(cash_coll_status) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.cash_coll_status_code = d.cash_coll_status_code )
begin
   raiserror ('(cash_coll_status) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(cash_coll_status_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.cash_coll_status_code = d.cash_coll_status_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(cash_coll_status) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[cash_coll_status] ADD CONSTRAINT [cash_coll_status_pk] PRIMARY KEY CLUSTERED  ([cash_coll_status_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cash_coll_status] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cash_coll_status] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cash_coll_status] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cash_coll_status] TO [next_usr]
GO
