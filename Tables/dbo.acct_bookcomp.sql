CREATE TABLE [dbo].[acct_bookcomp]
(
[acct_bookcomp_key] [int] NOT NULL,
[acct_bookcomp_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__acct_book__acct___3C69FB99] DEFAULT ('A'),
[acct_num] [int] NOT NULL,
[bookcomp_num] [int] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[acct_bookcomp_deltrg]
on [dbo].[acct_bookcomp]
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
   select @errmsg = '(acct_bookcomp) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_acct_bookcomp
(  
   acct_bookcomp_key,
   acct_bookcomp_status,
   acct_num,
   bookcomp_num,
   trans_id,
   resp_trans_id
)
select
   d.acct_bookcomp_key,
   d.acct_bookcomp_status,
   d.acct_num,
   d.bookcomp_num,
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

create trigger [dbo].[acct_bookcomp_updtrg]
on [dbo].[acct_bookcomp]
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
   raiserror ('(acct_bookcomp) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(acct_bookcomp) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.acct_bookcomp_key = d.acct_bookcomp_key)
begin
   select @errmsg = '(acct_bookcomp) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.acct_bookcomp_key) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(acct_bookcomp_key)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.acct_bookcomp_key = d.acct_bookcomp_key)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(acct_bookcomp) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_acct_bookcomp
 	    (acct_bookcomp_key,
       acct_bookcomp_status,
       acct_num,
       bookcomp_num,
       trans_id,
       resp_trans_id)
   select
 	    d.acct_bookcomp_key,
      d.acct_bookcomp_status,
      d.acct_num,
      d.bookcomp_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.acct_bookcomp_key = i.acct_bookcomp_key 

return
GO
ALTER TABLE [dbo].[acct_bookcomp] ADD CONSTRAINT [CK__acct_book__acct___3D5E1FD2] CHECK (([acct_bookcomp_status]='I' OR [acct_bookcomp_status]='A'))
GO
ALTER TABLE [dbo].[acct_bookcomp] ADD CONSTRAINT [acct_bookcomp_pk] PRIMARY KEY CLUSTERED  ([acct_bookcomp_key]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[acct_bookcomp] ADD CONSTRAINT [acct_bookcomp_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[acct_bookcomp] ADD CONSTRAINT [acct_bookcomp_fk2] FOREIGN KEY ([bookcomp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[acct_bookcomp] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[acct_bookcomp] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[acct_bookcomp] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[acct_bookcomp] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'acct_bookcomp', NULL, NULL
GO
