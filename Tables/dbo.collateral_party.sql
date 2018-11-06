CREATE TABLE [dbo].[collateral_party]
(
[coll_party_num] [int] NOT NULL,
[mca_num] [int] NOT NULL,
[acct_num] [int] NOT NULL,
[is_payor] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[coll_party_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[payor_acct_num] [int] NULL,
[invoice_num] [int] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[collateral_party_deltrg]
on [dbo].[collateral_party]
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
   select @errmsg = '(collateral_party) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_collateral_party
   (coll_party_num,
    mca_num,
    acct_num,
    is_payor,
    coll_party_type,
    payor_acct_num,
    invoice_num,
    trans_id,
    resp_trans_id)
select
   d.coll_party_num,
   d.mca_num,
   d.acct_num,
   d.is_payor,
   d.coll_party_type,
   d.payor_acct_num,
   d.invoice_num,
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

create trigger [dbo].[collateral_party_updtrg]
on [dbo].[collateral_party]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errorNumber      int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(collateral_party) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(collateral_party) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.coll_party_num = d.coll_party_num )
begin
   raiserror ('(collateral_party) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(coll_party_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.coll_party_num = d.coll_party_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(collateral_party) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_collateral_party
      (coll_party_num,
       mca_num,
       acct_num,
       is_payor,
       coll_party_type,
       payor_acct_num,
       invoice_num,
       trans_id,
       resp_trans_id)
   select
      d.coll_party_num,
      d.mca_num,
      d.acct_num,
      d.is_payor,
      d.coll_party_type,
      d.payor_acct_num,
      d.invoice_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.coll_party_num = i.coll_party_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[collateral_party] ADD CONSTRAINT [collateral_party_pk] PRIMARY KEY CLUSTERED  ([coll_party_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[collateral_party] ADD CONSTRAINT [collateral_party_fk1] FOREIGN KEY ([payor_acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[collateral_party] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[collateral_party] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[collateral_party] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[collateral_party] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'collateral_party', NULL, NULL
GO