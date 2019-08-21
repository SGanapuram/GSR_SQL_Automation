CREATE TABLE [dbo].[inv_build_draw_spec]
(
[inv_num] [int] NOT NULL,
[inv_b_d_num] [int] NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_actual_value] [float] NULL,
[spec_actual_value_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[inv_build_draw_spec_deltrg]
on [dbo].[inv_build_draw_spec]
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
   select @errmsg = '(inv_build_draw_spec) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_inv_build_draw_spec
   (inv_num,
    inv_b_d_num,
    spec_code,
    spec_actual_value,
    spec_actual_value_text,
    trans_id,
    resp_trans_id)
select
   d.inv_num,
   d.inv_b_d_num,
   d.spec_code,
   d.spec_actual_value,
   d.spec_actual_value_text,
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

create trigger [dbo].[inv_build_draw_spec_updtrg]
on [dbo].[inv_build_draw_spec]
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
   raiserror ('(inv_build_draw_spec) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(inv_build_draw_spec) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.inv_num = d.inv_num  and i.inv_b_d_num = d.inv_b_d_num  and i.spec_code = d.spec_code )
begin
   raiserror ('(inv_build_draw_spec) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(inv_num) or  
   update(inv_b_d_num) or  
   update(spec_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.inv_num = d.inv_num and 
                                   i.inv_b_d_num = d.inv_b_d_num and 
                                   i.spec_code = d.spec_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(inv_build_draw_spec) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_inv_build_draw_spec
      (inv_num,
       inv_b_d_num,
       spec_code,
       spec_actual_value,
       spec_actual_value_text,
       trans_id,
       resp_trans_id)
   select
      d.inv_num,
      d.inv_b_d_num,
      d.spec_code,
      d.spec_actual_value,
      d.spec_actual_value_text,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.inv_num = i.inv_num and
         d.inv_b_d_num = i.inv_b_d_num and
         d.spec_code = i.spec_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[inv_build_draw_spec] ADD CONSTRAINT [inv_build_draw_spec_pk] PRIMARY KEY CLUSTERED  ([inv_num], [inv_b_d_num], [spec_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[inv_build_draw_spec] ADD CONSTRAINT [inv_build_draw_spec_fk2] FOREIGN KEY ([spec_code]) REFERENCES [dbo].[specification] ([spec_code])
GO
GRANT DELETE ON  [dbo].[inv_build_draw_spec] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[inv_build_draw_spec] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[inv_build_draw_spec] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[inv_build_draw_spec] TO [next_usr]
GO
