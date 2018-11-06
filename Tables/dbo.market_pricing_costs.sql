CREATE TABLE [dbo].[market_pricing_costs]
(
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_amt] [float] NULL,
[cost_date] [datetime] NOT NULL,
[cost_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__market_pr__cost___611C5D5B] DEFAULT ('USD'),
[cost_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__market_pr__cost___62108194] DEFAULT ('BBL'),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[market_pricing_costs_deltrg]
on [dbo].[market_pricing_costs]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   int

select @num_rows = @@rowcount
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
   select @errmsg = '(market_pricing_costs) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   if @@trancount > 0 rollback tran

   return
end


insert dbo.aud_market_pricing_costs
   (mkt_code,
    cost_name,
    cost_amt,
    cost_date,
    cost_curr_code,
    cost_uom_code, 
    trans_id,
    resp_trans_id)
select
   d.mkt_code,
   d.cost_name,
   d.cost_amt,
   d.cost_date,
   d.cost_curr_code,
   d.cost_uom_code, 
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

create trigger [dbo].[market_pricing_costs_updtrg]
on [dbo].[market_pricing_costs]
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
   raiserror ('(market_pricing_costs) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(market_pricing_costs) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.mkt_code = d.mkt_code)
begin
   raiserror ('(market_pricing_costs) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(mkt_code)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where  i.mkt_code = d.mkt_code)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(market_pricing_costs) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_market_pricing_costs
      (mkt_code,
       cost_name,
       cost_amt,
       cost_date,
       cost_curr_code,
       cost_uom_code, 
       trans_id,
       resp_trans_id)
   select
       d.mkt_code,
       d.cost_name,
       d.cost_amt,
       d.cost_date,
       d.cost_curr_code,
       d.cost_uom_code, 
       d.trans_id,
       i.trans_id
   from deleted d, inserted i
   where d.mkt_code = i.mkt_code

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[market_pricing_costs] ADD CONSTRAINT [market_pricing_costs_pk] PRIMARY KEY CLUSTERED  ([mkt_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [market_pricing_costs_idx1] ON [dbo].[market_pricing_costs] ([mkt_code], [cost_date]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[market_pricing_costs] ADD CONSTRAINT [market_pricing_costs_fk1] FOREIGN KEY ([mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
ALTER TABLE [dbo].[market_pricing_costs] ADD CONSTRAINT [market_pricing_costs_fk2] FOREIGN KEY ([cost_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[market_pricing_costs] ADD CONSTRAINT [market_pricing_costs_fk3] FOREIGN KEY ([cost_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[market_pricing_costs] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[market_pricing_costs] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[market_pricing_costs] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[market_pricing_costs] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'market_pricing_costs', NULL, NULL
GO
