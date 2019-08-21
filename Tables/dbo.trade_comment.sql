CREATE TABLE [dbo].[trade_comment]
(
[trade_num] [int] NOT NULL,
[cmnt_num] [int] NOT NULL,
[trade_cmnt_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_comment_deltrg]
on [dbo].[trade_comment]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
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
   select @errmsg = '(trade_comment) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_trade_comment
   (trade_num,
    cmnt_num,
    trade_cmnt_type,
    trans_id,
    resp_trans_id)
select
   d.trade_num,
   d.cmnt_num,
   d.trade_cmnt_type,
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

create trigger [dbo].[trade_comment_updtrg]
on [dbo].[trade_comment]
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
   raiserror ('(trade_comment) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(trade_comment) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.trade_num = d.trade_num and 
                 i.cmnt_num = d.cmnt_num )
begin
   raiserror ('(trade_comment) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(trade_num) or  
   update(cmnt_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.trade_num = d.trade_num and 
                                   i.cmnt_num = d.cmnt_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(trade_comment) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_trade_comment
      (trade_num,
       cmnt_num,
       trade_cmnt_type,
       trans_id,
       resp_trans_id)
   select
      d.trade_num,
      d.cmnt_num,
      d.trade_cmnt_type,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.trade_num = i.trade_num and
         d.cmnt_num = i.cmnt_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[trade_comment] ADD CONSTRAINT [trade_comment_pk] PRIMARY KEY NONCLUSTERED  ([trade_num], [cmnt_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trade_comment] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_comment] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_comment] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_comment] TO [next_usr]
GO
