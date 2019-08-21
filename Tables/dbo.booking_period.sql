CREATE TABLE [dbo].[booking_period]
(
[booking_comp_num] [int] NOT NULL,
[booking_prd_year] [smallint] NOT NULL,
[booking_prd_num] [smallint] NOT NULL,
[booking_prd_start_date] [datetime] NULL,
[booking_prd_end_date] [datetime] NULL,
[booking_prd_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[booking_period_updtrg]
on [dbo].[booking_period]
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
   raiserror ('(booking_period) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(booking_period) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.booking_comp_num = d.booking_comp_num  and i.booking_prd_year = d.booking_prd_year  and i.booking_prd_num = d.booking_prd_num )
begin
   raiserror ('(booking_period) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(booking_comp_num) or  
   update(booking_prd_year) or  
   update(booking_prd_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.booking_comp_num = d.booking_comp_num and 
                                   i.booking_prd_year = d.booking_prd_year and 
                                   i.booking_prd_num = d.booking_prd_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(booking_period) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[booking_period] ADD CONSTRAINT [booking_period_pk] PRIMARY KEY CLUSTERED  ([booking_comp_num], [booking_prd_year], [booking_prd_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[booking_period] ADD CONSTRAINT [booking_period_fk1] FOREIGN KEY ([booking_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[booking_period] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[booking_period] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[booking_period] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[booking_period] TO [next_usr]
GO
