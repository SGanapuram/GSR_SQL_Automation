CREATE TABLE [dbo].[account_address]
(
[acct_num] [int] NOT NULL,
[acct_addr_num] [smallint] NOT NULL,
[acct_addr_line_1] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_addr_line_2] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_line_3] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_line_4] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_city] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[state_code] [nchar] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[country_code] [nchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_addr_zip_code] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_ph_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_telex_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_fax_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_telex_ansback] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_fax_ansback] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_addr_email] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[accounting_system_id] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[account_address_deltrg]
on [dbo].[account_address]
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
   select @errmsg = '(account_address) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_account_address
   (acct_num,
    acct_addr_num,
    acct_addr_line_1,
    acct_addr_line_2,
    acct_addr_line_3,
    acct_addr_line_4,
    acct_addr_city,
    state_code,
    country_code,
    acct_addr_zip_code,
    acct_addr_ph_num,
    acct_addr_telex_num,
    acct_addr_fax_num,
    acct_addr_telex_ansback,
    acct_addr_fax_ansback,
    acct_addr_status,
    acct_addr_email,
    accounting_system_id,
    trans_id,
    resp_trans_id)
select
   d.acct_num,
   d.acct_addr_num,
   d.acct_addr_line_1,
   d.acct_addr_line_2,
   d.acct_addr_line_3,
   d.acct_addr_line_4,
   d.acct_addr_city,
   d.state_code,
   d.country_code,
   d.acct_addr_zip_code,
   d.acct_addr_ph_num,
   d.acct_addr_telex_num,
   d.acct_addr_fax_num,
   d.acct_addr_telex_ansback,
   d.acct_addr_fax_ansback,
   d.acct_addr_status,
   d.acct_addr_email,
   d.accounting_system_id,
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

create trigger [dbo].[account_address_updtrg]
on [dbo].[account_address]
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
   raiserror ('(account_address) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(account_address) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.acct_num = d.acct_num and 
                 i.acct_addr_num = d.acct_addr_num )
begin
   raiserror ('(account_address) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return 
end

/* RECORD_STAMP_END */

if update(acct_num) or  
   update(acct_addr_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.acct_num = d.acct_num and 
                                   i.acct_addr_num = d.acct_addr_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(account_address) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_account_address
      (acct_num,
       acct_addr_num,
       acct_addr_line_1,
       acct_addr_line_2,
       acct_addr_line_3,
       acct_addr_line_4,
       acct_addr_city,
       state_code,
       country_code,
       acct_addr_zip_code,
       acct_addr_ph_num,
       acct_addr_telex_num,
       acct_addr_fax_num,
       acct_addr_telex_ansback,
       acct_addr_fax_ansback,
       acct_addr_status,
       acct_addr_email,
       accounting_system_id,
       trans_id,
       resp_trans_id)
   select
      d.acct_num,
      d.acct_addr_num,
      d.acct_addr_line_1,
      d.acct_addr_line_2,
      d.acct_addr_line_3,
      d.acct_addr_line_4,
      d.acct_addr_city,
      d.state_code,
      d.country_code,
      d.acct_addr_zip_code,
      d.acct_addr_ph_num,
      d.acct_addr_telex_num,
      d.acct_addr_fax_num,
      d.acct_addr_telex_ansback,
      d.acct_addr_fax_ansback,
      d.acct_addr_status,
      d.acct_addr_email,
      d.accounting_system_id,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.acct_num = i.acct_num and
         d.acct_addr_num = i.acct_addr_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[account_address] ADD CONSTRAINT [account_address_pk] PRIMARY KEY CLUSTERED  ([acct_num], [acct_addr_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[account_address] ADD CONSTRAINT [account_address_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[account_address] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[account_address] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[account_address] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[account_address] TO [next_usr]
GO
