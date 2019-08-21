CREATE TABLE [dbo].[department]
(
[dept_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dept_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[profit_center_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[manager_init] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_cont_fld1_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_cont_fld2_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_cont_fld3_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_cont_fld4_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_cont_fld5_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_cont_fld6_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_acct_fld1_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_acct_fld2_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_acct_fld3_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_acct_fld4_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_acct_fld5_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_acct_fld6_label] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dept_num] [smallint] NULL,
[trading_entity_num] [int] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[department_deltrg]
on [dbo].[department]
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
   select @errmsg = '(department) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_department
   (dept_code,
    dept_name,
    profit_center_ind,
    manager_init,
    user_cont_fld1_label,
    user_cont_fld2_label,
    user_cont_fld3_label,
    user_cont_fld4_label,
    user_cont_fld5_label,
    user_cont_fld6_label,
    user_acct_fld1_label,
    user_acct_fld2_label,
    user_acct_fld3_label,
    user_acct_fld4_label,
    user_acct_fld5_label,
    user_acct_fld6_label,
    dept_num,
    trading_entity_num,
    trans_id,
    resp_trans_id)
select
   d.dept_code,
   d.dept_name,
   d.profit_center_ind,
   d.manager_init,
   d.user_cont_fld1_label,
   d.user_cont_fld2_label,
   d.user_cont_fld3_label,
   d.user_cont_fld4_label,
   d.user_cont_fld5_label,
   d.user_cont_fld6_label,
   d.user_acct_fld1_label,
   d.user_acct_fld2_label,
   d.user_acct_fld3_label,
   d.user_acct_fld4_label,
   d.user_acct_fld5_label,
   d.user_acct_fld6_label,
   d.dept_num,
   d.trading_entity_num,
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

create trigger [dbo].[department_updtrg]
on [dbo].[department]
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
   raiserror ('(department) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(department) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.dept_code = d.dept_code )
begin
   raiserror ('(department) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(dept_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.dept_code = d.dept_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(department) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_department
      (dept_code,
       dept_name,
       profit_center_ind,
       manager_init,
       user_cont_fld1_label,
       user_cont_fld2_label,
       user_cont_fld3_label,
       user_cont_fld4_label,
       user_cont_fld5_label,
       user_cont_fld6_label,
       user_acct_fld1_label,
       user_acct_fld2_label,
       user_acct_fld3_label,
       user_acct_fld4_label,
       user_acct_fld5_label,
       user_acct_fld6_label,
       dept_num,
       trading_entity_num,
       trans_id,
       resp_trans_id)
   select
      d.dept_code,
      d.dept_name,
      d.profit_center_ind,
      d.manager_init,
      d.user_cont_fld1_label,
      d.user_cont_fld2_label,
      d.user_cont_fld3_label,
      d.user_cont_fld4_label,
      d.user_cont_fld5_label,
      d.user_cont_fld6_label,
      d.user_acct_fld1_label,
      d.user_acct_fld2_label,
      d.user_acct_fld3_label,
      d.user_acct_fld4_label,
      d.user_acct_fld5_label,
      d.user_acct_fld6_label,
      d.dept_num,
      d.trading_entity_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.dept_code = i.dept_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[department] ADD CONSTRAINT [department_pk] PRIMARY KEY CLUSTERED  ([dept_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[department] ADD CONSTRAINT [department_fk1] FOREIGN KEY ([trading_entity_num]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[department] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[department] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[department] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[department] TO [next_usr]
GO
