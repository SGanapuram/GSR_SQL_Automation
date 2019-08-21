CREATE TABLE [dbo].[commodity_location]
(
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[typical_gravity] [float] NULL,
[cmdty_delivered_scheduled] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_received_scheduled] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[commodity_location_deltrg]
on [dbo].[commodity_location]
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
   select @errmsg = '(commodity_location) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_commodity_location
   (cmdty_code,
    loc_code,
    typical_gravity,
    cmdty_delivered_scheduled,
    cmdty_received_scheduled,
    trans_id,
    resp_trans_id)
select
   d.cmdty_code,
   d.loc_code,
   d.typical_gravity,
   d.cmdty_delivered_scheduled,
   d.cmdty_received_scheduled,
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

create trigger [dbo].[commodity_location_updtrg]
on [dbo].[commodity_location]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errorNumber      int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(commodity_location) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(commodity_location) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.cmdty_code = d.cmdty_code and 
                 i.loc_code = d.loc_code )
begin
   raiserror ('(commodity_location) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(cmdty_code) or 
   update(loc_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.cmdty_code = d.cmdty_code and 
                                   i.loc_code = d.loc_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(commodity_location) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_commodity_location
      (cmdty_code,
       loc_code,
       typical_gravity,
       cmdty_delivered_scheduled,
       cmdty_received_scheduled,
       trans_id,
       resp_trans_id)
   select
      d.cmdty_code,
      d.loc_code,
      d.typical_gravity,
      d.cmdty_delivered_scheduled,
      d.cmdty_received_scheduled,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.cmdty_code = i.cmdty_code and
         d.loc_code = i.loc_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[commodity_location] ADD CONSTRAINT [commodity_location_pk] PRIMARY KEY CLUSTERED  ([cmdty_code], [loc_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commodity_location] ADD CONSTRAINT [commodity_location_fk1] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[commodity_location] ADD CONSTRAINT [commodity_location_fk2] FOREIGN KEY ([cmdty_delivered_scheduled]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[commodity_location] ADD CONSTRAINT [commodity_location_fk3] FOREIGN KEY ([cmdty_received_scheduled]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[commodity_location] ADD CONSTRAINT [commodity_location_fk4] FOREIGN KEY ([loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
GRANT DELETE ON  [dbo].[commodity_location] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[commodity_location] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[commodity_location] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[commodity_location] TO [next_usr]
GO
