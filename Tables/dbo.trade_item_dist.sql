CREATE TABLE [dbo].[trade_item_dist]
(
[dist_num] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[accum_num] [smallint] NULL,
[qpp_num] [smallint] NULL,
[pos_num] [int] NULL,
[real_port_num] [int] NOT NULL,
[dist_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[real_synth_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[is_equiv_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[what_if_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bus_date] [datetime] NOT NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dist_qty] [float] NOT NULL,
[alloc_qty] [float] NOT NULL,
[discount_qty] [float] NOT NULL,
[priced_qty] [float] NOT NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[qty_uom_code_conv_to] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qty_uom_conv_rate] [float] NULL,
[price_curr_code_conv_to] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_curr_conv_rate] [float] NULL,
[price_uom_code_conv_to] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_conv_rate] [float] NULL,
[spread_pos_group_num] [int] NULL,
[delivered_qty] [float] NULL,
[open_pl] [float] NULL,
[pl_asof_date] [datetime] NULL,
[closed_pl] [float] NULL,
[addl_cost_sum] [float] NULL,
[sec_conversion_factor] [float] NULL,
[sec_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_key] [int] NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[estimate_qty] [numeric] (20, 8) NULL,
[formula_num] [int] NULL,
[formula_body_num] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_dist_deltrg]
on [dbo].[trade_item_dist]
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
   select @errmsg = '(trade_item_dist) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_trade_item_dist
   (dist_num,
    trade_num,
    order_num,
    item_num,
    accum_num,
    qpp_num,
    pos_num,
    real_port_num,
    dist_type,
    real_synth_ind,
    is_equiv_ind,
    what_if_ind,
    bus_date,
    p_s_ind,
    dist_qty,
    alloc_qty,
    discount_qty,
    priced_qty,
    qty_uom_code,
    qty_uom_code_conv_to,
    qty_uom_conv_rate,
    price_curr_code_conv_to,
    price_curr_conv_rate,
    price_uom_code_conv_to,
    price_uom_conv_rate,
    spread_pos_group_num,
    delivered_qty,
    open_pl,
    pl_asof_date,
    closed_pl,
    addl_cost_sum,
    sec_conversion_factor,
    sec_qty_uom_code,
    commkt_key,
    trading_prd,
    estimate_qty,
    trans_id,
    resp_trans_id,
    formula_num,
    formula_body_num)
select
   d.dist_num,
   d.trade_num,
   d.order_num,
   d.item_num,
   d.accum_num,
   d.qpp_num,
   d.pos_num,
   d.real_port_num,
   d.dist_type,
   d.real_synth_ind,
   d.is_equiv_ind,
   d.what_if_ind,
   d.bus_date,
   d.p_s_ind,
   d.dist_qty,
   d.alloc_qty,
   d.discount_qty,
   d.priced_qty,
   d.qty_uom_code,
   d.qty_uom_code_conv_to,
   d.qty_uom_conv_rate,
   d.price_curr_code_conv_to,
   d.price_curr_conv_rate,
   d.price_uom_code_conv_to,
   d.price_uom_conv_rate,
   d.spread_pos_group_num,
   d.delivered_qty,
   d.open_pl,
   d.pl_asof_date,
   d.closed_pl,
   d.addl_cost_sum,
   d.sec_conversion_factor,
   d.sec_qty_uom_code,
   d.commkt_key,
   d.trading_prd,
   d.estimate_qty,
   d.trans_id,
   @atrans_id,
   d.formula_num,
   d.formula_body_num
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'TradeItemDist'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it WITH (NOLOCK)
      where it.trans_id = @atrans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'D',
             @the_entity_name,
             convert(varchar(40),d.dist_num),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             @the_sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
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

      insert dbo.transaction_touch
      select 'DELETE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40),d.dist_num),
             null,
             null,
             null,
             null,
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
             convert(varchar(40),d.dist_num),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             it.sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           deleted d,
           dbo.icts_transaction it WITH (NOLOCK)
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
             convert(varchar(40),d.dist_num),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           deleted d
      where it.trans_id = @atrans_id

      /* END_TRANSACTION_TOUCH */
   end

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_dist_instrg]
on [dbo].[trade_item_dist]
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

   select @the_entity_name = 'TradeItemDist'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where it.trans_id = i.trans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'I',
             @the_entity_name,
             convert(varchar(40),dist_num),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             @the_sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
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

      insert dbo.transaction_touch
      select 'INSERT',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40),dist_num),
             null,
             null,
             null,
             null,
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
             convert(varchar(40),dist_num),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           inserted i,
           dbo.icts_transaction it WITH (NOLOCK)
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
             convert(varchar(40),dist_num),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where i.trans_id = it.trans_id

      /* END_TRANSACTION_TOUCH */
   end

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_dist_updtrg]
on [dbo].[trade_item_dist]
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
   raiserror ('(trade_item_dist) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(trade_item_dist) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.dist_num = d.dist_num )
begin
   raiserror ('(trade_item_dist) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(dist_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.dist_num = d.dist_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(trade_item_dist) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_trade_item_dist
      (dist_num,
       trade_num,
       order_num,
       item_num,
       accum_num,
       qpp_num,
       pos_num,
       real_port_num,
       dist_type,
       real_synth_ind,
       is_equiv_ind,
       what_if_ind,
       bus_date,
       p_s_ind,
       dist_qty,
       alloc_qty,
       discount_qty,
       priced_qty,
       qty_uom_code,
       qty_uom_code_conv_to,
       qty_uom_conv_rate,
       price_curr_code_conv_to,
       price_curr_conv_rate,
       price_uom_code_conv_to,
       price_uom_conv_rate,
       spread_pos_group_num,
       delivered_qty,
       open_pl,
       pl_asof_date,
       closed_pl,
       addl_cost_sum,
       sec_conversion_factor,
       sec_qty_uom_code,
       commkt_key,
       trading_prd,
       estimate_qty,
       trans_id,
       resp_trans_id,
       formula_num,
       formula_body_num)
   select
      d.dist_num,
      d.trade_num,
      d.order_num,
      d.item_num,
      d.accum_num,
      d.qpp_num,
      d.pos_num,
      d.real_port_num,
      d.dist_type,
      d.real_synth_ind,
      d.is_equiv_ind,
      d.what_if_ind,
      d.bus_date,
      d.p_s_ind,
      d.dist_qty,
      d.alloc_qty,
      d.discount_qty,
      d.priced_qty,
      d.qty_uom_code,
      d.qty_uom_code_conv_to,
      d.qty_uom_conv_rate,
      d.price_curr_code_conv_to,
      d.price_curr_conv_rate,
      d.price_uom_code_conv_to,
      d.price_uom_conv_rate,
      d.spread_pos_group_num,
      d.delivered_qty,
      d.open_pl,
      d.pl_asof_date,
      d.closed_pl,
      d.addl_cost_sum,
      d.sec_conversion_factor,
      d.sec_qty_uom_code,
      d.commkt_key,
      d.trading_prd,
      d.estimate_qty,
      d.trans_id,
      i.trans_id,
      d.formula_num,
      d.formula_body_num
   from deleted d, inserted i
   where d.dist_num = i.dist_num

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'TradeItemDist'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where it.trans_id = i.trans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'U',
             @the_entity_name,
             convert(varchar(40),dist_num),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             @the_sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
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

      insert dbo.transaction_touch
      select 'UPDATE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40),dist_num),
             null,
             null,
             null,
             null,
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
             convert(varchar(40),dist_num),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           inserted i,
           dbo.icts_transaction it WITH (NOLOCK)
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
             convert(varchar(40),dist_num),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where i.trans_id = it.trans_id

      /* END_TRANSACTION_TOUCH */
   end


return
GO
ALTER TABLE [dbo].[trade_item_dist] ADD CONSTRAINT [trade_item_dist_pk] PRIMARY KEY CLUSTERED  ([dist_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_dist_idx3] ON [dbo].[trade_item_dist] ([bus_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_dist_TS_idx90] ON [dbo].[trade_item_dist] ([dist_type], [real_synth_ind], [real_port_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_dist_idx2] ON [dbo].[trade_item_dist] ([pos_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_dist_idx5] ON [dbo].[trade_item_dist] ([real_port_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_dist_idx1] ON [dbo].[trade_item_dist] ([trade_num], [order_num], [item_num], [accum_num], [qpp_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_dist_idx7] ON [dbo].[trade_item_dist] ([trade_num], [order_num], [item_num], [bus_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_dist_idx6] ON [dbo].[trade_item_dist] ([trade_num], [order_num], [item_num], [real_port_num], [dist_type], [is_equiv_ind], [what_if_ind]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_dist_idx4] ON [dbo].[trade_item_dist] ([trade_num], [order_num], [item_num], [trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_dist] ADD CONSTRAINT [trade_item_dist_fk10] FOREIGN KEY ([price_uom_code_conv_to]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_dist] ADD CONSTRAINT [trade_item_dist_fk11] FOREIGN KEY ([sec_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_dist] ADD CONSTRAINT [trade_item_dist_fk12] FOREIGN KEY ([commkt_key], [trading_prd]) REFERENCES [dbo].[trading_period] ([commkt_key], [trading_prd])
GO
ALTER TABLE [dbo].[trade_item_dist] ADD CONSTRAINT [trade_item_dist_fk2] FOREIGN KEY ([price_curr_code_conv_to]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_dist] ADD CONSTRAINT [trade_item_dist_fk8] FOREIGN KEY ([qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_dist] ADD CONSTRAINT [trade_item_dist_fk9] FOREIGN KEY ([qty_uom_code_conv_to]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[trade_item_dist] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_dist] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_dist] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_dist] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'trade_item_dist', NULL, NULL
GO
