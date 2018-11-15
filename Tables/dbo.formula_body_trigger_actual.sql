CREATE TABLE [dbo].[formula_body_trigger_actual]
(
[formula_num] [int] NOT NULL,
[formula_body_num] [tinyint] NOT NULL,
[trigger_num] [tinyint] NOT NULL,
[parcel_num] [int] NOT NULL,
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[ai_est_actual_num] [smallint] NOT NULL,
[applied_trigger_pcnt] [float] NULL,
[applied_trigger_qty] [float] NULL,
[applied_trigger_qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[actual_triggered_pcnt] [float] NULL,
[actual_triggered_qty] [float] NULL,
[actual_triggered_qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fully_triggered] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[trigger_actual_num] [int] NOT NULL,
[trigger_rem_bal] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[formula_body_trigger_actual_deltrg]
on [dbo].[formula_body_trigger_actual]
instead of delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   int

select @num_rows = @@rowcount
if @num_rows = 0
   return

delete dbo.formula_body_trigger_actual 
from deleted d
where	formula_body_trigger_actual.trigger_actual_num = d.trigger_actual_num  

/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(formula_body) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   rollback tran
   return
end


insert dbo.aud_formula_body_trigger_actual
	(formula_num,
	 formula_body_num,
	 trigger_num,
	 parcel_num,
	 alloc_num,
	 alloc_item_num,
	 ai_est_actual_num,
	 applied_trigger_pcnt,
	 applied_trigger_qty,
	 applied_trigger_qty_uom_code,
	 actual_triggered_pcnt,
	 actual_triggered_qty,
	 actual_triggered_qty_uom_code,
	 fully_triggered,
	 trans_id,
	 resp_trans_id,
	 trigger_actual_num,
	 trigger_rem_bal)
select
	d.formula_num,
	d.formula_body_num,
	d.trigger_num,
	d.parcel_num,
	d.alloc_num,
	d.alloc_item_num,
	d.ai_est_actual_num,
	d.applied_trigger_pcnt,
	d.applied_trigger_qty,
	d.applied_trigger_qty_uom_code,
	d.actual_triggered_pcnt,
	d.actual_triggered_qty,
	d.actual_triggered_qty_uom_code,
	d.fully_triggered,
	d.trans_id,
	@atrans_id,
	d.trigger_actual_num,
	d.trigger_rem_bal
from deleted d

/* AUDIT_CODE_END */
return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[formula_body_trigger_actual_updtrg]
on [dbo].[formula_body_trigger_actual]
instead of update
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
   raiserror ( '(formula_body_trigger_actual) The change needs to be attached with a new trans_id',10,1)
   rollback tran
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
      select @errmsg = '(formula_body_trigger_actual) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      rollback tran
      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.trigger_actual_num = d.trigger_actual_num )
begin
   raiserror ( '(formula_body_trigger_actual) new trans_id must not be older than current trans_id.',10,1)
   rollback tran
   return
end

/* RECORD_STAMP_END */

if	update (trigger_actual_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where	i.trigger_actual_num = d.trigger_actual_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(formula_body_trigger_actual) primary key can not be changed.',10,1)
      rollback tran
      return
   end
end


update formula_body_trigger_actual 
set formula_num 				 	= i.formula_num,
	formula_body_num 			 	= i.formula_body_num,
	trigger_num 				 	= i.trigger_num,
	parcel_num 				 	    = i.parcel_num,
	alloc_num 					 	= i.alloc_num,
	alloc_item_num 			 	    = i.alloc_item_num,
	ai_est_actual_num 			 	= i.ai_est_actual_num,
	applied_trigger_pcnt 		 	= i.applied_trigger_pcnt,
	applied_trigger_qty 		 	= i.applied_trigger_qty,
	applied_trigger_qty_uom_code 	= i.applied_trigger_qty_uom_code,
	actual_triggered_pcnt 		 	= i.actual_triggered_pcnt,
	actual_triggered_qty 		 	= i.actual_triggered_qty,
	actual_triggered_qty_uom_code	= i.actual_triggered_qty_uom_code,
	fully_triggered			 	    = i.fully_triggered,
	trans_id					 	= i.trans_id,
	trigger_actual_num				= i.trigger_actual_num,
	trigger_rem_bal				    = i.trigger_rem_bal
from deleted d, inserted i
where formula_body_trigger_actual.trigger_actual_num = d.trigger_actual_num 
					

/* AUDIT_CODE_BEGIN */
if @dummy_update = 0
insert dbo.aud_formula_body_trigger_actual
	(formula_num,
	formula_body_num,
	trigger_num,
	parcel_num,
	alloc_num,
	alloc_item_num,
	ai_est_actual_num,
	applied_trigger_pcnt,
	applied_trigger_qty,
	applied_trigger_qty_uom_code,
	actual_triggered_pcnt,
	actual_triggered_qty,
	actual_triggered_qty_uom_code,
	fully_triggered,
	trans_id,
	resp_trans_id,
	trigger_actual_num,
	trigger_rem_bal)
select
	d.formula_num,
	d.formula_body_num,
	d.trigger_num,
	d.parcel_num,
	d.alloc_num,
	d.alloc_item_num,
	d.ai_est_actual_num,
	d.applied_trigger_pcnt,
	d.applied_trigger_qty,
	d.applied_trigger_qty_uom_code,
	d.actual_triggered_pcnt,
	d.actual_triggered_qty,
	d.actual_triggered_qty_uom_code,
	d.fully_triggered,
	d.trans_id,
	i.trans_id,
	d.trigger_actual_num,
	d.trigger_rem_bal
from deleted d, inserted i
where d.trigger_actual_num = i.trigger_actual_num 	

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'FormulaBodyTriggerActual',
       'DIRECT',
       convert(varchar(40),trigger_actual_num),
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
ALTER TABLE [dbo].[formula_body_trigger_actual] ADD CONSTRAINT [formula_body_trigger_actual_pk] PRIMARY KEY CLUSTERED  ([trigger_actual_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [formula_body_trigger_actual_idx1] ON [dbo].[formula_body_trigger_actual] ([formula_num], [formula_body_num], [trigger_num], [parcel_num], [alloc_num], [alloc_item_num], [ai_est_actual_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[formula_body_trigger_actual] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[formula_body_trigger_actual] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[formula_body_trigger_actual] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[formula_body_trigger_actual] TO [next_usr]
GO
