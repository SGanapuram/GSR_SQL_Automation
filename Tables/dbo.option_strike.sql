CREATE TABLE [dbo].[option_strike]
(
[commkt_key] [int] NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[opt_strike_price] [float] NOT NULL,
[put_call_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[option_strike_deltrg]
on [dbo].[option_strike]
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
   select @errmsg = '(option_strike) Failed to obtain a valid responsible trans_id.'
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


/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'DELETE',
       'OptionStrike',
       'DIRECT',
       convert(varchar(40), d.commkt_key),
       convert(varchar(40), d.trading_prd),
       convert(varchar(40), d.opt_strike_price),
       convert(varchar(40), d.put_call_ind),
       null,
       null,
       null,
       null,
       @atrans_id,
       it.sequence
from deleted d, dbo.icts_transaction it
where it.trans_id = @atrans_id and
      it.type != 'E'
 
/* END_TRANSACTION_TOUCH */


/* AUDIT_CODE_BEGIN */

insert dbo.aud_option_strike
   (commkt_key,
    trading_prd,
    opt_strike_price,
    put_call_ind,
    trans_id,
    resp_trans_id)
select
   d.commkt_key,
   d.trading_prd,
   d.opt_strike_price,
   d.put_call_ind,
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

create trigger [dbo].[option_strike_instrg]
on [dbo].[option_strike]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

   /* BEGIN_TRANSACTION_TOUCH */
 
   insert dbo.transaction_touch
   select 'INSERT',
          'OptionStrike',
          'DIRECT',
          convert(varchar(40), i.commkt_key),
          convert(varchar(40), i.trading_prd),
          convert(varchar(40), i.opt_strike_price),
          convert(varchar(40), i.put_call_ind),
          null,
          null,
          null,
          null,
          i.trans_id,
          it.sequence
   from inserted i, dbo.icts_transaction it
   where i.trans_id = it.trans_id and
         it.type != 'E'
 
   /* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[option_strike_updtrg]
on [dbo].[option_strike]
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
   raiserror ('(option_strike) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(option_strike) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.commkt_key = d.commkt_key and 
                 i.trading_prd = d.trading_prd and 
                 i.opt_strike_price = d.opt_strike_price and 
                 i.put_call_ind = d.put_call_ind )
begin
   raiserror ('(option_strike) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(commkt_key) or  
   update(trading_prd) or  
   update(opt_strike_price) or  
   update(put_call_ind) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.commkt_key = d.commkt_key and 
                                   i.trading_prd = d.trading_prd and 
                                   i.opt_strike_price = d.opt_strike_price and 
                                   i.put_call_ind = d.put_call_ind )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(option_strike) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'UPDATE',
       'OptionStrike',
       'DIRECT',
       convert(varchar(40), i.commkt_key),
       convert(varchar(40), i.trading_prd),
       convert(varchar(40), i.opt_strike_price),
       convert(varchar(40), i.put_call_ind),
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from inserted i, dbo.icts_transaction it
where i.trans_id = it.trans_id and
      it.type != 'E'
 
/* END_TRANSACTION_TOUCH */


/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_option_strike
      (commkt_key,
       trading_prd,
       opt_strike_price,
       put_call_ind,
       trans_id,
       resp_trans_id)
   select
      d.commkt_key,
      d.trading_prd,
      d.opt_strike_price,
      d.put_call_ind,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.commkt_key = i.commkt_key and
         d.trading_prd = i.trading_prd and
         d.opt_strike_price = i.opt_strike_price and
         d.put_call_ind = i.put_call_ind 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[option_strike] ADD CONSTRAINT [option_strike_pk] PRIMARY KEY CLUSTERED  ([commkt_key], [trading_prd], [opt_strike_price], [put_call_ind]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[option_strike] ADD CONSTRAINT [option_strike_fk1] FOREIGN KEY ([commkt_key], [trading_prd]) REFERENCES [dbo].[trading_period] ([commkt_key], [trading_prd])
GO
GRANT DELETE ON  [dbo].[option_strike] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[option_strike] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[option_strike] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[option_strike] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'option_strike', NULL, NULL
GO
