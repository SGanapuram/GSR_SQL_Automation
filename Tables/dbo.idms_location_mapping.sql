CREATE TABLE [dbo].[idms_location_mapping]
(
[idms_loc_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[idms_loc_initial] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[idms_board_name] [char] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[newsgrazer_loc_name] [char] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[idms_location_mapping_deltrg]
on [dbo].[idms_location_mapping]
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
   select @errmsg = '(idms_location_mapping) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_idms_location_mapping
   (idms_loc_code,
    idms_loc_initial,
    idms_board_name,
    newsgrazer_loc_name,
    trans_id,
    resp_trans_id)
select
   d.idms_loc_code,
   d.idms_loc_initial,
   d.idms_board_name,
   d.newsgrazer_loc_name,
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

create trigger [dbo].[idms_location_mapping_updtrg]
on [dbo].[idms_location_mapping]
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
   raiserror ('(idms_location_mapping) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(idms_location_mapping) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.idms_loc_code = d.idms_loc_code )
begin
   raiserror ('(idms_location_mapping) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(idms_loc_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.idms_loc_code = d.idms_loc_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(idms_location_mapping) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_idms_location_mapping
      (idms_loc_code,
       idms_loc_initial,
       idms_board_name,
       newsgrazer_loc_name,
       trans_id,
       resp_trans_id)
   select
      d.idms_loc_code,
      d.idms_loc_initial,
      d.idms_board_name,
      d.newsgrazer_loc_name,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.idms_loc_code = i.idms_loc_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[idms_location_mapping] ADD CONSTRAINT [idms_location_mapping_pk] PRIMARY KEY CLUSTERED  ([idms_loc_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[idms_location_mapping] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[idms_location_mapping] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[idms_location_mapping] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[idms_location_mapping] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'idms_location_mapping', NULL, NULL
GO
