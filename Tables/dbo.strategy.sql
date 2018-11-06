CREATE TABLE [dbo].[strategy]
(
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[strategy_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[port_num] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[strategy_updtrg]
on [dbo].[strategy]
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
   raiserror ('(strategy) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(strategy) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.user_init = d.user_init and
                 i.strategy_name = d.strategy_name and
                 i.port_num = d.port_num and
                 i.cmdty_code = d.cmdty_code and
                 i.mkt_code = d.mkt_code and
                 i.trading_prd = d.trading_prd)
begin
   raiserror ('(strategy) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(user_init) or
   update(strategy_name) or
   update(port_num) or
   update(cmdty_code) or
   update(mkt_code) or
   update(trading_prd)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.user_init = d.user_init and
                                   i.strategy_name = d.strategy_name and
                                   i.port_num = d.port_num and
                                   i.cmdty_code = d.cmdty_code and
                                   i.mkt_code = d.mkt_code and
                                   i.trading_prd = d.trading_prd)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(strategy) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[strategy] ADD CONSTRAINT [strategy_pk] PRIMARY KEY CLUSTERED  ([user_init], [strategy_name], [port_num], [cmdty_code], [mkt_code], [trading_prd]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[strategy] ADD CONSTRAINT [strategy_fk1] FOREIGN KEY ([user_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[strategy] ADD CONSTRAINT [strategy_fk3] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[strategy] ADD CONSTRAINT [strategy_fk4] FOREIGN KEY ([mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
GRANT DELETE ON  [dbo].[strategy] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[strategy] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[strategy] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[strategy] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'strategy', NULL, NULL
GO
