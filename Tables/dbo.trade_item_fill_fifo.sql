CREATE TABLE [dbo].[trade_item_fill_fifo]
(
[fifo_group_num] [int] NOT NULL,
[fifo_num] [int] NOT NULL,
[match_fifo_num] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [int] NOT NULL,
[item_num] [int] NOT NULL,
[fill_num] [int] NOT NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fifo_asof_date] [datetime] NOT NULL,
[fifo_qty] [numeric] (20, 8) NOT NULL,
[match_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_fill_fifo_deltrg]
on [dbo].[trade_item_fill_fifo]
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
   select @errmsg = '(trade_item_fill_fifo) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_trade_item_fill_fifo
(  
   fifo_group_num,
   fifo_num,
   match_fifo_num,
   trade_num,
   order_num,
   item_num,
   fill_num,
   p_s_ind,
   fifo_asof_date,
   fifo_qty,
   match_type,
   trans_id,
   resp_trans_id
)
select
   d.fifo_group_num,
   d.fifo_num,
   d.match_fifo_num,
   d.trade_num,
   d.order_num,
   d.item_num,
   d.fill_num,
   d.p_s_ind,
   d.fifo_asof_date,
   d.fifo_qty,
   d.match_type,
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

create trigger [dbo].[trade_item_fill_fifo_updtrg]
on [dbo].[trade_item_fill_fifo]
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
   raiserror ('(trade_item_fill_fifo) The change needs to be attached with a new trans_id',16,1)
   if @@trancount > 0 rollback tran

   return
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.fifo_group_num = d.fifo_group_num and
                 i.fifo_num = d.fifo_num)
begin
   raiserror ('(trade_item_fill_fifo) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(fifo_group_num) or  
   update(fifo_num)
begin
   select @count_num_rows = (select count(*) 
                             from inserted i, deleted d
                             where i.fifo_group_num = d.fifo_group_num and
                                   i.fifo_num = d.fifo_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      select @errmsg = '(trade_item_fill_fifo) primary key can not be changed.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_trade_item_fill_fifo
   (
      fifo_group_num,
      fifo_num,
      match_fifo_num,
      trade_num,
      order_num,
      item_num,
      fill_num,
      p_s_ind,
      fifo_asof_date,
      fifo_qty,
      match_type,
      trans_id,
      resp_trans_id
   )
   select
      d.fifo_group_num,
      d.fifo_num,
      d.match_fifo_num,
      d.trade_num,
      d.order_num,
      d.item_num,
      d.fill_num,
      d.p_s_ind,
      d.fifo_asof_date,
      d.fifo_qty,
      d.match_type,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.fifo_group_num = i.fifo_group_num and
         d.fifo_num = i.fifo_num 

/* AUDIT_CODE_END */  
return
GO
ALTER TABLE [dbo].[trade_item_fill_fifo] ADD CONSTRAINT [chk_trade_item_fill_fifo_match_type] CHECK (([match_type]='O' OR [match_type]='F'))
GO
ALTER TABLE [dbo].[trade_item_fill_fifo] ADD CONSTRAINT [chk_trade_item_fill_fifo_p_s_ind] CHECK (([p_s_ind]='S' OR [p_s_ind]='P'))
GO
ALTER TABLE [dbo].[trade_item_fill_fifo] ADD CONSTRAINT [trade_item_fill_fifo_pk] PRIMARY KEY CLUSTERED  ([fifo_group_num], [fifo_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trade_item_fill_fifo] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_fill_fifo] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_fill_fifo] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_fill_fifo] TO [next_usr]
GO
