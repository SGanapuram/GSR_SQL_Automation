CREATE TABLE [dbo].[allocation_transfer]
(
[source_inv_num] [int] NULL,
[source_invbd_num] [int] NULL,
[target_inv_num] [int] NULL,
[target_invbd_num] [int] NULL,
[transfer_qty] [float] NOT NULL,
[transfer_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[transfer_price] [float] NULL,
[transfer_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[source_alloc_num] [int] NOT NULL,
[source_alloc_item_num] [smallint] NOT NULL,
[target_alloc_num] [int] NOT NULL,
[target_alloc_item_num] [smallint] NOT NULL,
[transfer_price_curr_code_to] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_price_currency_rate] [float] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[allocation_transfer_deltrg]  
on [dbo].[allocation_transfer]  
for delete  
as  
declare @num_rows    int,  
        @errmsg      varchar(255),  
        @atrans_id   int  
  
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
   select @errmsg = '(allocation_transfer) Failed to obtain a valid responsible trans_id.'  
   if exists (select 1  
              from master.dbo.sysprocesses (nolock)  
              where spid = @@spid and  
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR  
                     program_name like 'Microsoft SQL Server Management Studio%') )  
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'  
   raiserror (@errmsg, 10, 1) 
   rollback tran  
   return  
end  

insert dbo.aud_allocation_transfer
(
	 source_inv_num,
	 source_invbd_num,
	 target_inv_num,
	 target_invbd_num,
	 transfer_qty,
	 transfer_qty_uom_code,
	 transfer_price,
	 transfer_price_curr_code,
	 transfer_price_uom_code,
	 trans_id,
	 resp_trans_id,
	 source_alloc_num,
	 source_alloc_item_num,
	 target_alloc_num,
	 target_alloc_item_num,
   transfer_price_curr_code_to,
	 transfer_price_currency_rate	
)  
select
	 d.source_inv_num,
	 d.source_invbd_num,
	 d.target_inv_num,
	 d.target_invbd_num,
	 d.transfer_qty,
	 d.transfer_qty_uom_code,
	 d.transfer_price,
	 d.transfer_price_curr_code,
	 d.transfer_price_uom_code,
	 d.trans_id,
	 @atrans_id,
	 d.source_alloc_num,
	 d.source_alloc_item_num,
	 d.target_alloc_num,
	 d.target_alloc_item_num,
   d.transfer_price_curr_code_to,
	 d.transfer_price_currency_rate	
from deleted d   
  
/* AUDIT_CODE_END */  

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[allocation_transfer_updtrg]  
on [dbo].[allocation_transfer]  
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
   raiserror ('(allocation_transfer) The change needs to be attached with a new trans_id',10,1)  
   rollback tran  
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
      select @errmsg = '(allocation_transfer) New trans_id must be larger than original trans_id.'  
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'  
      raiserror (@errmsg, 10, 1)
      rollback tran  
      return  
   end  
end  
  
if exists (select * from inserted i, deleted d  
           where i.trans_id < d.trans_id and  
                 d.source_inv_num = i.source_inv_num and
             d.source_invbd_num = i.source_invbd_num and 
	     d.target_inv_num = i.target_inv_num and
	     d.target_invbd_num = i.target_invbd_num)  
begin  
   raiserror ('(allocation_transfer) new trans_id must not be older than current trans_id.',10,1)  
   rollback tran  
   return  
end  
  
/* RECORD_STAMP_END */
  
if update(source_inv_num) or 
   update(source_invbd_num) or 
   update(target_inv_num) or 
   update(target_invbd_num) 
begin  
   select @count_num_rows = (select count(*) from inserted i, deleted d  
                             where d.source_inv_num = i.source_inv_num and
                                   d.source_invbd_num = i.source_invbd_num and 
 	                                 d.target_inv_num = i.target_inv_num and
	                                 d.target_invbd_num = i.target_invbd_num)  
   if (@count_num_rows = @num_rows)  
   begin  
      select @dummy_update = 1  
   end  
   else  
   begin  
      raiserror ('(allocation_transfer) primary key can not be changed.',10,1)  
      rollback tran  
      return  
   end  
end  

/* AUDIT_CODE_BEGIN */  
  
if @dummy_update = 0  
insert dbo.aud_allocation_transfer  
(
	 source_inv_num,
	 source_invbd_num,
	 target_inv_num,
	 target_invbd_num,
	 transfer_qty,
	 transfer_qty_uom_code,
	 transfer_price,
	 transfer_price_curr_code ,
	 transfer_price_uom_code,
	 trans_id,
	 resp_trans_id,
	 source_alloc_num,
	 source_alloc_item_num,
	 target_alloc_num,
	 target_alloc_item_num,
   transfer_price_curr_code_to,
	 transfer_price_currency_rate	
)  
select
	 d.source_inv_num,
	 d.source_invbd_num,
	 d.target_inv_num,
	 d.target_invbd_num,
	 d.transfer_qty,
	 d.transfer_qty_uom_code,
	 d.transfer_price,
	 d.transfer_price_curr_code,
	 d.transfer_price_uom_code,
	 d.trans_id,
	 i.trans_id,
	 d.source_alloc_num,
	 d.source_alloc_item_num,
	 d.target_alloc_num,
	 d.target_alloc_item_num,
   d.transfer_price_curr_code_to,
	 d.transfer_price_currency_rate	
from deleted d, inserted i  
where d.source_inv_num = i.source_inv_num and
      d.source_invbd_num = i.source_invbd_num and 
      d.target_inv_num = i.target_inv_num and
      d.target_invbd_num = i.target_invbd_num
  
/* AUDIT_CODE_END */  

return
GO
ALTER TABLE [dbo].[allocation_transfer] ADD CONSTRAINT [allocation_transfer_fk1] FOREIGN KEY ([transfer_price_curr_code_to]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[allocation_transfer] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[allocation_transfer] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[allocation_transfer] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[allocation_transfer] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'allocation_transfer', NULL, NULL
GO