CREATE TABLE [dbo].[pl_reconciliation]
(
[pl_reconciliation_num] [int] NOT NULL,
[source_port_num] [int] NOT NULL,
[dest_port_num] [int] NOT NULL,
[offset_amount] [float] NOT NULL,
[booking_period] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pl_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[pl_reconciliation_deltrg]
on [dbo].[pl_reconciliation]
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
   select @errmsg = '(pl_reconciliation) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_pl_reconciliation
   (pl_reconciliation_num,
    source_port_num, 
    dest_port_num,  
    offset_amount,
    booking_period, 
    pl_curr_code,
    trans_id,
    resp_trans_id)
select
   d.pl_reconciliation_num,
   d.source_port_num, 
   d.dest_port_num,  
   d.offset_amount,
   d.booking_period, 
   d.pl_curr_code,
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

create trigger [dbo].[pl_reconciliation_updtrg]
on [dbo].[pl_reconciliation]
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
   raiserror ('(pl_reconciliation) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(pl_reconciliation) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.pl_reconciliation_num = d.pl_reconciliation_num)
begin
   raiserror ('(pl_reconciliation) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(pl_reconciliation_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.pl_reconciliation_num = d.pl_reconciliation_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(pl_reconciliation) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_pl_reconciliation
      (pl_reconciliation_num,
       source_port_num, 
       dest_port_num,  
       offset_amount,
       booking_period, 
       pl_curr_code,
       trans_id,
       resp_trans_id)
   select
      d.pl_reconciliation_num,
      d.source_port_num, 
      d.dest_port_num,  
      d.offset_amount,
      d.booking_period, 
      d.pl_curr_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.pl_reconciliation_num = i.pl_reconciliation_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[pl_reconciliation] ADD CONSTRAINT [pl_reconciliation_pk] PRIMARY KEY CLUSTERED  ([pl_reconciliation_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pl_reconciliation] ADD CONSTRAINT [pl_reconciliation_fk3] FOREIGN KEY ([pl_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[pl_reconciliation] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[pl_reconciliation] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[pl_reconciliation] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[pl_reconciliation] TO [next_usr]
GO
