CREATE TABLE [dbo].[facility_commodity]
(
[facility_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[capacity] [decimal] (20, 8) NULL,
[capacity_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[facility_commodity_deltrg]
on [dbo].[facility_commodity]
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
   select @errmsg = '(facility_commodity) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_facility_commodity
(  
   facility_code,
   cmdty_code,
   capacity,
   capacity_uom_code,
   trans_id,
   resp_trans_id
)
select
   d.facility_code,
   d.cmdty_code,
   d.capacity,
   d.capacity_uom_code,
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

create trigger [dbo].[facility_commodity_updtrg]
on [dbo].[facility_commodity]
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
   raiserror ('(facility_commodity) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(facility_commodity) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.facility_code = d.facility_code and
                 i.cmdty_code = d.cmdty_code)
begin
   select @errmsg = '(facility_commodity) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (''' + i.facility_code + ''', ''' + i.cmdty_code + ''')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end

/* RECORD_STAMP_END */

if update(facility_code) or
   update(cmdty_code)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.facility_code = d.facility_code and
                                   i.cmdty_code = d.cmdty_code)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(facility_commodity) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_facility_commodity
 	    (facility_code,
       cmdty_code,
       capacity,
       capacity_uom_code,
       trans_id,
       resp_trans_id)
   select
 	    d.facility_code,
      d.cmdty_code,
      d.capacity,
      d.capacity_uom_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.facility_code = i.facility_code and
         d.cmdty_code = i.cmdty_code

return
GO
ALTER TABLE [dbo].[facility_commodity] ADD CONSTRAINT [facility_commodity_pk] PRIMARY KEY CLUSTERED  ([facility_code], [cmdty_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[facility_commodity] ADD CONSTRAINT [facility_commodity_fk2] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[facility_commodity] ADD CONSTRAINT [facility_commodity_fk3] FOREIGN KEY ([capacity_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[facility_commodity] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[facility_commodity] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[facility_commodity] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[facility_commodity] TO [next_usr]
GO
