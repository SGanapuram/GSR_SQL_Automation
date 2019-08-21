CREATE TABLE [dbo].[pl_offset_transfer]
(
[oid] [int] NOT NULL,
[owner_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[owner_key1] [int] NULL,
[owner_key2] [int] NULL,
[owner_key3] [int] NULL,
[port_num] [int] NULL,
[base_port_num] [int] NULL,
[transfer_qty] [numeric] (20, 8) NULL,
[transfer_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_amt] [numeric] (20, 8) NULL,
[transfer_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[source_owner_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[source_owner_key1] [int] NULL,
[source_owner_key2] [int] NULL,
[source_owner_key3] [int] NULL,
[trans_id] [int] NOT NULL,
[source_price] [float] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[pl_offset_transfer_deltrg]  
on [dbo].[pl_offset_transfer]  
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
   select @errmsg = '(pl_offset_transfer) Failed to obtain a valid responsible trans_id.'  
   if exists (select 1  
              from master.dbo.sysprocesses (nolock)  
              where spid = @@spid and  
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR  
                     program_name like 'Microsoft SQL Server Management Studio%') )  
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'  
   raiserror (@errmsg ,16,1)
   if @@trancount > 0 rollback tran  
   return  
end  

insert dbo.aud_pl_offset_transfer  
(
	 oid,
	 owner_code,
	 owner_key1,
	 owner_key2,
	 owner_key3,
	 port_num,
	 base_port_num,
	 transfer_qty,
	 transfer_qty_uom_code,
	 transfer_amt,
	 transfer_curr_code,
	 source_owner_code,
	 source_owner_key1,
	 source_owner_key2,
	 source_owner_key3,
	 source_price,
	 trans_id,
   resp_trans_id
)  
select
 	 d.oid,
	 d.owner_code,
	 d.owner_key1,
	 d.owner_key2,
	 d.owner_key3,
	 d.port_num,
	 d.base_port_num,
	 d.transfer_qty,
	 d.transfer_qty_uom_code,
	 d.transfer_amt,
	 d.transfer_curr_code,
	 d.source_owner_code,
	 d.source_owner_key1,
	 d.source_owner_key2,
	 d.source_owner_key3,
	 d.source_price,
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

create trigger [dbo].[pl_offset_transfer_updtrg]  
on [dbo].[pl_offset_transfer]  
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
   raiserror  ('(pl_offset_transfer) The change needs to be attached with a new trans_id', 16, 1)
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
      select @errmsg = '(pl_offset_transfer) New trans_id must be larger than original trans_id.'  
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'  
      raiserror  (@errmsg, 16, 1)
      rollback tran  
      return  
   end  
end  
  
if exists (select * from inserted i, deleted d  
           where i.trans_id < d.trans_id and  
                 i.oid = d.oid)  
begin  
   raiserror  ('(pl_offset_transfer) new trans_id must not be older than current trans_id.', 16, 1) 
   rollback tran  
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
      raiserror  ('(pl_offset_transfer) primary key can not be changed.', 16, 1)
      rollback tran  
      return  
   end  
end  

/* AUDIT_CODE_BEGIN */  
  
if @dummy_update = 0  
   insert dbo.aud_pl_offset_transfer  
   (
	    oid,
	    owner_code,
	    owner_key1,
	    owner_key2,
	    owner_key3,
	    port_num,
	    base_port_num,
	    transfer_qty,
	    transfer_qty_uom_code,
	    transfer_amt,
	    transfer_curr_code,
	    source_owner_code,
	    source_owner_key1,
	    source_owner_key2,
	    source_owner_key3,
	    source_price,
	    trans_id,
	    resp_trans_id
   )  
   select
	    d.oid,
	    d.owner_code,
	    d.owner_key1,
	    d.owner_key2,
	    d.owner_key3,
	    d.port_num,
	    d.base_port_num,
	    d.transfer_qty,
	    d.transfer_qty_uom_code,
	    d.transfer_amt,
	    d.transfer_curr_code,
	    d.source_owner_code,
	    d.source_owner_key1,
	    d.source_owner_key2,
	    d.source_owner_key3,
	    d.source_price,
	    d.trans_id,
      i.trans_id
   from deleted d, inserted i  
   where d.oid = i.oid   
  
/* AUDIT_CODE_END */  

return
GO
ALTER TABLE [dbo].[pl_offset_transfer] ADD CONSTRAINT [pl_offset_transfer_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pl_offset_transfer] ADD CONSTRAINT [pl_offset_transfer_fk1] FOREIGN KEY ([port_num]) REFERENCES [dbo].[portfolio] ([port_num])
GO
ALTER TABLE [dbo].[pl_offset_transfer] ADD CONSTRAINT [pl_offset_transfer_fk2] FOREIGN KEY ([base_port_num]) REFERENCES [dbo].[portfolio] ([port_num])
GO
ALTER TABLE [dbo].[pl_offset_transfer] ADD CONSTRAINT [pl_offset_transfer_fk3] FOREIGN KEY ([transfer_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[pl_offset_transfer] ADD CONSTRAINT [pl_offset_transfer_fk4] FOREIGN KEY ([transfer_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[pl_offset_transfer] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[pl_offset_transfer] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[pl_offset_transfer] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[pl_offset_transfer] TO [next_usr]
GO
