CREATE TABLE [dbo].[broker_cost_autogen]
(
[cost_autogen_num] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[brkr_num] [int] NULL,
[clr_brkr_num] [int] NULL,
[exec_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[item_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[creation_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_price_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[unit_price] [numeric] (20, 8) NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_eff_date_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[validity_start_date] [datetime] NULL,
[validity_end_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[pay_to] [int] NULL,
[block_trade_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
create trigger [dbo].[broker_cost_autogen_deltrg]  
on [dbo].[broker_cost_autogen]  
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
   select @errmsg = '(broker_cost_autogen) Failed to obtain a valid responsible trans_id.'  
   if exists (select 1  
              from master.dbo.sysprocesses (nolock)  
              where spid = @@spid and  
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR  
                     program_name like 'Microsoft SQL Server Management Studio%') )  
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'  
   raiserror (@errmsg  ,10,1)  
   if @@trancount > 0 rollback tran  
   return  
end  
  
  
insert dbo.aud_broker_cost_autogen  
(    
   cost_autogen_num,  
   cmdty_code,  
   mkt_code,  
   brkr_num,  
   clr_brkr_num,  
   exec_type_code,  
   item_type,  
   cost_code,  
   creation_type,  
   cost_price_type,  
   unit_price,  
   price_curr_code,  
   price_uom_code,  
   pay_term_code,  
   cost_eff_date_ind,  
   validity_start_date,  
   validity_end_date,  
   pay_to,  
   trans_id,  
   resp_trans_id,
   block_trade_ind,
   p_s_ind
)  
select  
   d.cost_autogen_num,  
   d.cmdty_code,  
   d.mkt_code,  
   d.brkr_num,  
   d.clr_brkr_num,  
   d.exec_type_code,  
   d.item_type,  
   d.cost_code,  
   d.creation_type,  
   d.cost_price_type,  
   d.unit_price,  
   d.price_curr_code,  
   d.price_uom_code,  
   d.pay_term_code,  
   d.cost_eff_date_ind,  
   d.validity_start_date,  
   d.validity_end_date,  
   d.pay_to,  
   d.trans_id,  
   @atrans_id,
   d.block_trade_ind,
   d.p_s_ind
from deleted d  
  
/* AUDIT_CODE_END */  
return  
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
create trigger [dbo].[broker_cost_autogen_updtrg]  
on [dbo].[broker_cost_autogen]  
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
   raiserror ('(broker_cost_autogen) The change needs to be attached with a new trans_id'  ,10,1)  
   if @@trancount > 0 rollback tran   
   return  
end  
  
if exists (select * from inserted i, deleted d  
           where i.trans_id < d.trans_id and  
                 i.cost_autogen_num = d.cost_autogen_num)  
begin  
   raiserror ('(broker_cost_autogen) new trans_id must not be older than current trans_id.'  ,10,1)  
   if @@trancount > 0 rollback tran   
   return  
end  
  
/* RECORD_STAMP_END */  
  
if update(cost_autogen_num)  
begin  
   select @count_num_rows = (select count(*)   
                             from inserted i, deleted d  
                             where i.cost_autogen_num = d.cost_autogen_num)  
   if (@count_num_rows = @num_rows)  
   begin  
      select @dummy_update = 1  
   end  
   else  
   begin  
      select @errmsg = '(broker_cost_autogen) primary key can not be changed.'  
      raiserror (@errmsg  ,10,1)  
      if @@trancount > 0 rollback tran  
      return  
   end  
end  
  
/* AUDIT_CODE_BEGIN */  
  
if @dummy_update = 0  
   insert dbo.aud_broker_cost_autogen  
   (  
      cost_autogen_num,  
      cmdty_code,  
      mkt_code,  
      brkr_num,  
      clr_brkr_num,  
      exec_type_code,  
      item_type,  
      cost_code,  
      creation_type,  
      cost_price_type,  
      unit_price,  
      price_curr_code,  
      price_uom_code,  
      pay_term_code,  
      cost_eff_date_ind,  
      validity_start_date,  
      validity_end_date,  
      pay_to,  
      trans_id,  
      resp_trans_id,
      block_trade_ind,
      p_s_ind
   )  
   select  
      d.cost_autogen_num,  
      d.cmdty_code,  
      d.mkt_code,  
      d.brkr_num,  
      d.clr_brkr_num,  
      d.exec_type_code,  
      d.item_type,  
      d.cost_code,  
      d.creation_type,  
      d.cost_price_type,  
      d.unit_price,  
      d.price_curr_code,  
      d.price_uom_code,  
      d.pay_term_code,  
      d.cost_eff_date_ind,  
      d.validity_start_date,  
      d.validity_end_date,  
      d.pay_to,  
      d.trans_id,  
      i.trans_id,
      d.block_trade_ind,
      d.p_s_ind
   from deleted d, inserted i  
   where d.cost_autogen_num = i.cost_autogen_num  
  
/* AUDIT_CODE_END */    
return  
GO
ALTER TABLE [dbo].[broker_cost_autogen] ADD CONSTRAINT [CK__broker_co__block__4535E272] CHECK (([block_trade_ind]=NULL OR [block_trade_ind]='Y' OR [block_trade_ind]='N'))
GO
ALTER TABLE [dbo].[broker_cost_autogen] ADD CONSTRAINT [CK__broker_co__cost___6DCC4D03] CHECK (([cost_eff_date_ind]='E' OR [cost_eff_date_ind]='T' OR [cost_eff_date_ind]='F'))
GO
ALTER TABLE [dbo].[broker_cost_autogen] ADD CONSTRAINT [CK__broker_co__cost___6CD828CA] CHECK (([cost_price_type]='S' OR [cost_price_type]='F'))
GO
ALTER TABLE [dbo].[broker_cost_autogen] ADD CONSTRAINT [CK__broker_co__creat__6BE40491] CHECK (([creation_type]='O' OR [creation_type]='M' OR [creation_type]='D' OR [creation_type]='T'))
GO
ALTER TABLE [dbo].[broker_cost_autogen] ADD CONSTRAINT [broker_cost_autogen_pk] PRIMARY KEY CLUSTERED  ([cost_autogen_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[broker_cost_autogen] ADD CONSTRAINT [broker_cost_autogen_fk1] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[broker_cost_autogen] ADD CONSTRAINT [broker_cost_autogen_fk10] FOREIGN KEY ([pay_to]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[broker_cost_autogen] ADD CONSTRAINT [broker_cost_autogen_fk2] FOREIGN KEY ([mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
ALTER TABLE [dbo].[broker_cost_autogen] ADD CONSTRAINT [broker_cost_autogen_fk3] FOREIGN KEY ([brkr_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[broker_cost_autogen] ADD CONSTRAINT [broker_cost_autogen_fk4] FOREIGN KEY ([clr_brkr_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[broker_cost_autogen] ADD CONSTRAINT [broker_cost_autogen_fk5] FOREIGN KEY ([exec_type_code]) REFERENCES [dbo].[execution_type] ([exec_type_code])
GO
ALTER TABLE [dbo].[broker_cost_autogen] ADD CONSTRAINT [broker_cost_autogen_fk6] FOREIGN KEY ([cost_code]) REFERENCES [dbo].[cost_code] ([cost_code])
GO
ALTER TABLE [dbo].[broker_cost_autogen] ADD CONSTRAINT [broker_cost_autogen_fk7] FOREIGN KEY ([pay_term_code]) REFERENCES [dbo].[payment_term] ([pay_term_code])
GO
ALTER TABLE [dbo].[broker_cost_autogen] ADD CONSTRAINT [broker_cost_autogen_fk8] FOREIGN KEY ([price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[broker_cost_autogen] ADD CONSTRAINT [broker_cost_autogen_fk9] FOREIGN KEY ([price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[broker_cost_autogen] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[broker_cost_autogen] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[broker_cost_autogen] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[broker_cost_autogen] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'broker_cost_autogen', NULL, NULL
GO
