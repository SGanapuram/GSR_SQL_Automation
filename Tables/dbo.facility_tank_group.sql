CREATE TABLE [dbo].[facility_tank_group]
(
[facility_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tank_num] [int] NOT NULL,
[connected_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__facility___conne__695C9DA1] DEFAULT ('N'),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[facility_tank_group_deltrg]
on [dbo].[facility_tank_group]
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
   select @errmsg = '(facility_tank_group) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_facility_tank_group
(  
   facility_code,
   tank_num,
   connected_ind,
   trans_id,
   resp_trans_id
)
select
   d.facility_code,
   d.tank_num,
   d.connected_ind,
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

create trigger [dbo].[facility_tank_group_updtrg]
on [dbo].[facility_tank_group]
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
   raiserror ('(facility_tank_group) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(facility_tank_group) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.facility_code = d.facility_code and
                 i.tank_num = d.tank_num)
begin
   select @errmsg = '(facility_tank_group) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (''' + convert(varchar, i.facility_code) + ''', ' +
                         convert(varchar, i.tank_num) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(facility_code) or
   update(tank_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.facility_code = d.facility_code and
                                   i.tank_num = d.tank_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(facility_tank_group) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_facility_tank_group
 	    (facility_code,
       tank_num,
       connected_ind,
       trans_id,
       resp_trans_id)
   select
      d.facility_code,
      d.tank_num,
      d.connected_ind,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.facility_code = i.facility_code and
         d.tank_num = i.tank_num 

return
GO
ALTER TABLE [dbo].[facility_tank_group] ADD CONSTRAINT [CK__facility___conne__6A50C1DA] CHECK (([connected_ind]='N' OR [connected_ind]='Y'))
GO
ALTER TABLE [dbo].[facility_tank_group] ADD CONSTRAINT [facility_tank_group_pk] PRIMARY KEY CLUSTERED  ([facility_code], [tank_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[facility_tank_group] ADD CONSTRAINT [facility_tank_group_fk1] FOREIGN KEY ([facility_code]) REFERENCES [dbo].[facility] ([facility_code])
GO
ALTER TABLE [dbo].[facility_tank_group] ADD CONSTRAINT [facility_tank_group_fk2] FOREIGN KEY ([tank_num]) REFERENCES [dbo].[location_tank_info] ([tank_num])
GO
GRANT DELETE ON  [dbo].[facility_tank_group] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[facility_tank_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[facility_tank_group] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[facility_tank_group] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'facility_tank_group', NULL, NULL
GO
