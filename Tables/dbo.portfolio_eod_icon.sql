CREATE TABLE [dbo].[portfolio_eod_icon]
(
[port_num] [int] NOT NULL,
[icon] [image] NULL,
[trans_id] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_eod_icon_updtrg]
on [dbo].[portfolio_eod_icon]
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
   raiserror ('(portfolio_eod_icon) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(portfolio_eod_icon) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.port_num = d.port_num )
begin
   raiserror ('(portfolio_eod_icon) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(port_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.port_num = d.port_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(portfolio_eod_icon) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[portfolio_eod_icon] ADD CONSTRAINT [portfolio_eod_icon_pk] PRIMARY KEY NONCLUSTERED  ([port_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[portfolio_eod_icon] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[portfolio_eod_icon] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[portfolio_eod_icon] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[portfolio_eod_icon] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'portfolio_eod_icon', NULL, NULL
GO
