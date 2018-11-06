CREATE TABLE [dbo].[parcel]
(
[oid] [int] NOT NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[associative_state] [tinyint] NOT NULL,
[status] [tinyint] NOT NULL,
[reference] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sch_qty] [numeric] (20, 8) NULL,
[sch_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[location_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[facility_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tank_code] [int] NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[product_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[grade] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[quality] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_type_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[estimated_date] [datetime] NULL,
[sch_from_date] [datetime] NULL,
[sch_to_date] [datetime] NULL,
[creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_date] [datetime] NULL,
[last_update_by_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_update_date] [datetime] NULL,
[forecast_num] [int] NULL,
[trade_num] [int] NULL,
[order_num] [smallint] NULL,
[item_num] [smallint] NULL,
[inv_num] [int] NULL,
[shipment_num] [int] NULL,
[alloc_num] [int] NULL,
[alloc_item_num] [smallint] NULL,
[trans_id] [int] NOT NULL,
[nomin_qty] [numeric] (20, 8) NULL,
[nomin_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[t4_loc] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[t4_consignee] [int] NULL,
[t4_tankage] [int] NULL,
[gn_taric_code] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_code] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tariff_code] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_status] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[excise_status] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transmitall_type] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inspector] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[latest_feed_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[send_to_sap] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bookco_bank_acct_num] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[parcel_deltrg]
on [dbo].[parcel]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
        @atrans_id int

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
   select @errmsg = '(parcel) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   rollback tran
   return
end

insert dbo.aud_parcel
(  
   oid,
   type,
   associative_state,
   status,
   reference,
   sch_qty,
   sch_qty_uom_code,
   location_code,
   facility_code,
   tank_code,
   cmdty_code,
   product_code,
   grade,
   quality,
   mot_type_code,
   estimated_date,
   sch_from_date,
   sch_to_date,
   creator_init,
   creation_date,
   last_update_by_init,
   last_update_date,
   forecast_num,
   trade_num,
   order_num,
   item_num,
   inv_num,
   shipment_num,
   alloc_num,
   alloc_item_num,
   nomin_qty,
   nomin_qty_uom_code,
   cmnt_num,
   t4_loc,
   t4_consignee,
   t4_tankage,
   gn_taric_code,
   custom_code,
   tariff_code,
   custom_status,
   excise_status,
   transmitall_type,
   inspector,
   latest_feed_name,
   send_to_sap,
   bookco_bank_acct_num,
   trans_id,
   resp_trans_id
)
select
   d.oid,
   d.type,
   d.associative_state,
   d.status,
   d.reference,
   d.sch_qty,
   d.sch_qty_uom_code,
   d.location_code,
   d.facility_code,
   d.tank_code,
   d.cmdty_code,
   d.product_code,
   d.grade,
   d.quality,
   d.mot_type_code,
   d.estimated_date,
   d.sch_from_date,
   d.sch_to_date,
   d.creator_init,
   d.creation_date,
   d.last_update_by_init,
   d.last_update_date,
   d.forecast_num,
   d.trade_num,
   d.order_num,
   d.item_num,
   d.inv_num,
   d.shipment_num,
   d.alloc_num,
   d.alloc_item_num,
   d.nomin_qty,
   d.nomin_qty_uom_code,
   d.cmnt_num,
   d.t4_loc,
   d.t4_consignee,
   d.t4_tankage,
   d.gn_taric_code,
   d.custom_code,
   d.tariff_code,
   d.custom_status,
   d.excise_status,
   d.transmitall_type,
   d.inspector,
   d.latest_feed_name,
   d.send_to_sap,
   d.bookco_bank_acct_num,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'Parcel'

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
              convert(varchar(40), d.oid),
              null,
              null,
              null,
              null,
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
       begin
          insert dbo.transaction_touch
          select 'DELETE',
                 @the_entity_name,
                 'DIRECT',
                 convert(varchar(40), d.oid),
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
       end

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
             convert(varchar(40), d.oid),
             null,
             null,
             null,
             null,
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
             convert(varchar(40), d.oid),
             null,
             null,
             null,
             null,
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

create trigger [dbo].[parcel_instrg]
on [dbo].[parcel]
for insert
as
declare @num_rows        int

select @num_rows = @@rowcount
if @num_rows = 0
   return
   
declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'Parcel'

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
              convert(varchar(40), oid),
              null,
              null,
              null,
              null,
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
       begin
          insert dbo.transaction_touch
          select 'INSERT',
                 @the_entity_name,
                 'DIRECT',
                 convert(varchar(40), oid),
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
       end

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
             convert(varchar(40), oid),
             null,
             null,
             null,
             null,
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
             convert(varchar(40), oid),
             null,
             null,
             null,
             null,
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

create trigger [dbo].[parcel_updtrg]
on [dbo].[parcel]
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
   raiserror ('(parcel) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(parcel) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      rollback tran
      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   select @errmsg = '(parcel) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.oid) + ')'
      from inserted i
   end
   rollback tran
   raiserror  (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(oid)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(parcel) primary key can not be changed.',10,1)
      rollback tran
      return
   end
end

if @dummy_update = 0
   insert dbo.aud_parcel
       (oid,
       type,
       associative_state,
       status,
       reference,
       sch_qty,
       sch_qty_uom_code,
       location_code,
       facility_code,
       tank_code,
       cmdty_code,
       product_code,
       grade,
       quality,
       mot_type_code,
       estimated_date,
       sch_from_date,
       sch_to_date,
       creator_init,
       creation_date,
       last_update_by_init,
       last_update_date,
       forecast_num,
       trade_num,
       order_num,
       item_num,
       inv_num,
       shipment_num,
       alloc_num,
       alloc_item_num,
       nomin_qty,
       nomin_qty_uom_code,
       cmnt_num,
       t4_loc,
       t4_consignee,
       t4_tankage,
       gn_taric_code,
       custom_code,
       tariff_code,
       custom_status,
       excise_status,
       transmitall_type,
       inspector,
       latest_feed_name,
       send_to_sap,
       bookco_bank_acct_num,
       trans_id,
       resp_trans_id)
   select
      d.oid,
      d.type,
      d.associative_state,
      d.status,
      d.reference,
      d.sch_qty,
      d.sch_qty_uom_code,
      d.location_code,
      d.facility_code,
      d.tank_code,
      d.cmdty_code,
      d.product_code,
      d.grade,
      d.quality,
      d.mot_type_code,
      d.estimated_date,
      d.sch_from_date,
      d.sch_to_date,
      d.creator_init,
      d.creation_date,
      d.last_update_by_init,
      d.last_update_date,
      d.forecast_num,
      d.trade_num,
      d.order_num,
      d.item_num,
      d.inv_num,
      d.shipment_num,
      d.alloc_num,
      d.alloc_item_num,
      d.nomin_qty,
      d.nomin_qty_uom_code,
      d.cmnt_num,
      d.t4_loc,
      d.t4_consignee,
      d.t4_tankage,
      d.gn_taric_code,
      d.custom_code,
      d.tariff_code,
      d.custom_status,
      d.excise_status,
      d.transmitall_type,
      d.inspector,
      d.latest_feed_name,
      d.send_to_sap,
      d.bookco_bank_acct_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'Parcel'

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
              convert(varchar(40), oid),
              null,
              null,
              null,
              null,
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
       begin
          insert dbo.transaction_touch
          select 'UPDATE',
                 @the_entity_name,
                 'DIRECT',
                 convert(varchar(40), oid),
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
       end

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
             convert(varchar(40), oid),
             null,
             null,
             null,
             null,
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
             convert(varchar(40), oid),
             null,
             null,
             null,
             null,
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
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [parcel_idx1] ON [dbo].[parcel] ([shipment_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_fk1] FOREIGN KEY ([status]) REFERENCES [dbo].[parcel_status] ([oid])
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_fk10] FOREIGN KEY ([nomin_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_fk2] FOREIGN KEY ([sch_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_fk3] FOREIGN KEY ([location_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_fk4] FOREIGN KEY ([facility_code]) REFERENCES [dbo].[facility] ([facility_code])
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_fk5] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_fk6] FOREIGN KEY ([product_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_fk7] FOREIGN KEY ([mot_type_code]) REFERENCES [dbo].[mot_type] ([mot_type_code])
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_fk8] FOREIGN KEY ([creator_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_fk9] FOREIGN KEY ([last_update_by_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[parcel] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[parcel] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[parcel] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[parcel] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'parcel', NULL, NULL
GO
