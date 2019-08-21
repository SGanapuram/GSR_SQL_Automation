CREATE TABLE [dbo].[broker_cost_step_price]
(
[cost_autogen_num] [int] NOT NULL,
[step_price_num] [int] NOT NULL,
[unit_price] [numeric] (20, 8) NOT NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[qty_upto] [numeric] (20, 8) NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[broker_cost_step_price_deltrg]
on [dbo].[broker_cost_step_price]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
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
   select @errmsg = '(broker_cost_step_price) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_broker_cost_step_price
(  
   cost_autogen_num,
   step_price_num,
   unit_price,
   price_curr_code,
   price_uom_code,
   qty_upto,
   qty_uom_code,
   trans_id,
   resp_trans_id
)
select
   d.cost_autogen_num,
   d.step_price_num,
   d.unit_price,
   d.price_curr_code,
   d.price_uom_code,
   d.qty_upto,
   d.qty_uom_code,
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

create trigger [dbo].[broker_cost_step_price_updtrg]
on [dbo].[broker_cost_step_price]
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
   raiserror ('(broker_cost_step_price) The change needs to be attached with a new trans_id',16,1)
   if @@trancount > 0 rollback tran

   return
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.cost_autogen_num = d.cost_autogen_num and
                 i.step_price_num = d.step_price_num)
begin
   raiserror ('(broker_cost_step_price) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(cost_autogen_num)  or  
   update(step_price_num) 
begin
   select @count_num_rows = (select count(*) 
                             from inserted i, deleted d
                             where i.cost_autogen_num = d.cost_autogen_num and
                                   i.step_price_num = d.step_price_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      select @errmsg = '(broker_cost_step_price) primary key can not be changed.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_broker_cost_step_price
   (
      cost_autogen_num,
      step_price_num,
      unit_price,
      price_curr_code,
      price_uom_code,
      qty_upto,
      qty_uom_code,
      trans_id,
      resp_trans_id
   )
   select
      d.cost_autogen_num,
      d.step_price_num,
      d.unit_price,
      d.price_curr_code,
      d.price_uom_code,
      d.qty_upto,
      d.qty_uom_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.cost_autogen_num = i.cost_autogen_num and
         d.step_price_num = i.step_price_num 

/* AUDIT_CODE_END */  
return
GO
ALTER TABLE [dbo].[broker_cost_step_price] ADD CONSTRAINT [broker_cost_step_price_pk] PRIMARY KEY CLUSTERED  ([cost_autogen_num], [step_price_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[broker_cost_step_price] ADD CONSTRAINT [broker_cost_step_price_fk1] FOREIGN KEY ([cost_autogen_num]) REFERENCES [dbo].[broker_cost_autogen] ([cost_autogen_num])
GO
ALTER TABLE [dbo].[broker_cost_step_price] ADD CONSTRAINT [broker_cost_step_price_fk2] FOREIGN KEY ([price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[broker_cost_step_price] ADD CONSTRAINT [broker_cost_step_price_fk3] FOREIGN KEY ([qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[broker_cost_step_price] ADD CONSTRAINT [broker_cost_step_price_fk4] FOREIGN KEY ([price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[broker_cost_step_price] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[broker_cost_step_price] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[broker_cost_step_price] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[broker_cost_step_price] TO [next_usr]
GO
