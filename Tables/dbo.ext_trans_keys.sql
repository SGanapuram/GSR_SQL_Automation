CREATE TABLE [dbo].[ext_trans_keys]
(
[oid] [int] NOT NULL,
[int_key_value] [int] NULL,
[str_key_value] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dt_key_value] [datetime] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ext_trans_keys_deltrg]
on [dbo].[ext_trans_keys]
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
   select @errmsg = '(ext_trans_keys) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_ext_trans_keys
(  
   oid,
   int_key_value,
   str_key_value,
   dt_key_value,
   trans_id,
   resp_trans_id
)
select
   d.oid,
   d.int_key_value,
   d.str_key_value,
   d.dt_key_value,
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

create trigger [dbo].[ext_trans_keys_updtrg]
on [dbo].[ext_trans_keys]
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
   raiserror ('(ext_trans_keys) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(ext_trans_keys) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   select @errmsg = '(ext_trans_keys) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.oid) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(oid)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(ext_trans_keys) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_ext_trans_keys
 	    (oid,
       int_key_value,
       str_key_value,
       dt_key_value,
       trans_id,
       resp_trans_id)
   select
 	    d.oid,
      d.int_key_value,
      d.str_key_value,
      d.dt_key_value,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

return
GO
ALTER TABLE [dbo].[ext_trans_keys] ADD CONSTRAINT [ext_trans_keys_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ext_trans_keys] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[ext_trans_keys] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[ext_trans_keys] TO [ictspurge]
GO
GRANT DELETE ON  [dbo].[ext_trans_keys] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ext_trans_keys] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ext_trans_keys] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ext_trans_keys] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'ext_trans_keys', NULL, NULL
GO
