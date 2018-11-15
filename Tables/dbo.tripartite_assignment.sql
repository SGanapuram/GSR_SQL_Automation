CREATE TABLE [dbo].[tripartite_assignment]
(
[trade_num] [int] NOT NULL,
[order_num] [int] NOT NULL,
[item_num] [smallint] NOT NULL,
[assign_num] [smallint] NOT NULL,
[port_num] [int] NULL,
[shipment_num] [int] NULL,
[parcel_num] [int] NULL,
[actual_num] [int] NULL,
[assign_pcnt] [float] NOT NULL,
[bank_acct_num] [int] NULL,
[acct_bank_id] [int] NULL,
[assign_start_date] [datetime] NULL,
[assign_end_date] [datetime] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
create trigger [dbo].[tripartite_assignment_deltrg]  
on [dbo].[tripartite_assignment]  
for delete  
as  
declare @num_rows   int,  
        @errmsg     varchar(255),  
        @atrans_id  int  
  
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
   select @errmsg = '(tripartite_assignment) Failed to obtain a valid responsible trans_id.'  
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
  
   /* AUDIT_CODE_BEGIN */  
   insert dbo.aud_tripartite_assignment  
   ( 
	trade_num,  
	order_num,  
	item_num,  
	assign_num,  
	port_num,  
	shipment_num,  
	parcel_num,  
	actual_num,  
	assign_pcnt,  
	bank_acct_num,  
	acct_bank_id,  
	assign_start_date,  
	assign_end_date,  
	trans_id,  
	resp_trans_id)  
  select  
	d.trade_num,  
	d.order_num,  
	d.item_num,  
	d.assign_num,  
	d.port_num,  
	d.shipment_num,  
	d.parcel_num,  
	d.actual_num,  
	d.assign_pcnt,  
	d.bank_acct_num,  
	d.acct_bank_id,  
	d.assign_start_date,  
	d.assign_end_date,  
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

create trigger [dbo].[tripartite_assignment_updtrg]  
on [dbo].[tripartite_assignment]  
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
   raiserror ('(tripartite_assignment) The change needs to be attached with a new trans_id.',10,1)  
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
      select @errmsg = '(tripartite_assignment) New trans_id must be larger than original trans_id.'  
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'  
      raiserror (@errmsg,10,1)  
      if @@trancount > 0 rollback tran  
  
      return  
   end  
end  
  
if exists (select * from inserted i, deleted d  
           where i.trans_id < d.trans_id and  
                 i.trade_num = d.trade_num and  
                 i.order_num = d.order_num and  
                 i.item_num = d.item_num and  
                 i.assign_num = d.assign_num)  
begin  
   raiserror ('(tripartite_assignment) new trans_id must not be older than current trans_id.',10,1)  
   if @@trancount > 0 rollback tran  
  
   return  
end  
  
/* RECORD_STAMP_END */  
  
if update(trade_num) OR  
   update(order_num) OR  
   update(item_num) OR  
   update(assign_num)   
begin  
   select @count_num_rows = (select count(*) from inserted i, deleted d  
                             where i.trade_num = d.trade_num and  
         i.order_num = d.order_num and  
         i.item_num = d.item_num and  
         i.assign_num = d.assign_num)  
   if (@count_num_rows = @num_rows)  
   begin  
      select @dummy_update = 1  
   end  
   else  
   begin  
      raiserror ('(tripartite_assignment) primary key can not be changed.',10,1)  
      if @@trancount > 0 rollback tran   
      return  
   end  
end  
  
/* AUDIT_CODE_BEGIN */  
  
if @dummy_update = 0  
   insert dbo.aud_tripartite_assignment  
      (trade_num,  
       order_num,  
       item_num,  
       assign_num,  
       port_num,  
       shipment_num,  
       parcel_num,  
       actual_num,  
       assign_pcnt,  
       bank_acct_num,  
       acct_bank_id,  
       assign_start_date,  
       assign_end_date,  
       trans_id,  
       resp_trans_id)  
   select  
      d.trade_num,  
      d.order_num,  
      d.item_num,  
      d.assign_num,  
      d.port_num,  
      d.shipment_num,  
      d.parcel_num,  
      d.actual_num,  
      d.assign_pcnt,  
      d.bank_acct_num,  
      d.acct_bank_id,  
      d.assign_start_date,  
      d.assign_end_date,  
      d.trans_id,  
      i.trans_id  
   from deleted d, inserted i  
   where d.trade_num = i.trade_num and  
         d.order_num = i.order_num and  
         d.item_num =  i.item_num and  
         d.assign_num = i.assign_num  
  
/* AUDIT_CODE_END */  
  
return  
GO
ALTER TABLE [dbo].[tripartite_assignment] ADD CONSTRAINT [tripartite_assignment_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num], [assign_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tripartite_assignment] ADD CONSTRAINT [tripartite_assignment_fk1] FOREIGN KEY ([shipment_num]) REFERENCES [dbo].[shipment] ([oid])
GO
ALTER TABLE [dbo].[tripartite_assignment] ADD CONSTRAINT [tripartite_assignment_fk2] FOREIGN KEY ([parcel_num]) REFERENCES [dbo].[parcel] ([oid])
GO
ALTER TABLE [dbo].[tripartite_assignment] ADD CONSTRAINT [tripartite_assignment_fk3] FOREIGN KEY ([bank_acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[tripartite_assignment] ADD CONSTRAINT [tripartite_assignment_fk4] FOREIGN KEY ([acct_bank_id]) REFERENCES [dbo].[account_bank_info] ([acct_bank_id])
GO
GRANT DELETE ON  [dbo].[tripartite_assignment] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tripartite_assignment] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tripartite_assignment] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tripartite_assignment] TO [next_usr]
GO
