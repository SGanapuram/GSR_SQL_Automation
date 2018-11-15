CREATE TABLE [dbo].[market_value]
(
[id] [int] NOT NULL,
[market_value] [decimal] (20, 8) NOT NULL,
[marketdata_supplier_id] [int] NOT NULL,
[priced_quote_period_id] [int] NOT NULL,
[received_date_time] [datetime] NOT NULL,
[settlement_date] [datetime] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
create trigger [dbo].[market_value_deltrg]
on [dbo].[market_value]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
        @atrans_id int
 
set @num_rows = @@rowcount
if @num_rows = 0
   return
 
/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)
 
if @atrans_id is null
begin
   set @errmsg = '(market_value) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      set @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror(@errmsg, 10, 1)
   if @@trancount > 0 rollback tran
   return
end
 
insert dbo.aud_market_value
(
   id,
   market_value,
   marketdata_supplier_id,
   priced_quote_period_id,
   received_date_time,
   settlement_date,
   trans_id,
   resp_trans_id
)
select
   d.id,
   d.market_value,
   d.marketdata_supplier_id,
   d.priced_quote_period_id,
   d.received_date_time,
   d.settlement_date,
   d.trans_id,
   @atrans_id
from deleted d
 
/* AUDIT_CODE_END */
return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
create trigger [dbo].[market_value_updtrg]
on [dbo].[market_value]
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
   raiserror('(market_value) The change needs to be attached with a new trans_id.', 10, 1)
   if @@trancount > 0 rollback tran
   return
end
 
if exists (select 1
           from master.dbo.sysprocesses
           where spid = @@spid and
                (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                 program_name like 'Microsoft SQL Server Management Studio%') )
begin
   if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0
   begin
      set @errmsg = '(market_value) New trans_id must be larger than original trans_id.'
      set @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg, 10, 1)
      if @@trancount > 0 rollback tran
      return
   end
end
 
if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.id = d.id)
begin
   raiserror ('(market_value) new trans_id must not be older than current trans_id.', 10, 1)
   if @@trancount > 0 rollback tran
   return
end
 
/* RECORD_STAMP_END */
if update(id)
begin
   set @count_num_rows = (select count(*) from inserted i, deleted d
                          where i.id = d.id)
   if (@count_num_rows = @num_rows)
   begin
      set @dummy_update = 1
   end
   else
   begin
      raiserror ('(market_value) primary key can not be changed.', 10, 1)
      if @@trancount > 0 rollback tran
      return
   end
end
 
if @dummy_update = 0
   insert dbo.aud_market_value
 	    (id,
 	     market_value,
 	     marketdata_supplier_id,
 	     priced_quote_period_id,
 	     received_date_time,
 	     settlement_date,
 	     trans_id,
       resp_trans_id)
   select
 	    d.id,
 	    d.market_value,
 	    d.marketdata_supplier_id,
 	    d.priced_quote_period_id,
 	    d.received_date_time,
 	    d.settlement_date,
 	    d.trans_id,
 	    i.trans_id
   from deleted d, inserted i
   where d.id = i.id
return
GO
ALTER TABLE [dbo].[market_value] ADD CONSTRAINT [market_value_pk] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[market_value] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[market_value] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[market_value] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[market_value] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'market_value', NULL, NULL
GO
