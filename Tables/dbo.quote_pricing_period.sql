CREATE TABLE [dbo].[quote_pricing_period]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[accum_num] [smallint] NOT NULL,
[qpp_num] [smallint] NOT NULL,
[formula_num] [int] NULL,
[formula_body_num] [tinyint] NULL,
[formula_comp_num] [smallint] NULL,
[real_trading_prd] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[risk_trading_prd] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[nominal_start_date] [datetime] NULL,
[nominal_end_date] [datetime] NULL,
[quote_start_date] [datetime] NULL,
[quote_end_date] [datetime] NULL,
[num_of_pricing_days] [smallint] NULL,
[num_of_days_priced] [smallint] NULL,
[total_qty] [float] NOT NULL,
[priced_qty] [float] NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[priced_price] [float] NULL,
[open_price] [float] NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_pricing_date] [datetime] NULL,
[manual_override_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[cal_impact_start_date] [datetime] NULL,
[cal_impact_end_date] [datetime] NULL,
[calendar_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[quote_pricing_period_deltrg]
on [dbo].[quote_pricing_period]
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
   select @errmsg = '(quote_pricing_period) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_quote_pricing_period
   (trade_num,
    order_num,
    item_num,
    accum_num,
    qpp_num,
    formula_num,
    formula_body_num,
    formula_comp_num,
    real_trading_prd,
    risk_trading_prd,
    nominal_start_date,
    nominal_end_date,
    quote_start_date,
    quote_end_date,
    num_of_pricing_days,
    num_of_days_priced,
    total_qty,
    priced_qty,
    qty_uom_code,
    priced_price,
    open_price,
    price_curr_code,
    price_uom_code,
    last_pricing_date,
    manual_override_ind,
    cal_impact_start_date,
    cal_impact_end_date,
    calendar_code,         
    trans_id,
    resp_trans_id)
select
   d.trade_num,
   d.order_num,
   d.item_num,
   d.accum_num,
   d.qpp_num,
   d.formula_num,
   d.formula_body_num,
   d.formula_comp_num,
   d.real_trading_prd,
   d.risk_trading_prd,
   d.nominal_start_date,
   d.nominal_end_date,
   d.quote_start_date,
   d.quote_end_date,
   d.num_of_pricing_days,
   d.num_of_days_priced,
   d.total_qty,
   d.priced_qty,
   d.qty_uom_code,
   d.priced_price,
   d.open_price,
   d.price_curr_code,
   d.price_uom_code,
   d.last_pricing_date,
   d.manual_override_ind,
   d.cal_impact_start_date,
   d.cal_impact_end_date,
   d.calendar_code,         
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'QuotePricingPeriod'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it
      where it.trans_id = @atrans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'D',
             @the_entity_name,
             convert(varchar(40), d.trade_num),
             convert(varchar(40), d.order_num),
             convert(varchar(40), d.item_num),
             convert(varchar(40), d.accum_num),
             convert(varchar(40), d.qpp_num),
             null,
             null,
             null,
             @atrans_id,
             @the_sequence
      from dbo.als_module_entity a,
           dbo.server_config sc,
           deleted d
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (@the_tran_type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (@the_tran_type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (@the_tran_type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (@the_tran_type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (@the_tran_type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (@the_tran_type = 'A') )
            ) AND
            (a.operation_type_mask & 4) = 4 AND
            a.entity_name = @the_entity_name

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */
      if @the_tran_type <> 'E'
         insert dbo.transaction_touch
         select 'DELETE',
                @the_entity_name,
                'DIRECT',
                convert(varchar(40), d.trade_num),
                convert(varchar(40), d.order_num),
                convert(varchar(40), d.item_num),
                convert(varchar(40), d.accum_num),
                convert(varchar(40), d.qpp_num),
                null,
                null,
                null,
                @atrans_id,
                @the_sequence
         from deleted d

      /* END_TRANSACTION_TOUCH */
   end
   else
   begin  /* if @num_rows > 1 */
      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'D',
             @the_entity_name,
             convert(varchar(40), d.trade_num),
             convert(varchar(40), d.order_num),
             convert(varchar(40), d.item_num),
             convert(varchar(40), d.accum_num),
             convert(varchar(40), d.qpp_num),
             null,
             null,
             null,
             @atrans_id,
             it.sequence
      from dbo.als_module_entity a,
           dbo.server_config sc,
           deleted d,
           dbo.icts_transaction it
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (it.type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (it.type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (it.type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (it.type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (it.type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (it.type = 'A') )
            ) AND
            (a.operation_type_mask & 4) = 4 AND
            a.entity_name = @the_entity_name AND
            it.trans_id = @atrans_id

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'DELETE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), d.trade_num),
             convert(varchar(40), d.order_num),
             convert(varchar(40), d.item_num),
             convert(varchar(40), d.accum_num),
             convert(varchar(40), d.qpp_num),
             null,
             null,
             null,
             @atrans_id,
             it.sequence
      from dbo.icts_transaction it,
           deleted d
      where it.trans_id = @atrans_id and
            it.type != 'E'

      /* END_TRANSACTION_TOUCH */
   end

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[quote_pricing_period_instrg]
on [dbo].[quote_pricing_period]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'QuotePricingPeriod'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it,
           inserted i
      where it.trans_id = i.trans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'I',
             @the_entity_name,
             convert(varchar(40), trade_num),
             convert(varchar(40), order_num),
             convert(varchar(40), item_num),
             convert(varchar(40), accum_num),
             convert(varchar(40), qpp_num),
             null,
             null,
             null,
             i.trans_id,
             @the_sequence
      from dbo.als_module_entity a,
           dbo.server_config sc,
           inserted i
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (@the_tran_type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (@the_tran_type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (@the_tran_type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (@the_tran_type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (@the_tran_type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (@the_tran_type = 'A') )
            ) AND
            (a.operation_type_mask & 1) = 1 AND
            a.entity_name = @the_entity_name

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */
      if @the_tran_type <> 'E'
         insert dbo.transaction_touch
         select 'INSERT',
                @the_entity_name,
                'DIRECT',
                convert(varchar(40), trade_num),
                convert(varchar(40), order_num),
                convert(varchar(40), item_num),
                convert(varchar(40), accum_num),
                convert(varchar(40), qpp_num),
                null,
                null,
                null,
                i.trans_id,
                @the_sequence
         from inserted i

      /* END_TRANSACTION_TOUCH */
   end
   else
   begin  /* if @num_rows > 1 */
      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'I',
             @the_entity_name,
             convert(varchar(40), trade_num),
             convert(varchar(40), order_num),
             convert(varchar(40), item_num),
             convert(varchar(40), accum_num),
             convert(varchar(40), qpp_num),
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.als_module_entity a,
           dbo.server_config sc,
           inserted i,
           dbo.icts_transaction it
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (it.type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (it.type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (it.type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (it.type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (it.type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (it.type = 'A') )
            ) AND
            (a.operation_type_mask & 1) = 1 AND
            a.entity_name = @the_entity_name AND
            i.trans_id = it.trans_id

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'INSERT',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), trade_num),
             convert(varchar(40), order_num),
             convert(varchar(40), item_num),
             convert(varchar(40), accum_num),
             convert(varchar(40), qpp_num),
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it,
           inserted i
      where i.trans_id = it.trans_id and
            it.type != 'E'

      /* END_TRANSACTION_TOUCH */
   end

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[quote_pricing_period_updtrg]
on [dbo].[quote_pricing_period]
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
   raiserror ('(quote_pricing_period) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(quote_pricing_period) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.trade_num = d.trade_num and 
                 i.order_num = d.order_num and 
                 i.item_num = d.item_num and 
                 i.accum_num = d.accum_num and 
                 i.qpp_num = d.qpp_num )
begin
   raiserror ('(quote_pricing_period) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(trade_num) or  
   update(order_num) or  
   update(item_num) or  
   update(accum_num) or  
   update(qpp_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.trade_num = d.trade_num and 
                                   i.order_num = d.order_num and 
                                   i.item_num = d.item_num and 
                                   i.accum_num = d.accum_num and 
                                   i.qpp_num = d.qpp_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(quote_pricing_period) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end


/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_quote_pricing_period
      (trade_num,
       order_num,
       item_num,
       accum_num,
       qpp_num,
       formula_num,
       formula_body_num,
       formula_comp_num,
       real_trading_prd,
       risk_trading_prd,
       nominal_start_date,
       nominal_end_date,
       quote_start_date,
       quote_end_date,
       num_of_pricing_days,
       num_of_days_priced,
       total_qty,
       priced_qty,
       qty_uom_code,
       priced_price,
       open_price,
       price_curr_code,
       price_uom_code,
       last_pricing_date,
       manual_override_ind,
       cal_impact_start_date,
       cal_impact_end_date,
       calendar_code,         
       trans_id,
       resp_trans_id)
   select
      d.trade_num,
      d.order_num,
      d.item_num,
      d.accum_num,
      d.qpp_num,
      d.formula_num,
      d.formula_body_num,
      d.formula_comp_num,
      d.real_trading_prd,
      d.risk_trading_prd,
      d.nominal_start_date,
      d.nominal_end_date,
      d.quote_start_date,
      d.quote_end_date,
      d.num_of_pricing_days,
      d.num_of_days_priced,
      d.total_qty,
      d.priced_qty,
      d.qty_uom_code,
      d.priced_price,
      d.open_price,
      d.price_curr_code,
      d.price_uom_code,
      d.last_pricing_date,
      d.manual_override_ind,
      d.cal_impact_start_date,
      d.cal_impact_end_date,
      d.calendar_code,         
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.trade_num = i.trade_num and
         d.order_num = i.order_num and
         d.item_num = i.item_num and
         d.accum_num = i.accum_num and
         d.qpp_num = i.qpp_num

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'QuotePricingPeriod'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it,
           inserted i
      where it.trans_id = i.trans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'U',
             @the_entity_name,
             convert(varchar(40), trade_num),
             convert(varchar(40), order_num),
             convert(varchar(40), item_num),
             convert(varchar(40), accum_num),
             convert(varchar(40), qpp_num),
             null,
             null,
             null,
             i.trans_id,
             @the_sequence
      from dbo.als_module_entity a,
           dbo.server_config sc,
           inserted i
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (@the_tran_type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (@the_tran_type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (@the_tran_type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (@the_tran_type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (@the_tran_type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (@the_tran_type = 'A') )
            ) AND
            (a.operation_type_mask & 2) = 2 AND
            a.entity_name = @the_entity_name

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */
      if @the_tran_type <> 'E'
         insert dbo.transaction_touch
         select 'UPDATE',
                @the_entity_name,
                'DIRECT',
             convert(varchar(40), trade_num),
             convert(varchar(40), order_num),
             convert(varchar(40), item_num),
             convert(varchar(40), accum_num),
             convert(varchar(40), qpp_num),
             null,
             null,
             null,
             i.trans_id,
             @the_sequence
      from inserted i

      /* END_TRANSACTION_TOUCH */
   end
   else
   begin  /* if @num_rows > 1 */
      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'U',
             @the_entity_name,
             convert(varchar(40), trade_num),
             convert(varchar(40), order_num),
             convert(varchar(40), item_num),
             convert(varchar(40), accum_num),
             convert(varchar(40), qpp_num),
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.als_module_entity a,
           dbo.server_config sc,
           inserted i,
           dbo.icts_transaction it
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (it.type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (it.type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (it.type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (it.type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (it.type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (it.type = 'A') )
            ) AND
            (a.operation_type_mask & 2) = 2 AND
            a.entity_name = @the_entity_name AND
            i.trans_id = it.trans_id

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'UPDATE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), trade_num),
             convert(varchar(40), order_num),
             convert(varchar(40), item_num),
             convert(varchar(40), accum_num),
             convert(varchar(40), qpp_num),
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it,
           inserted i
      where i.trans_id = it.trans_id and
            it.type != 'E'

      /* END_TRANSACTION_TOUCH */
   end

return
GO
ALTER TABLE [dbo].[quote_pricing_period] ADD CONSTRAINT [quote_pricing_period_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num], [accum_num], [qpp_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [quote_pricing_period_idx3] ON [dbo].[quote_pricing_period] ([formula_num], [formula_body_num], [formula_comp_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [quote_pricing_period_idx2] ON [dbo].[quote_pricing_period] ([formula_num], [trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [quote_pricing_period_idx1] ON [dbo].[quote_pricing_period] ([trade_num], [order_num], [item_num], [accum_num], [trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[quote_pricing_period] ADD CONSTRAINT [quote_pricing_period_fk4] FOREIGN KEY ([qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[quote_pricing_period] ADD CONSTRAINT [quote_pricing_period_fk5] FOREIGN KEY ([price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[quote_pricing_period] ADD CONSTRAINT [quote_pricing_period_fk6] FOREIGN KEY ([calendar_code]) REFERENCES [dbo].[calendar] ([calendar_code])
GO
GRANT DELETE ON  [dbo].[quote_pricing_period] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[quote_pricing_period] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[quote_pricing_period] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[quote_pricing_period] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'quote_pricing_period', NULL, NULL
GO
