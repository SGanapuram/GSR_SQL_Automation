CREATE TABLE [dbo].[trade_feed]
(
[fdd_id] [int] NOT NULL,
[icts_trade_num] [int] NULL,
[econfirm_status] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_submitted_time] [datetime] NULL,
[resubmit_count] [int] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_feed_deltrg]
on [dbo].[trade_feed]
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
   select @errmsg = '(trade_feed) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_trade_feed
(  
   fdd_id,
   icts_trade_num, 
   econfirm_status,
   last_submitted_time,
   resubmit_count,
   trans_id,
   resp_trans_id
)
select
   d.fdd_id,
   d.icts_trade_num, 
   d.econfirm_status,
   d.last_submitted_time,
   d.resubmit_count,
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

create trigger [dbo].[trade_feed_updtrg]
on [dbo].[trade_feed]
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
   raiserror ('(trade_feed) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(trade_feed) New trans_id must be larger than original trans_id.'
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
   select @errmsg = '(trade_feed) new trans_id must not be older than current trans_id.'   
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
      raiserror ('(trade_feed) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_trade_feed
      (fdd_id,
       icts_trade_num, 
       econfirm_status,
       last_submitted_time,
       resubmit_count,
       trans_id,
       resp_trans_id)
   select
      d.fdd_id,
      d.icts_trade_num, 
      d.econfirm_status,
      d.last_submitted_time,
      d.resubmit_count,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.fdd_id = i.fdd_id 

return
GO
ALTER TABLE [dbo].[trade_feed] ADD CONSTRAINT [trade_feed_pk] PRIMARY KEY CLUSTERED  ([fdd_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_feed] ADD CONSTRAINT [trade_feed_fk1] FOREIGN KEY ([fdd_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
ALTER TABLE [dbo].[trade_feed] ADD CONSTRAINT [trade_feed_fk2] FOREIGN KEY ([icts_trade_num]) REFERENCES [dbo].[trade] ([trade_num])
GO
GRANT DELETE ON  [dbo].[trade_feed] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_feed] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_feed] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_feed] TO [next_usr]
GO
