CREATE TABLE [dbo].[var_component]
(
[rowid] [int] NOT NULL IDENTITY(1, 1),
[var_run_id] [int] NOT NULL,
[port_num_list] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_key] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[component_amt] [float] NULL,
[annual_volatility] [float] NULL,
[var_pct] [float] NULL,
[var_amt] [float] NULL,
[open_qty] [float] NULL,
[open_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[settl_price] [float] NULL,
[settl_exch_rate] [float] NULL,
[settl_price_curr_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[time_hor_price] [float] NULL,
[time_hor_exch_rate] [float] NULL,
[time_hor_price_curr_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[time_hor_component_amt] [float] NULL,
[time_hor_price_date] [datetime] NULL,
[time_hor_calc_date] [datetime] NULL,
[time_hor_calc_user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[var_component_deltrg]  
on [dbo].[var_component]  
for delete  
as  
declare @num_rows         int
		 
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  
  
insert dbo.aud_var_component  
(  
	rowid,  
    var_run_id,  
    port_num_list,  
    commkt_key,  
    cmdty_code,  
    mkt_code,  
    price_source_code,  
    trading_prd,  
    price_type,  
    component_amt,  
    annual_volatility,  
    var_pct,  
    var_amt,  
    open_qty,  
    open_qty_uom_code,  
    settl_price,  
    settl_exch_rate,  
    settl_price_curr_code,  
    time_hor_price,  
    time_hor_exch_rate,  
    time_hor_price_curr_code,  
    time_hor_component_amt,  
    time_hor_price_date,  
    time_hor_calc_date,  
    time_hor_calc_user_init,  
	operation,  
	userid,  
	date_op    
)  
select   
	d.rowid,  
    d.var_run_id,  
    d.port_num_list,  
    d.commkt_key,  
    d.cmdty_code,  
    d.mkt_code,  
    d.price_source_code,  
    d.trading_prd,  
    d.price_type,  
    d.component_amt,  
    d.annual_volatility,  
    d.var_pct,  
    d.var_amt,  
    d.open_qty,  
    d.open_qty_uom_code,  
    d.settl_price,  
    d.settl_exch_rate,  
    d.settl_price_curr_code,  
    d.time_hor_price,  
    d.time_hor_exch_rate,  
    d.time_hor_price_curr_code,  
    d.time_hor_component_amt,  
    d.time_hor_price_date,  
    d.time_hor_calc_date,  
    d.time_hor_calc_user_init,  
	'DEL',  
    suser_name(),  
    getdate()     
from deleted d  
  
/* AUDIT_CODE_END */  
  
return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[var_component_instrg]  
on [dbo].[var_component]  
for insert  
as  
  
declare @num_rows         int
  
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  
  
insert dbo.aud_var_component  
(  
   rowid,  
   var_run_id,  
   port_num_list,  
   commkt_key,  
   cmdty_code,  
   mkt_code,  
   price_source_code,  
   trading_prd,  
   price_type,  
   component_amt,  
   annual_volatility,  
   var_pct,  
   var_amt,  
   open_qty,  
   open_qty_uom_code,  
   settl_price,  
   settl_exch_rate,  
   settl_price_curr_code,  
   time_hor_price,  
   time_hor_exch_rate,  
   time_hor_price_curr_code,  
   time_hor_component_amt,  
   time_hor_price_date,  
   time_hor_calc_date,  
   time_hor_calc_user_init,  
   operation,  
   userid,  
   date_op    
)  
select   
   i.rowid,  
   i.var_run_id,  
   i.port_num_list,  
   i.commkt_key,  
   i.cmdty_code,  
   i.mkt_code,  
   i.price_source_code,  
   i.trading_prd,  
   i.price_type,  
   i.component_amt,  
   i.annual_volatility,  
   i.var_pct,  
   i.var_amt,  
   i.open_qty,  
   i.open_qty_uom_code,  
   i.settl_price,  
   i.settl_exch_rate,  
   i.settl_price_curr_code,  
   i.time_hor_price,  
   i.time_hor_exch_rate,  
   i.time_hor_price_curr_code,  
   i.time_hor_component_amt,  
   i.time_hor_price_date,  
   i.time_hor_calc_date,  
   i.time_hor_calc_user_init,  
   'INS',  
   suser_name(),  
   getdate()    
from inserted i  
  
/* AUDIT_CODE_END */  
  
return  
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[var_component_updtrg]  
on [dbo].[var_component]  
for update  
as  
declare @num_rows         int 
  
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  

insert dbo.aud_var_component  
(  
   rowid,  
   var_run_id,  
   port_num_list,  
   commkt_key,  
   cmdty_code,  
   mkt_code,  
   price_source_code,  
   trading_prd,  
   price_type,  
   component_amt,  
   annual_volatility,  
   var_pct,  
   var_amt,  
   open_qty,  
   open_qty_uom_code,  
   settl_price,  
   settl_exch_rate,  
   settl_price_curr_code,  
   time_hor_price,  
   time_hor_exch_rate,  
   time_hor_price_curr_code,  
   time_hor_component_amt,  
   time_hor_price_date,  
   time_hor_calc_date,  
   time_hor_calc_user_init,  
   operation,  
   userid,  
   date_op   
)  
select   
   i.rowid,  
   i.var_run_id,  
   i.port_num_list,  
   i.commkt_key,  
   i.cmdty_code,  
   i.mkt_code,  
   i.price_source_code,  
   i.trading_prd,  
   i.price_type,  
   i.component_amt,  
   i.annual_volatility,  
   i.var_pct,  
   i.var_amt,  
   i.open_qty,  
   i.open_qty_uom_code,  
   i.settl_price,  
   i.settl_exch_rate,  
   i.settl_price_curr_code,  
   i.time_hor_price,  
   i.time_hor_exch_rate,  
   i.time_hor_price_curr_code,  
   i.time_hor_component_amt,  
   i.time_hor_price_date,  
   i.time_hor_calc_date,  
   i.time_hor_calc_user_init,  
   'UPD',  
   suser_name(),  
   getdate()     
from inserted i  
  
/* AUDIT_CODE_END */  
  
return  
GO
ALTER TABLE [dbo].[var_component] ADD CONSTRAINT [var_component_pk] PRIMARY KEY CLUSTERED  ([rowid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[var_component] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[var_component] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[var_component] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[var_component] TO [next_usr]
GO
