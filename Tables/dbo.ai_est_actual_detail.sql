CREATE TABLE [dbo].[ai_est_actual_detail]
(
[detail_num] [int] NOT NULL,
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[ai_est_actual_num] [smallint] NOT NULL,
[creation_date] [datetime] NULL,
[actual_date] [datetime] NOT NULL,
[actual_gross_qty] [float] NULL,
[actual_gross_qty_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[actual_net_qty] [float] NULL,
[actual_net_qty_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_actual_gross_qty] [float] NULL,
[sec_actual_gross_qty_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_actual_net_qty] [float] NULL,
[sec_actual_net_qty_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[unit_price] [float] NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ai_est_actual_detail_deltrg]
on [dbo].[ai_est_actual_detail]
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
   select @errmsg = '(ai_est_actual_detail) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_ai_est_actual_detail
(  
	detail_num,
	alloc_num,
	alloc_item_num,
	ai_est_actual_num,
	creation_date,
	actual_date,
	actual_gross_qty,
	actual_gross_qty_uom,
	actual_net_qty,
	actual_net_qty_uom,
	sec_actual_gross_qty,
	sec_actual_gross_qty_uom,
	sec_actual_net_qty,
	sec_actual_net_qty_uom,
	unit_price,
	price_curr_code,
	price_uom_code,
	trans_id,
	resp_trans_id	
)
select
	d.detail_num,
	d.alloc_num,
	d.alloc_item_num,
	d.ai_est_actual_num,
	d.creation_date,
	d.actual_date,
	d.actual_gross_qty,
	d.actual_gross_qty_uom,
	d.actual_net_qty,
	d.actual_net_qty_uom,
	d.sec_actual_gross_qty,
	d.sec_actual_gross_qty_uom,
	d.sec_actual_net_qty,
	d.sec_actual_net_qty_uom,
	d.unit_price,
	d.price_curr_code,
	d.price_uom_code,
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

create trigger [dbo].[ai_est_actual_detail_updtrg]
on [dbo].[ai_est_actual_detail]
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
	raiserror ('(ai_est_actual_detail) The change needs to be attached with a new trans_id.',10,1)
	if @@trancount > 0 rollback tran  
   return
end

if exists (select 1
           from master.dbo.sysprocesses
           where spid = @@spid and
                (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                 program_name like 'Microsoft SQL Server Management Studio%') )
begin
   if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0
   begin
      select @errmsg = '(ai_est_actual_detail) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran  
      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.detail_num = d.detail_num)
begin
   raiserror ('(ai_est_actual_detail) new trans_id must not be older than current trans_id.',10,1  )
    if @@trancount > 0 rollback tran  
   return
end

/* RECORD_STAMP_END */

if update(detail_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.detail_num = d.detail_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(ai_est_actual_detail) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran 
      return
   end
end

if @dummy_update = 0
insert dbo.aud_ai_est_actual_detail
(  
	detail_num,
	alloc_num,
	alloc_item_num,
	ai_est_actual_num,
	creation_date,
	actual_date,
	actual_gross_qty,
	actual_gross_qty_uom,
	actual_net_qty,
	actual_net_qty_uom,
	sec_actual_gross_qty,
	sec_actual_gross_qty_uom,
	sec_actual_net_qty,
	sec_actual_net_qty_uom,
	unit_price,
	price_curr_code,
	price_uom_code,
	trans_id,
	resp_trans_id	
)
select
	d.detail_num,
	d.alloc_num,
	d.alloc_item_num,
	d.ai_est_actual_num,
	d.creation_date,
	d.actual_date,
	d.actual_gross_qty,
	d.actual_gross_qty_uom,
	d.actual_net_qty,
	d.actual_net_qty_uom,
	d.sec_actual_gross_qty,
	d.sec_actual_gross_qty_uom,
	d.sec_actual_net_qty,
	d.sec_actual_net_qty_uom,
	d.unit_price,
	d.price_curr_code,
	d.price_uom_code,
	d.trans_id,
	i.trans_id	
from deleted d, inserted i
where d.detail_num = i.detail_num 

/* AUDIT_CODE_END */ 

return
GO
ALTER TABLE [dbo].[ai_est_actual_detail] ADD CONSTRAINT [ai_est_actual_detail_pk] PRIMARY KEY CLUSTERED  ([detail_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ai_est_actual_detail] ADD CONSTRAINT [ai_est_actual_detail_fk1] FOREIGN KEY ([alloc_num], [alloc_item_num], [ai_est_actual_num]) REFERENCES [dbo].[ai_est_actual] ([alloc_num], [alloc_item_num], [ai_est_actual_num])
GO
GRANT DELETE ON  [dbo].[ai_est_actual_detail] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ai_est_actual_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ai_est_actual_detail] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ai_est_actual_detail] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'ai_est_actual_detail', NULL, NULL
GO
