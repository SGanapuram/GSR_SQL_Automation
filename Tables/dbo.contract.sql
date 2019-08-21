CREATE TABLE [dbo].[contract]
(
[contr_num] [int] NOT NULL,
[contr_rev_num] [int] NOT NULL,
[contr_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_num] [int] NOT NULL,
[contr_creation_date] [datetime] NOT NULL,
[contr_creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[contr_reviewer_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[contr_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[contr_type] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[contr_on_hold_inds] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_confirmed_date] [datetime] NULL,
[contr_confirmed_by] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[contract_deltrg]
on [dbo].[contract]
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
   select @errmsg = '(contract) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_contract
   (contr_num,
    contr_rev_num,
    contr_name,
    acct_num,
    contr_creation_date,
    contr_creator_init,
    contr_reviewer_init,
    contr_status_code,
    contr_type,
    contr_on_hold_inds,
    contr_confirmed_date,
    contr_confirmed_by,
    trans_id,
    resp_trans_id)
select
   d.contr_num,
   d.contr_rev_num,
   d.contr_name,
   d.acct_num,
   d.contr_creation_date,
   d.contr_creator_init,
   d.contr_reviewer_init,
   d.contr_status_code,
   d.contr_type,
   d.contr_on_hold_inds,
   d.contr_confirmed_date,
   d.contr_confirmed_by,
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

create trigger [dbo].[contract_updtrg]
on [dbo].[contract]
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
   raiserror ('(contract) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(contract) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.contr_num = d.contr_num and 
                 i.contr_rev_num = d.contr_rev_num )
begin
   raiserror ('(contract) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(contr_num) or  
   update(contr_rev_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.contr_num = d.contr_num and 
                                   i.contr_rev_num = d.contr_rev_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(contract) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_contract
      (contr_num,
       contr_rev_num,
       contr_name,
       acct_num,
       contr_creation_date,
       contr_creator_init,
       contr_reviewer_init,
       contr_status_code,
       contr_type,
       contr_on_hold_inds,
       contr_confirmed_date,
       contr_confirmed_by,
       trans_id,
       resp_trans_id)
   select
      d.contr_num,
      d.contr_rev_num,
      d.contr_name,
      d.acct_num,
      d.contr_creation_date,
      d.contr_creator_init,
      d.contr_reviewer_init,
      d.contr_status_code,
      d.contr_type,
      d.contr_on_hold_inds,
      d.contr_confirmed_date,
      d.contr_confirmed_by,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.contr_num = i.contr_num and
         d.contr_rev_num = i.contr_rev_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[contract] ADD CONSTRAINT [contract_pk] PRIMARY KEY CLUSTERED  ([contr_num], [contr_rev_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[contract] ADD CONSTRAINT [contract_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[contract] ADD CONSTRAINT [contract_fk2] FOREIGN KEY ([contr_status_code]) REFERENCES [dbo].[contract_status] ([contr_status_code])
GO
ALTER TABLE [dbo].[contract] ADD CONSTRAINT [contract_fk3] FOREIGN KEY ([contr_creator_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[contract] ADD CONSTRAINT [contract_fk4] FOREIGN KEY ([contr_reviewer_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[contract] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[contract] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[contract] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[contract] TO [next_usr]
GO
