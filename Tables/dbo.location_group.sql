CREATE TABLE [dbo].[location_group]
(
[parent_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[virtual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[location_group_deltrg]
on [dbo].[location_group]
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
   select @errmsg = '(location_group) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_location_group
   (parent_loc_code,
    loc_code,
    loc_type_code,
    virtual_ind,
    trans_id,
    resp_trans_id)
select
   d.parent_loc_code,
   d.loc_code,
   d.loc_type_code,
   d.virtual_ind,
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

create trigger [dbo].[location_group_updtrg]
on [dbo].[location_group]
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
   raiserror ('(location_group) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(location_group) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.parent_loc_code = d.parent_loc_code and 
                 i.loc_code = d.loc_code and 
                 i.loc_type_code = d.loc_type_code )
begin
   raiserror ('(location_group) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(parent_loc_code) or 
   update(loc_code) or  
   update(loc_type_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.parent_loc_code = d.parent_loc_code and 
                                   i.loc_code = d.loc_code and 
                                   i.loc_type_code = d.loc_type_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(location_group) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_location_group
      (parent_loc_code,
       loc_code,
       loc_type_code,
       virtual_ind,
       trans_id,
       resp_trans_id)
   select
      d.parent_loc_code,
      d.loc_code,
      d.loc_type_code,
      d.virtual_ind,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.parent_loc_code = i.parent_loc_code and
         d.loc_code = i.loc_code and
         d.loc_type_code = i.loc_type_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[location_group] ADD CONSTRAINT [location_group_pk] PRIMARY KEY CLUSTERED  ([parent_loc_code], [loc_code], [loc_type_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[location_group] ADD CONSTRAINT [location_group_fk1] FOREIGN KEY ([parent_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[location_group] ADD CONSTRAINT [location_group_fk2] FOREIGN KEY ([loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[location_group] ADD CONSTRAINT [location_group_fk3] FOREIGN KEY ([loc_type_code]) REFERENCES [dbo].[location_type] ([loc_type_code])
GO
GRANT DELETE ON  [dbo].[location_group] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[location_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[location_group] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[location_group] TO [next_usr]
GO
