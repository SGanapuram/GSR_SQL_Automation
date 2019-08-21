CREATE TABLE [dbo].[credit_term_group]
(
[group_num] [int] NOT NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[credit_term_group_deltrg]
on [dbo].[credit_term_group]
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
   select @errmsg = '(credit_term_group) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_credit_term_group
(  
   group_num,
   credit_term_code,
   trans_id,
   resp_trans_id
)
select
   d.group_num,
   d.credit_term_code,
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

create trigger [dbo].[credit_term_group_updtrg]
on [dbo].[credit_term_group]
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
   raiserror ('(credit_term_group) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(credit_term_group) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.group_num = d.group_num and
                 i.credit_term_code = d.credit_term_code)
begin
   select @errmsg = '(credit_term_group) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.group_num) + ', ''' + i.credit_term_code + ''')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end

/* RECORD_STAMP_END */

if update(group_num) or
   update(credit_term_code)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.group_num = d.group_num and
                                   i.credit_term_code = d.credit_term_code)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(credit_term_group) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_credit_term_group
 	    (group_num,
       credit_term_code,
       trans_id,
       resp_trans_id)
   select
 	    d.group_num,
      d.credit_term_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.group_num = i.group_num and
         d.credit_term_code = i.credit_term_code

return
GO
ALTER TABLE [dbo].[credit_term_group] ADD CONSTRAINT [credit_term_group_pk] PRIMARY KEY CLUSTERED  ([group_num], [credit_term_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[credit_term_group] ADD CONSTRAINT [credit_term_group_fk1] FOREIGN KEY ([group_num]) REFERENCES [dbo].[credit_group] ([group_num])
GO
ALTER TABLE [dbo].[credit_term_group] ADD CONSTRAINT [credit_term_group_fk2] FOREIGN KEY ([credit_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
GRANT DELETE ON  [dbo].[credit_term_group] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[credit_term_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[credit_term_group] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[credit_term_group] TO [next_usr]
GO
