CREATE TABLE [dbo].[ai_est_actual]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[ai_est_actual_num] [smallint] NOT NULL,
[ai_est_actual_date] [datetime] NOT NULL,
[ai_est_actual_gross_qty] [float] NULL,
[ai_gross_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ai_est_actual_net_qty] [float] NULL,
[ai_net_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ai_est_actual_short_cmnt] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ai_est_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ticket_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lease_num] [int] NULL,
[dest_trade_num] [int] NULL,
[del_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[scac_carrier_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transporter_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bol_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[owner_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[accum_num] [int] NULL,
[secondary_actual_gross_qty] [float] NULL,
[secondary_actual_net_qty] [float] NULL,
[secondary_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[manual_input_sec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__ai_est_ac__manua__0A9D95DB] DEFAULT ('N'),
[trans_id] [int] NOT NULL,
[fixed_swing_qty_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[insert_sequence] [int] NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tertiary_gross_qty] [numeric] (20, 8) NULL,
[tertiary_net_qty] [numeric] (20, 8) NULL,
[tertiary_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[actual_tax_mt_qty] [numeric] (20, 8) NULL,
[actual_tax_m315_qty] [numeric] (20, 8) NULL,
[start_load_date] [datetime] NULL,
[stop_load_date] [datetime] NULL,
[sap_position_num] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[assay_final_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ai_est_actual_deltrg]
on [dbo].[ai_est_actual]
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
   select @errmsg = '(ai_est_actual) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_ai_est_actual
   (alloc_num,
    alloc_item_num,
    ai_est_actual_num,
    ai_est_actual_date,
    ai_est_actual_gross_qty,
    ai_gross_qty_uom_code,
    ai_est_actual_net_qty,
    ai_net_qty_uom_code,
    ai_est_actual_short_cmnt,
    ai_est_actual_ind,
    ticket_num,
    lease_num,
    dest_trade_num,
    del_loc_code,
    scac_carrier_code,
    transporter_code,
    bol_code,
    owner_code,
    accum_num,
    secondary_actual_gross_qty,
    secondary_actual_net_qty,
    secondary_qty_uom_code,
    manual_input_sec_ind,
    fixed_swing_qty_ind,
    insert_sequence,
    mot_code,
    tertiary_gross_qty,
    tertiary_net_qty,
    tertiary_uom_code,
    actual_tax_mt_qty,
    actual_tax_m315_qty,
    start_load_date,
    stop_load_date,
    sap_position_num,
    assay_final_ind,
    trans_id,
    resp_trans_id)
select
   d.alloc_num,
   d.alloc_item_num,
   d.ai_est_actual_num,
   d.ai_est_actual_date,
   d.ai_est_actual_gross_qty,
   d.ai_gross_qty_uom_code,
   d.ai_est_actual_net_qty,
   d.ai_net_qty_uom_code,
   d.ai_est_actual_short_cmnt,
   d.ai_est_actual_ind,
   d.ticket_num,
   d.lease_num,
   d.dest_trade_num,
   d.del_loc_code,
   d.scac_carrier_code,
   d.transporter_code,
   d.bol_code,
   d.owner_code,
   d.accum_num,
   d.secondary_actual_gross_qty,
   d.secondary_actual_net_qty,
   d.secondary_qty_uom_code,
   d.manual_input_sec_ind,
   d.fixed_swing_qty_ind,
   d.insert_sequence,
   d.mot_code,
   d.tertiary_gross_qty,
   d.tertiary_net_qty,
   d.tertiary_uom_code,
   d.actual_tax_mt_qty,
   d.actual_tax_m315_qty,
   d.start_load_date,
   d.stop_load_date,
   d.sap_position_num,
   d.assay_final_ind,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'AiEstActual'

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
             convert(varchar(40),d.alloc_item_num),
             convert(varchar(40),d.ai_est_actual_num),
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
                convert(varchar(40),d.alloc_item_num),
                convert(varchar(40),d.ai_est_actual_num),
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
             convert(varchar(40),d.alloc_item_num),
             convert(varchar(40),d.ai_est_actual_num),
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
             convert(varchar(40),d.alloc_item_num),
             convert(varchar(40),d.ai_est_actual_num),
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
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ai_est_actual_instrg]
on [dbo].[ai_est_actual]
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

   select @the_entity_name = 'AiEstActual'

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
             convert(varchar(40),alloc_item_num),
             convert(varchar(40),ai_est_actual_num),
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
                convert(varchar(40),alloc_item_num),
                convert(varchar(40),ai_est_actual_num),
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
             convert(varchar(40),alloc_item_num),
             convert(varchar(40),ai_est_actual_num),
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
             convert(varchar(40),alloc_item_num),
             convert(varchar(40),ai_est_actual_num),
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
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ai_est_actual_updtrg]
on [dbo].[ai_est_actual]
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
   raiserror ('(ai_est_actual) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(ai_est_actual) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran
      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.alloc_num = d.alloc_num and 
                 i.alloc_item_num = d.alloc_item_num and 
                 i.ai_est_actual_num = d.ai_est_actual_num )
begin
   raiserror ('(ai_est_actual) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran
   return
end

/* RECORD_STAMP_END */

if update(alloc_num) or 
   update(alloc_item_num) or 
   update(ai_est_actual_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.alloc_num = d.alloc_num and 
                                   i.alloc_item_num = d.alloc_item_num and 
                                   i.ai_est_actual_num = d.ai_est_actual_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(ai_est_actual) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran
      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_ai_est_actual
      (alloc_num,
       alloc_item_num,
       ai_est_actual_num,
       ai_est_actual_date,
       ai_est_actual_gross_qty,
       ai_gross_qty_uom_code,
       ai_est_actual_net_qty,
       ai_net_qty_uom_code,
       ai_est_actual_short_cmnt,
       ai_est_actual_ind,
       ticket_num,
       lease_num,
       dest_trade_num,
       del_loc_code,
       scac_carrier_code,
       transporter_code,
       bol_code,
       owner_code,
       accum_num,
       secondary_actual_gross_qty,
       secondary_actual_net_qty,
       secondary_qty_uom_code,
       manual_input_sec_ind,
       fixed_swing_qty_ind,
       insert_sequence,
       mot_code,
       tertiary_gross_qty,
       tertiary_net_qty,
       tertiary_uom_code,
       actual_tax_mt_qty,
       actual_tax_m315_qty,
       start_load_date,
       stop_load_date,
       sap_position_num,
       assay_final_ind,
       trans_id,
       resp_trans_id)
    select
       d.alloc_num,
       d.alloc_item_num,
       d.ai_est_actual_num,
       d.ai_est_actual_date,
       d.ai_est_actual_gross_qty,
       d.ai_gross_qty_uom_code,
       d.ai_est_actual_net_qty,
       d.ai_net_qty_uom_code,
       d.ai_est_actual_short_cmnt,
       d.ai_est_actual_ind,
       d.ticket_num,
       d.lease_num,
       d.dest_trade_num,
       d.del_loc_code,
       d.scac_carrier_code,
       d.transporter_code,
       d.bol_code,
       d.owner_code,
       d.accum_num,
       d.secondary_actual_gross_qty,
       d.secondary_actual_net_qty,
       d.secondary_qty_uom_code,
       d.manual_input_sec_ind,
       d.fixed_swing_qty_ind,
       d.insert_sequence,
       d.mot_code,
       d.tertiary_gross_qty,
       d.tertiary_net_qty,
       d.tertiary_uom_code,
       d.actual_tax_mt_qty,
       d.actual_tax_m315_qty,
       d.start_load_date,
       d.stop_load_date,
       d.sap_position_num,
       d.assay_final_ind,
       d.trans_id,
       i.trans_id
    from deleted d, inserted i
    where d.alloc_num = i.alloc_num and
          d.alloc_item_num = i.alloc_item_num and
          d.ai_est_actual_num = i.ai_est_actual_num

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'AiEstActual'

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
             convert(varchar(40),alloc_item_num),
             convert(varchar(40),ai_est_actual_num),
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
                convert(varchar(40),alloc_item_num),
                convert(varchar(40),ai_est_actual_num),
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
             convert(varchar(40),alloc_item_num),
             convert(varchar(40),ai_est_actual_num),
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
             convert(varchar(40),alloc_item_num),
             convert(varchar(40),ai_est_actual_num),
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
ALTER TABLE [dbo].[ai_est_actual] ADD CONSTRAINT [CK__ai_est_ac__fixed__0B91BA14] CHECK (([fixed_swing_qty_ind] IS NULL OR [fixed_swing_qty_ind]='S' OR [fixed_swing_qty_ind]='F'))
GO
ALTER TABLE [dbo].[ai_est_actual] ADD CONSTRAINT [ai_est_actual_pk] PRIMARY KEY CLUSTERED  ([alloc_num], [alloc_item_num], [ai_est_actual_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ai_est_actual_idx1] ON [dbo].[ai_est_actual] ([alloc_num], [alloc_item_num], [trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ai_est_actual] ADD CONSTRAINT [ai_est_actual_fk2] FOREIGN KEY ([del_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[ai_est_actual] ADD CONSTRAINT [ai_est_actual_fk4] FOREIGN KEY ([ai_gross_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[ai_est_actual] ADD CONSTRAINT [ai_est_actual_fk5] FOREIGN KEY ([ai_net_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[ai_est_actual] ADD CONSTRAINT [ai_est_actual_fk6] FOREIGN KEY ([secondary_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[ai_est_actual] ADD CONSTRAINT [ai_est_actual_fk7] FOREIGN KEY ([mot_code]) REFERENCES [dbo].[mot] ([mot_code])
GO
ALTER TABLE [dbo].[ai_est_actual] ADD CONSTRAINT [ai_est_actual_fk8] FOREIGN KEY ([tertiary_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[ai_est_actual] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ai_est_actual] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ai_est_actual] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ai_est_actual] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'ai_est_actual', NULL, NULL
GO
