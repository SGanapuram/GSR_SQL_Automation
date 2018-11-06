CREATE TABLE [dbo].[ag_custody_ticket]
(
[fdd_oid] [int] NOT NULL,
[batch_number] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[product_id] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[location_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[supplier_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[consignee_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[shipper_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tankage_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[carrier_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bol_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[market_place] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ticket_datetime] [datetime] NOT NULL,
[timezone] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ticket_number] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_start_date] [datetime] NOT NULL,
[transfer_stop_date] [datetime] NOT NULL,
[transport_method_code] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[net_qty] [numeric] (20, 8) NOT NULL,
[net_qty_uom] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[gross_qty] [numeric] (20, 8) NOT NULL,
[gross_qty_uom] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pipeline_num] [int] NULL,
[line_item_tank_num] [int] NULL,
[trans_id] [int] NOT NULL,
[doc_id] [int] NOT NULL,
[trans_purpose_ind] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[transport_event] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[observed_temp] [numeric] (20, 8) NULL,
[observed_temp_uom] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[average_temp] [numeric] (20, 8) NULL,
[average_temp_uom] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[average_pressure] [numeric] (20, 8) NULL,
[average_pressure_uom] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[apl_gravity] [numeric] (20, 8) NULL,
[corrected_gravity] [numeric] (20, 8) NULL,
[alloc_num] [int] NULL,
[alloc_item_num] [smallint] NULL,
[ai_est_actual_num] [smallint] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ag_custody_ticket_deltrg]
on [dbo].[ag_custody_ticket]
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
   select @errmsg = '(ag_custody_ticket) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_ag_custody_ticket
(  
   fdd_oid,
   batch_number,
   product_id,
   location_code,
   supplier_code,
   consignee_code,
   shipper_code,
   tankage_code,
   carrier_code,
   bol_code,
   market_place,
   ticket_datetime,
   timezone,
   ticket_number,
   transfer_start_date,
   transfer_stop_date,
   transport_method_code,
   net_qty,
   net_qty_uom,
   gross_qty,
   gross_qty_uom,
   pipeline_num,
   line_item_tank_num,
   doc_id,
   trans_purpose_ind,
   transport_event,
   observed_temp,
   observed_temp_uom,
   average_temp,
   average_temp_uom,
   average_pressure,
   average_pressure_uom,
   apl_gravity,
   corrected_gravity,
   alloc_num,
   alloc_item_num,
   ai_est_actual_num,
   trans_id,
   resp_trans_id
)
select
   d.fdd_oid,
   d.batch_number,
   d.product_id,
   d.location_code,
   d.supplier_code,
   d.consignee_code,
   d.shipper_code,
   d.tankage_code,
   d.carrier_code,
   d.bol_code,
   d.market_place,
   d.ticket_datetime,
   d.timezone,
   d.ticket_number,
   d.transfer_start_date,
   d.transfer_stop_date,
   d.transport_method_code,
   d.net_qty,
   d.net_qty_uom,
   d.gross_qty,
   d.gross_qty_uom,
   d.pipeline_num,
   d.line_item_tank_num,
   d.doc_id,
   d.trans_purpose_ind,
   d.transport_event,
   d.observed_temp,
   d.observed_temp_uom,
   d.average_temp,
   d.average_temp_uom,
   d.average_pressure,
   d.average_pressure_uom,
   d.apl_gravity,
   d.corrected_gravity,
   d.alloc_num,
   d.alloc_item_num,
   d.ai_est_actual_num,
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

create trigger [dbo].[ag_custody_ticket_updtrg]
on [dbo].[ag_custody_ticket]
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
   raiserror ('(ag_custody_ticket) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(ag_custody_ticket) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.fdd_oid = d.fdd_oid)
begin
   select @errmsg = '(ag_custody_ticket) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.fdd_oid) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(fdd_oid)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.fdd_oid = d.fdd_oid)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(ag_custody_ticket) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_ag_custody_ticket
   (
      fdd_oid,
      batch_number,
      product_id,
      location_code,
      supplier_code,
      consignee_code,
      shipper_code,
      tankage_code,
      carrier_code,
      bol_code,
      market_place,
      ticket_datetime,
      timezone,
      ticket_number,
      transfer_start_date,
      transfer_stop_date,
      transport_method_code,
      net_qty,
      net_qty_uom,
      gross_qty,
      gross_qty_uom,
      pipeline_num,
      line_item_tank_num,
      doc_id,
      trans_purpose_ind,
      transport_event,
      observed_temp,
      observed_temp_uom,
      average_temp,
      average_temp_uom,
      average_pressure,
      average_pressure_uom,
      apl_gravity,
      corrected_gravity,
      alloc_num,
      alloc_item_num,
      ai_est_actual_num,
      trans_id,
      resp_trans_id)
 select
   d.fdd_oid,
   d.batch_number,
   d.product_id,
   d.location_code,
   d.supplier_code,
   d.consignee_code,
   d.shipper_code,
   d.tankage_code,
   d.carrier_code,
   d.bol_code,
   d.market_place,
   d.ticket_datetime,
   d.timezone,
   d.ticket_number,
   d.transfer_start_date,
   d.transfer_stop_date,
   d.transport_method_code,
   d.net_qty,
   d.net_qty_uom,
   d.gross_qty,
   d.gross_qty_uom,
   d.pipeline_num,
   d.line_item_tank_num,
   d.doc_id,
   d.trans_purpose_ind,
   d.transport_event,
   d.observed_temp,
   d.observed_temp_uom,
   d.average_temp,
   d.average_temp_uom,
   d.average_pressure,
   d.average_pressure_uom,
   d.apl_gravity,
   d.corrected_gravity,
   d.alloc_num,
   d.alloc_item_num,
   d.ai_est_actual_num,
   d.trans_id,
   i.trans_id
from deleted d, inserted i
where d.fdd_oid = i.fdd_oid 

return
GO
ALTER TABLE [dbo].[ag_custody_ticket] ADD CONSTRAINT [ag_custody_ticket_pk] PRIMARY KEY CLUSTERED  ([fdd_oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ag_custody_ticket_idx2] ON [dbo].[ag_custody_ticket] ([doc_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ag_custody_ticket_idx1] ON [dbo].[ag_custody_ticket] ([location_code], [supplier_code], [consignee_code], [shipper_code], [tankage_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ag_custody_ticket_idx3] ON [dbo].[ag_custody_ticket] ([transport_event]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ag_custody_ticket] ADD CONSTRAINT [ag_custody_ticket_fk1] FOREIGN KEY ([fdd_oid]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
ALTER TABLE [dbo].[ag_custody_ticket] ADD CONSTRAINT [ag_custody_ticket_fk2] FOREIGN KEY ([alloc_num], [alloc_item_num], [ai_est_actual_num]) REFERENCES [dbo].[ai_est_actual] ([alloc_num], [alloc_item_num], [ai_est_actual_num])
GO
GRANT DELETE ON  [dbo].[ag_custody_ticket] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ag_custody_ticket] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ag_custody_ticket] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ag_custody_ticket] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'ag_custody_ticket', NULL, NULL
GO
