CREATE TABLE [dbo].[option_strike_alias]
(
[commkt_key] [int] NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[opt_strike_price] [float] NOT NULL,
[put_call_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alias_high_low_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[option_strike_alias_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alias_format_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[option_strike_alias_deltrg]
on [dbo].[option_strike_alias]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
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
   select @errmsg = '(option_strike_alias) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,16,1)
   if @@trancount > 0 rollback tran

   return
end


insert dbo.aud_option_strike_alias
   (commkt_key,
    trading_prd,
    opt_strike_price,
    put_call_ind,
    price_source_code,
    alias_source_code,
    alias_high_low_ind,
    option_strike_alias_name,
    alias_format_code,
    trans_id,
    resp_trans_id)
select
   d.commkt_key,
   d.trading_prd,
   d.opt_strike_price,
   d.put_call_ind,
   d.price_source_code,
   d.alias_source_code,
   d.alias_high_low_ind,
   d.option_strike_alias_name,
   d.alias_format_code,
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

create trigger [dbo].[option_strike_alias_updtrg]
on [dbo].[option_strike_alias]
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
   raiserror ('(option_strike_alias) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(option_strike_alias) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.commkt_key = d.commkt_key and 
                 i.trading_prd = d.trading_prd and 
                 i.opt_strike_price = d.opt_strike_price and 
                 i.put_call_ind = d.put_call_ind and 
                 i.price_source_code = d.price_source_code and
                 i.alias_source_code = d.alias_source_code )
begin
   raiserror ('(option_strike_alias) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(commkt_key) or  
   update(trading_prd) or  
   update(opt_strike_price) or  
   update(put_call_ind) or  
   update(price_source_code) or
   update(alias_source_code)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.commkt_key = d.commkt_key and 
                                   i.trading_prd = d.trading_prd and 
                                   i.opt_strike_price = d.opt_strike_price and 
                                   i.put_call_ind = d.put_call_ind and 
                                   i.price_source_code = d.price_source_code and
                                   i.alias_source_code = d.alias_source_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(option_strike_alias) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_option_strike_alias
      (commkt_key,
       trading_prd,
       opt_strike_price,
       put_call_ind,
       price_source_code,
       alias_source_code,
       alias_high_low_ind,
       option_strike_alias_name,
       alias_format_code,
       trans_id,
       resp_trans_id)
   select
      d.commkt_key,
      d.trading_prd,
      d.opt_strike_price,
      d.put_call_ind,
      d.price_source_code,
      d.alias_source_code,
      d.alias_high_low_ind,
      d.option_strike_alias_name,
      d.alias_format_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.commkt_key = i.commkt_key and
         d.trading_prd = i.trading_prd and
         d.opt_strike_price = i.opt_strike_price and
         d.put_call_ind = i.put_call_ind and
         d.price_source_code = i.price_source_code and
         d.alias_source_code = i.alias_source_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[option_strike_alias] ADD CONSTRAINT [option_strike_alias_pk] PRIMARY KEY CLUSTERED  ([commkt_key], [trading_prd], [opt_strike_price], [put_call_ind], [price_source_code], [alias_source_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [option_strike_alias_ix2] ON [dbo].[option_strike_alias] ([alias_source_code], [option_strike_alias_name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[option_strike_alias] ADD CONSTRAINT [option_strike_alias_fk1] FOREIGN KEY ([alias_source_code]) REFERENCES [dbo].[alias_source] ([alias_source_code])
GO
ALTER TABLE [dbo].[option_strike_alias] ADD CONSTRAINT [option_strike_alias_fk2] FOREIGN KEY ([commkt_key], [trading_prd], [opt_strike_price], [put_call_ind]) REFERENCES [dbo].[option_strike] ([commkt_key], [trading_prd], [opt_strike_price], [put_call_ind])
GO
ALTER TABLE [dbo].[option_strike_alias] ADD CONSTRAINT [option_strike_alias_fk3] FOREIGN KEY ([price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
GRANT DELETE ON  [dbo].[option_strike_alias] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[option_strike_alias] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[option_strike_alias] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[option_strike_alias] TO [next_usr]
GO
