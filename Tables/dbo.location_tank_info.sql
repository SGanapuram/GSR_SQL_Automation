CREATE TABLE [dbo].[location_tank_info]
(
[tank_num] [int] NOT NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[long_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__location___statu__3A02903A] DEFAULT ('A'),
[excise_warehouse_loc_ind] [bit] NOT NULL CONSTRAINT [DF__location___excis__3BEAD8AC] DEFAULT ((0)),
[bonded_warehouse_loc_ind] [bit] NOT NULL CONSTRAINT [DF__location___bonde__3CDEFCE5] DEFAULT ((0)),
[excise_info_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[legal_desc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[battery_govt_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tank_capacity] [decimal] (20, 8) NULL,
[tank_capacity_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[location_tank_info_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__location___locat__3DD3211E] DEFAULT ('T'),
[confirmation_status] [bit] NOT NULL CONSTRAINT [DF__location___confi__3FBB6990] DEFAULT ((0)),
[first_purchaser_ind] [bit] NOT NULL CONSTRAINT [DF__location___first__40AF8DC9] DEFAULT ((0)),
[well_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[api_well_num] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[meter_num] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[address_line1] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[address_line2] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[city_code] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[county_code] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[state_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[postal_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[latitude] [numeric] (9, 6) NULL,
[longitude] [numeric] (9, 6) NULL,
[survey_address] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[field_name] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[geologic_formation] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[operator_num] [int] NULL,
[owner_num] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[location_tank_info_deltrg]
on [dbo].[location_tank_info]
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
   select @errmsg = '(location_tank_info) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_location_tank_info
   (tank_num,
    loc_code,
    long_description,	
    status,
    excise_warehouse_loc_ind,	
    bonded_warehouse_loc_ind,	
    excise_info_id,
    legal_desc,
    battery_govt_code,
    tank_capacity,
    tank_capacity_uom_code,
    trans_id,
    resp_trans_id,
    location_tank_info_type,
    confirmation_status,
    first_purchaser_ind,
    well_name,
    api_well_num,
    meter_num,
    address_line1,
    address_line2,
    city_code,
    county_code,
    state_code,		
    country_code,		
    postal_code,
    latitude,
    longitude,
    survey_address,
    field_name,
    geologic_formation,
    operator_num,		
    owner_num)
 select
    d.tank_num,
    d.loc_code,
    d.long_description,	
    d.status,
    d.excise_warehouse_loc_ind,	
    d.bonded_warehouse_loc_ind,	
    d.excise_info_id,
    d.legal_desc,
    d.battery_govt_code,
    d.tank_capacity,
    d.tank_capacity_uom_code,
    d.trans_id,
    @atrans_id,
    d.location_tank_info_type,
    d.confirmation_status,
    d.first_purchaser_ind,
    d.well_name,
    d.api_well_num,
    d.meter_num,
    d.address_line1,
    d.address_line2,
    d.city_code,
    d.county_code,
    d.state_code,		
    d.country_code,		
    d.postal_code,
    d.latitude,
    d.longitude,
    d.survey_address,
    d.field_name,
    d.geologic_formation,
    d.operator_num,		
    d.owner_num
 from deleted d

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[location_tank_info_updtrg]
on [dbo].[location_tank_info]
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
   raiserror ('(location_tank_info) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(location_tank_info) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.tank_num = d.tank_num)
begin
   raiserror ('(location_tank_info) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(tank_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.tank_num = d.tank_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(location_tank_info) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_location_tank_info
      (tank_num,
       loc_code,
       long_description,	
       status,
       excise_warehouse_loc_ind,	
       bonded_warehouse_loc_ind,	
       excise_info_id,
       legal_desc,
       battery_govt_code,
       tank_capacity,
       tank_capacity_uom_code,
       trans_id,
       resp_trans_id,
       location_tank_info_type,
       confirmation_status,
       first_purchaser_ind,
       well_name,
       api_well_num,
       meter_num,
       address_line1,
       address_line2,
       city_code,
       county_code,
       state_code,		
       country_code,		
       postal_code,
       latitude,
       longitude,
       survey_address,
       field_name,
       geologic_formation,
       operator_num,		
       owner_num)
   select
      d.tank_num,
      d.loc_code,
      d.long_description,	
      d.status,
      d.excise_warehouse_loc_ind,	
      d.bonded_warehouse_loc_ind,	
      d.excise_info_id,
      d.legal_desc,
      d.battery_govt_code,
      d.tank_capacity,
      d.tank_capacity_uom_code,
      d.trans_id,
      i.trans_id,
      d.location_tank_info_type,
      d.confirmation_status,
      d.first_purchaser_ind,
      d.well_name,
      d.api_well_num,
      d.meter_num,
      d.address_line1,
      d.address_line2,
      d.city_code,
      d.county_code,
      d.state_code,		
      d.country_code,		
      d.postal_code,
      d.latitude,
      d.longitude,
      d.survey_address,
      d.field_name,
      d.geologic_formation,
      d.operator_num,		
      d.owner_num
   from deleted d, inserted i
   where d.tank_num = i.tank_num

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[location_tank_info] ADD CONSTRAINT [CK__location___locat__3EC74557] CHECK (([location_tank_info_type]='T' OR [location_tank_info_type]='L'))
GO
ALTER TABLE [dbo].[location_tank_info] ADD CONSTRAINT [CK__location___statu__3AF6B473] CHECK (([status]='N' OR [status]='I' OR [status]='A'))
GO
ALTER TABLE [dbo].[location_tank_info] ADD CONSTRAINT [location_tank_info_pk] PRIMARY KEY CLUSTERED  ([tank_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[location_tank_info] ADD CONSTRAINT [location_tank_info_fk1] FOREIGN KEY ([loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[location_tank_info] ADD CONSTRAINT [location_tank_info_fk3] FOREIGN KEY ([tank_capacity_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[location_tank_info] ADD CONSTRAINT [location_tank_info_fk4] FOREIGN KEY ([state_code]) REFERENCES [dbo].[state] ([state_code])
GO
ALTER TABLE [dbo].[location_tank_info] ADD CONSTRAINT [location_tank_info_fk5] FOREIGN KEY ([country_code]) REFERENCES [dbo].[country] ([country_code])
GO
ALTER TABLE [dbo].[location_tank_info] ADD CONSTRAINT [location_tank_info_fk6] FOREIGN KEY ([operator_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[location_tank_info] ADD CONSTRAINT [location_tank_info_fk7] FOREIGN KEY ([owner_num]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[location_tank_info] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[location_tank_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[location_tank_info] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[location_tank_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'location_tank_info', NULL, NULL
GO
