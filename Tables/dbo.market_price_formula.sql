CREATE TABLE [dbo].[market_price_formula]
(
[commkt_key] [int] NOT NULL,
[formula_num] [int] NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_market_price_formula_status] DEFAULT ('A'),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[market_price_formula_updtrg]
on [dbo].[market_price_formula]
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
   raiserror ('(market_price_formula) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(market_price_formula) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.commkt_key = d.commkt_key and
                 i.formula_num = d.formula_num )
begin
   raiserror ('(market_price_formula) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(commkt_key) or
   update(formula_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.commkt_key = d.commkt_key and
                                   i.formula_num = d.formula_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(market_price_formula) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[market_price_formula] ADD CONSTRAINT [chk_market_price_formula_status] CHECK (([status]='I' OR [status]='A'))
GO
ALTER TABLE [dbo].[market_price_formula] ADD CONSTRAINT [market_price_formula_pk] PRIMARY KEY CLUSTERED  ([commkt_key], [formula_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[market_price_formula] ADD CONSTRAINT [market_price_formula_fk1] FOREIGN KEY ([commkt_key]) REFERENCES [dbo].[commodity_market] ([commkt_key])
GO
ALTER TABLE [dbo].[market_price_formula] ADD CONSTRAINT [market_price_formula_fk2] FOREIGN KEY ([formula_num]) REFERENCES [dbo].[formula] ([formula_num])
GO
GRANT DELETE ON  [dbo].[market_price_formula] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[market_price_formula] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[market_price_formula] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[market_price_formula] TO [next_usr]
GO
