CREATE TABLE [dbo].[position_mark_to_market]
(
[pos_num] [int] NOT NULL,
[mtm_asof_date] [datetime] NOT NULL,
[mtm_mkt_price] [float] NULL,
[mtm_mkt_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mtm_mkt_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mtm_mkt_price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[opt_eval_method] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[otc_opt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[volatility] [float] NULL,
[interest_rate] [float] NULL,
[delta] [float] NULL,
[gamma] [float] NULL,
[theta] [float] NULL,
[vega] [float] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[position_mark_to_market_deltrg]
on [dbo].[position_mark_to_market]
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
   select @errmsg = '(position_mark_to_market) Failed to obtain a valid responsible trans_id.'
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
       'PositionMarkToMarket',
       'DIRECT',
       convert(varchar(40), d.pos_num),
       convert(varchar(40), d.mtm_asof_date),
       null,
       null,
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

insert dbo.aud_position_mark_to_market
   (pos_num,
    mtm_asof_date,
    mtm_mkt_price,
    mtm_mkt_price_curr_code,
    mtm_mkt_price_uom_code,
    mtm_mkt_price_source_code,
    opt_eval_method,
    otc_opt_code,
    volatility,
    interest_rate,
    delta,
    gamma,
    theta,
    vega,
    trans_id,
    resp_trans_id)
select
   d.pos_num,
   d.mtm_asof_date,
   d.mtm_mkt_price,
   d.mtm_mkt_price_curr_code,
   d.mtm_mkt_price_uom_code,
   d.mtm_mkt_price_source_code,
   d.opt_eval_method,
   d.otc_opt_code,
   d.volatility,
   d.interest_rate,
   d.delta,
   d.gamma,
   d.theta,
   d.vega,
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

create trigger [dbo].[position_mark_to_market_instrg]
on [dbo].[position_mark_to_market]
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
          'PositionMarkToMarket',
          'DIRECT',
          convert(varchar(40), i.pos_num),
          convert(varchar(40), i.mtm_asof_date),
          null,
          null,
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

create trigger [dbo].[position_mark_to_market_updtrg]
on [dbo].[position_mark_to_market]
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
   raiserror ('(position_mark_to_market) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(position_mark_to_market) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.pos_num = d.pos_num and 
                 i.mtm_asof_date = d.mtm_asof_date )
begin
   raiserror ('(position_mark_to_market) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(pos_num) or  
   update(mtm_asof_date) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.pos_num = d.pos_num and 
                                   i.mtm_asof_date = d.mtm_asof_date )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(position_mark_to_market) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'UPDATE',
       'PositionMarkToMarket',
       'DIRECT',
       convert(varchar(40), i.pos_num),
       convert(varchar(40), i.mtm_asof_date),
       null,
       null,
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
   insert dbo.aud_position_mark_to_market
      (pos_num,
       mtm_asof_date,
       mtm_mkt_price,
       mtm_mkt_price_curr_code,
       mtm_mkt_price_uom_code,
       mtm_mkt_price_source_code,
       opt_eval_method,
       otc_opt_code,
       volatility,
       interest_rate,
       delta,
       gamma,
       theta,
       vega,
       trans_id,
       resp_trans_id)
   select
      d.pos_num,
      d.mtm_asof_date,
      d.mtm_mkt_price,
      d.mtm_mkt_price_curr_code,
      d.mtm_mkt_price_uom_code,
      d.mtm_mkt_price_source_code,
      d.opt_eval_method,
      d.otc_opt_code,
      d.volatility,
      d.interest_rate,
      d.delta,
      d.gamma,
      d.theta,
      d.vega,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.pos_num = i.pos_num and
         d.mtm_asof_date = i.mtm_asof_date 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[position_mark_to_market] ADD CONSTRAINT [position_mark_to_market_pk] PRIMARY KEY NONCLUSTERED  ([pos_num], [mtm_asof_date]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [position_mark_to_market_idx1] ON [dbo].[position_mark_to_market] ([mtm_asof_date]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[position_mark_to_market] ADD CONSTRAINT [position_mark_to_market_fk1] FOREIGN KEY ([mtm_mkt_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[position_mark_to_market] ADD CONSTRAINT [position_mark_to_market_fk2] FOREIGN KEY ([otc_opt_code]) REFERENCES [dbo].[otc_option] ([otc_opt_code])
GO
ALTER TABLE [dbo].[position_mark_to_market] ADD CONSTRAINT [position_mark_to_market_fk4] FOREIGN KEY ([mtm_mkt_price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[position_mark_to_market] ADD CONSTRAINT [position_mark_to_market_fk5] FOREIGN KEY ([mtm_mkt_price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[position_mark_to_market] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[position_mark_to_market] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[position_mark_to_market] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[position_mark_to_market] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'position_mark_to_market', NULL, NULL
GO
