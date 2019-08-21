CREATE TABLE [dbo].[state]
(
[state_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[state_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[state_num] [smallint] NOT NULL,
[calendar_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[state_deltrg]
on [dbo].[state]
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
   select @errmsg = '(state) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_state
   (state_code,
    state_name,
    state_num,
    calendar_code,
    trans_id,
    resp_trans_id)
select
   d.state_code,
   d.state_name,
   d.state_num,
   d.calendar_code,
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

create trigger [dbo].[state_updtrg]
on [dbo].[state]
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
   raiserror ('(state) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(state) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.state_code = d.state_code )
begin
   raiserror ('(state) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(state_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.state_code = d.state_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(state) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_state
      (state_code,
       state_name,
       state_num,
       calendar_code,
       trans_id,
       resp_trans_id)
   select
      d.state_code,
      d.state_name,
      d.state_num,
      d.calendar_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.state_code = i.state_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[state] ADD CONSTRAINT [state_pk] PRIMARY KEY CLUSTERED  ([state_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[state] ADD CONSTRAINT [state_fk1] FOREIGN KEY ([calendar_code]) REFERENCES [dbo].[calendar] ([calendar_code])
GO
GRANT DELETE ON  [dbo].[state] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[state] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[state] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[state] TO [next_usr]
GO
