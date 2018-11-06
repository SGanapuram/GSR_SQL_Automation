CREATE TABLE [dbo].[live_scenario_item]
(
[oid] [int] NOT NULL,
[live_scenario_id] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[alloc_num] [int] NULL,
[alloc_item_num] [smallint] NULL,
[sub_alloc_num] [smallint] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[live_scenario_item_deltrg]
on [dbo].[live_scenario_item]
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
   select @errmsg = '(live_scenario_item) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_live_scenario_item
(  
 	 oid,
   live_scenario_id,
   trade_num, 
   order_num, 
   item_num, 
   alloc_num, 
   alloc_item_num, 
   sub_alloc_num,  
   trans_id,
   resp_trans_id
)
select
 	 d.oid,
   d.live_scenario_id,
   d.trade_num, 
   d.order_num, 
   d.item_num, 
   d.alloc_num, 
   d.alloc_item_num, 
   d.sub_alloc_num,  
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

create trigger [dbo].[live_scenario_item_updtrg]
on [dbo].[live_scenario_item]
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
   raiserror ('(live_scenario_item) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(live_scenario_item) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   select @errmsg = '(live_scenario_item) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.oid) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(oid)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(live_scenario_item) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_live_scenario_item
 	    (oid,
       live_scenario_id,
       trade_num, 
       order_num, 
       item_num, 
       alloc_num, 
       alloc_item_num, 
       sub_alloc_num,  
       trans_id,
       resp_trans_id)
   select
 	    d.oid,
      d.live_scenario_id,
      d.trade_num, 
      d.order_num, 
      d.item_num, 
      d.alloc_num, 
      d.alloc_item_num, 
      d.sub_alloc_num,  
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

return
GO
ALTER TABLE [dbo].[live_scenario_item] ADD CONSTRAINT [live_scenario_item_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[live_scenario_item] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[live_scenario_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[live_scenario_item] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[live_scenario_item] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'live_scenario_item', NULL, NULL
GO
