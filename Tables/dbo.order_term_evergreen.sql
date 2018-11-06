CREATE TABLE [dbo].[order_term_evergreen]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[contr_qty] [float] NULL,
[contr_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[term_prd_start_date] [datetime] NULL,
[term_prd_end_date] [datetime] NULL,
[del_date_from] [datetime] NULL,
[del_date_to] [datetime] NULL,
[buyer_seller_opt] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[term_min_qty] [float] NULL,
[term_max_qty] [float] NULL,
[term_qty_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[term_end_action] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[evergrn_cancel_notice] [int] NULL,
[evergrn_cancel_notice_prd] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[evergrn_start_date] [datetime] NULL,
[evergrn_end_date] [datetime] NULL,
[evergrn_future_dlvs] [int] NULL,
[dlv_buyer_seller_opt] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dlv_risk_vol_det] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[order_term_evergreen_deltrg]
on [dbo].[order_term_evergreen]
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
   select @errmsg = '(order_term_evergreen) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_order_term_evergreen
   (trade_num,
    order_num,
    contr_qty,
    contr_qty_uom_code,
    cmdty_code,
    term_prd_start_date,
    term_prd_end_date,
    del_date_from,
    del_date_to,
    buyer_seller_opt,
    term_min_qty,
    term_max_qty,
    term_qty_type,
    term_end_action,
    evergrn_cancel_notice,
    evergrn_cancel_notice_prd,
    evergrn_start_date,
    evergrn_end_date,
    evergrn_future_dlvs,
    dlv_buyer_seller_opt,
    dlv_risk_vol_det,
    trans_id,
    resp_trans_id)
select
   d.trade_num,
   d.order_num,
   d.contr_qty,
   d.contr_qty_uom_code,
   d.cmdty_code,
   d.term_prd_start_date,
   d.term_prd_end_date,
   d.del_date_from,
   d.del_date_to,
   d.buyer_seller_opt,
   d.term_min_qty,
   d.term_max_qty,
   d.term_qty_type,
   d.term_end_action,
   d.evergrn_cancel_notice,
   d.evergrn_cancel_notice_prd,
   d.evergrn_start_date,
   d.evergrn_end_date,
   d.evergrn_future_dlvs,
   d.dlv_buyer_seller_opt,
   d.dlv_risk_vol_det,
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

create trigger [dbo].[order_term_evergreen_updtrg]
on [dbo].[order_term_evergreen]
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
   raiserror ('(order_term_evergreen) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(order_term_evergreen) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.trade_num = d.trade_num and 
                 i.order_num = d.order_num )
begin
   raiserror ('(order_term_evergreen) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(trade_num) or  
   update(order_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.trade_num = d.trade_num and 
                                   i.order_num = d.order_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(order_term_evergreen) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_order_term_evergreen
      (trade_num,
       order_num,
       contr_qty,
       contr_qty_uom_code,
       cmdty_code,
       term_prd_start_date,
       term_prd_end_date,
       del_date_from,
       del_date_to,
       buyer_seller_opt,
       term_min_qty,
       term_max_qty,
       term_qty_type,
       term_end_action,
       evergrn_cancel_notice,
       evergrn_cancel_notice_prd,
       evergrn_start_date,
       evergrn_end_date,
       evergrn_future_dlvs,
       dlv_buyer_seller_opt,
       dlv_risk_vol_det,
       trans_id,
       resp_trans_id)
   select
      d.trade_num,
      d.order_num,
      d.contr_qty,
      d.contr_qty_uom_code,
      d.cmdty_code,
      d.term_prd_start_date,
      d.term_prd_end_date,
      d.del_date_from,
      d.del_date_to,
      d.buyer_seller_opt,
      d.term_min_qty,
      d.term_max_qty,
      d.term_qty_type,
      d.term_end_action,
      d.evergrn_cancel_notice,
      d.evergrn_cancel_notice_prd,
      d.evergrn_start_date,
      d.evergrn_end_date,
      d.evergrn_future_dlvs,
      d.dlv_buyer_seller_opt,
      d.dlv_risk_vol_det,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.trade_num = i.trade_num and
         d.order_num = i.order_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[order_term_evergreen] ADD CONSTRAINT [order_term_evergreen_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[order_term_evergreen] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[order_term_evergreen] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[order_term_evergreen] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[order_term_evergreen] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'order_term_evergreen', NULL, NULL
GO
