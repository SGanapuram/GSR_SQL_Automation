CREATE TABLE [dbo].[ai_est_actual_airline]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[ai_est_actual_num] [smallint] NOT NULL,
[auth_id] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[aircraft_num] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[flight_num] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[before_fuel_qty] [float] NULL,
[equip_type] [char] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[flight_orig_date] [datetime] NULL,
[flight_region] [char] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[flight_off_date] [datetime] NULL,
[vendor_auth_type] [char] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sales_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[reg_nbr] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rsn_code] [char] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[orig_trans_date] [datetime] NULL,
[trans_date] [datetime] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ai_est_actual_airline_deltrg]
on [dbo].[ai_est_actual_airline]
for delete
as
declare @num_rows   int,
        @errmsg     varchar(255),
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
   select @errmsg = '(ai_est_actual_airline) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_ai_est_actual_airline
   (alloc_num,
    alloc_item_num,
    ai_est_actual_num,
    auth_id,
    aircraft_num,
    flight_num,
    before_fuel_qty,
    equip_type,
    flight_orig_date,
    flight_region,
    flight_off_date,
    vendor_auth_type,
    sales_type,
    reg_nbr,
    rsn_code,
    orig_trans_date,
    trans_date,
    trans_id,
    resp_trans_id)
select
    d.alloc_num,
    d.alloc_item_num,
    d.ai_est_actual_num,
    d.auth_id,
    d.aircraft_num,
    d.flight_num,
    d.before_fuel_qty,
    d.equip_type,
    d.flight_orig_date,
    d.flight_region,
    d.flight_off_date,
    d.vendor_auth_type,
    d.sales_type,
    d.reg_nbr,
    d.rsn_code,
    d.orig_trans_date,
    d.trans_date,
    d.trans_id,
    @atrans_id
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'AiEstActualAirline',
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
from deleted d, dbo.icts_transaction it
where it.trans_id = @atrans_id and
      it.type != 'E'

/* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ai_est_actual_airline_instrg]
on [dbo].[ai_est_actual_airline]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'INSERT',
       'AiEstActualAirline',
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
from inserted i, dbo.icts_transaction it
where i.trans_id = it.trans_id and
      it.type != 'E'

/* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ai_est_actual_airline_updtrg]
on [dbo].[ai_est_actual_airline]
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
   raiserror ('(ai_est_actual) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(ai_est_actual_airline) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
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
   raiserror ('(ai_est_actual_airline) new trans_id must not be older than current trans_id.',16,1)
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
      raiserror ('(ai_est_actual_airline) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_ai_est_actual_airline
      (alloc_num,
       alloc_item_num,
       ai_est_actual_num,
       auth_id,
       aircraft_num,
       flight_num,
       before_fuel_qty,
       equip_type,
       flight_orig_date,
       flight_region,
       flight_off_date,
       vendor_auth_type,
       sales_type,
       reg_nbr,
       rsn_code,
       orig_trans_date,
       trans_date,
       trans_id,
       resp_trans_id)
    select
       d.alloc_num,
       d.alloc_item_num,
       d.ai_est_actual_num,
       d.auth_id,
       d.aircraft_num,
       d.flight_num,
       d.before_fuel_qty,
       d.equip_type,
       d.flight_orig_date,
       d.flight_region,
       d.flight_off_date,
       d.vendor_auth_type,
       d.sales_type,
       d.reg_nbr,
       d.rsn_code,
       d.orig_trans_date,
       d.trans_date,
       d.trans_id,
       i.trans_id
    from deleted d, inserted i
    where d.alloc_num = i.alloc_num and
          d.alloc_item_num = i.alloc_item_num and
          d.ai_est_actual_num = i.ai_est_actual_num

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'AiEstActualAirline',
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
from inserted i, dbo.icts_transaction it
where i.trans_id = it.trans_id and
      it.type != 'E'

/* END_TRANSACTION_TOUCH */

return
GO
ALTER TABLE [dbo].[ai_est_actual_airline] ADD CONSTRAINT [ai_est_actual_airline_pk] PRIMARY KEY CLUSTERED  ([alloc_num], [alloc_item_num], [ai_est_actual_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ai_est_actual_airline] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ai_est_actual_airline] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ai_est_actual_airline] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ai_est_actual_airline] TO [next_usr]
GO
