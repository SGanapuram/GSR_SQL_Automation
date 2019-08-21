CREATE TABLE [dbo].[account_collateral]
(
[acct_num] [int] NOT NULL,
[collateral_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[account_collateral_deltrg]
on [dbo].[account_collateral]
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
   select @errmsg = '(account_collateral) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_account_collateral
(  
 	 acct_num,
   collateral_type_code,
   trans_id,
   resp_trans_id
)
select
   d.acct_num,
   d.collateral_type_code,
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

create trigger [dbo].[account_collateral_updtrg]
on [dbo].[account_collateral]
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
   raiserror ('(account_collateral) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(account_collateral) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.acct_num = d.acct_num and
                 i.collateral_type_code = d.collateral_type_code)
begin
   select @errmsg = '(account_collateral) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.acct_num) + ', ''' + i.collateral_type_code + ''')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end

/* RECORD_STAMP_END */

if update(acct_num) or
   update(collateral_type_code)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.acct_num = d.acct_num and
                                   i.collateral_type_code = d.collateral_type_code)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(account_collateral) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_account_collateral
 	    (acct_num,
       collateral_type_code,
       trans_id,
       resp_trans_id)
   select
 	    d.acct_num,
      d.collateral_type_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.acct_num = i.acct_num and
         d.collateral_type_code = i.collateral_type_code

return
GO
ALTER TABLE [dbo].[account_collateral] ADD CONSTRAINT [account_collateral_pk] PRIMARY KEY CLUSTERED  ([acct_num], [collateral_type_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[account_collateral] ADD CONSTRAINT [account_collateral_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[account_collateral] ADD CONSTRAINT [account_collateral_fk2] FOREIGN KEY ([collateral_type_code]) REFERENCES [dbo].[collateral_type] ([collateral_type_code])
GO
GRANT DELETE ON  [dbo].[account_collateral] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[account_collateral] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[account_collateral] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[account_collateral] TO [next_usr]
GO
