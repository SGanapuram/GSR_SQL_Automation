CREATE TABLE [dbo].[exposure]
(
[exposure_num] [int] NOT NULL,
[exp_acct_num] [int] NULL,
[exp_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exp_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exp_as_of_date] [datetime] NOT NULL,
[exp_booking_comp_num] [int] NULL,
[exp_order_type_group] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exp_pastdue_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exp_secur_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[exp_risk_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exp_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exp_trading_prd] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[exposure_updtrg]
on [dbo].[exposure]
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
   raiserror ('(exposure) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(exposure) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.exposure_num = d.exposure_num )
begin
   raiserror ('(exposure) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(exposure_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.exposure_num = d.exposure_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(exposure) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[exposure] ADD CONSTRAINT [exposure_pk] PRIMARY KEY CLUSTERED  ([exposure_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[exposure] ADD CONSTRAINT [exposure_fk1] FOREIGN KEY ([exp_acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[exposure] ADD CONSTRAINT [exposure_fk2] FOREIGN KEY ([exp_booking_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[exposure] ADD CONSTRAINT [exposure_fk3] FOREIGN KEY ([exp_cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[exposure] ADD CONSTRAINT [exposure_fk4] FOREIGN KEY ([exp_country_code]) REFERENCES [dbo].[country] ([country_code])
GO
ALTER TABLE [dbo].[exposure] ADD CONSTRAINT [exposure_fk5] FOREIGN KEY ([exp_risk_mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
ALTER TABLE [dbo].[exposure] ADD CONSTRAINT [exposure_fk6] FOREIGN KEY ([exp_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
GRANT DELETE ON  [dbo].[exposure] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[exposure] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[exposure] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[exposure] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'exposure', NULL, NULL
GO
