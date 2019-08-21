CREATE TABLE [dbo].[broker_fifo_run_rec]
(
[broker_num] [int] NOT NULL,
[world_port_num] [int] NOT NULL,
[futures_last_fifo_date] [datetime] NULL,
[options_last_fifo_date] [datetime] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[broker_fifo_run_rec_deltrg]
on [dbo].[broker_fifo_run_rec]
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
   select @errmsg = '(broker_fifo_run_rec) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_broker_fifo_run_rec
(  
   broker_num,
   world_port_num,
   futures_last_fifo_date, 
   options_last_fifo_date, 
   trans_id,
   resp_trans_id
)
select
   d.broker_num,
   d.world_port_num,
   d.futures_last_fifo_date, 
   d.options_last_fifo_date, 
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

create trigger [dbo].[broker_fifo_run_rec_updtrg]
on [dbo].[broker_fifo_run_rec]
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
   raiserror ('(broker_fifo_run_rec) The change needs to be attached with a new trans_id',16,1)
   if @@trancount > 0 rollback tran

   return
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.broker_num = d.broker_num and
                 i.world_port_num = d.world_port_num)
begin
   raiserror ('(broker_fifo_run_rec) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(broker_num)  or  
   update(world_port_num) 
begin
   select @count_num_rows = (select count(*) 
                             from inserted i, deleted d
                             where i.broker_num = d.broker_num and
                                   i.world_port_num = d.world_port_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      select @errmsg = '(broker_fifo_run_rec) primary key can not be changed.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_broker_fifo_run_rec
   (
      broker_num,
      world_port_num,
      futures_last_fifo_date, 
      options_last_fifo_date, 
      trans_id,
      resp_trans_id
   )
   select
      d.broker_num,
      d.world_port_num,
      d.futures_last_fifo_date, 
      d.options_last_fifo_date, 
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.broker_num = i.broker_num and
         d.world_port_num = i.world_port_num

/* AUDIT_CODE_END */  
return
GO
ALTER TABLE [dbo].[broker_fifo_run_rec] ADD CONSTRAINT [broker_fifo_run_rec_pk] PRIMARY KEY CLUSTERED  ([broker_num], [world_port_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[broker_fifo_run_rec] ADD CONSTRAINT [broker_fifo_run_rec_fk1] FOREIGN KEY ([broker_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[broker_fifo_run_rec] ADD CONSTRAINT [broker_fifo_run_rec_fk2] FOREIGN KEY ([world_port_num]) REFERENCES [dbo].[portfolio] ([port_num])
GO
GRANT DELETE ON  [dbo].[broker_fifo_run_rec] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[broker_fifo_run_rec] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[broker_fifo_run_rec] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[broker_fifo_run_rec] TO [next_usr]
GO
