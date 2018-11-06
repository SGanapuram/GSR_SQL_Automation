CREATE TABLE [dbo].[cost_center]
(
[cost_center_code] [char] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_center_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[company_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_send_id] [smallint] NULL,
[cost_center_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__cost_cent__cost___075714DC] DEFAULT ('A'),
[trans_id] [int] NOT NULL,
[profit_center] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[order_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cost_center_deltrg]
on [dbo].[cost_center]
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
   select @errmsg = '(cost_center) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_cost_center
   (cost_center_code,
    cost_center_desc,
    company_code,
    cost_center_status,
    profit_center,
    order_type,
    trans_id,
    resp_trans_id)
select
   d.cost_center_code,
   d.cost_center_desc,
   d.company_code,
   d.cost_center_status,
   d.profit_center,
   d.order_type,
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

create trigger [dbo].[cost_center_updtrg]
on [dbo].[cost_center]
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
   raiserror ('(cost_center) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(cost_center) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.cost_center_code = d.cost_center_code )
begin
   raiserror ('(cost_center) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(cost_center_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.cost_center_code = d.cost_center_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(cost_center) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_cost_center
      (cost_center_code,
       cost_center_desc,
       company_code,
       cost_center_status,
       profit_center,
       order_type,
       trans_id,
       resp_trans_id)
   select
      d.cost_center_code,
      d.cost_center_desc,
      d.company_code,
      d.cost_center_status,
      d.profit_center,
      d.order_type,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.cost_center_code = i.cost_center_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[cost_center] ADD CONSTRAINT [CK__cost_cent__cost___084B3915] CHECK (([cost_center_status]='I' OR [cost_center_status]='A'))
GO
ALTER TABLE [dbo].[cost_center] ADD CONSTRAINT [cost_center_pk] PRIMARY KEY CLUSTERED  ([cost_center_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cost_center_idx2] ON [dbo].[cost_center] ([company_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cost_center] ADD CONSTRAINT [cost_center_fk1] FOREIGN KEY ([company_code]) REFERENCES [dbo].[company_code_list] ([company_code])
GO
GRANT DELETE ON  [dbo].[cost_center] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cost_center] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cost_center] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cost_center] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'cost_center', NULL, NULL
GO
