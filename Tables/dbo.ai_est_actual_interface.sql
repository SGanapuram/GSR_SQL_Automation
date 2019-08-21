CREATE TABLE [dbo].[ai_est_actual_interface]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [int] NOT NULL,
[ai_est_actual_num] [int] NOT NULL,
[feed_def_oid] [int] NULL,
[record_id] [char] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[record_type] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[record_status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[carrier] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[truck_or_rail_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[driver_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_tank] [int] NULL,
[load_meter_open] [numeric] (20, 8) NULL,
[load_meter_open2] [numeric] (20, 8) NULL,
[load_meter_close] [numeric] (20, 8) NULL,
[load_meter_close2] [numeric] (20, 8) NULL,
[load_meter_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_temp] [numeric] (20, 8) NULL,
[load_temp_uom] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[discharge_tank] [int] NULL,
[discharge_meter_open] [numeric] (20, 8) NULL,
[discharge_meter_open2] [numeric] (20, 8) NULL,
[discharge_meter_close] [numeric] (20, 8) NULL,
[discharge_meter_close2] [numeric] (20, 8) NULL,
[discharge_meter_uom] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[discharge_temp] [numeric] (20, 8) NULL,
[discharge_temp_uom] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[offload_railcar] [numeric] (20, 8) NULL,
[rins_expected] [numeric] (20, 8) NULL,
[rins_received] [numeric] (20, 8) NULL,
[govt_certificate] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mileage] [numeric] (20, 8) NULL,
[generic_column1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_column2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_column3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_column4] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_column5] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_column6] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_column7] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_column8] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_column9] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_column10] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[system_well_id] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ticket_time] [datetime] NULL,
[tank_size] [numeric] (20, 8) NULL,
[load_meter_open_qty] [numeric] (20, 8) NULL,
[load_meter_close_qty] [numeric] (20, 8) NULL,
[quantity_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[obs_gravity] [numeric] (20, 8) NULL,
[obs_bsw] [numeric] (20, 8) NULL,
[obs_temp] [numeric] (20, 8) NULL,
[ticket_gross_vol] [numeric] (20, 8) NULL,
[meter_open_time] [datetime] NULL,
[meter_close_time] [datetime] NULL,
[temp_factor] [numeric] (20, 8) NULL,
[meter_factor] [numeric] (20, 8) NULL,
[rejected_load] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[driver_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ai_est_actual_interface_deltrg]  
on [dbo].[ai_est_actual_interface]  
for delete  
as  
declare @num_rows    int,  
        @errmsg      varchar(255),  
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
   select @errmsg = '(ai_est_actual_interface) Failed to obtain a valid responsible trans_id.'  
   if exists (select 1  
              from master.dbo.sysprocesses (nolock)  
              where spid = @@spid and  
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR  
                     program_name like 'Microsoft SQL Server Management Studio%') )  
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'  
   raiserror (@errmsg  ,16,1)
   if @@trancount > 0 rollback tran  

   return  
end  

   insert dbo.aud_ai_est_actual_interface  
      (alloc_num,              
	alloc_item_num,
	ai_est_actual_num,
	feed_def_oid,
	record_id,
	record_type,
	record_status,
	carrier,
	truck_or_rail_num,
	driver_num,
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
	generic_column1,
	generic_column2,
	generic_column3,
	generic_column4,
	generic_column5,
	generic_column6,
	generic_column7,
	generic_column8,
	generic_column9,
	generic_column10,
	trans_id,
	resp_trans_id,
	system_well_id,
	ticket_time,
	tank_size,
	load_meter_open_qty,
	load_meter_close_qty,
	quantity_uom,
	obs_gravity,
	obs_bsw,
	obs_temp,
	ticket_gross_vol,
	meter_open_time,
	meter_close_time,
	temp_factor,
	meter_factor,
	rejected_load,
	driver_name
      )  
   select
	d.alloc_num,
	d.alloc_item_num,
	d.ai_est_actual_num,
	d.feed_def_oid,
	d.record_id,
	d.record_type,
	d.record_status,
	d.carrier,
	d.truck_or_rail_num,
	d.driver_num,
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
	d.generic_column1,
	d.generic_column2,
	d.generic_column3,
	d.generic_column4,
	d.generic_column5,
	d.generic_column6,
	d.generic_column7,
	d.generic_column8,
	d.generic_column9,
	d.generic_column10,
	d.trans_id,
	@atrans_id,
	d.system_well_id,
	d.ticket_time,
	d.tank_size,
	d.load_meter_open_qty,
	d.load_meter_close_qty,
	d.quantity_uom,
	d.obs_gravity,
	d.obs_bsw,
	d.obs_temp,
	d.ticket_gross_vol,
	d.meter_open_time,
	d.meter_close_time,
	d.temp_factor,
	d.meter_factor,
	d.rejected_load,
	d.driver_name
   from deleted d   
  
/* AUDIT_CODE_END */  

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ai_est_actual_interface_updtrg]  
on [dbo].[ai_est_actual_interface]  
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
   raiserror ('(ai_est_actual_interface) The change needs to be attached with a new trans_id'  ,16,1)
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
      select @errmsg = '(ai_est_actual_interface) New trans_id must be larger than original trans_id.'  
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'  
      raiserror (@errmsg  ,16,1)
      if @@trancount > 0 rollback tran  

      return  
   end  
end  
  
if exists (select * from inserted i, deleted d  
           where i.trans_id < d.trans_id and  
                 i.alloc_num = d.alloc_num and 
		 i.alloc_item_num = d.alloc_item_num and
		 i.ai_est_actual_num = d.ai_est_actual_num)  
begin  
   raiserror ('(ai_est_actual_interface) new trans_id must not be older than current trans_id.'  ,16,1)
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
				i.alloc_item_num=d.alloc_item_num and
				i.ai_est_actual_num=d.ai_est_actual_num)  
   if (@count_num_rows = @num_rows)  
   begin  
      select @dummy_update = 1  
   end  
   else  
   begin  
      raiserror ('(ai_est_actual_interface) primary key can not be changed.'  ,16,1)
      if @@trancount > 0 rollback tran  

      return  
   end  
end  
  
/* AUDIT_CODE_BEGIN */  
  
if @dummy_update = 0  
   insert dbo.aud_ai_est_actual_interface  
      ( alloc_num,              
	alloc_item_num,
	ai_est_actual_num,
	feed_def_oid,
	record_id,
	record_type,
	record_status,
	carrier,
	truck_or_rail_num,
	driver_num,
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
	generic_column1,
	generic_column2,
	generic_column3,
	generic_column4,
	generic_column5,
	generic_column6,
	generic_column7,
	generic_column8,
	generic_column9,
	generic_column10,
	trans_id,
	resp_trans_id,
	system_well_id,
	ticket_time,
	tank_size,
	load_meter_open_qty,
	load_meter_close_qty,
	quantity_uom,
	obs_gravity,
	obs_bsw,
	obs_temp,
	ticket_gross_vol,
	meter_open_time,
	meter_close_time,
	temp_factor,
	meter_factor,
	rejected_load,
	driver_name
	)  
   select
        d.alloc_num,
	d.alloc_item_num,
	d.ai_est_actual_num,
	d.feed_def_oid,
	d.record_id,
	d.record_type,
	d.record_status,
	d.carrier,
	d.truck_or_rail_num,
	d.driver_num,
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
	d.generic_column1,
	d.generic_column2,
	d.generic_column3,
	d.generic_column4,
	d.generic_column5,
	d.generic_column6,
	d.generic_column7,
	d.generic_column8,
	d.generic_column9,
	d.generic_column10,
	d.trans_id,
        i.trans_id,
	d.system_well_id,
	d.ticket_time,
	d.tank_size,
	d.load_meter_open_qty,
	d.load_meter_close_qty,
	d.quantity_uom,
	d.obs_gravity,
	d.obs_bsw,
	d.obs_temp,
	d.ticket_gross_vol,
	d.meter_open_time,
	d.meter_close_time,
	d.temp_factor,
	d.meter_factor,
	d.rejected_load,
	d.driver_name
   from deleted d, inserted i  
   where i.alloc_num = d.alloc_num and 
	i.alloc_item_num=d.alloc_item_num and
	i.ai_est_actual_num=d.ai_est_actual_num   
  
/* AUDIT_CODE_END */  

return
GO
ALTER TABLE [dbo].[ai_est_actual_interface] ADD CONSTRAINT [chk_ai_est_actual_interface_rejected_load] CHECK (([rejected_load]=NULL OR [rejected_load]='N' OR [rejected_load]='Y'))
GO
ALTER TABLE [dbo].[ai_est_actual_interface] ADD CONSTRAINT [ai_est_actual_interface_pk] PRIMARY KEY CLUSTERED  ([alloc_num], [alloc_item_num], [ai_est_actual_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ai_est_actual_interface] ADD CONSTRAINT [ai_est_actual_interface_fk1] FOREIGN KEY ([feed_def_oid]) REFERENCES [dbo].[feed_definition] ([oid])
GO
ALTER TABLE [dbo].[ai_est_actual_interface] ADD CONSTRAINT [ai_est_actual_interface_fk2] FOREIGN KEY ([quantity_uom]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[ai_est_actual_interface] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ai_est_actual_interface] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ai_est_actual_interface] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ai_est_actual_interface] TO [next_usr]
GO
