CREATE TABLE [dbo].[pipeline_cycle]
(
[pipeline_cycle_num] [int] NOT NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[timing_cycle_num] [smallint] NOT NULL,
[split_cycle_opt] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[timing_cycle_mth] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cycle_start_date] [datetime] NOT NULL,
[cycle_end_date] [datetime] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[pipeline_cycle_deltrg]
on [dbo].[pipeline_cycle]
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
   select @errmsg = '(pipeline_cycle) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_pipeline_cycle
   (pipeline_cycle_num,
    mot_code,
    timing_cycle_num,
    split_cycle_opt,
    timing_cycle_mth,
    cmdty_code,
    cycle_start_date,
    cycle_end_date,
    trans_id,
    resp_trans_id)
select
   d.pipeline_cycle_num,
   d.mot_code,
   d.timing_cycle_num,
   d.split_cycle_opt,
   d.timing_cycle_mth,
   d.cmdty_code,
   d.cycle_start_date,
   d.cycle_end_date,
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

create trigger [dbo].[pipeline_cycle_updtrg]
on [dbo].[pipeline_cycle]
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
   raiserror ('(pipeline_cycle) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(pipeline_cycle) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.pipeline_cycle_num = d.pipeline_cycle_num )
begin
   raiserror ('(pipeline_cycle) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(pipeline_cycle_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.pipeline_cycle_num = d.pipeline_cycle_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(pipeline_cycle) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_pipeline_cycle
      (pipeline_cycle_num,
       mot_code,
       timing_cycle_num,
       split_cycle_opt,
       timing_cycle_mth,
       cmdty_code,
       cycle_start_date,
       cycle_end_date,
       trans_id,
       resp_trans_id)
   select
      d.pipeline_cycle_num,
      d.mot_code,
      d.timing_cycle_num,
      d.split_cycle_opt,
      d.timing_cycle_mth,
      d.cmdty_code,
      d.cycle_start_date,
      d.cycle_end_date,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.pipeline_cycle_num = i.pipeline_cycle_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[pipeline_cycle] ADD CONSTRAINT [pipeline_cycle_pk] PRIMARY KEY CLUSTERED  ([pipeline_cycle_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pipeline_cycle] ADD CONSTRAINT [pipeline_cycle_fk1] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[pipeline_cycle] ADD CONSTRAINT [pipeline_cycle_fk2] FOREIGN KEY ([mot_code]) REFERENCES [dbo].[mot] ([mot_code])
GO
GRANT DELETE ON  [dbo].[pipeline_cycle] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[pipeline_cycle] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[pipeline_cycle] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[pipeline_cycle] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'pipeline_cycle', NULL, NULL
GO
