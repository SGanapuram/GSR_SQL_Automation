CREATE TABLE [dbo].[acct_bc_ot_crinfo]
(
[oid] [int] NOT NULL,
[acct_bookcomp_key] [int] NOT NULL,
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[order_direction] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[acct_bc_ot_crinfo_deltrg]
on [dbo].[acct_bc_ot_crinfo]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
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
   select @errmsg = '(acct_bc_ot_crinfo) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_acct_bc_ot_crinfo
(  
   oid,
   acct_bookcomp_key,
   order_type_code,
   credit_term_code,
   order_direction,
   trans_id,
   resp_trans_id
)
select
   d.oid,
   d.acct_bookcomp_key,
   d.order_type_code,
   d.credit_term_code,
   d.order_direction,
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

create trigger [dbo].[acct_bc_ot_crinfo_updtrg]
on [dbo].[acct_bc_ot_crinfo]
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
   raiserror ('(acct_bc_ot_crinfo) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(acct_bc_ot_crinfo) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   select @errmsg = '(acct_bc_ot_crinfo) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.oid) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
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
      raiserror ('(acct_bc_ot_crinfo) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_acct_bc_ot_crinfo
      (oid,
       acct_bookcomp_key,
       order_type_code,
       credit_term_code,
       order_direction,
       trans_id,
       resp_trans_id)
   select
      d.oid,
      d.acct_bookcomp_key,
      d.order_type_code,
      d.credit_term_code,
      d.order_direction,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

return
GO
ALTER TABLE [dbo].[acct_bc_ot_crinfo] ADD CONSTRAINT [chk_acct_bc_ot_crinfo_order_direction] CHECK (([order_direction]=NULL OR [order_direction]='S' OR [order_direction]='P'))
GO
ALTER TABLE [dbo].[acct_bc_ot_crinfo] ADD CONSTRAINT [acct_bc_ot_crinfo_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[acct_bc_ot_crinfo] ADD CONSTRAINT [acct_bc_ot_crinfo_fk1] FOREIGN KEY ([acct_bookcomp_key]) REFERENCES [dbo].[acct_bookcomp] ([acct_bookcomp_key])
GO
ALTER TABLE [dbo].[acct_bc_ot_crinfo] ADD CONSTRAINT [acct_bc_ot_crinfo_fk2] FOREIGN KEY ([order_type_code]) REFERENCES [dbo].[order_type] ([order_type_code])
GO
ALTER TABLE [dbo].[acct_bc_ot_crinfo] ADD CONSTRAINT [acct_bc_ot_crinfo_fk3] FOREIGN KEY ([credit_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
GRANT DELETE ON  [dbo].[acct_bc_ot_crinfo] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[acct_bc_ot_crinfo] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[acct_bc_ot_crinfo] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[acct_bc_ot_crinfo] TO [next_usr]
GO
