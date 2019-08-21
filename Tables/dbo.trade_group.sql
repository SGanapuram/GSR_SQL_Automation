CREATE TABLE [dbo].[trade_group]
(
[trade_group_num] [int] NOT NULL,
[trade_group_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trade_group_desc] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_trade_group_status] DEFAULT ('A'),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_group_deltrg]
on [dbo].[trade_group]
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
   select @errmsg = '(trade_group) Failed to obtain a valid responsible trans_id.'
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

/* AUDIT_CODE_BEGIN */
insert dbo.aud_trade_group
   (trade_group_num,  
    trade_group_code, 
    trade_group_desc,
    status,
    trans_id,
    resp_trans_id)
select
   d.trade_group_num,  
   d.trade_group_code, 
   d.trade_group_desc,
   d.status,
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

create trigger [dbo].[trade_group_updtrg]
on [dbo].[trade_group]
for update
as
declare @num_rows       int,
        @count_num_rows int,
        @dummy_update   int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(trade_group) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(trade_group) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.trade_group_num = d.trade_group_num )
begin
   raiserror ('(trade_group) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(trade_group_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.trade_group_num = d.trade_group_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(trade_group) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_trade_group
   (trade_group_num,  
    trade_group_code, 
    trade_group_desc,
    status,
    trans_id,
    resp_trans_id)
   select
      d.trade_group_num,  
      d.trade_group_code, 
      d.trade_group_desc,
      d.status,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.trade_group_num = i.trade_group_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[trade_group] ADD CONSTRAINT [chk_trade_group_status] CHECK (([status]='I' OR [status]='A'))
GO
ALTER TABLE [dbo].[trade_group] ADD CONSTRAINT [trade_group_pk] PRIMARY KEY CLUSTERED  ([trade_group_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trade_group] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_group] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_group] TO [next_usr]
GO
