CREATE TABLE [dbo].[mca_trade_item]
(
[mca_num] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[mtm_amount] [float] NULL,
[mtm_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mca_trade_item_deltrg]
on [dbo].[mca_trade_item]
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
   select @errmsg = '(mca_trade_item) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_mca_trade_item
   (mca_num,
    trade_num,
    order_num,
    item_num,
    mtm_amount,
    mtm_curr_code,
    trans_id,
    resp_trans_id)
select
   d.mca_num,
   d.trade_num,
   d.order_num,
   d.item_num,
   d.mtm_amount,
   d.mtm_curr_code,
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

create trigger [dbo].[mca_trade_item_updtrg]
on [dbo].[mca_trade_item]
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
   raiserror ('(mca_trade_item) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(mca_trade_item) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.mca_num = d.mca_num and 
                 i.trade_num = d.trade_num and 
                 i.order_num = d.order_num and 
                 i.item_num = d.item_num )
begin
   raiserror ('(mca_trade_item) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(mca_num) or  
   update(trade_num) or  
   update(order_num) or  
   update(item_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.mca_num = d.mca_num and 
                                   i.trade_num = d.trade_num and 
                                   i.order_num = d.order_num and 
                                   i.item_num = d.item_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(mca_trade_item) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_mca_trade_item
      (mca_num,
       trade_num,
       order_num,
       item_num,
       mtm_amount,
       mtm_curr_code,
       trans_id,
       resp_trans_id)
   select
      d.mca_num,
      d.trade_num,
      d.order_num,
      d.item_num,
      d.mtm_amount,
      d.mtm_curr_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.mca_num = i.mca_num and
         d.trade_num = i.trade_num and
         d.order_num = i.order_num and
         d.item_num = i.item_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[mca_trade_item] ADD CONSTRAINT [mca_trade_item_pk] PRIMARY KEY CLUSTERED  ([mca_num], [trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[mca_trade_item] ADD CONSTRAINT [mca_trade_item_fk1] FOREIGN KEY ([mtm_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[mca_trade_item] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[mca_trade_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[mca_trade_item] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[mca_trade_item] TO [next_usr]
GO
