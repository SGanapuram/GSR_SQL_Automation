CREATE TABLE [dbo].[ag_nomination_line_item]
(
[fdd_oid] [int] NOT NULL,
[fd_oid] [int] NOT NULL,
[pipeline_event_type] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[location_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[consignee_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tankage_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[supplier_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[carrier_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sch_start_date] [datetime] NOT NULL,
[trans_id] [int] NOT NULL,
[shipment_id] [int] NULL,
[parcel_id] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ag_nomination_line_item_deltrg]
on [dbo].[ag_nomination_line_item]
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
   select @errmsg = '(ag_nomination_line_item) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_ag_nomination_line_item
(  
    fdd_oid,
    fd_oid,
    pipeline_event_type,
    location_code,
    consignee_code,
    tankage_code,
    supplier_code,  
    carrier_code,
    sch_start_date,
    shipment_id,
    parcel_id,
    trans_id,
    resp_trans_id
)
select
    d.fdd_oid,
    d.fd_oid,
    d.pipeline_event_type,
    d.location_code,
    d.consignee_code,
    d.tankage_code,
    d.supplier_code,
    d.carrier_code,
    d.sch_start_date,
    d.shipment_id,
    d.parcel_id,
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

create trigger [dbo].[ag_nomination_line_item_updtrg]
on [dbo].[ag_nomination_line_item]
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
   raiserror ('(ag_nomination_line_item) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(ag_nomination_line_item) New trans_id must be larger than original trans_id.'
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
   select @errmsg = '(ag_nomination_line_item) new trans_id must not be older than current trans_id.'   
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
      raiserror ('(ag_nomination_line_item) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_ag_nomination_line_item
   (
      fdd_oid,
      fd_oid,
      pipeline_event_type,
      location_code,
      consignee_code,
      tankage_code,
      supplier_code,   
      carrier_code,
      sch_start_date,
      shipment_id,
      parcel_id,
      trans_id,	
      resp_trans_id)
 select
    d.fdd_oid,
    d.fd_oid,
    d.pipeline_event_type,
    d.location_code,
    d.consignee_code,
    d.tankage_code,
    d.supplier_code,
    d.carrier_code,
    d.sch_start_date,
    d.shipment_id,
    d.parcel_id,
    d.trans_id,
    i.trans_id
 from deleted d, inserted i
 where d.fdd_oid = i.fdd_oid 

return
GO
ALTER TABLE [dbo].[ag_nomination_line_item] ADD CONSTRAINT [ag_nomination_line_item_pk] PRIMARY KEY CLUSTERED  ([fdd_oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ag_nomination_line_item_idx1] ON [dbo].[ag_nomination_line_item] ([pipeline_event_type], [location_code], [consignee_code], [tankage_code], [supplier_code], [carrier_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ag_nomination_line_item] ADD CONSTRAINT [ag_nomination_line_item_fk1] FOREIGN KEY ([fdd_oid]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
ALTER TABLE [dbo].[ag_nomination_line_item] ADD CONSTRAINT [ag_nomination_line_item_fk2] FOREIGN KEY ([fd_oid]) REFERENCES [dbo].[ag_nomination] ([fd_oid])
GO
ALTER TABLE [dbo].[ag_nomination_line_item] ADD CONSTRAINT [ag_nomination_line_item_fk3] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[shipment] ([oid])
GO
ALTER TABLE [dbo].[ag_nomination_line_item] ADD CONSTRAINT [ag_nomination_line_item_fk4] FOREIGN KEY ([parcel_id]) REFERENCES [dbo].[parcel] ([oid])
GO
GRANT DELETE ON  [dbo].[ag_nomination_line_item] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ag_nomination_line_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ag_nomination_line_item] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ag_nomination_line_item] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'ag_nomination_line_item', NULL, NULL
GO
