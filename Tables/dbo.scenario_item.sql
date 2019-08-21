CREATE TABLE [dbo].[scenario_item]
(
[oid] [int] NOT NULL,
[scenario_id] [int] NOT NULL,
[buy_sell_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_scenario_item_buy_sell_ind] DEFAULT ('B'),
[qty_percent] [numeric] (20, 8) NOT NULL,
[port_num] [int] NOT NULL,
[opp_port_num] [int] NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qty] [numeric] (20, 8) NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qty_periodicity] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[risk_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[risk_period] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_num] [int] NULL,
[acct_ref_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[booking_comp_num] [int] NULL,
[quote] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[differential] [numeric] (20, 8) NULL,
[price_start_date] [datetime] NULL,
[price_end_date] [datetime] NULL,
[load_port_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[disch_port_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_start_date] [datetime] NULL,
[del_end_date] [datetime] NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ref_trade_num] [int] NULL,
[ref_order_num] [smallint] NULL,
[ref_item_num] [smallint] NULL,
[ref_alloc_num] [int] NULL,
[ref_alloc_item_num] [smallint] NULL,
[ref_sub_alloc_num] [int] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[scenario_item_deltrg]
on [dbo].[scenario_item]
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
   select @errmsg = '(scenario_item) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_scenario_item
(  
   oid,
   scenario_id, 
   buy_sell_ind,
   qty_percent,
   port_num, 
   opp_port_num,
   cmdty_code, 
   qty,
   qty_uom_code,
   qty_periodicity,
   risk_mkt_code, 
   risk_period, 
   acct_num, 
   acct_ref_num,
   booking_comp_num, 
   quote, 
   price_curr_code,
   differential, 
   price_start_date, 
   price_end_date, 
   load_port_loc_code,
   disch_port_loc_code,
   del_start_date, 
   del_end_date, 
   mot_code,
   ref_trade_num, 
   ref_order_num, 
   ref_item_num,
   ref_alloc_num,
   ref_alloc_item_num,
   ref_sub_alloc_num,
   trans_id,
   resp_trans_id
)
select
 	 d.oid,
   d.scenario_id, 
   d.buy_sell_ind,
   d.qty_percent,
   d.port_num, 
   d.opp_port_num,
   d.cmdty_code, 
   d.qty,
   d.qty_uom_code,
   d.qty_periodicity,
   d.risk_mkt_code, 
   d.risk_period, 
   d.acct_num, 
   d.acct_ref_num,
   d.booking_comp_num, 
   d.quote, 
   d.price_curr_code,
   d.differential, 
   d.price_start_date, 
   d.price_end_date, 
   d.load_port_loc_code,
   d.disch_port_loc_code,
   d.del_start_date, 
   d.del_end_date, 
   d.mot_code,
   d.ref_trade_num, 
   d.ref_order_num, 
   d.ref_item_num,
   d.ref_alloc_num,
   d.ref_alloc_item_num,
   d.ref_sub_alloc_num,
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

create trigger [dbo].[scenario_item_updtrg]
on [dbo].[scenario_item]
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
   raiserror ('(scenario_item) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(scenario_item) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   select @errmsg = '(scenario_item) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.oid) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
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
      raiserror ('(scenario_item) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_scenario_item
 	    (oid,
       scenario_id, 
       buy_sell_ind,
       qty_percent,
       port_num, 
       opp_port_num,
       cmdty_code, 
       qty,
       qty_uom_code,
       qty_periodicity,
       risk_mkt_code, 
       risk_period, 
       acct_num, 
       acct_ref_num,
       booking_comp_num, 
       quote, 
       price_curr_code,
       differential, 
       price_start_date, 
       price_end_date, 
       load_port_loc_code,
       disch_port_loc_code,
       del_start_date, 
       del_end_date, 
       mot_code,
       ref_trade_num, 
       ref_order_num, 
       ref_item_num,
       ref_alloc_num,
       ref_alloc_item_num,
       ref_sub_alloc_num,
       trans_id,
       resp_trans_id)
   select
 	    d.oid,
      d.scenario_id, 
      d.buy_sell_ind,
      d.qty_percent,
      d.port_num, 
      d.opp_port_num,
      d.cmdty_code, 
      d.qty,
      d.qty_uom_code,
      d.qty_periodicity,
      d.risk_mkt_code, 
      d.risk_period, 
      d.acct_num, 
      d.acct_ref_num,
      d.booking_comp_num, 
      d.quote, 
      d.price_curr_code,
      d.differential, 
      d.price_start_date, 
      d.price_end_date, 
      d.load_port_loc_code,
      d.disch_port_loc_code,
      d.del_start_date, 
      d.del_end_date, 
      d.mot_code,
      d.ref_trade_num, 
      d.ref_order_num, 
      d.ref_item_num,
      d.ref_alloc_num,
      d.ref_alloc_item_num,
      d.ref_sub_alloc_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

return
GO
ALTER TABLE [dbo].[scenario_item] ADD CONSTRAINT [chk_scenario_item_buy_sell_ind] CHECK (([buy_sell_ind]='S' OR [buy_sell_ind]='B'))
GO
ALTER TABLE [dbo].[scenario_item] ADD CONSTRAINT [chk_scenario_item_qty_periodicity] CHECK (([qty_periodicity]='V' OR [qty_periodicity]='M' OR [qty_periodicity]='L' OR [qty_periodicity]='D'))
GO
ALTER TABLE [dbo].[scenario_item] ADD CONSTRAINT [scenario_item_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[scenario_item] ADD CONSTRAINT [scenario_item_fk1] FOREIGN KEY ([port_num]) REFERENCES [dbo].[portfolio] ([port_num])
GO
ALTER TABLE [dbo].[scenario_item] ADD CONSTRAINT [scenario_item_fk10] FOREIGN KEY ([price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[scenario_item] ADD CONSTRAINT [scenario_item_fk2] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[scenario_item] ADD CONSTRAINT [scenario_item_fk3] FOREIGN KEY ([risk_mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
ALTER TABLE [dbo].[scenario_item] ADD CONSTRAINT [scenario_item_fk4] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[scenario_item] ADD CONSTRAINT [scenario_item_fk5] FOREIGN KEY ([booking_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[scenario_item] ADD CONSTRAINT [scenario_item_fk6] FOREIGN KEY ([ref_trade_num], [ref_order_num], [ref_item_num]) REFERENCES [dbo].[trade_item] ([trade_num], [order_num], [item_num])
GO
ALTER TABLE [dbo].[scenario_item] ADD CONSTRAINT [scenario_item_fk8] FOREIGN KEY ([qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[scenario_item] ADD CONSTRAINT [scenario_item_fk9] FOREIGN KEY ([ref_alloc_num], [ref_alloc_item_num]) REFERENCES [dbo].[allocation_item] ([alloc_num], [alloc_item_num])
GO
GRANT DELETE ON  [dbo].[scenario_item] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[scenario_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[scenario_item] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[scenario_item] TO [next_usr]
GO
