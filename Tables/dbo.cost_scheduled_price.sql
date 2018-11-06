CREATE TABLE [dbo].[cost_scheduled_price]
(
[cost_num] [int] NOT NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[volume_scale] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[volume_usg_from] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mini_usg_test_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mini_usg] [float] NULL,
[mini_usg_fee] [float] NULL,
[mini_use_incl_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[reference] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cost_scheduled_price_deltrg]
on [dbo].[cost_scheduled_price]
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
   select @errmsg = '(cost_scheduled_price) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_cost_scheduled_price
   (cost_num, 
    price_curr_code,
    price_uom_code,
    volume_scale,
    volume_usg_from, 
    mini_usg_test_ind,
    mini_usg, 
    mini_usg_fee, 
    mini_use_incl_ind, 
    reference,
    trans_id,
    resp_trans_id)
select
   d.cost_num, 
   d.price_curr_code,
   d.price_uom_code,
   d.volume_scale,
   d.volume_usg_from, 
   d.mini_usg_test_ind,
   d.mini_usg, 
   d.mini_usg_fee, 
   d.mini_use_incl_ind, 
   d.reference,
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

create trigger [dbo].[cost_scheduled_price_updtrg]
on [dbo].[cost_scheduled_price]
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
   raiserror ('(cost_scheduled_price) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(cost_scheduled_price) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.cost_num = d.cost_num )
begin
   raiserror ('(cost_scheduled_price) new trans_id must not be older than current trans_id.',10,1)
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
      raiserror ('(cost_scheduled_price) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_cost_scheduled_price
      (cost_num, 
       price_curr_code,
       price_uom_code,
       volume_scale,
       volume_usg_from, 
       mini_usg_test_ind,
       mini_usg, 
       mini_usg_fee, 
       mini_use_incl_ind, 
       reference,
       trans_id,
       resp_trans_id)
   select
      d.cost_num, 
      d.price_curr_code,
      d.price_uom_code,
      d.volume_scale,
      d.volume_usg_from, 
      d.mini_usg_test_ind,
      d.mini_usg, 
      d.mini_usg_fee, 
      d.mini_use_incl_ind, 
      d.reference,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.cost_num = i.cost_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[cost_scheduled_price] ADD CONSTRAINT [CK__cost_sche__mini___324172E1] CHECK (([mini_use_incl_ind]='N' OR [mini_use_incl_ind]='Y'))
GO
ALTER TABLE [dbo].[cost_scheduled_price] ADD CONSTRAINT [CK__cost_sche__mini___314D4EA8] CHECK (([mini_usg_test_ind]='N' OR [mini_usg_test_ind]='Y'))
GO
ALTER TABLE [dbo].[cost_scheduled_price] ADD CONSTRAINT [CK__cost_sche__volum__30592A6F] CHECK (([volume_scale]='S' OR [volume_scale]='W'))
GO
ALTER TABLE [dbo].[cost_scheduled_price] ADD CONSTRAINT [cost_scheduled_price_pk] PRIMARY KEY CLUSTERED  ([cost_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cost_scheduled_price] ADD CONSTRAINT [cost_scheduled_price_fk2] FOREIGN KEY ([price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[cost_scheduled_price] ADD CONSTRAINT [cost_scheduled_price_fk3] FOREIGN KEY ([price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[cost_scheduled_price] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cost_scheduled_price] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cost_scheduled_price] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cost_scheduled_price] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'cost_scheduled_price', NULL, NULL
GO
