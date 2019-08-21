CREATE TABLE [dbo].[inv_actual_fifo]
(
[oid] [int] NOT NULL,
[draw_inv_actual_num] [int] NOT NULL,
[build_inv_actual_num] [int] NOT NULL,
[fifo_qty] [float] NOT NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[inv_actual_fifo_deltrg]
on [dbo].[inv_actual_fifo]
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
   select @errmsg = '(inventory) Failed to obtain a valid responsible trans_id.'  
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
  
insert dbo.aud_inv_actual_fifo
   (    oid,
	draw_inv_actual_num,
	build_inv_actual_num,
	fifo_qty,
	qty_uom_code,
	trans_id,
	resp_trans_id)
select
        d.oid,
	d.draw_inv_actual_num,
	d.build_inv_actual_num,
	d.fifo_qty,
	d.qty_uom_code,
	d.trans_id,
	@atrans_id
from deleted d

return  
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[inv_actual_fifo_updtrg]
on [dbo].[inv_actual_fifo]
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
   raiserror ('(inventory) The change needs to be attached with a new trans_id.',16,1)  
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
      select @errmsg = '(inv_actual_fifo) New trans_id must be larger than original trans_id.'  
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'  
      raiserror (@errmsg,16,1)  
      if @@trancount > 0 rollback tran  
  
      return  
   end  
end  
  
if exists (select * from inserted i, deleted d  
           where i.trans_id < d.trans_id and  
                 i.oid = d.oid )  
begin  
   raiserror ('(inventory) new trans_id must not be older than current trans_id.',16,1)  
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
      raiserror ('(inventory) primary key can not be changed.',16,1)  
      if @@trancount > 0 rollback tran  
  
      return  
   end  
end  
    
/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_inv_actual_fifo
   (     oid,
	 draw_inv_actual_num,
	 build_inv_actual_num,
	 fifo_qty,
	 qty_uom_code,
	 trans_id,
	 resp_trans_id)
 select    
        d.oid,
	d.draw_inv_actual_num,
	d.build_inv_actual_num,
	d.fifo_qty,
	d.qty_uom_code,
	d.trans_id,
	i.trans_id
    from deleted d, inserted i
    where d.oid = i.oid

/* AUDIT_CODE_END */  
  
return  
GO
ALTER TABLE [dbo].[inv_actual_fifo] ADD CONSTRAINT [inv_actual_fifo_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[inv_actual_fifo] ADD CONSTRAINT [inv_actual_fifo_fk1] FOREIGN KEY ([draw_inv_actual_num]) REFERENCES [dbo].[inv_actual] ([oid])
GO
ALTER TABLE [dbo].[inv_actual_fifo] ADD CONSTRAINT [inv_actual_fifo_fk2] FOREIGN KEY ([build_inv_actual_num]) REFERENCES [dbo].[inv_actual] ([oid])
GO
ALTER TABLE [dbo].[inv_actual_fifo] ADD CONSTRAINT [inv_actual_fifo_fk3] FOREIGN KEY ([qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[inv_actual_fifo] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[inv_actual_fifo] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[inv_actual_fifo] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[inv_actual_fifo] TO [next_usr]
GO
