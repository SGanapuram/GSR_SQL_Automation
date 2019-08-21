CREATE TABLE [dbo].[location]
(
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[office_loc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[del_loc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[inv_loc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_num] [smallint] NOT NULL,
[loc_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[latitude] [numeric] (9, 6) NULL,
[longitude] [numeric] (9, 6) NULL,
[warehouse_agp_num] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[location_deltrg]
on [dbo].[location]
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
   select @errmsg = '(location) Failed to obtain a valid responsible trans_id.'
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


/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'DELETE',
       'Location',
       'DIRECT',
       convert(varchar(40), d.loc_code),
       null,
       null,
       null,
       null,
       null,
       null,
       null,
       @atrans_id,
       it.sequence
from deleted d, dbo.icts_transaction it
where it.trans_id = @atrans_id and
      it.type != 'E'
 
/* END_TRANSACTION_TOUCH */


/* AUDIT_CODE_BEGIN */

insert dbo.aud_location
   (loc_code,
    loc_name,
    office_loc_ind,
    del_loc_ind,
    inv_loc_ind,
    loc_num,
    loc_status,    
    latitude,
    longitude,
    warehouse_agp_num,
    trans_id,
    resp_trans_id)
select
   d.loc_code,
   d.loc_name,
   d.office_loc_ind,
   d.del_loc_ind,
   d.inv_loc_ind,
   d.loc_num,
   d.loc_status,
   d.latitude,
   d.longitude,   
   d.warehouse_agp_num,
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

create trigger [dbo].[location_instrg]
on [dbo].[location]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

   /* BEGIN_TRANSACTION_TOUCH */
 
   insert dbo.transaction_touch
   select 'INSERT',
          'Location',
          'DIRECT',
          convert(varchar(40), i.loc_code),
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          i.trans_id,
          it.sequence
   from inserted i, dbo.icts_transaction it
   where i.trans_id = it.trans_id and
         it.type != 'E'
 
   /* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[location_updtrg]
on [dbo].[location]
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
   raiserror ('(location) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(location) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.loc_code = d.loc_code )
begin
   raiserror ('(location) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(loc_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.loc_code = d.loc_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(location) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'UPDATE',
       'Location',
       'DIRECT',
       convert(varchar(40), i.loc_code),
       null,
       null,
       null,
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from inserted i, dbo.icts_transaction it
where i.trans_id = it.trans_id and
      it.type != 'E'
 
/* END_TRANSACTION_TOUCH */


/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_location
      (loc_code,
       loc_name,
       office_loc_ind,
       del_loc_ind,
       inv_loc_ind,
       loc_num,
       loc_status,       
       latitude,
       longitude,
       warehouse_agp_num,
       trans_id,
       resp_trans_id)
   select
      d.loc_code,
      d.loc_name,
      d.office_loc_ind,
      d.del_loc_ind,
      d.inv_loc_ind,
      d.loc_num,
      d.loc_status,
      d.latitude,
      d.longitude,
      d.warehouse_agp_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.loc_code = i.loc_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[location] ADD CONSTRAINT [location_pk] PRIMARY KEY CLUSTERED  ([loc_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [loc_name_idx] ON [dbo].[location] ([loc_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[location] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[location] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[location] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[location] TO [next_usr]
GO
