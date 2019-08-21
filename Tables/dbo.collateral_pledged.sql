CREATE TABLE [dbo].[collateral_pledged]
(
[coll_pledged_num] [int] NOT NULL,
[mca_num] [int] NOT NULL,
[margin_call_num] [int] NULL,
[coll_pledged_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_num] [int] NULL,
[lc_num] [int] NULL,
[pg_num] [int] NULL,
[mkt_security_num] [int] NULL,
[cash_coll_num] [int] NULL,
[coll_party_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[collateral_pledged_deltrg]
on [dbo].[collateral_pledged]
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
   select @errmsg = '(collateral_pledged) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_collateral_pledged
   (coll_pledged_num,
    mca_num,
    margin_call_num,
    coll_pledged_type,
    cost_num,
    lc_num,
    pg_num,
    mkt_security_num,
    cash_coll_num,
    coll_party_type,
    trans_id,
    resp_trans_id)
select
   d.coll_pledged_num,
   d.mca_num,
   d.margin_call_num,
   d.coll_pledged_type,
   d.cost_num,
   d.lc_num,
   d.pg_num,
   d.mkt_security_num,
   d.cash_coll_num,
   d.coll_party_type,
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

create trigger [dbo].[collateral_pledged_updtrg]
on [dbo].[collateral_pledged]
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
   raiserror ('(collateral_pledged) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(collateral_pledged) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.coll_pledged_num = d.coll_pledged_num )
begin
   raiserror ('(collateral_pledged) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(coll_pledged_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.coll_pledged_num = d.coll_pledged_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(collateral_pledged) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_collateral_pledged
      (coll_pledged_num,
       mca_num,
       margin_call_num,
       coll_pledged_type,
       cost_num,
       lc_num,
       pg_num,
       mkt_security_num,
       cash_coll_num,
       coll_party_type,
       trans_id,
       resp_trans_id)
   select
      d.coll_pledged_num,
      d.mca_num,
      d.margin_call_num,
      d.coll_pledged_type,
      d.cost_num,
      d.lc_num,
      d.pg_num,
      d.mkt_security_num,
      d.cash_coll_num,
      d.coll_party_type,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.coll_pledged_num = i.coll_pledged_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[collateral_pledged] ADD CONSTRAINT [collateral_pledged_pk] PRIMARY KEY NONCLUSTERED  ([coll_pledged_num]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [collateral_pledged_idx1] ON [dbo].[collateral_pledged] ([coll_pledged_num], [coll_pledged_type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[collateral_pledged] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[collateral_pledged] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[collateral_pledged] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[collateral_pledged] TO [next_usr]
GO
