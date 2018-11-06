CREATE TABLE [dbo].[allocation]
(
[alloc_num] [int] NOT NULL,
[alloc_type_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sch_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alloc_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmnt_num] [int] NULL,
[ppl_comp_num] [int] NULL,
[ppl_comp_cont_num] [int] NULL,
[sch_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ppl_batch_num] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ppl_pump_date] [datetime] NULL,
[compr_trade_num] [int] NULL,
[initiator_acct_num] [int] NULL,
[deemed_bl_date] [datetime] NULL,
[alloc_pay_date] [datetime] NULL,
[alloc_base_price] [float] NULL,
[alloc_disc_rate] [float] NULL,
[transportation] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[netout_gross_qty] [float] NULL,
[netout_net_qty] [float] NULL,
[netout_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ppl_batch_given_date] [datetime] NULL,
[ppl_batch_received_date] [datetime] NULL,
[ppl_origin_given_date] [datetime] NULL,
[ppl_origin_received_date] [datetime] NULL,
[ppl_timing_cycle_num] [int] NULL,
[ppl_split_cycle_opt] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alloc_short_cmnt] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[netout_parcel_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alloc_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bookout_pay_date] [datetime] NULL,
[bookout_rec_date] [datetime] NULL,
[alloc_match_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alloc_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alloc_begin_date] [datetime] NULL,
[alloc_end_date] [datetime] NULL,
[alloc_load_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[book_net_price_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_date] [datetime] NULL,
[multiple_cmdty_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_precision] [smallint] NULL,
[pay_for_del] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pay_for_weight] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[max_alloc_item_num] [smallint] NULL,
[voyage_code] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[release_doc_num] [int] NULL,
[bookout_brkr_num] [int] NULL,
[base_port_num] [int] NULL,
[transfer_price] [numeric] (20, 8) NULL,
[transfer_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_price_curr_code_to] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_price_currency_rate] [float] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[allocation_deltrg]
on [dbo].[allocation]
for delete
as
declare @num_rows   int,
        @errmsg     varchar(255),
        @atrans_id  int

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
   select @errmsg = '(allocation) Failed to obtain a valid responsible trans_id. '
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   rollback tran
   return
end

insert dbo.aud_allocation
   (alloc_num,
    alloc_type_code,
    mot_code,
    sch_init,
    alloc_status,
    cmnt_num,
    ppl_comp_num,
    ppl_comp_cont_num,
    sch_prd,
    ppl_batch_num,
    ppl_pump_date,
    compr_trade_num,
    initiator_acct_num,
    deemed_bl_date,
    alloc_pay_date,
    alloc_base_price,
    alloc_disc_rate,
    transportation,
    netout_gross_qty,
    netout_net_qty,
    netout_qty_uom_code,
    ppl_batch_given_date,
    ppl_batch_received_date,
    ppl_origin_given_date,
    ppl_origin_received_date,
    ppl_timing_cycle_num,
    ppl_split_cycle_opt,
    alloc_short_cmnt,
    creation_type,
    netout_parcel_num,
    alloc_cmdty_code,
    bookout_pay_date,
    bookout_rec_date,
    alloc_match_ind,
    alloc_loc_code,
    alloc_begin_date,
    alloc_end_date,
    alloc_load_loc_code,
    book_net_price_ind,
    creation_date,
    multiple_cmdty_ind,
    price_precision,
    pay_for_del,
    pay_for_weight,
    max_alloc_item_num,
    voyage_code,
    release_doc_num,
    bookout_brkr_num,
    base_port_num,
    transfer_price,
    transfer_price_uom_code,
    transfer_price_curr_code,
    transfer_price_curr_code_to,
	  transfer_price_currency_rate,
    trans_id,
    resp_trans_id)
select
   d.alloc_num,
   d.alloc_type_code,
   d.mot_code,
   d.sch_init,
   d.alloc_status,
   d.cmnt_num,
   d.ppl_comp_num,
   d.ppl_comp_cont_num,
   d.sch_prd,
   d.ppl_batch_num,
   d.ppl_pump_date,
   d.compr_trade_num,
   d.initiator_acct_num,
   d.deemed_bl_date,
   d.alloc_pay_date,
   d.alloc_base_price,
   d.alloc_disc_rate,
   d.transportation,
   d.netout_gross_qty,
   d.netout_net_qty,
   d.netout_qty_uom_code,
   d.ppl_batch_given_date,
   d.ppl_batch_received_date,
   d.ppl_origin_given_date,
   d.ppl_origin_received_date,
   d.ppl_timing_cycle_num,
   d.ppl_split_cycle_opt,
   d.alloc_short_cmnt,
   d.creation_type,
   d.netout_parcel_num,
   d.alloc_cmdty_code,
   d.bookout_pay_date,
   d.bookout_rec_date,
   d.alloc_match_ind,
   d.alloc_loc_code,
   d.alloc_begin_date,
   d.alloc_end_date,
   d.alloc_load_loc_code,
   d.book_net_price_ind,
   d.creation_date,
   d.multiple_cmdty_ind,
   d.price_precision,
   d.pay_for_del,
   d.pay_for_weight,
   d.max_alloc_item_num,
   d.voyage_code,
   d.release_doc_num,
   d.bookout_brkr_num,
   d.base_port_num,
   d.transfer_price,
   d.transfer_price_uom_code,
   d.transfer_price_curr_code,
   d.transfer_price_curr_code_to,
	 d.transfer_price_currency_rate,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'Allocation'

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
             convert(varchar(40),d.alloc_num),
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

      if @the_tran_type != 'E'
      begin
         /* BEGIN_TRANSACTION_TOUCH */

         insert dbo.transaction_touch
         select 'DELETE',
                @the_entity_name,
                'DIRECT',
                convert(varchar(40),d.alloc_num),
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
             convert(varchar(40),d.alloc_num),
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
             convert(varchar(40),d.alloc_num),
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
      where it.trans_id = @atrans_id and
            it.type != 'E'

      /* END_TRANSACTION_TOUCH */
   end

return
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[allocation_instrg]
on [dbo].[allocation]
for insert
as
declare @num_rows        int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'Allocation'

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
             convert(varchar(40),alloc_num),
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

      if @the_tran_type != 'E'
      begin
         /* BEGIN_TRANSACTION_TOUCH */

         insert dbo.transaction_touch
         select 'INSERT',
                @the_entity_name,
                'DIRECT',
                convert(varchar(40),alloc_num),
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
             convert(varchar(40),alloc_num),
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
             convert(varchar(40),alloc_num),
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
      where i.trans_id = it.trans_id and
            it.type != 'E'

      /* END_TRANSACTION_TOUCH */
   end

return
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[allocation_updtrg]
on [dbo].[allocation]
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
   raiserror ('(allocation) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(allocation) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      rollback tran
      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.alloc_num = d.alloc_num )
begin
   select @errmsg = '(allocation) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.alloc_num) + ')'
      from inserted i
   end
   rollback tran
   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(alloc_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.alloc_num = d.alloc_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror  ('(allocation) primary key can not be changed.',10,1)
      rollback tran
      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_allocation
      (alloc_num,
       alloc_type_code,
       mot_code,
       sch_init,
       alloc_status,
       cmnt_num,
       ppl_comp_num,
       ppl_comp_cont_num,
       sch_prd,
       ppl_batch_num,
       ppl_pump_date,
       compr_trade_num,
       initiator_acct_num,
       deemed_bl_date,
       alloc_pay_date,
       alloc_base_price,
       alloc_disc_rate,
       transportation,
       netout_gross_qty,
       netout_net_qty,
       netout_qty_uom_code,
       ppl_batch_given_date,
       ppl_batch_received_date,
       ppl_origin_given_date,
       ppl_origin_received_date,
       ppl_timing_cycle_num,
       ppl_split_cycle_opt,
       alloc_short_cmnt,
       creation_type,
       netout_parcel_num,
       alloc_cmdty_code,
       bookout_pay_date,
       bookout_rec_date,
       alloc_match_ind,
       alloc_loc_code,
       alloc_begin_date,
       alloc_end_date,
       alloc_load_loc_code,
       book_net_price_ind,
       creation_date,
       multiple_cmdty_ind,
       price_precision,
       pay_for_del,
       pay_for_weight,
       max_alloc_item_num,
       voyage_code,
       release_doc_num,
       bookout_brkr_num,
       base_port_num,
       transfer_price,
       transfer_price_uom_code,
       transfer_price_curr_code,
       transfer_price_curr_code_to,
	     transfer_price_currency_rate,
       trans_id,
       resp_trans_id)
    select
       d.alloc_num,
       d.alloc_type_code,
       d.mot_code,
       d.sch_init,
       d.alloc_status,
       d.cmnt_num,
       d.ppl_comp_num,
       d.ppl_comp_cont_num,
       d.sch_prd,
       d.ppl_batch_num,
       d.ppl_pump_date,
       d.compr_trade_num,
       d.initiator_acct_num,
       d.deemed_bl_date,
       d.alloc_pay_date,
       d.alloc_base_price,
       d.alloc_disc_rate,
       d.transportation,
       d.netout_gross_qty,
       d.netout_net_qty,
       d.netout_qty_uom_code,
       d.ppl_batch_given_date,
       d.ppl_batch_received_date,
       d.ppl_origin_given_date,
       d.ppl_origin_received_date,
       d.ppl_timing_cycle_num,
       d.ppl_split_cycle_opt,
       d.alloc_short_cmnt,
       d.creation_type,
       d.netout_parcel_num,
       d.alloc_cmdty_code,
       d.bookout_pay_date,
       d.bookout_rec_date,
       d.alloc_match_ind,
       d.alloc_loc_code,
       d.alloc_begin_date,
       d.alloc_end_date,
       d.alloc_load_loc_code,
       d.book_net_price_ind,
       d.creation_date,
       d.multiple_cmdty_ind,
       d.price_precision,
       d.pay_for_del,
       d.pay_for_weight,
       d.max_alloc_item_num,
       d.voyage_code,
       d.release_doc_num,
       d.bookout_brkr_num,
       d.base_port_num,
       d.transfer_price,
       d.transfer_price_uom_code,
       d.transfer_price_curr_code,
       d.transfer_price_curr_code_to,
	     d.transfer_price_currency_rate,
       d.trans_id,
       i.trans_id
    from deleted d, inserted i
    where d.alloc_num = i.alloc_num

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'Allocation'

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
             convert(varchar(40),alloc_num),
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

      if @the_tran_type != 'E'
      begin
         /* BEGIN_TRANSACTION_TOUCH */

         insert dbo.transaction_touch
         select 'UPDATE',
                @the_entity_name,
                'DIRECT',
                convert(varchar(40),alloc_num),
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
             convert(varchar(40),alloc_num),
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
             convert(varchar(40),alloc_num),
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
      where i.trans_id = it.trans_id and
            it.type != 'E'

      /* END_TRANSACTION_TOUCH */
   end

return
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_pk] PRIMARY KEY CLUSTERED  ([alloc_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [allocation_idx2] ON [dbo].[allocation] ([alloc_type_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [allocation_idx1] ON [dbo].[allocation] ([compr_trade_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk1] FOREIGN KEY ([initiator_acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk11] FOREIGN KEY ([netout_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk12] FOREIGN KEY ([voyage_code]) REFERENCES [dbo].[voyage] ([voyage_code])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk13] FOREIGN KEY ([release_doc_num]) REFERENCES [dbo].[release_document] ([release_doc_num])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk14] FOREIGN KEY ([bookout_brkr_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk15] FOREIGN KEY ([base_port_num]) REFERENCES [dbo].[portfolio] ([port_num])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk16] FOREIGN KEY ([transfer_price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk17] FOREIGN KEY ([transfer_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk18] FOREIGN KEY ([transfer_price_curr_code_to]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk2] FOREIGN KEY ([ppl_comp_num], [ppl_comp_cont_num]) REFERENCES [dbo].[account_contact] ([acct_num], [acct_cont_num])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk3] FOREIGN KEY ([alloc_type_code]) REFERENCES [dbo].[allocation_type] ([alloc_type_code])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk5] FOREIGN KEY ([alloc_cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk6] FOREIGN KEY ([sch_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk7] FOREIGN KEY ([alloc_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk8] FOREIGN KEY ([alloc_load_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk9] FOREIGN KEY ([mot_code]) REFERENCES [dbo].[mot] ([mot_code])
GO
GRANT DELETE ON  [dbo].[allocation] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[allocation] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[allocation] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[allocation] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'allocation', NULL, NULL
GO
