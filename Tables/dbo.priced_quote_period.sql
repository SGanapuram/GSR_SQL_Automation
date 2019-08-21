CREATE TABLE [dbo].[priced_quote_period]
(
[id] [int] NOT NULL,
[end_pricing_date] [datetime] NULL,
[end_trading_date] [datetime] NULL,
[quote_id] [int] NULL,
[quote_period_desc_id] [int] NULL,
[symbol] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[priced_quote_period_deltrg]
on [dbo].[priced_quote_period]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
        @atrans_id   bigint

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
   select @errmsg = '(priced_quote_period) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,16,1)
   rollback tran
   return
end

insert dbo.aud_priced_quote_period
(  
   id, 
   end_pricing_date, 
   end_trading_date, 
   quote_id, 
   quote_period_desc_id, 
   type,
   trans_id,
   resp_trans_id
)
select
   d.id, 
   d.end_pricing_date, 
   d.end_trading_date, 
   d.quote_id, 
   d.quote_period_desc_id, 
   d.type,
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

create trigger [dbo].[priced_quote_period_updtrg]
on [dbo].[priced_quote_period]
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
   raiserror('(priced_quote_period) The change needs to be attached with a new trans_id.', 16, 1)
   rollback tran
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
      select @errmsg = '(priced_quote_period) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      rollback tran
      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.id = d.id)
begin
   select @errmsg = '(priced_quote_period) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.id) + ')'
      from inserted i
   end
   rollback tran
   raiserror (@errmsg,16,1)
   return
end

/* RECORD_STAMP_END */

if update(id)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.id = d.id)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(priced_quote_period) primary key can not be changed.',16,1)
      rollback tran
      return
   end
end

if @dummy_update = 0
   insert dbo.aud_priced_quote_period
 	    (id,
       end_pricing_date, 
       end_trading_date, 
       quote_id, 
       quote_period_desc_id, 
       type,
       trans_id,
       resp_trans_id)
   select
 	    d.id,
      d.end_pricing_date, 
      d.end_trading_date, 
      d.quote_id, 
      d.quote_period_desc_id, 
      d.type,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.id = i.id 

return
GO
ALTER TABLE [dbo].[priced_quote_period] ADD CONSTRAINT [priced_quote_period_pk] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [priced_quote_period_idx1] ON [dbo].[priced_quote_period] ([quote_id], [quote_period_desc_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[priced_quote_period] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[priced_quote_period] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[priced_quote_period] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[priced_quote_period] TO [next_usr]
GO
