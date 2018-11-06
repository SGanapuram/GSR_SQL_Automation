CREATE TABLE [dbo].[shipment]
(
[oid] [int] NOT NULL,
[status] [tinyint] NOT NULL,
[reference] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[primary_shipment_num] [int] NULL,
[alloc_num] [int] NULL,
[mot_type_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[capacity] [numeric] (20, 8) NULL,
[capacity_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ship_qty] [numeric] (20, 8) NULL,
[ship_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[start_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[end_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[start_date] [datetime] NULL,
[end_date] [datetime] NULL,
[transport_owner_id] [int] NULL,
[transport_operator_id] [int] NULL,
[pipeline_cycle_num] [int] NULL,
[freight_rate] [numeric] (20, 8) NULL,
[freight_rate_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[freight_rate_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[freight_pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_num] [int] NULL,
[creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_date] [datetime] NULL,
[last_update_by_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_update_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[transport_reference] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[load_facility_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_tank_num] [int] NULL,
[dest_facility_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dest_tank_num] [int] NULL,
[contract_order_num] [int] NULL,
[manual_transport_parcels] [bit] NOT NULL CONSTRAINT [DF__shipment__manual__33AA9866] DEFAULT ((1)),
[feed_interface] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[balance_qty] [numeric] (20, 8) NULL,
[sap_shipment_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[shipment_deltrg]
on [dbo].[shipment]
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
   select @errmsg = '(shipment) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_shipment
(  
   oid,
   status,
   reference,
   primary_shipment_num,
   alloc_num,
   mot_type_code,
   capacity,
   capacity_uom_code,
   ship_qty,
   ship_qty_uom_code,
   cmdty_code,
   start_loc_code,
   end_loc_code,
   start_date,
   end_date,
   transport_owner_id,
   transport_operator_id,
   pipeline_cycle_num,
   freight_rate,
   freight_rate_uom_code,
   freight_rate_curr_code,
   freight_pay_term_code,
   contract_num,
   creator_init,
   creation_date,
   last_update_by_init,
   last_update_date,
   transport_reference,
   cmnt_num,
   load_facility_code,
   load_tank_num,
   dest_facility_code,
   dest_tank_num,
   contract_order_num,
   manual_transport_parcels,
   feed_interface,
   balance_qty,
   sap_shipment_num,
   trans_id,
   resp_trans_id
)
select
   d.oid,
   d.status,
   d.reference,
   d.primary_shipment_num,
   d.alloc_num,
   d.mot_type_code,
   d.capacity,
   d.capacity_uom_code,
   d.ship_qty,
   d.ship_qty_uom_code,
   d.cmdty_code,
   d.start_loc_code,
   d.end_loc_code,
   d.start_date,
   d.end_date,
   d.transport_owner_id,
   d.transport_operator_id,
   d.pipeline_cycle_num,
   d.freight_rate,
   d.freight_rate_uom_code,
   d.freight_rate_curr_code,
   d.freight_pay_term_code,
   d.contract_num,
   d.creator_init,
   d.creation_date,
   d.last_update_by_init,
   d.last_update_date,
   d.transport_reference,
   d.cmnt_num,
   d.load_facility_code,
   d.load_tank_num,
   d.dest_facility_code,
   d.dest_tank_num,
   d.contract_order_num,
   d.manual_transport_parcels,
   d.feed_interface,
   d.balance_qty,
   d.sap_shipment_num,
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

create trigger [dbo].[shipment_instrg]
on [dbo].[shipment]
for insert
as
declare @num_rows        int

select @num_rows = @@rowcount
if @num_rows = 0
   return
   
declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'Shipment'

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

create trigger [dbo].[shipment_updtrg]
on [dbo].[shipment]
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
   raiserror ('(shipment) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(shipment) New trans_id must be larger than original trans_id.'
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
   select @errmsg = '(shipment) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.oid) + ')'
      from inserted i
   end
   rollback tran
   raiserror (@errmsg,10,1)
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
      raiserror  ('(shipment) primary key can not be changed.',10,1)
      rollback tran
      return
   end
end

if @dummy_update = 0
   insert dbo.aud_shipment
      (oid,
       status,
       reference,
       primary_shipment_num,
       alloc_num,
       mot_type_code,
       capacity,
       capacity_uom_code,
       ship_qty,
       ship_qty_uom_code,
       cmdty_code,
       start_loc_code,
       end_loc_code,
       start_date,
       end_date,
       transport_owner_id,
       transport_operator_id,
       pipeline_cycle_num,
       freight_rate,
       freight_rate_uom_code,
       freight_rate_curr_code,
       freight_pay_term_code,
       contract_num,
       creator_init,
       creation_date,
       last_update_by_init,
       last_update_date,
       transport_reference,
       cmnt_num,
       load_facility_code,
       load_tank_num,
       dest_facility_code,
       dest_tank_num,
       contract_order_num,
       manual_transport_parcels,
       feed_interface,
       balance_qty,
       sap_shipment_num,
       trans_id,
       resp_trans_id)
   select
      d.oid,
      d.status,
      d.reference,
      d.primary_shipment_num,
      d.alloc_num,
      d.mot_type_code,
      d.capacity,
      d.capacity_uom_code,
      d.ship_qty,
      d.ship_qty_uom_code,
      d.cmdty_code,
      d.start_loc_code,
      d.end_loc_code,
      d.start_date,
      d.end_date,
      d.transport_owner_id,
      d.transport_operator_id,
      d.pipeline_cycle_num,
      d.freight_rate,
      d.freight_rate_uom_code,
      d.freight_rate_curr_code,
      d.freight_pay_term_code,
      d.contract_num,
      d.creator_init,
      d.creation_date,
      d.last_update_by_init,
      d.last_update_date,
      d.transport_reference,
      d.cmnt_num,
      d.load_facility_code,
      d.load_tank_num,
      d.dest_facility_code,
      d.dest_tank_num,
      d.contract_order_num,
      d.manual_transport_parcels,
      d.feed_interface,
      d.balance_qty,
      d.sap_shipment_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid
return
GO
ALTER TABLE [dbo].[shipment] ADD CONSTRAINT [shipment_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [shipment_idx1] ON [dbo].[shipment] ([alloc_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[shipment] ADD CONSTRAINT [shipment_fk1] FOREIGN KEY ([status]) REFERENCES [dbo].[shipment_status] ([oid])
GO
ALTER TABLE [dbo].[shipment] ADD CONSTRAINT [shipment_fk10] FOREIGN KEY ([freight_rate_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[shipment] ADD CONSTRAINT [shipment_fk11] FOREIGN KEY ([freight_rate_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[shipment] ADD CONSTRAINT [shipment_fk12] FOREIGN KEY ([freight_pay_term_code]) REFERENCES [dbo].[payment_term] ([pay_term_code])
GO
ALTER TABLE [dbo].[shipment] ADD CONSTRAINT [shipment_fk13] FOREIGN KEY ([last_update_by_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[shipment] ADD CONSTRAINT [shipment_fk14] FOREIGN KEY ([creator_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[shipment] ADD CONSTRAINT [shipment_fk15] FOREIGN KEY ([cmnt_num]) REFERENCES [dbo].[comment] ([cmnt_num])
GO
ALTER TABLE [dbo].[shipment] ADD CONSTRAINT [shipment_fk2] FOREIGN KEY ([mot_type_code]) REFERENCES [dbo].[mot_type] ([mot_type_code])
GO
ALTER TABLE [dbo].[shipment] ADD CONSTRAINT [shipment_fk3] FOREIGN KEY ([capacity_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[shipment] ADD CONSTRAINT [shipment_fk4] FOREIGN KEY ([ship_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[shipment] ADD CONSTRAINT [shipment_fk5] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[shipment] ADD CONSTRAINT [shipment_fk6] FOREIGN KEY ([start_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[shipment] ADD CONSTRAINT [shipment_fk7] FOREIGN KEY ([end_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[shipment] ADD CONSTRAINT [shipment_fk8] FOREIGN KEY ([transport_owner_id]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[shipment] ADD CONSTRAINT [shipment_fk9] FOREIGN KEY ([transport_operator_id]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[shipment] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[shipment] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[shipment] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[shipment] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'shipment', NULL, NULL
GO
