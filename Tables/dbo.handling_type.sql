CREATE TABLE [dbo].[handling_type]
(
[handling_type_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[handling_type_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[handling_type_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__handling___handl__0A888742] DEFAULT ('A'),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[handling_type_deltrg]
on [dbo].[handling_type]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
        @atrans_id int

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
   select @errmsg = '(handling_type) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_handling_type
(  
   handling_type_code,
   handling_type_desc,
   handling_type_status,
   trans_id,
   resp_trans_id
)
select
   d.handling_type_code,
   d.handling_type_desc,
   d.handling_type_status,
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

create trigger [dbo].[handling_type_updtrg]
on [dbo].[handling_type]
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
   raiserror ('(handling_type) The change needs to be attached with a new trans_id',10,1)
   if @@trancount > 0 rollback tran

   return
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.handling_type_code = d.handling_type_code)
begin
   raiserror ('(handling_type) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(handling_type_code)
begin
   select @count_num_rows = (select count(*) 
                             from inserted i, deleted d
                             where i.handling_type_code = d.handling_type_code)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      select @errmsg = '(handling_type) primary key can not be changed.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_handling_type
   (
      handling_type_code,
      handling_type_desc,
      handling_type_status,
      trans_id,
      resp_trans_id
   )
   select
      d.handling_type_code,
      d.handling_type_desc,
      d.handling_type_status,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.handling_type_code = i.handling_type_code

/* AUDIT_CODE_END */  
return
GO
ALTER TABLE [dbo].[handling_type] ADD CONSTRAINT [CK__handling___handl__0B7CAB7B] CHECK (([handling_type_status]='I' OR [handling_type_status]='A'))
GO
ALTER TABLE [dbo].[handling_type] ADD CONSTRAINT [handling_type_pk] PRIMARY KEY CLUSTERED  ([handling_type_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[handling_type] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[handling_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[handling_type] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[handling_type] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'handling_type', NULL, NULL
GO
