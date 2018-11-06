CREATE TABLE [dbo].[shipment_chain]
(
[shipment_num] [int] NOT NULL,
[next_shipment_num] [int] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[shipment_chain_deltrg]
on [dbo].[shipment_chain]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
        @atrans_id int

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
   select @errmsg = '(shipment_chain) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_shipment_chain
(  
 	 shipment_num,
   next_shipment_num,
   trans_id,
   resp_trans_id
)
select
 	 d.shipment_num,
   d.next_shipment_num,
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

create trigger [dbo].[shipment_chain_updtrg]
on [dbo].[shipment_chain]
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
   raiserror ('(shipment_chain) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(shipment_chain) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.shipment_num = d.shipment_num and
                 i.next_shipment_num = d.next_shipment_num)
begin
   select @errmsg = '(shipment_chain) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.shipment_num) + ', ' + convert(varchar, i.next_shipment_num) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(shipment_num) or
   update(next_shipment_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.shipment_num = d.shipment_num and
                                   i.next_shipment_num = d.next_shipment_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(shipment_chain) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_shipment_chain
 	    (shipment_num,
       next_shipment_num,
       trans_id,
       resp_trans_id)
   select
 	    d.shipment_num,
      d.next_shipment_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.shipment_num = i.shipment_num and
         d.next_shipment_num = i.next_shipment_num

return
GO
ALTER TABLE [dbo].[shipment_chain] ADD CONSTRAINT [shipment_chain_pk] PRIMARY KEY CLUSTERED  ([shipment_num], [next_shipment_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[shipment_chain] ADD CONSTRAINT [shipment_chain_fk1] FOREIGN KEY ([shipment_num]) REFERENCES [dbo].[shipment] ([oid])
GO
ALTER TABLE [dbo].[shipment_chain] ADD CONSTRAINT [shipment_chain_fk2] FOREIGN KEY ([next_shipment_num]) REFERENCES [dbo].[shipment] ([oid])
GO
GRANT DELETE ON  [dbo].[shipment_chain] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[shipment_chain] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[shipment_chain] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[shipment_chain] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'shipment_chain', NULL, NULL
GO
