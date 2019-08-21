CREATE TABLE [dbo].[trade_default]
(
[dflt_num] [int] NOT NULL,
[acct_num] [int] NULL,
[cmdty_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_loc_code_key] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[order_type_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[risk_mkt_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[title_mkt_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_qty] [float] NULL,
[contr_qty_uom_code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[booking_comp_num] [int] NULL,
[gtc_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_term_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_loc_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[min_qty] [float] NULL,
[min_qty_uom_code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_qty] [float] NULL,
[max_qty_uom_code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_qty] [float] NULL,
[tol_qty_uom_code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_sign] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_opt] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_precision] [tinyint] NULL,
[brkr_num] [int] NULL,
[brkr_cont_num] [int] NULL,
[brkr_comm_amt] [float] NULL,
[brkr_comm_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[brkr_comm_uom_code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[brkr_ref_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_default_deltrg]
on [dbo].[trade_default]
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
   select @errmsg = '(trade_default) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_trade_default
   (dflt_num,
    acct_num,
    cmdty_code,
    del_loc_code_key,
    order_type_code,
    risk_mkt_code,
    title_mkt_code,
    contr_qty,
    contr_qty_uom_code,
    price_curr_code,
    price_uom_code,
    booking_comp_num,
    gtc_code,
    pay_term_code,
    del_term_code,
    mot_code,
    del_loc_code,
    min_qty,
    min_qty_uom_code,
    max_qty,
    max_qty_uom_code,
    tol_qty,
    tol_qty_uom_code,
    tol_sign,
    tol_opt,
    formula_precision,
    brkr_num,
    brkr_cont_num,
    brkr_comm_amt,
    brkr_comm_curr_code,
    brkr_comm_uom_code,
    brkr_ref_num,
    trans_id,
    resp_trans_id)
select
   d.dflt_num,
   d.acct_num,
   d.cmdty_code,
   d.del_loc_code_key,
   d.order_type_code,
   d.risk_mkt_code,
   d.title_mkt_code,
   d.contr_qty,
   d.contr_qty_uom_code,
   d.price_curr_code,
   d.price_uom_code,
   d.booking_comp_num,
   d.gtc_code,
   d.pay_term_code,
   d.del_term_code,
   d.mot_code,
   d.del_loc_code,
   d.min_qty,
   d.min_qty_uom_code,
   d.max_qty,
   d.max_qty_uom_code,
   d.tol_qty,
   d.tol_qty_uom_code,
   d.tol_sign,
   d.tol_opt,
   d.formula_precision,
   d.brkr_num,
   d.brkr_cont_num,
   d.brkr_comm_amt,
   d.brkr_comm_curr_code,
   d.brkr_comm_uom_code,
   d.brkr_ref_num,
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

create trigger [dbo].[trade_default_updtrg]
on [dbo].[trade_default]
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
   raiserror ('(trade_default) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(trade_default) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.dflt_num = d.dflt_num )
begin
   raiserror ('(trade_default) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(dflt_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.dflt_num = d.dflt_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(trade_default) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_trade_default
      (dflt_num,
       acct_num,
       cmdty_code,
       del_loc_code_key,
       order_type_code,
       risk_mkt_code,
       title_mkt_code,
       contr_qty,
       contr_qty_uom_code,
       price_curr_code,
       price_uom_code,
       booking_comp_num,
       gtc_code,
       pay_term_code,
       del_term_code,
       mot_code,
       del_loc_code,
       min_qty,
       min_qty_uom_code,
       max_qty,
       max_qty_uom_code,
       tol_qty,
       tol_qty_uom_code,
       tol_sign,
       tol_opt,
       formula_precision,
       brkr_num,
       brkr_cont_num,
       brkr_comm_amt,
       brkr_comm_curr_code,
       brkr_comm_uom_code,
       brkr_ref_num,
       trans_id,
       resp_trans_id)
   select
      d.dflt_num,
      d.acct_num,
      d.cmdty_code,
      d.del_loc_code_key,
      d.order_type_code,
      d.risk_mkt_code,
      d.title_mkt_code,
      d.contr_qty,
      d.contr_qty_uom_code,
      d.price_curr_code,
      d.price_uom_code,
      d.booking_comp_num,
      d.gtc_code,
      d.pay_term_code,
      d.del_term_code,
      d.mot_code,
      d.del_loc_code,
      d.min_qty,
      d.min_qty_uom_code,
      d.max_qty,
      d.max_qty_uom_code,
      d.tol_qty,
      d.tol_qty_uom_code,
      d.tol_sign,
      d.tol_opt,
      d.formula_precision,
      d.brkr_num,
      d.brkr_cont_num,
      d.brkr_comm_amt,
      d.brkr_comm_curr_code,
      d.brkr_comm_uom_code,
      d.brkr_ref_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.dflt_num = i.dflt_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[trade_default] ADD CONSTRAINT [trade_default_pk] PRIMARY KEY CLUSTERED  ([dflt_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trade_default] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_default] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_default] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_default] TO [next_usr]
GO
