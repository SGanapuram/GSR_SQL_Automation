CREATE TABLE [dbo].[path_segment]
(
[path_oid] [int] NOT NULL,
[segment_oid] [int] NOT NULL,
[path_sequence] [int] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[path_segment_deltrg]
on [dbo].[path_segment]
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
   select @errmsg = '(path_segment) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_path_segment
(  
   path_oid,
   segment_oid,
   path_sequence,
   trans_id,
   resp_trans_id
)
select
   d.path_oid,
   d.segment_oid,
   d.path_sequence,
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

create trigger [dbo].[path_segment_updtrg]
on [dbo].[path_segment]
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
   raiserror ('(path_segment) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(path_segment) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.path_oid = d.path_oid and
                 i.segment_oid = d.segment_oid)
begin
   select @errmsg = '(path_segment) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.path_oid) + ',' + convert(varchar, i.segment_oid) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(path_oid) or
   update(segment_oid)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.path_oid = d.path_oid and
                                   i.segment_oid = d.segment_oid)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(path_segment) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_path_segment
 	    (path_oid,
       segment_oid,
       path_sequence,
       trans_id,
       resp_trans_id)
   select
 	    d.path_oid,
      d.segment_oid,
      d.path_sequence,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.path_oid = i.path_oid and
         d.segment_oid = i.segment_oid 

return
GO
ALTER TABLE [dbo].[path_segment] ADD CONSTRAINT [path_segment_pk] PRIMARY KEY CLUSTERED  ([path_oid], [segment_oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[path_segment] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[path_segment] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[path_segment] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[path_segment] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'path_segment', NULL, NULL
GO
