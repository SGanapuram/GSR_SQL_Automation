CREATE TABLE [dbo].[generic_data_values]
(
[gdv_num] [int] NOT NULL,
[gdd_num] [int] NOT NULL,
[int_value] [int] NULL,
[double_value] [float] NULL,
[datetime_value] [datetime] NULL,
[string_value] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[generic_data_values_deltrg]
on [dbo].[generic_data_values]
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
   select @errmsg = '(generic_data_values) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_generic_data_values
   (gdv_num,
    gdd_num,
    int_value,
    double_value,
    datetime_value,
    string_value,
    trans_id,
    resp_trans_id)
select
   d.gdv_num,
   d.gdd_num,
   d.int_value,
   d.double_value,
   d.datetime_value,
   d.string_value,
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

create trigger [dbo].[generic_data_values_updtrg]
on [dbo].[generic_data_values]
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
   raiserror ('(generic_data_values) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(generic_data_values) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.gdv_num = d.gdv_num and 
                 i.gdd_num = d.gdd_num )
begin
   raiserror ('(generic_data_values) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(gdv_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.gdv_num = d.gdv_num and 
                                   i.gdd_num = d.gdd_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(generic_data_values) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_generic_data_values
      (gdv_num,
       gdd_num,
       int_value,
       double_value,
       datetime_value,
       string_value,
       trans_id,
       resp_trans_id)
   select
      d.gdv_num,
      d.gdd_num,
      d.int_value,
      d.double_value,
      d.datetime_value,
      d.string_value,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.gdv_num = i.gdv_num and
         d.gdd_num = i.gdd_num

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[generic_data_values] ADD CONSTRAINT [generic_data_values_pk] PRIMARY KEY CLUSTERED  ([gdv_num], [gdd_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[generic_data_values] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[generic_data_values] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[generic_data_values] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[generic_data_values] TO [next_usr]
GO
