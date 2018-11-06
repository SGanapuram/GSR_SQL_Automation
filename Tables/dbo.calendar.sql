CREATE TABLE [dbo].[calendar]
(
[calendar_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[calendar_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[calendar_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[calendar_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[calendar_date_mask] [char] (7) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[calendar_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[calendar_deltrg]
on [dbo].[calendar]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   int

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
   select @errmsg = '(calendar) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   if @@trancount > 0 rollback tran

   return
end


insert dbo.aud_calendar
   (calendar_code,
    calendar_name,
    calendar_type,
    calendar_desc,
    calendar_date_mask,
    calendar_status,
    trans_id,
    resp_trans_id)
select
   d.calendar_code,
   d.calendar_name,
   d.calendar_type,
   d.calendar_desc,
   d.calendar_date_mask,
   d.calendar_status,
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

create trigger [dbo].[calendar_updtrg]
on [dbo].[calendar]
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
   raiserror ('(calendar) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(calendar) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.calendar_code = d.calendar_code )
begin
   raiserror ('(calendar) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(calendar_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.calendar_code = d.calendar_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(calendar) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_calendar
      (calendar_code,
       calendar_name,
       calendar_type,
       calendar_desc,
       calendar_date_mask,
       calendar_status,
       trans_id,
       resp_trans_id)
   select
      d.calendar_code,
      d.calendar_name,
      d.calendar_type,
      d.calendar_desc,
      d.calendar_date_mask,
      d.calendar_status,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.calendar_code = i.calendar_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[calendar] ADD CONSTRAINT [calendar_pk] PRIMARY KEY CLUSTERED  ([calendar_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[calendar] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[calendar] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[calendar] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[calendar] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'calendar', NULL, NULL
GO
