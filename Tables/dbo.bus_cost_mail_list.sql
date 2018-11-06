CREATE TABLE [dbo].[bus_cost_mail_list]
(
[bc_mail_list_num] [int] NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_mail_login_name] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_mail_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_mail_time_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_mail_criteria_time_code] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_type_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[bus_cost_mail_list_updtrg]
on [dbo].[bus_cost_mail_list]
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
   raiserror ('(bus_cost_mail_list) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(bus_cost_mail_list) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.bc_mail_list_num = d.bc_mail_list_num )
begin
   raiserror ('(bus_cost_mail_list) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(bc_mail_list_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.bc_mail_list_num = d.bc_mail_list_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(bus_cost_mail_list) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[bus_cost_mail_list] ADD CONSTRAINT [bus_cost_mail_list_pk] PRIMARY KEY CLUSTERED  ([bc_mail_list_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[bus_cost_mail_list] ADD CONSTRAINT [bus_cost_mail_list_fk1] FOREIGN KEY ([bc_mail_criteria_time_code]) REFERENCES [dbo].[bc_mail_criteria_time] ([bc_mail_criteria_time_code])
GO
ALTER TABLE [dbo].[bus_cost_mail_list] ADD CONSTRAINT [bus_cost_mail_list_fk2] FOREIGN KEY ([bc_mail_code]) REFERENCES [dbo].[bus_cost_mail] ([bc_mail_code])
GO
ALTER TABLE [dbo].[bus_cost_mail_list] ADD CONSTRAINT [bus_cost_mail_list_fk3] FOREIGN KEY ([bc_mail_time_code]) REFERENCES [dbo].[bus_cost_mail_time] ([bc_mail_time_code])
GO
ALTER TABLE [dbo].[bus_cost_mail_list] ADD CONSTRAINT [bus_cost_mail_list_fk4] FOREIGN KEY ([user_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[bus_cost_mail_list] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[bus_cost_mail_list] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[bus_cost_mail_list] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[bus_cost_mail_list] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'bus_cost_mail_list', NULL, NULL
GO
