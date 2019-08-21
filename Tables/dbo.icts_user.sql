CREATE TABLE [dbo].[icts_user]
(
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_last_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_first_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[desk_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_logon_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[us_citizen_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_icts_user_us_citizen_ind] DEFAULT ('Y'),
[user_job_title] [char] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_employee_num] [int] NULL,
[email_address] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[icts_user_deltrg]
on [dbo].[icts_user]
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
   select @errmsg = '(icts_user) Failed to obtain a valid responsible trans_id.'
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


/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'DELETE',
       'IctsUser',
       'DIRECT',
       convert(varchar(40), d.user_init),
       null,
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

/* AUDIT_CODE_BEGIN */
insert dbo.aud_icts_user
   (user_init,
    user_last_name,
    user_first_name,
    desk_code,
    loc_code,
    user_logon_id,
    us_citizen_ind,
    user_job_title,
    user_status,
    user_employee_num,
    email_address,
    trans_id,
    resp_trans_id)
select
   d.user_init,
   d.user_last_name,
   d.user_first_name,
   d.desk_code,
   d.loc_code,
   d.user_logon_id,
   d.us_citizen_ind,
   d.user_job_title,
   d.user_status,
   d.user_employee_num,
   d.email_address,
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

create trigger [dbo].[icts_user_instrg]
on [dbo].[icts_user]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* BEGIN_DATA_INTEGRITY */
/* In MS SQL Server, the constraint will perform this checking */
-- if exists (select 1 
--           from inserted
--           where user_job_title not in 
--                   (select job_title
--                    from user_job_title))
-- begin
--   raiserror ('An invalid user_job_title was used, please look up the user_job_title table for a valid job title.',16,1)
--   if @@trancount > 0 rollback tran

--   return
-- end

/* The design of the new_num table support multiple locations which are identified by loc_num.
   The location table provide the mapping between a loc_code and a loc_num.
   When a user login into any of ICTS applications, a record in the icts_user table is retrieved for 
   this user, and then the loc_code from this record is used to locate a record in the location table, 
   and finally, obtain a loc_num for the location.

   Later, the loc_num information will be used in calling the stored procedure get_new_num. If the loc_code
   in the icts_user record is invalid (it means that the loc_code is not defined in the location table), 
   then a loc_num can be obtained, therefore, execution of the stored procedure get_new_num will be failed 
   due to the syntax error.

   -- Peter Lo    8/25/2000
*/
   if exists (select 1 
              from inserted
              where loc_code not in (select loc_code from dbo.location))
   begin
      if @num_rows = 1
      begin
         select @errmsg = 'The loc_code ''' + loc_code + ''' is not a valid code defined in the location table.'
         from inserted
      end
      else
      begin
         select @errmsg = 'The loc_code is not a valid code defined in the location table.'
      end
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
   
   if exists (select 1 
              from inserted, dbo.icts_user
              where icts_user.user_logon_id = rtrim(inserted.user_logon_id) and
                 icts_user.user_init != inserted.user_init)
   begin
      if @num_rows = 1
      begin
         select @errmsg = 'The user_logon_id ''' + user_logon_id + ''' has existed in the icts_user table. Duplicate is not allowed!'
         from inserted
      end
      else
      begin
         select @errmsg = 'The user_logon_id(s) have existed in the icts_user table. Duplicate is not allowed!'
      end
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end

   /* END_DATA_INTEGRITY */

   /* BEGIN_TRANSACTION_TOUCH */
 
   insert dbo.transaction_touch
   select 'INSERT',
          'IctsUser',
          'DIRECT',
          convert(varchar(40), i.user_init),
          null,
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

create trigger [dbo].[icts_user_updtrg]
on [dbo].[icts_user]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* BEGIN_DATA_INTEGRITY */
/* In MS SQL Server, the constraint will perform this checking */
-- if update(user_job_title)
-- begin
--    if exists (select 1 
--               from inserted
--               where user_job_title not in 
--                       (select job_title
--                        from dbo.user_job_title))
--    begin
--       raiserror ('An invalid user_job_title was used, please look up the user_job_title table for a valid job title.',16,1)
--       if @@trancount > 0 rollback tran

--       return
--    end
-- end

/* The design of the new_num table support multiple locations which are identified by loc_num.
   The location table provide the mapping between a loc_code and a loc_num.
   When a user login into any of ICTS applications, a record in the icts_user table is retrieved for 
   this user, and then the loc_code from this record is used to locate a record in the location table, 
   and finally, obtain a loc_num for the location.

   Later, the loc_num information will be used in calling the stored procedure get_new_num. If the loc_code
   in the icts_user record is invalid (it means that the loc_code is not defined in the location table), 
   then a loc_num can be obtained, therefore, execution of the stored procedure get_new_num will be failed 
   due to the syntax error.

   -- Peter Lo    8/25/2000
*/
if update(loc_code)
begin
if exists (select 1 from inserted
           where loc_code not in (select loc_code from dbo.location))
   begin
      if @num_rows = 1
      begin
         select @errmsg = 'The loc_code ''' + loc_code + ''' is not a valid code defined in the location table.'
         from inserted
      end
      else
      begin
         select @errmsg = 'The loc_code is not a valid code defined in the location table.'
      end
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select 1 from inserted, dbo.icts_user
           where icts_user.user_logon_id = rtrim(inserted.user_logon_id) and
                 icts_user.user_init != inserted.user_init)
begin
   if @num_rows = 1
   begin
      select @errmsg = 'The new user_logon_id ''' + user_logon_id + ''' has existed in the icts_user table. Duplicate is not allowed!'
      from inserted
   end
   else
   begin
      select @errmsg = 'The new user_logon_id(s) have existed in the icts_user table. Duplicate is not allowed!'
   end
   raiserror (@errmsg,16,1)
   if @@trancount > 0 rollback tran

   return
end   

/* END_DATA_INTEGRITY */

select @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(icts_user) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(icts_user) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.user_init = d.user_init )
begin
   select @errmsg = '(icts_user) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (''' + i.user_init + ''')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end

/* RECORD_STAMP_END */

if update(user_init) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.user_init = d.user_init )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(icts_user) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'UPDATE',
       'IctsUser',
       'DIRECT',
       convert(varchar(40), i.user_init),
       null,
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
   insert dbo.aud_icts_user
      (user_init,
       user_last_name,
       user_first_name,
       desk_code,
       loc_code,
       user_logon_id,
       us_citizen_ind,
       user_job_title,
       user_status,
       user_employee_num,
       email_address,
       trans_id,
       resp_trans_id)
   select
      d.user_init,
      d.user_last_name,
      d.user_first_name,
      d.desk_code,
      d.loc_code,
      d.user_logon_id,
      d.us_citizen_ind,
      d.user_job_title,
      d.user_status,
      d.user_employee_num,
      d.email_address,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.user_init = i.user_init 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[icts_user] ADD CONSTRAINT [chk_icts_user_us_citizen_ind] CHECK (([us_citizen_ind]='N' OR [us_citizen_ind]='Y'))
GO
ALTER TABLE [dbo].[icts_user] ADD CONSTRAINT [icts_user_pk] PRIMARY KEY CLUSTERED  ([user_init]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [icts_user_idx1] ON [dbo].[icts_user] ([user_logon_id], [user_status]) INCLUDE ([user_init]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[icts_user] ADD CONSTRAINT [icts_user_fk1] FOREIGN KEY ([desk_code]) REFERENCES [dbo].[desk] ([desk_code])
GO
ALTER TABLE [dbo].[icts_user] ADD CONSTRAINT [icts_user_fk2] FOREIGN KEY ([loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[icts_user] ADD CONSTRAINT [icts_user_fk3] FOREIGN KEY ([user_job_title]) REFERENCES [dbo].[user_job_title] ([job_title])
GO
GRANT DELETE ON  [dbo].[icts_user] TO [admin_group]
GO
GRANT INSERT ON  [dbo].[icts_user] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[icts_user] TO [admin_group]
GO
GRANT UPDATE ON  [dbo].[icts_user] TO [admin_group]
GO
GRANT DELETE ON  [dbo].[icts_user] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[icts_user] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[icts_user] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[icts_user] TO [next_usr]
GO
