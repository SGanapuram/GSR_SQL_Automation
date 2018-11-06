CREATE TABLE [dbo].[ag_schedule]
(
[fd_oid] [int] NOT NULL,
[create_date_time] [datetime] NOT NULL,
[carrier_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[market_place] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pipeline_num] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[created_date] [datetime] NOT NULL,
[last_update_date] [datetime] NOT NULL,
[trans_id] [int] NOT NULL,
[doc_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ag_schedule_deltrg]
on [dbo].[ag_schedule]
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
   select @errmsg = '(ag_schedule) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_ag_schedule
(  
   fd_oid,
   create_date_time,
   carrier_code,
   market_place,
   pipeline_num,
   created_date,
   last_update_date,
   doc_id,
   trans_id,
   resp_trans_id
)
select
   d.fd_oid,
   d.create_date_time,
   d.carrier_code,
   d.market_place,
   d.pipeline_num,
   d.created_date,
   d.last_update_date,
   d.doc_id,
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

create trigger [dbo].[ag_schedule_updtrg]
on [dbo].[ag_schedule]
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
   raiserror ('(ag_schedule) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(ag_schedule) New trans_id must be larger than original trans_id.'
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
   select @errmsg = '(ag_schedule) new trans_id must not be older than current trans_id.'   
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
      raiserror ('(ag_schedule) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_ag_schedule
   (fd_oid,
    create_date_time,
    carrier_code,
    market_place,
    pipeline_num,
    created_date,
    last_update_date,
    doc_id,
    trans_id,	
    resp_trans_id)
 select
    d.fd_oid,
    d.create_date_time,
    d.carrier_code,
    d.market_place,
    d.pipeline_num,
    d.created_date,
    d.last_update_date,
    d.doc_id,
    d.trans_id,
    i.trans_id
   from deleted d, inserted i
   where d.fd_oid = i.fd_oid 

return
GO
ALTER TABLE [dbo].[ag_schedule] ADD CONSTRAINT [ag_schedule_pk] PRIMARY KEY CLUSTERED  ([fd_oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ag_schedule] ADD CONSTRAINT [ag_schedule_fk1] FOREIGN KEY ([fd_oid]) REFERENCES [dbo].[feed_data] ([oid])
GO
GRANT DELETE ON  [dbo].[ag_schedule] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ag_schedule] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ag_schedule] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ag_schedule] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'ag_schedule', NULL, NULL
GO
