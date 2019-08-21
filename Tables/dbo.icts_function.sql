CREATE TABLE [dbo].[icts_function]
(
[function_num] [int] NOT NULL,
[app_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[function_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[icts_function_deltrg]
on [dbo].[icts_function]
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
   select @errmsg = '(icts_function) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_icts_function
   (function_num,
    app_name,
    function_name,
    trans_id,
    resp_trans_id)
select
   d.function_num,
   d.app_name,
   d.function_name,
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

create trigger [dbo].[icts_function_instrg]
on [dbo].[icts_function]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* The functions #20000 ..#30000 are reserved for dynamically 
   assigned function_num for the security objects so that records 
   can be setup in the user_permission table to control whether a 
   used can edit the data in PORTFOLIO TAG structure.

   These functions in icts_function table may look like:
      function_num app_name             function_name
      ------------ -------------------- ---------------------------
             20001 PortfolioManager     PORT_TAG_MODIFY_CLASS
             20002 PortfolioManager     PORT_TAG_MODIFY_DEPT
             20003 PortfolioManager     PORT_TAG_MODIFY_DESK
             20004 PortfolioManager     PORT_TAG_MODIFY_DIVISION
             20005 PortfolioManager     PORT_TAG_MODIFY_GROUP
             20006 PortfolioManager     PORT_TAG_MODIFY_LEGALENT
             20007 PortfolioManager     PORT_TAG_MODIFY_LOCATION
             20008 PortfolioManager     PORT_TAG_MODIFY_PRFTCNTR
             20009 PortfolioManager     PORT_TAG_MODIFY_STRATEGY
             20010 PortfolioManager     PORT_TAG_MODIFY_TRADER
*/

if exists (select 1
           from inserted
           where function_name not like 'PORT_TAG_MODIFY_%' and
                 function_num between 20000 and 30000)
begin
   raiserror ('(icts_function) The func_nums between 20000 and 30000 are reserved for PORTFOLIO TAG.',16,1)
   if @@trancount > 0 rollback tran

   return
end

if exists (select 1
           from inserted
           where app_name not in (select app_name from dbo.application))
begin
   raiserror ('(icts_function) The app_name does not exist in the application table.',16,1)
   if @@trancount > 0 rollback tran

   return
end

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[icts_function_updtrg]
on [dbo].[icts_function]
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
   raiserror ('(icts_function) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(icts_function) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.function_num = d.function_num )
begin
   select @errmsg = '(icts_function) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.function_num) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end

/* RECORD_STAMP_END */

if update(function_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.function_num = d.function_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(icts_function) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* The functions #20000 ..#30000 are reserved for dynamically 
   assigned function_num for the security objects so that records 
   can be setup in the user_permission table to control whether a 
   used can edit the data in PORTFOLIO TAG structure.

   These functions in icts_function table may look like:
      function_num app_name             function_name
      ------------ -------------------- ---------------------------
             20001 PortfolioManager     PORT_TAG_MODIFY_CLASS
             20002 PortfolioManager     PORT_TAG_MODIFY_DEPT
             20003 PortfolioManager     PORT_TAG_MODIFY_DESK
             20004 PortfolioManager     PORT_TAG_MODIFY_DIVISION
             20005 PortfolioManager     PORT_TAG_MODIFY_GROUP
             20006 PortfolioManager     PORT_TAG_MODIFY_LEGALENT
             20007 PortfolioManager     PORT_TAG_MODIFY_LOCATION
             20008 PortfolioManager     PORT_TAG_MODIFY_PRFTCNTR
             20009 PortfolioManager     PORT_TAG_MODIFY_STRATEGY
             20010 PortfolioManager     PORT_TAG_MODIFY_TRADER
*/

if exists (select 1
           from inserted
           where function_name not like 'PORT_TAG_MODIFY_%' and
                 function_num between 20000 and 30000)
begin
   raiserror ('(icts_function) The func_nums between 20000 and 30000 are reserved for PORTFOLIO TAG.',16,1)
   if @@trancount > 0 rollback tran

   return
end

if exists (select 1
           from inserted
           where app_name not in (select app_name from dbo.application))
begin
   raiserror ('(icts_function) The app_name does not exist in the application table.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_icts_function
      (function_num,
       app_name,
       function_name,
       trans_id,
       resp_trans_id)
   select
      d.function_num,
      d.app_name,
      d.function_name,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.function_num = i.function_num 

/* AUDIT_CODE_END */
return
GO
ALTER TABLE [dbo].[icts_function] ADD CONSTRAINT [icts_function_pk] PRIMARY KEY NONCLUSTERED  ([function_num]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [icts_function] ON [dbo].[icts_function] ([app_name], [function_name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[icts_function] ADD CONSTRAINT [icts_function_fk1] FOREIGN KEY ([app_name]) REFERENCES [dbo].[application] ([app_name])
GO
GRANT DELETE ON  [dbo].[icts_function] TO [admin_group]
GO
GRANT INSERT ON  [dbo].[icts_function] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[icts_function] TO [admin_group]
GO
GRANT UPDATE ON  [dbo].[icts_function] TO [admin_group]
GO
GRANT DELETE ON  [dbo].[icts_function] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[icts_function] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[icts_function] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[icts_function] TO [next_usr]
GO
