CREATE TABLE [dbo].[ag_truck_actual_details]
(
[fdd_id] [int] NOT NULL,
[lease_num] [int] NULL,
[lease_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ticket_number] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ticket_date] [datetime] NULL,
[gross_volume] [decimal] (20, 8) NULL,
[net_volume] [decimal] (20, 8) NULL,
[bill_of_lading_num] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[company_code] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[destination_facility] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[vehicle_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[driver_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[railcar_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[product_code] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[opening_reading] [decimal] (20, 8) NULL,
[closing_reading] [decimal] (20, 8) NULL,
[operator_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tax] [decimal] (20, 8) NULL,
[net_value] [decimal] (20, 8) NULL,
[alloc_num] [int] NULL,
[alloc_item_num] [smallint] NULL,
[ai_est_actual_num] [smallint] NULL,
[generic_col1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col5] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col6] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col7] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col8] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col9] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col10] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[feed_source_type] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[gross_volume_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[net_volume_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[carrier] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[driver_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_tank] [int] NULL,
[load_meter_open] [numeric] (20, 8) NULL,
[load_meter_open2] [numeric] (20, 8) NULL,
[load_meter_close] [numeric] (20, 8) NULL,
[load_meter_close2] [numeric] (20, 8) NULL,
[load_meter_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_temp] [numeric] (20, 8) NULL,
[load_temp_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[discharge_tank] [int] NULL,
[discharge_meter_open] [numeric] (20, 8) NULL,
[discharge_meter_open2] [numeric] (20, 8) NULL,
[discharge_meter_close] [numeric] (20, 8) NULL,
[discharge_meter_close2] [numeric] (20, 8) NULL,
[discharge_meter_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[discharge_temp] [numeric] (20, 8) NULL,
[discharge_temp_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[offload_railcar] [numeric] (20, 8) NULL,
[rins_expected] [numeric] (20, 8) NULL,
[rins_received] [numeric] (20, 8) NULL,
[govt_certificate] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mileage] [numeric] (20, 8) NULL,
[system_well_id] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ticket_time] [datetime] NULL,
[tank_size] [numeric] (20, 8) NULL,
[load_meter_open_qty] [numeric] (20, 8) NULL,
[load_meter_close_qty] [numeric] (20, 8) NULL,
[quantity_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ticket_gross_vol] [numeric] (20, 8) NULL,
[meter_open_time] [datetime] NULL,
[meter_close_time] [datetime] NULL,
[temp_factor] [numeric] (20, 8) NULL,
[meter_factor] [numeric] (20, 8) NULL,
[rejected_load] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[action_type] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value4] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value5] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value6] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value7] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value8] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value9] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value10] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value11] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value12] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value13] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value14] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value15] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_date] [datetime] NULL,
[parcel_id] [int] NULL,
[sec_gross_volume] [decimal] (18, 0) NULL,
[sec_net_volume] [decimal] (18, 0) NULL,
[sec_gross_volume_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_net_volume_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
create trigger [dbo].[ag_truck_actual_details_deltrg]  
on [dbo].[ag_truck_actual_details]  
for delete  
as  
declare @num_rows  int,  
        @errmsg    varchar(255),  
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
   select @errmsg = '(ag_truck_actual_details) Failed to obtain a valid responsible trans_id.'  
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
  
insert dbo.aud_ag_truck_actual_details  
(    
    fdd_id,  
    lease_num,  
    lease_name,  
    ticket_number,  
    ticket_date,  
    gross_volume,  
    net_volume,  
    bill_of_lading_num,  
    company_code,  
    destination_facility,  
    vehicle_num,  
    driver_num,  
    railcar_num,  
    product_code,  
    --  gravity,  
    --  obs_gravity,  
    --  obs_temp,  
    --  bsw_percent,  
    opening_reading,  
    closing_reading,  
    operator_num,  
    tax,  
    net_value,  
    alloc_num,  
    alloc_item_num,  
    ai_est_actual_num,  
    generic_col1,  
    generic_col2,  
    generic_col3,  
    generic_col4,  
    generic_col5,  
    generic_col6,  
    generic_col7,  
    generic_col8,  
    generic_col9,  
    generic_col10,  
    trans_id,  
    resp_trans_id,  
    feed_source_type,  
    gross_volume_uom,  
    net_volume_uom,  
    carrier,  
    driver_name,  
    load_tank,  
    load_meter_open,  
    load_meter_open2,  
    load_meter_close,  
    load_meter_close2,  
    load_meter_uom,  
    load_temp,  
    load_temp_uom,  
    discharge_tank,  
    discharge_meter_open,  
    discharge_meter_open2,  
    discharge_meter_close,  
    discharge_meter_close2,  
    discharge_meter_uom,  
    discharge_temp,  
    discharge_temp_uom,  
    offload_railcar,  
    rins_expected,  
    rins_received,  
    govt_certificate,  
    mileage,  
    system_well_id,  
    ticket_time,  
    tank_size,  
    load_meter_open_qty,  
    load_meter_close_qty,  
    quantity_uom,  
    --obs_gravity,  
    --  obs_bsw,  
    --obs_temp,  
    ticket_gross_vol,  
    meter_open_time,  
    meter_close_time,  
    temp_factor,  
    meter_factor,  
    rejected_load,  
    action_type,  
    spec_value1,  
    spec_value2,  
    spec_value3,  
    spec_value4,  
    spec_value5,  
    spec_value6,  
    spec_value7,  
    spec_value8,  
    spec_value9,  
    spec_value10,  
    spec_value11,  
    spec_value12,  
    spec_value13,  
    spec_value14,  
    spec_value15,
	creation_date,
	parcel_id,
	sec_gross_volume,
	sec_net_volume,
	sec_gross_volume_uom,
	sec_net_volume_uom
)  
select  
    d.fdd_id,  
    d.lease_num,  
    d.lease_name,  
    d.ticket_number,  
    d.ticket_date,  
    d.gross_volume,  
    d.net_volume,  
    d.bill_of_lading_num,  
    d.company_code,  
    d.destination_facility,  
    d.vehicle_num,  
    d.driver_num,  
    d.railcar_num,  
    d.product_code,  
    --  d.gravity,  
    --  d.obs_gravity,  
    --  d.obs_temp,  
    --  d.bsw_percent,  
    d.opening_reading,  
    d.closing_reading,  
    d.operator_num,  
    d.tax,  
    d.net_value,  
    d.alloc_num,  
    d.alloc_item_num,  
    d.ai_est_actual_num,  
    d.generic_col1,  
    d.generic_col2,  
    d.generic_col3,  
    d.generic_col4,  
    d.generic_col5,  
    d.generic_col6,  
    d.generic_col7,  
    d.generic_col8,  
    d.generic_col9,  
    d.generic_col10,  
    d.trans_id,  
    @atrans_id,  
    d.feed_source_type,  
    d.gross_volume_uom,  
	d.net_volume_uom,  
    d.carrier,  
    d.driver_name,  
    d.load_tank,  
    d.load_meter_open,  
    d.load_meter_open2,  
    d.load_meter_close,  
    d.load_meter_close2,  
    d.load_meter_uom,  
    d.load_temp,  
    d.load_temp_uom,  
    d.discharge_tank,  
    d.discharge_meter_open,  
    d.discharge_meter_open2,  
    d.discharge_meter_close,  
    d.discharge_meter_close2,  
    d.discharge_meter_uom,  
    d.discharge_temp,  
    d.discharge_temp_uom,  
    d.offload_railcar,  
    d.rins_expected,  
    d.rins_received,  
    d.govt_certificate,  
    d.mileage,  
    d.system_well_id,  
    d.ticket_time,  
    d.tank_size,  
    d.load_meter_open_qty,  
    d.load_meter_close_qty,  
    d.quantity_uom,  
    --d.obs_gravity,  
    --  d.obs_bsw,  
    --d.obs_temp,  
    d.ticket_gross_vol,  
    d.meter_open_time,  
    d.meter_close_time,  
    d.temp_factor,  
    d.meter_factor,  
    d.rejected_load,  
    d.action_type,  
    d.spec_value1,  
    d.spec_value2,  
    d.spec_value3,  
    d.spec_value4,  
    d.spec_value5,  
    d.spec_value6,  
    d.spec_value7,  
    d.spec_value8,  
    d.spec_value9,  
    d.spec_value10,  
    d.spec_value11,  
    d.spec_value12,  
    d.spec_value13,  
    d.spec_value14,  
    d.spec_value15,
	d.creation_date,
	d.parcel_id,
	d.sec_gross_volume,
	d.sec_net_volume,
	d.sec_gross_volume_uom,
	d.sec_net_volume_uom
from deleted d  
  
/* AUDIT_CODE_END */  
return  

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
create trigger [dbo].[ag_truck_actual_details_updtrg]  
on [dbo].[ag_truck_actual_details]  
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
   raiserror ('(ag_truck_actual_details) The change needs to be attached with a new trans_id.',16,1)  
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
      select @errmsg = '(ag_truck_actual_details) New trans_id must be larger than original trans_id.'  
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'  
      raiserror (@errmsg,16,1)  
      if @@trancount > 0 rollback tran  
  
      return  
   end  
end  
  
if exists (select * from inserted i, deleted d  
           where i.trans_id < d.trans_id and  
                 i.fdd_id = d.fdd_id)  
begin  
   select @errmsg = '(ag_truck_actual_details) new trans_id must not be older than current trans_id.'     
   if @num_rows = 1   
   begin  
      select @errmsg = @errmsg + ' (' + convert(varchar, i.fdd_id) + ')'  
      from inserted i  
   end  
   if @@trancount > 0 rollback tran  
  
   raiserror (@errmsg,16,1)  
   return  
end  
  
/* RECORD_STAMP_END */  
  
if update(fdd_id)  
begin  
   select @count_num_rows = (select count(*) from inserted i, deleted d  
                             where i.fdd_id = d.fdd_id)  
   if (@count_num_rows = @num_rows)  
   begin  
      select @dummy_update = 1  
   end  
   else  
   begin  
      raiserror ('(ag_truck_actual_details) primary key can not be changed.',16,1)  
      if @@trancount > 0 rollback tran  
  
      return  
   end  
end  
  
if @dummy_update = 0  
insert dbo.aud_ag_truck_actual_details  
(  
    fdd_id,  
    lease_num,  
    lease_name,  
    ticket_number,  
    ticket_date,  
    gross_volume,  
    net_volume,  
    bill_of_lading_num,  
    company_code,  
    destination_facility,  
    vehicle_num,  
    driver_num,  
    railcar_num,  
    product_code,  
    --  gravity,  
    --  obs_gravity,  
    --  obs_temp,  
    --  bsw_percent,  
    opening_reading,  
    closing_reading,  
    operator_num,  
    tax,  
    net_value,  
    alloc_num,  
    alloc_item_num,  
    ai_est_actual_num,  
    generic_col1,  
    generic_col2,  
    generic_col3,  
    generic_col4,  
    generic_col5,  
    generic_col6,  
    generic_col7,  
    generic_col8,  
    generic_col9,  
    generic_col10,  
    trans_id,  
    resp_trans_id,  
    feed_source_type,  
    gross_volume_uom,  
    net_volume_uom,  
    carrier,  
    driver_name,  
    load_tank,  
    load_meter_open,  
    load_meter_open2,  
    load_meter_close,  
    load_meter_close2,  
    load_meter_uom,  
    load_temp,  
    load_temp_uom,  
    discharge_tank,  
    discharge_meter_open,  
    discharge_meter_open2,  
    discharge_meter_close,  
    discharge_meter_close2,  
    discharge_meter_uom,  
    discharge_temp,  
    discharge_temp_uom,  
    offload_railcar,  
    rins_expected,  
    rins_received,  
    govt_certificate,  
    mileage,  
    system_well_id,  
    ticket_time,  
    tank_size,  
    load_meter_open_qty,  
    load_meter_close_qty,  
    quantity_uom,  
    --obs_gravity,  
    --  obs_bsw,  
    --obs_temp,  
    ticket_gross_vol,  
    meter_open_time,  
    meter_close_time,  
    temp_factor,  
    meter_factor,  
    rejected_load,  
    action_type,  
    spec_value1,  
    spec_value2,  
    spec_value3,  
    spec_value4,  
    spec_value5,  
    spec_value6,  
    spec_value7,  
    spec_value8,  
    spec_value9,  
    spec_value10,  
    spec_value11,  
    spec_value12,  
    spec_value13,  
    spec_value14,  
    spec_value15,
	creation_date,
	parcel_id,
	sec_gross_volume,
	sec_net_volume,
	sec_gross_volume_uom,
	sec_net_volume_uom
)  
select  
    d.fdd_id,  
    d.lease_num,  
    d.lease_name,  
    d.ticket_number,  
    d.ticket_date,  
    d.gross_volume,  
    d.net_volume,  
    d.bill_of_lading_num,  
    d.company_code,  
    d.destination_facility,  
    d.vehicle_num,  
    d.driver_num,  
    d.railcar_num,  
    d.product_code,  
    --  d.gravity,  
    --  d.obs_gravity,  
    --  d.obs_temp,  
    --  d.bsw_percent,  
    d.opening_reading,  
    d.closing_reading,  
    d.operator_num,  
    d.tax,  
    d.net_value,  
    d.alloc_num,  
    d.alloc_item_num,  
    d.ai_est_actual_num,  
    d.generic_col1,  
    d.generic_col2,  
    d.generic_col3,  
    d.generic_col4,  
    d.generic_col5,  
    d.generic_col6,  
    d.generic_col7,  
    d.generic_col8,  
    d.generic_col9,  
    d.generic_col10,  
    d.trans_id,  
    i.trans_id,  
    d.feed_source_type,  
    d.gross_volume_uom,  
    d.net_volume_uom,  
    d.carrier,  
    d.driver_name,  
    d.load_tank,  
    d.load_meter_open,  
    d.load_meter_open2,  
    d.load_meter_close,  
    d.load_meter_close2,  
    d.load_meter_uom,  
    d.load_temp,  
    d.load_temp_uom,  
    d.discharge_tank,  
    d.discharge_meter_open,  
    d.discharge_meter_open2,  
    d.discharge_meter_close,  
    d.discharge_meter_close2,  
    d.discharge_meter_uom,  
    d.discharge_temp,  
    d.discharge_temp_uom,  
    d.offload_railcar,  
    d.rins_expected,  
    d.rins_received,  
    d.govt_certificate,  
    d.mileage,  
    d.system_well_id,  
    d.ticket_time,  
    d.tank_size,  
    d.load_meter_open_qty,  
    d.load_meter_close_qty,  
    d.quantity_uom,  
    --d.obs_gravity,  
    --  d.obs_bsw,  
    --d.obs_temp,  
    d.ticket_gross_vol,  
    d.meter_open_time,  
    d.meter_close_time,  
    d.temp_factor,  
    d.meter_factor,  
    d.rejected_load,  
    d.action_type,  
    d.spec_value1,  
    d.spec_value2,  
    d.spec_value3,  
    d.spec_value4,  
    d.spec_value5,  
    d.spec_value6,  
    d.spec_value7,  
    d.spec_value8,  
    d.spec_value9,  
    d.spec_value10,  
    d.spec_value11,  
    d.spec_value12,  
    d.spec_value13,  
    d.spec_value14,  
    d.spec_value15,
	d.creation_date,
	d.parcel_id,
	d.sec_gross_volume,
	d.sec_net_volume,
	d.sec_gross_volume_uom,
	d.sec_net_volume_uom	
from deleted d, inserted i  
where d.fdd_id = i.fdd_id   
  
return  

GO
ALTER TABLE [dbo].[ag_truck_actual_details] ADD CONSTRAINT [chk_ag_truck_actual_details_rejected_load] CHECK (([rejected_load]=NULL OR [rejected_load]='N' OR [rejected_load]='Y'))
GO
ALTER TABLE [dbo].[ag_truck_actual_details] ADD CONSTRAINT [ag_truck_actual_details_pk] PRIMARY KEY CLUSTERED  ([fdd_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ag_truck_actual_details] ADD CONSTRAINT [ag_truck_actual_details_fk1] FOREIGN KEY ([fdd_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
GRANT DELETE ON  [dbo].[ag_truck_actual_details] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ag_truck_actual_details] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ag_truck_actual_details] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ag_truck_actual_details] TO [next_usr]
GO
