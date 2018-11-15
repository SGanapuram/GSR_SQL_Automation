CREATE TABLE [dbo].[inv_actual]
(
[oid] [int] NOT NULL,
[inv_fifo_num] [int] NULL,
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[ai_est_actual_num] [smallint] NULL,
[inv_num] [int] NULL,
[inv_b_d_num] [int] NULL,
[build_draw_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[actual_date] [datetime] NOT NULL,
[actual_qty] [float] NOT NULL,
[fifoed_qty] [float] NOT NULL,
[open_qty] [float] NOT NULL,
[adjustment_qty] [float] NOT NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[sec_actual_qty] [float] NOT NULL,
[sec_fifoed_qty] [float] NOT NULL,
[sec_open_qty] [float] NOT NULL,
[sec_adjustment_qty] [float] NOT NULL,
[sec_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[avg_price] [float] NULL,
[real_avg_price] [float] NULL,
[unreal_avg_price] [float] NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[field1] [int] NULL,
[field2] [float] NULL,
[field3] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[field4] [datetime] NULL,
[trans_id] [int] NOT NULL,
[pos_adj_qty] [numeric] (20, 8) NULL,
[neg_adj_qty] [numeric] (20, 8) NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[inv_actual_deltrg]
on [dbo].[inv_actual]
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
   select @errmsg = '(inv_actual) Failed to obtain a valid responsible trans_id.'  
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
  

insert dbo.aud_inv_actual
   (oid,
	  inv_fifo_num,
	  alloc_num,
	  alloc_item_num,
	  ai_est_actual_num,
	  inv_num,
	  inv_b_d_num,
	  build_draw_ind,
	  actual_date,
	  actual_qty,
	  fifoed_qty,
	  open_qty,
	  adjustment_qty,
	  qty_uom_code,
	  sec_actual_qty,
	  sec_fifoed_qty,
	  sec_open_qty,
	  sec_adjustment_qty,
	  sec_qty_uom_code,
	  avg_price,
	  real_avg_price,
	  unreal_avg_price,
	  price_curr_code,
	  price_uom_code,
	  field1,
	  field2,
	  field3,
	  field4,
	  pos_adj_qty,
    neg_adj_qty,
	  trans_id,
	  resp_trans_id)
select
   d.oid,
	 d.inv_fifo_num,
	 d.alloc_num,
	 d.alloc_item_num,
	 d.ai_est_actual_num,
	 d.inv_num,
	 d.inv_b_d_num,
	 d.build_draw_ind,
	 d.actual_date,
	 d.actual_qty,
	 d.fifoed_qty,
	 d.open_qty,
	 d.adjustment_qty,
	 d.qty_uom_code,
	 d.sec_actual_qty,
	 d.sec_fifoed_qty,
	 d.sec_open_qty,
	 d.sec_adjustment_qty,
	 d.sec_qty_uom_code,
	 d.avg_price,
	 d.real_avg_price,
	 d.unreal_avg_price,
	 d.price_curr_code,
	 d.price_uom_code,
	 d.field1,
	 d.field2,
	 d.field3,
	 d.field4,
	 d.pos_adj_qty,
   d.neg_adj_qty,
	 d.trans_id,
	 @atrans_id
from deleted d

return  
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[inv_actual_updtrg]
on [dbo].[inv_actual]
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
   raiserror ('(inv_actual) The change needs to be attached with a new trans_id.',10,1)  
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
      select @errmsg = '(inv_actual) New trans_id must be larger than original trans_id.'  
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'  
      raiserror (@errmsg, 10, 1)  
      if @@trancount > 0 rollback tran    
      return  
   end  
end  
  
if exists (select * from inserted i, deleted d  
           where i.trans_id < d.trans_id and  
                 i.oid = d.oid )  
begin  
   raiserror ('(inv_actual) new trans_id must not be older than current trans_id.', 10, 1)  
   if @@trancount > 0 rollback tran  
  
   return  
end  
  
/* RECORD_STAMP_END */  
  
if update(oid)  
begin  
   select @count_num_rows = (select count(*) from inserted i, deleted d  
                             where i.oid = d.oid )  
   if (@count_num_rows = @num_rows)  
   begin  
      select @dummy_update = 1  
   end  
   else  
   begin  
      raiserror ('(inv_actual) primary key can not be changed.', 10, 1)  
      if @@trancount > 0 rollback tran    
      return  
   end  
end  

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_inv_actual
   (oid,
	  inv_fifo_num,
	  alloc_num,
	  alloc_item_num,
	  ai_est_actual_num,
	  inv_num,
	  inv_b_d_num,
	  build_draw_ind,
	  actual_date,
	  actual_qty,
	  fifoed_qty,
	  open_qty,
	  adjustment_qty,
	  qty_uom_code,
	  sec_actual_qty,
	  sec_fifoed_qty,
	  sec_open_qty,
	  sec_adjustment_qty,
	  sec_qty_uom_code,
	  avg_price,
	  real_avg_price,
	  unreal_avg_price,
	  price_curr_code,
	  price_uom_code,
	  field1,
	  field2,
	  field3,
	  field4,
	  pos_adj_qty,
    neg_adj_qty,
	  trans_id,
	  resp_trans_id)
select  
   d.oid,
	 d.inv_fifo_num,
	 d.alloc_num,
	 d.alloc_item_num,
	 d.ai_est_actual_num,
	 d.inv_num,
	 d.inv_b_d_num,
	 d.build_draw_ind,
	 d.actual_date,
	 d.actual_qty,
	 d.fifoed_qty,
	 d.open_qty,
	 d.adjustment_qty,
	 d.qty_uom_code,
	 d.sec_actual_qty,
	 d.sec_fifoed_qty,
	 d.sec_open_qty,
	 d.sec_adjustment_qty,
	 d.sec_qty_uom_code,
	 d.avg_price,
	 d.real_avg_price,
	 d.unreal_avg_price,
	 d.price_curr_code,
	 d.price_uom_code,
	 d.field1,
	 d.field2,
	 d.field3,
	 d.field4,
	 d.pos_adj_qty,
   d.neg_adj_qty,
	 d.trans_id,
	 i.trans_id
from deleted d, inserted i
where d.oid = i.oid

return  
GO
ALTER TABLE [dbo].[inv_actual] ADD CONSTRAINT [CK__inv_actua__build__0A537D18] CHECK (([build_draw_ind]='A' OR [build_draw_ind]='D' OR [build_draw_ind]='B'))
GO
ALTER TABLE [dbo].[inv_actual] ADD CONSTRAINT [inv_actual_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[inv_actual] ADD CONSTRAINT [inv_actual_fk1] FOREIGN KEY ([inv_num]) REFERENCES [dbo].[inventory] ([inv_num])
GO
ALTER TABLE [dbo].[inv_actual] ADD CONSTRAINT [inv_actual_fk2] FOREIGN KEY ([qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[inv_actual] ADD CONSTRAINT [inv_actual_fk3] FOREIGN KEY ([sec_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[inv_actual] ADD CONSTRAINT [inv_actual_fk4] FOREIGN KEY ([price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[inv_actual] ADD CONSTRAINT [inv_actual_fk5] FOREIGN KEY ([price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[inv_actual] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[inv_actual] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[inv_actual] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[inv_actual] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'inv_actual', NULL, NULL
GO
