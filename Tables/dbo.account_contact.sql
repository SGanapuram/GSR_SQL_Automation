CREATE TABLE [dbo].[account_contact]
(
[acct_num] [int] NOT NULL,
[acct_cont_num] [int] NOT NULL,
[acct_cont_last_name] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_cont_first_name] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_cont_nick_name] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_title] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_addr_line_1] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_addr_line_2] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_addr_line_3] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_addr_line_4] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_addr_city] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[state_code] [nchar] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[country_code] [nchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_addr_zip_code] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_home_ph_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_off_ph_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_oth_ph_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_telex_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_fax_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_email] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_cont_function] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_addr_num] [smallint] NULL,
[acct_cont_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[account_contact_deltrg]
on [dbo].[account_contact]
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
   select @errmsg = '(account_contact) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_account_contact
   (acct_num,
    acct_cont_num,
    acct_cont_last_name,
    acct_cont_first_name,
    acct_cont_nick_name,
    acct_cont_title,
    acct_cont_addr_line_1,
    acct_cont_addr_line_2,
    acct_cont_addr_line_3,
    acct_cont_addr_line_4,
    acct_cont_addr_city,
    state_code,
    country_code,
    acct_cont_addr_zip_code,
    acct_cont_home_ph_num,
    acct_cont_off_ph_num,
    acct_cont_oth_ph_num,
    acct_cont_telex_num,
    acct_cont_fax_num,
    acct_cont_email,
    acct_cont_function,
    acct_addr_num,
    acct_cont_status,
    trans_id,
    resp_trans_id)
select
   d.acct_num,
   d.acct_cont_num,
   d.acct_cont_last_name,
   d.acct_cont_first_name,
   d.acct_cont_nick_name,
   d.acct_cont_title,
   d.acct_cont_addr_line_1,
   d.acct_cont_addr_line_2,
   d.acct_cont_addr_line_3,
   d.acct_cont_addr_line_4,
   d.acct_cont_addr_city,
   d.state_code,
   d.country_code,
   d.acct_cont_addr_zip_code,
   d.acct_cont_home_ph_num,
   d.acct_cont_off_ph_num,
   d.acct_cont_oth_ph_num,
   d.acct_cont_telex_num,
   d.acct_cont_fax_num,
   d.acct_cont_email,
   d.acct_cont_function,
   d.acct_addr_num,
   d.acct_cont_status,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'DELETE',
       'AccountContact',
       'DIRECT',
       convert(varchar(40), d.acct_num),
       convert(varchar(40), d.acct_cont_num),
       null,
       null,
       null,
       null,
       null,
       null,
       @atrans_id,
       it.sequence
from deleted d, dbo.icts_transaction it
where it.trans_id = @atrans_id and
      it.type != 'E'
 
/* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[account_contact_instrg]
on [dbo].[account_contact]
for insert
as
declare @num_rows        int,
        @count_num_rows  int,
        @errmsg          varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'INSERT',
       'AccountContact',
       'DIRECT',
       convert(varchar(40), i.acct_num),
       convert(varchar(40), i.acct_cont_num),
       null,
       null,
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from inserted i, dbo.icts_transaction it
where i.trans_id = it.trans_id and
      it.type != 'E'
 
/* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[account_contact_updtrg]
on [dbo].[account_contact]
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
   raiserror ('(account_contact) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(account_contact) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.acct_num = d.acct_num and 
                 i.acct_cont_num = d.acct_cont_num )
begin
   raiserror ('(account_contact) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(acct_num) or 
   update(acct_cont_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.acct_num = d.acct_num and 
                                   i.acct_cont_num = d.acct_cont_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(account_contact) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'UPDATE',
       'AccountContact',
       'DIRECT',
       convert(varchar(40), i.acct_num),
       convert(varchar(40), i.acct_cont_num),
       null,
       null,
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from inserted i, dbo.icts_transaction it
where i.trans_id = it.trans_id and
      it.type != 'E'
  
/* END_TRANSACTION_TOUCH */

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_account_contact
      (acct_num,
       acct_cont_num,
       acct_cont_last_name,
       acct_cont_first_name,
       acct_cont_nick_name,
       acct_cont_title,
       acct_cont_addr_line_1,
       acct_cont_addr_line_2,
       acct_cont_addr_line_3,
       acct_cont_addr_line_4,
       acct_cont_addr_city,
       state_code,
       country_code,
       acct_cont_addr_zip_code,
       acct_cont_home_ph_num,
       acct_cont_off_ph_num,
       acct_cont_oth_ph_num,
       acct_cont_telex_num,
       acct_cont_fax_num,
       acct_cont_email,
       acct_cont_function,
       acct_addr_num,
       acct_cont_status,
       trans_id,
       resp_trans_id)
   select
      d.acct_num,
      d.acct_cont_num,
      d.acct_cont_last_name,
      d.acct_cont_first_name,
      d.acct_cont_nick_name,
      d.acct_cont_title,
      d.acct_cont_addr_line_1,
      d.acct_cont_addr_line_2,
      d.acct_cont_addr_line_3,
      d.acct_cont_addr_line_4,
      d.acct_cont_addr_city,
      d.state_code,
      d.country_code,
      d.acct_cont_addr_zip_code,
      d.acct_cont_home_ph_num,
      d.acct_cont_off_ph_num,
      d.acct_cont_oth_ph_num,
      d.acct_cont_telex_num,
      d.acct_cont_fax_num,
      d.acct_cont_email,
      d.acct_cont_function,
      d.acct_addr_num,
      d.acct_cont_status,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.acct_num = i.acct_num and
         d.acct_cont_num = i.acct_cont_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[account_contact] ADD CONSTRAINT [account_contact_pk] PRIMARY KEY CLUSTERED  ([acct_num], [acct_cont_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[account_contact] ADD CONSTRAINT [account_contact_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[account_contact] ADD CONSTRAINT [account_contact_fk2] FOREIGN KEY ([acct_num], [acct_addr_num]) REFERENCES [dbo].[account_address] ([acct_num], [acct_addr_num])
GO
GRANT DELETE ON  [dbo].[account_contact] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[account_contact] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[account_contact] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[account_contact] TO [next_usr]
GO
