CREATE TABLE [dbo].[assay_activity]
(
[activity_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[description] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
create trigger [dbo].[assay_activity_deltrg]
on [dbo].[assay_activity]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   int
 
set @num_rows = @@rowcount
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
   set @errmsg = '(assay_activity) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      set @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror(@errmsg, 16, 1)
   if @@trancount > 0 rollback tran
 
   return
end

insert into dbo.aud_assay_activity
   (
	 activity_code,
	 description,
	 trans_id,
	 resp_trans_id
   )
select 
   d.activity_code,
   d.description,
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
 
create trigger [dbo].[assay_activity_updtrg]
on [dbo].[assay_activity]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errmsg           varchar(255)
 
set @num_rows = @@rowcount
if @num_rows = 0
   return
 
set @dummy_update = 0
 
/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror('(assay_activity) The change needs to be attached with a new trans_id',16,1)
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
      set @errmsg = '(assay_activity) New trans_id must be larger than original trans_id.'
      set @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror(@errmsg, 16, 1)
      if @@trancount > 0 rollback tran
 
      return
   end
end
 
if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.activity_code = d.activity_code)
begin
   raiserror('(assay_activity) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran
 
   return
end
 
/* RECORD_STAMP_END */
 
if update(activity_code) 
begin
   set @count_num_rows = (select count(*) from inserted i, deleted d
                          where i.activity_code = d.activity_code)
   if (@count_num_rows = @num_rows)
      set @dummy_update = 1
   else
   begin
      raiserror('(assay_activity) primary key can not be changed.', 16, 1)
      if @@trancount > 0 rollback tran
 
      return
   end
end
 
/* AUDIT_CODE_BEGIN */
 
if @dummy_update = 0
   insert into aud_assay_activity
      (
	   activity_code,
	   description,	
	   trans_id,	
	   resp_trans_id
      )
   select 
      d.activity_code,
      d.description,	
      d.trans_id,	
      i.trans_id	
   from deleted d, inserted i
   where d.activity_code = i.activity_code

/* AUDIT_CODE_END */
 
return
GO
ALTER TABLE [dbo].[assay_activity] ADD CONSTRAINT [assay_activity_pk] PRIMARY KEY CLUSTERED  ([activity_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[assay_activity] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[assay_activity] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[assay_activity] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[assay_activity] TO [next_usr]
GO
