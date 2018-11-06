CREATE TABLE [dbo].[ag_nomination]
(
[fd_oid] [int] NOT NULL,
[transaction_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[batch_number] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[event_datetime] [datetime] NOT NULL,
[pipeline_cycle] [int] NULL,
[pipeline_cycle_year] [int] NULL,
[pipeline_sequence] [int] NULL,
[pipeline_scd] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[product_id] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[created_date] [datetime] NOT NULL,
[last_update_date] [datetime] NOT NULL,
[trans_id] [int] NOT NULL,
[doc_id] [int] NOT NULL,
[shipper_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[carrier_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[market_place] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ag_nomination_deltrg]
on [dbo].[ag_nomination]
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
   select @errmsg = '(ag_nomination) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_ag_nomination
(  
    fd_oid,
    transaction_type,
    batch_number,
    event_datetime,
    pipeline_cycle,
    pipeline_cycle_year,
    pipeline_sequence,
    pipeline_scd,
    product_id,
    created_date,
    last_update_date,
    doc_id,
    shipper_code,
    carrier_code,
    market_place,
    trans_id,
    resp_trans_id
)
select
    d.fd_oid,
    d.transaction_type,
    d.batch_number,
    d.event_datetime,
    d.pipeline_cycle,
    d.pipeline_cycle_year,
    d.pipeline_sequence,
    d.pipeline_scd,
    d.product_id,
    d.created_date,
    d.last_update_date,
    d.doc_id,
    d.shipper_code,
    d.carrier_code,
    d.market_place,
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

create trigger [dbo].[ag_nomination_updtrg]
on [dbo].[ag_nomination]
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
   raiserror ('(ag_nomination) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(ag_nomination) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.fd_oid = d.fd_oid)
begin
   select @errmsg = '(ag_nomination) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.fd_oid) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(fd_oid)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.fd_oid = d.fd_oid)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(ag_nomination) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_ag_nomination
   (fd_oid,
    transaction_type,
    batch_number,
    event_datetime,
    pipeline_cycle,
    pipeline_cycle_year,
    pipeline_sequence,
    pipeline_scd,
    product_id,
    created_date,
    last_update_date,
    doc_id,
    shipper_code,
    carrier_code,
    market_place,
    trans_id,		
    resp_trans_id)
  select
    d.fd_oid,
    d.transaction_type,
    d.batch_number,
    d.event_datetime,
    d.pipeline_cycle,
    d.pipeline_cycle_year,
    d.pipeline_sequence,
    d.pipeline_scd,
    d.product_id,
    d.created_date,
    d.last_update_date,
    d.doc_id,
    d.shipper_code,
    d.carrier_code,
    d.market_place,
    d.trans_id,
    i.trans_id
   from deleted d, inserted i
   where d.fd_oid = i.fd_oid 

return
GO
ALTER TABLE [dbo].[ag_nomination] ADD CONSTRAINT [ag_nomination_pk] PRIMARY KEY CLUSTERED  ([fd_oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ag_nomination_idx3] ON [dbo].[ag_nomination] ([carrier_code], [market_place]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ag_nomination_idx2] ON [dbo].[ag_nomination] ([doc_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ag_nomination_idx1] ON [dbo].[ag_nomination] ([transaction_type], [batch_number], [event_datetime]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ag_nomination] ADD CONSTRAINT [ag_nomination_fk1] FOREIGN KEY ([fd_oid]) REFERENCES [dbo].[feed_data] ([oid])
GO
GRANT DELETE ON  [dbo].[ag_nomination] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ag_nomination] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ag_nomination] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ag_nomination] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'ag_nomination', NULL, NULL
GO
