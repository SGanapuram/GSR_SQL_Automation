CREATE TABLE [dbo].[allocation_chain]
(
[alloc_num] [int] NOT NULL,
[alloc_chain_num] [smallint] NOT NULL,
[acct_num] [int] NOT NULL,
[alloc_chain_acct_seq_num] [smallint] NULL,
[alloc_confirmed_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[circled_qty] [decimal] (20, 8) NULL,
[circled_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[allocation_chain_deltrg]
on [dbo].[allocation_chain]
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
   select @errmsg = '(allocation_chain) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_allocation_chain
   (alloc_num,
    alloc_chain_num,
    acct_num,
    alloc_chain_acct_seq_num,
    alloc_confirmed_date,
    circled_qty,
    circled_qty_uom_code,
    trans_id,
    resp_trans_id)
select
   d.alloc_num,
   d.alloc_chain_num,
   d.acct_num,
   d.alloc_chain_acct_seq_num,
   d.alloc_confirmed_date,
   d.circled_qty,
   d.circled_qty_uom_code,
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

create trigger [dbo].[allocation_chain_updtrg]
on [dbo].[allocation_chain]
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
   raiserror ('(allocation_chain) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(allocation_chain) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.alloc_num = d.alloc_num and 
                 i.alloc_chain_num = d.alloc_chain_num )
begin
   raiserror ('(allocation_chain) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(alloc_num) or  
   update(alloc_chain_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.alloc_num = d.alloc_num and 
                                   i.alloc_chain_num = d.alloc_chain_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(allocation_chain) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_allocation_chain
      (alloc_num,
       alloc_chain_num,
       acct_num,
       alloc_chain_acct_seq_num,
       alloc_confirmed_date,
       circled_qty,
       circled_qty_uom_code,
       trans_id,
       resp_trans_id)
   select
      d.alloc_num,
      d.alloc_chain_num,
      d.acct_num,
      d.alloc_chain_acct_seq_num,
      d.alloc_confirmed_date,
      d.circled_qty,
      d.circled_qty_uom_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.alloc_num = i.alloc_num and
         d.alloc_chain_num = i.alloc_chain_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[allocation_chain] ADD CONSTRAINT [allocation_chain_pk] PRIMARY KEY CLUSTERED  ([alloc_num], [alloc_chain_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[allocation_chain] ADD CONSTRAINT [allocation_chain_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[allocation_chain] ADD CONSTRAINT [allocation_chain_fk3] FOREIGN KEY ([circled_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[allocation_chain] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[allocation_chain] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[allocation_chain] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[allocation_chain] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'allocation_chain', NULL, NULL
GO
