CREATE TABLE [dbo].[ext_trade_loading_sched]
(
[oid] [int] NOT NULL,
[external_trade_source_oid] [int] NULL,
[buyer_seller_account] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loading_schedule] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_ext_trade_loading_sched_loading_schedule] DEFAULT ('O'),
[loading_time_from] [datetime] NULL,
[loading_time_to] [datetime] NULL,
[loading_date_timezone] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_date_to_load] [datetime] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ext_trade_loading_sched_deltrg]
on [dbo].[ext_trade_loading_sched]
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
   select @errmsg = '(ext_trade_loading_sched) Failed to obtain a valid responsible trans_id.'
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

/* AUDIT_CODE_END */
return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ext_trade_loading_sched_updtrg]
on [dbo].[ext_trade_loading_sched]
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
   raiserror ('(ext_trade_loading_sched) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(ext_trade_loading_sched) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   select @errmsg = '(ext_trade_loading_sched) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.oid) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end

/* RECORD_STAMP_END */

if update(oid)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(ext_trade_loading_sched) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[ext_trade_loading_sched] ADD CONSTRAINT [chk_ext_trade_loading_sched_loading_schedule] CHECK (([loading_schedule]='O' OR [loading_schedule]='D' OR [loading_schedule]='T' OR [loading_schedule]='B' OR [loading_schedule]='L'))
GO
ALTER TABLE [dbo].[ext_trade_loading_sched] ADD CONSTRAINT [ext_trade_loading_sched_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ext_trade_loading_sched] ADD CONSTRAINT [ext_trade_loading_sched_fk1] FOREIGN KEY ([external_trade_source_oid]) REFERENCES [dbo].[external_trade_source] ([oid])
GO
GRANT DELETE ON  [dbo].[ext_trade_loading_sched] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ext_trade_loading_sched] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ext_trade_loading_sched] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ext_trade_loading_sched] TO [next_usr]
GO
