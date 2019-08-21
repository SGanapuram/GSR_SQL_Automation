CREATE TABLE [dbo].[ag_truck_shipper_stmt]
(
[fdd_id] [int] NOT NULL,
[lease_num] [int] NULL,
[lease_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[purchaser] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_per_mile] [numeric] (20, 8) NULL,
[destination] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[volume] [numeric] (20, 8) NULL,
[miles] [numeric] (20, 8) NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rate] [numeric] (20, 8) NULL,
[fuel_rate] [numeric] (20, 8) NULL,
[total_rate] [numeric] (20, 8) NULL,
[barrels_charge] [numeric] (20, 8) NULL,
[split_rate] [numeric] (20, 8) NULL,
[reject_rate] [numeric] (20, 8) NULL,
[bob_tail_qty] [numeric] (20, 8) NULL,
[bob_tail] [numeric] (20, 8) NULL,
[chain_up_qty] [numeric] (20, 8) NULL,
[chain_up] [numeric] (20, 8) NULL,
[demurrage_hours] [numeric] (20, 8) NULL,
[demurrage] [numeric] (20, 8) NULL,
[divert] [numeric] (20, 8) NULL,
[total_charge] [numeric] (20, 8) NULL,
[alloc_num] [int] NULL,
[alloc_item_num] [smallint] NULL,
[ai_est_actual_num] [smallint] NULL,
[actual_cost] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
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
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ag_truck_shipper_stmt_deltrg]
on [dbo].[ag_truck_shipper_stmt]
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
   select @errmsg = '(ag_truck_shipper_stmt) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_ag_truck_shipper_stmt
(  
    fdd_id,
    lease_num,
    lease_name,
    purchaser,
    price_per_mile,
    destination,
    volume,
    miles,
    status,
    rate,
    fuel_rate,
    total_rate,
    barrels_charge,
    split_rate,
    reject_rate,
    bob_tail_qty,
    bob_tail,
    chain_up_qty,
    chain_up,
    demurrage_hours,
    demurrage,
    divert,
    total_charge,
    alloc_num,
    alloc_item_num,
    ai_est_actual_num,
    actual_cost,
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
    resp_trans_id
)
select
    d.fdd_id,
    d.lease_num,
    d.lease_name,
    d.purchaser,
    d.price_per_mile,
    d.destination,
    d.volume,
    d.miles,
    d.status,
    d.rate,
    d.fuel_rate,
    d.total_rate,
    d.barrels_charge,
    d.split_rate,
    d.reject_rate,
    d.bob_tail_qty,
    d.bob_tail,
    d.chain_up_qty,
    d.chain_up,
    d.demurrage_hours,
    d.demurrage,
    d.divert,
    d.total_charge,
    d.alloc_num,
    d.alloc_item_num,
    d.ai_est_actual_num,
    d.actual_cost,
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
    @atrans_id
from deleted d

/* AUDIT_CODE_END */
return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ag_truck_shipper_stmt_updtrg]
on [dbo].[ag_truck_shipper_stmt]
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
   raiserror ('(ag_truck_shipper_stmt) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(ag_truck_shipper_stmt) New trans_id must be larger than original trans_id.'
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
   select @errmsg = '(ag_truck_shipper_stmt) new trans_id must not be older than current trans_id.'   
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
      raiserror ('(ag_truck_shipper_stmt) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
insert dbo.aud_ag_truck_shipper_stmt
(
    fdd_id,
    lease_num,
    lease_name,
    purchaser,
    price_per_mile,
    destination,
    volume,
    miles,
    status,
    rate,
    fuel_rate,
    total_rate,
    barrels_charge,
    split_rate,
    reject_rate,
    bob_tail_qty,
    bob_tail,
    chain_up_qty,
    chain_up,
    demurrage_hours,
    demurrage,
    divert,
    total_charge,
    alloc_num,
    alloc_item_num,
    ai_est_actual_num,
    actual_cost,
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
    resp_trans_id
)
select
    d.fdd_id,
    d.lease_num,
    d.lease_name,
    d.purchaser,
    d.price_per_mile,
    d.destination,
    d.volume,
    d.miles,
    d.status,
    d.rate,
    d.fuel_rate,
    d.total_rate,
    d.barrels_charge,
    d.split_rate,
    d.reject_rate,
    d.bob_tail_qty,
    d.bob_tail,
    d.chain_up_qty,
    d.chain_up,
    d.demurrage_hours,
    d.demurrage,
    d.divert,
    d.total_charge,
    d.alloc_num,
    d.alloc_item_num,
    d.ai_est_actual_num,
    d.actual_cost,
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
    i.trans_id
from deleted d, inserted i
where d.fdd_id = i.fdd_id 

return
GO
ALTER TABLE [dbo].[ag_truck_shipper_stmt] ADD CONSTRAINT [ag_truck_shipper_stmt_pk] PRIMARY KEY CLUSTERED  ([fdd_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ag_truck_shipper_stmt] ADD CONSTRAINT [ag_truck_shipper_stmt_fk1] FOREIGN KEY ([fdd_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
ALTER TABLE [dbo].[ag_truck_shipper_stmt] ADD CONSTRAINT [ag_truck_shipper_stmt_fk2] FOREIGN KEY ([alloc_num], [alloc_item_num], [ai_est_actual_num]) REFERENCES [dbo].[ai_est_actual] ([alloc_num], [alloc_item_num], [ai_est_actual_num])
GO
GRANT DELETE ON  [dbo].[ag_truck_shipper_stmt] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ag_truck_shipper_stmt] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ag_truck_shipper_stmt] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ag_truck_shipper_stmt] TO [next_usr]
GO
