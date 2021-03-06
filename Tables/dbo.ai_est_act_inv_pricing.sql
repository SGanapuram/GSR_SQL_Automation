CREATE TABLE [dbo].[ai_est_act_inv_pricing]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [int] NOT NULL,
[ai_est_actual_num] [int] NOT NULL,
[insert_val_amt] [numeric] (20, 8) NULL,
[insert_val_override_transid] [int] NULL,
[mac_actual_value] [numeric] (20, 8) NULL,
[mac_r_actual_value] [numeric] (20, 8) NULL,
[mac_unr_actual_value] [numeric] (20, 8) NULL,
[fifo_actual_value] [numeric] (20, 8) NULL,
[fifo_r_actual_value] [numeric] (20, 8) NULL,
[fifo_unr_actual_value] [numeric] (20, 8) NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ai_est_act_inv_pricing_deltrg]
on [dbo].[ai_est_act_inv_pricing]
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
   select @errmsg = '(ai_est_act_inv_pricing) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_ai_est_act_inv_pricing
(  
   alloc_num,
   alloc_item_num,
   ai_est_actual_num,  
   insert_val_amt,
   insert_val_override_transid,
   mac_actual_value,
   mac_r_actual_value,
   mac_unr_actual_value,
   fifo_actual_value,
   fifo_r_actual_value,
   fifo_unr_actual_value,
   trans_id,
   resp_trans_id
)
select
   d.alloc_num,
   d.alloc_item_num,
   d.ai_est_actual_num,  
   d.insert_val_amt,
   d.insert_val_override_transid,
   d.mac_actual_value,
   d.mac_r_actual_value,
   d.mac_unr_actual_value,
   d.fifo_actual_value,
   d.fifo_r_actual_value,
   d.fifo_unr_actual_value,
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

create trigger [dbo].[ai_est_act_inv_pricing_updtrg]
on [dbo].[ai_est_act_inv_pricing]
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
   raiserror ('(ai_est_act_inv_pricing) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(ai_est_act_inv_pricing) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.alloc_num = d.alloc_num and
                 i.alloc_item_num = d.alloc_item_num and
		             i.ai_est_actual_num = d.ai_est_actual_num)
begin
   select @errmsg = '(ai_est_act_inv_pricing) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (''' + convert(varchar, i.alloc_num) + ''',''' + + convert(varchar, i.alloc_item_num) + ''',''' + + convert(varchar, i.ai_est_actual_num) + ''')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end

/* RECORD_STAMP_END */

if update(alloc_num) or
   update(alloc_item_num) or
   update(ai_est_actual_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.alloc_num = d.alloc_num and
                                   i.alloc_item_num = d.alloc_item_num and
				                           i.ai_est_actual_num = d.ai_est_actual_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(ai_est_act_inv_pricing) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_ai_est_act_inv_pricing
     (alloc_num,
      alloc_item_num,
      ai_est_actual_num,     
      insert_val_amt,
      insert_val_override_transid,
      mac_actual_value,
      mac_r_actual_value,
      mac_unr_actual_value,
      fifo_actual_value,
      fifo_r_actual_value,
      fifo_unr_actual_value,
      trans_id,
      resp_trans_id)
   select
      d.alloc_num,
      d.alloc_item_num,
      d.ai_est_actual_num,   
      d.insert_val_amt,
      d.insert_val_override_transid,
      d.mac_actual_value,
      d.mac_r_actual_value,
      d.mac_unr_actual_value,
      d.fifo_actual_value,
      d.fifo_r_actual_value,
      d.fifo_unr_actual_value,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.alloc_num = i.alloc_num and
         d.alloc_item_num = i.alloc_item_num and
	       d.ai_est_actual_num = i.ai_est_actual_num

return
GO
ALTER TABLE [dbo].[ai_est_act_inv_pricing] ADD CONSTRAINT [ai_est_act_inv_pricing_pk] PRIMARY KEY CLUSTERED  ([alloc_num], [alloc_item_num], [ai_est_actual_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ai_est_act_inv_pricing] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ai_est_act_inv_pricing] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ai_est_act_inv_pricing] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ai_est_act_inv_pricing] TO [next_usr]
GO
