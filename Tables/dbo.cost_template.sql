CREATE TABLE [dbo].[cost_template]
(
[oid] [int] NOT NULL,
[template_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[template_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_date] [datetime] NOT NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[discharge_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_num] [int] NULL,
[segment_oid] [int] NULL,
[trans_id] [int] NOT NULL,
[facility_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tank_num] [int] NULL,
[trade_item_p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cost_template_deltrg]
on [dbo].[cost_template]
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
   select @errmsg = '(cost_template) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_cost_template
(
   oid,
   template_code,
   template_name,
   creation_date,
   mot_code,
   load_loc_code,
   discharge_loc_code,
   del_term_code,
   acct_num,
   segment_oid,
   facility_code,
   tank_num,
   trade_item_p_s_ind, 
   trans_id,
   resp_trans_id
)
select
   d.oid,
   d.template_code,
   d.template_name,
   d.creation_date,
   d.mot_code,
   d.load_loc_code,
   d.discharge_loc_code,
   d.del_term_code,
   d.acct_num,
   d.segment_oid,
   d.facility_code,
   d.tank_num,
   d.trade_item_p_s_ind, 
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
create trigger [dbo].[cost_template_updtrg]
on [dbo].[cost_template]
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
   raiserror ('(cost_template) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(cost_template) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid )
begin
   raiserror ('(cost_template) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(oid) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(cost_template) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_cost_template
   (
      oid,
      template_code,
      template_name,
      creation_date,
      mot_code,
      load_loc_code,
      discharge_loc_code,
      del_term_code,
      acct_num,
      segment_oid,
      facility_code,
      tank_num,
      trade_item_p_s_ind, 
      trans_id,
      resp_trans_id
   )
   select 
      d.oid,
      d.template_code,
      d.template_name,
      d.creation_date,
      d.mot_code,
      d.load_loc_code,
      d.discharge_loc_code,
      d.del_term_code,
      d.acct_num,
      d.segment_oid,
      d.facility_code,
      d.tank_num,
      d.trade_item_p_s_ind, 
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[cost_template] ADD CONSTRAINT [cost_template_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cost_template] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cost_template] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cost_template] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cost_template] TO [next_usr]
GO
