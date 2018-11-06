CREATE TABLE [dbo].[cost_price_detail]
(
[cost_num] [int] NOT NULL,
[formula_body_num] [int] NOT NULL,
[formula_num] [int] NOT NULL,
[unit_price] [float] NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[field1] [int] NULL,
[fb_value] [float] NULL,
[field3] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[field4] [datetime] NULL,
[trans_id] [int] NOT NULL,
[qty_uom_code_conv_to] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qty_uom_conv_rate] [numeric] (20, 8) NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cost_price_detail_deltrg]  
on [dbo].[cost_price_detail]  
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
   select @errmsg = '(cost_price_detail) Failed to obtain a valid responsible trans_id.'  
   if exists (select 1  
              from master.dbo.sysprocesses (nolock)  
              where spid = @@spid and  
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR  
                     program_name like 'Microsoft SQL Server Management Studio%') )  
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'  
   raiserror (@errmsg ,10,1)
   rollback tran  
   return  
end  

   insert dbo.aud_cost_price_detail  
      (
	cost_num,
	formula_body_num,
	formula_num,
	unit_price,
	price_uom_code,
	price_curr_code,
	field1,
	fb_value,
	field3,
	field4,
	trans_id,
        resp_trans_id,
       qty_uom_code_conv_to,
       qty_uom_conv_rate)  
   select
	d.cost_num,
	d.formula_body_num,
	d.formula_num,
	d.unit_price,
	d.price_uom_code,
	d.price_curr_code,
	d.field1,
	d.fb_value,
	d.field3,
	d.field4,
	d.trans_id,
       @atrans_id,
        d.qty_uom_code_conv_to,
	d.qty_uom_conv_rate
   from deleted d   
  
/* AUDIT_CODE_END */  

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cost_price_detail_updtrg]  
on [dbo].[cost_price_detail]  
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
   raiserror  ('(cost_price_detail) The change needs to be attached with a new trans_id' ,10,1)
   rollback tran  
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
      select @errmsg = '(cost_price_detail) New trans_id must be larger than original trans_id.'  
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'  
      raiserror ( @errmsg  ,10,1)
      rollback tran  
      return  
   end  
end  
  
if exists (select * from inserted i, deleted d  
           where i.trans_id < d.trans_id and  
                 i.cost_num = d.cost_num and
		 i.formula_body_num = d.formula_body_num and 
		 i.formula_num = d.formula_num )  
begin  
   raiserror ( '(cost_price_detail) new trans_id must not be older than current trans_id.'  ,10,1)
   rollback tran  
   return  
end  
  
/* RECORD_STAMP_END */
  
if update(cost_num) or
update(formula_body_num) or
update(formula_num) 
begin  
   select @count_num_rows = (select count(*) from inserted i, deleted d  
                             where i.cost_num = d.cost_num and
			     i.formula_body_num = d.formula_body_num and
			     i.formula_num = d.formula_num )  
   if (@count_num_rows = @num_rows)  
   begin  
      select @dummy_update = 1  
   end  
   else  
   begin  
      raiserror ( '(cost_price_detail) primary key can not be changed.'  ,10,1)
      rollback tran  
      return  
   end  
end  

  
/* AUDIT_CODE_BEGIN */  
  
if @dummy_update = 0  
   insert dbo.aud_cost_price_detail  
      (
	cost_num,
	formula_body_num,
	formula_num,
	unit_price,
	price_uom_code,
	price_curr_code,
	field1,
	fb_value,
	field3,
	field4,
	trans_id,
        resp_trans_id,
	qty_uom_code_conv_to,
	qty_uom_conv_rate
       )  
   select
	d.cost_num,
	d.formula_body_num,
	d.formula_num,
	d.unit_price,
	d.price_uom_code,
	d.price_curr_code,
	d.field1,
	d.fb_value,
	d.field3,
	d.field4,
	d.trans_id,
        i.trans_id,
       d.qty_uom_code_conv_to,
       d.qty_uom_conv_rate
   from deleted d, inserted i  
   where i.cost_num = d.cost_num and
	 i.formula_body_num = d.formula_body_num and
	 i.formula_num = d.formula_num   
  
/* AUDIT_CODE_END */  

return
GO
ALTER TABLE [dbo].[cost_price_detail] ADD CONSTRAINT [cost_price_detail_pk] PRIMARY KEY CLUSTERED  ([cost_num], [formula_body_num], [formula_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cost_price_detail] ADD CONSTRAINT [cost_price_detail_fk1] FOREIGN KEY ([price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[cost_price_detail] ADD CONSTRAINT [cost_price_detail_fk2] FOREIGN KEY ([price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[cost_price_detail] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cost_price_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cost_price_detail] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cost_price_detail] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'cost_price_detail', NULL, NULL
GO
