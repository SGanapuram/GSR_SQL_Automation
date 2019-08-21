CREATE TABLE [dbo].[cash_forecast_file]
(
[cff_num] [int] NOT NULL,
[cff_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cff_gen_date] [datetime] NULL,
[cff_gen_id] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cff_trans_date] [datetime] NULL,
[cff_trans_id] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cash_forecast_file_updtrg]
on [dbo].[cash_forecast_file]
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
   raiserror ('(cash_forecast_file) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(cash_forecast_file) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.cff_num = d.cff_num )
begin
   raiserror ('(cash_forecast_file) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(cff_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.cff_num = d.cff_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(cash_forecast_file) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[cash_forecast_file] ADD CONSTRAINT [cash_forecast_file_pk] PRIMARY KEY CLUSTERED  ([cff_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cash_forecast_file] ADD CONSTRAINT [cash_forecast_file_fk1] FOREIGN KEY ([cff_gen_id]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[cash_forecast_file] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cash_forecast_file] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cash_forecast_file] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cash_forecast_file] TO [next_usr]
GO
