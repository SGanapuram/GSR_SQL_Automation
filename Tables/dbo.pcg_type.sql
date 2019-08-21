CREATE TABLE [dbo].[pcg_type]
(
[pcg_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pcg_type_short_name] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pcg_type_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[pcg_type_deltrg]
on [dbo].[pcg_type]
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
   select @errmsg = '(pcg_type) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_pcg_type
(  
   pcg_type_code,
   pcg_type_short_name,
   pcg_type_desc,
   trans_id,
   resp_trans_id
)
select
   d.pcg_type_code,
   d.pcg_type_short_name,
   d.pcg_type_desc,
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

create trigger [dbo].[pcg_type_updtrg]
on [dbo].[pcg_type]
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
   raiserror ('(pcg_type) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(pcg_type) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.pcg_type_code = d.pcg_type_code)
begin
   select @errmsg = '(pcg_type) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.pcg_type_code) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end

/* RECORD_STAMP_END */

if update(pcg_type_code)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.pcg_type_code = d.pcg_type_code)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(pcg_type) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_pcg_type
      (pcg_type_code,
       pcg_type_short_name,
       pcg_type_desc,
       trans_id,
       resp_trans_id)
   select
      d.pcg_type_code,
      d.pcg_type_short_name,
      d.pcg_type_desc,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.pcg_type_code = i.pcg_type_code 

return
GO
ALTER TABLE [dbo].[pcg_type] ADD CONSTRAINT [pcg_type_pk] PRIMARY KEY CLUSTERED  ([pcg_type_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pcg_type] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[pcg_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[pcg_type] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[pcg_type] TO [next_usr]
GO
