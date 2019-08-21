CREATE TABLE [dbo].[cost_interface_info]
(
[cost_num] [int] NOT NULL,
[aot_status] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[aot_status_mod_date] [datetime] NULL,
[aot_status_mod_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tax_rate] [float] NULL,
[trans_id] [int] NOT NULL,
[sent_on_date] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cost_interface_info_deltrg]
on [dbo].[cost_interface_info]
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
   select @errmsg = '(cost_interface_info) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_cost_interface_info
   (cost_num,
    aot_status,          
    aot_status_mod_date,	   
    aot_status_mod_init,	    
    tax_rate,	
    sent_on_date,   
    trans_id,
    resp_trans_id)
select
   d.cost_num,
   d.aot_status,          
   d.aot_status_mod_date,	   
   d.aot_status_mod_init,	    
   d.tax_rate,	   
   d.sent_on_date,   
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'CostInterfaceInfo',
       'DIRECT',
       convert(varchar(40), d.cost_num),
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

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cost_interface_info_instrg]
on [dbo].[cost_interface_info]
for insert
as
declare @num_rows        int,
        @count_num_rows  int,
        @errmsg          varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

   /* BEGIN_TRANSACTION_TOUCH */

   insert dbo.transaction_touch
   select 'INSERT',
          'CostInterfaceInfo',
          'DIRECT',
          convert(varchar(40), i.cost_num),
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

create trigger [dbo].[cost_interface_info_updtrg]
on [dbo].[cost_interface_info]
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
   raiserror ('(cost_interface_info) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(cost_interface_info) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.cost_num = d.cost_num )
begin
   raiserror ('(cost_interface_info) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(cost_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.cost_num = d.cost_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(cost_interface_info) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
 end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_cost_interface_info
      (cost_num,
       aot_status,          
       aot_status_mod_date,	   
       aot_status_mod_init,	    
       tax_rate,
       sent_on_date,	   
       trans_id,
       resp_trans_id)
   select
      d.cost_num,
      d.aot_status,          
      d.aot_status_mod_date,	   
      d.aot_status_mod_init,	    
      d.tax_rate,	   
      d.sent_on_date,	   
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.cost_num = i.cost_num 

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'CostInterfaceInfo',
       'DIRECT',
       convert(varchar(40), i.cost_num),
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
ALTER TABLE [dbo].[cost_interface_info] ADD CONSTRAINT [cost_interface_info_pk] PRIMARY KEY CLUSTERED  ([cost_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cost_interface_info] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cost_interface_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cost_interface_info] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cost_interface_info] TO [next_usr]
GO
