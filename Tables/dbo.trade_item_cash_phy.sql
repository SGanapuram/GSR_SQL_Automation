CREATE TABLE [dbo].[trade_item_cash_phy]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[min_qty] [float] NULL,
[min_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_qty] [float] NULL,
[max_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[total_settled_qty] [float] NULL,
[settled_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_days] [int] NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_imp_rec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_exp_rec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[margin_conv_factor] [float] NULL,
[cfd_swap_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[efs_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[execution_date] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_cash_phy_deltrg]  
on [dbo].[trade_item_cash_phy]  
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
   select @errmsg = '(trade_item_cash_phy) Failed to obtain a valid responsible trans_id.'  
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
  
  
insert dbo.aud_trade_item_cash_phy  
   (trade_num,  
    order_num,  
    item_num,  
    min_qty,  
    min_qty_uom_code,  
    max_qty,  
    max_qty_uom_code,  
    total_settled_qty,  
    settled_qty_uom_code,  
    credit_term_code,  
    pay_days,  
    pay_term_code,  
    trade_imp_rec_ind,  
    trade_exp_rec_ind,  
    margin_conv_factor,  
    cfd_swap_ind,  
    efs_ind, 
    execution_date,
    trans_id,  
    resp_trans_id)  
select  
   d.trade_num,  
   d.order_num,  
   d.item_num,  
   d.min_qty,  
   d.min_qty_uom_code,  
   d.max_qty,  
   d.max_qty_uom_code,  
   d.total_settled_qty,  
   d.settled_qty_uom_code,  
   d.credit_term_code,  
   d.pay_days,  
   d.pay_term_code,  
   d.trade_imp_rec_ind,  
   d.trade_exp_rec_ind,  
   d.margin_conv_factor,  
   d.cfd_swap_ind,  
   d.efs_ind,  
   d.execution_date,
   d.trans_id,  
   @atrans_id   
from deleted d  
  
/* AUDIT_CODE_END */  
  
declare @the_sequence       numeric(32, 0),  
        @the_tran_type      char(1),  
        @the_entity_name    varchar(30)  
  
   select @the_entity_name = 'TradeItemCashPhy'  
  
   if @num_rows = 1  
   begin  
      select @the_tran_type = it.type,  
             @the_sequence = it.sequence  
      from dbo.icts_transaction it WITH (NOLOCK)  
      where it.trans_id = @atrans_id  
  
      /* BEGIN_ALS_RUN_TOUCH */  
  
      insert into dbo.als_run_touch   
         (als_module_group_id, operation, entity_name,key1,key2,  
          key3,key4,key5,key6,key7,key8,trans_id,sequence)  
      select a.als_module_group_id,  
             'D',  
             @the_entity_name,  
             convert(varchar(40), d.trade_num),  
             convert(varchar(40), d.order_num),  
             convert(varchar(40), d.item_num),  
             null,  
             null,  
             null,  
             null,  
             null,  
             @atrans_id,  
             @the_sequence  
      from dbo.als_module_entity a WITH (NOLOCK),  
           dbo.server_config sc WITH (NOLOCK),  
           deleted d  
      where a.als_module_group_id = sc.als_module_group_id AND  
            ( ( ((sc.trans_type_mask &  1) =  1) and (@the_tran_type = 'E') ) OR  
              ( ((sc.trans_type_mask &  2) =  2) and (@the_tran_type = 'U') ) OR  
              ( ((sc.trans_type_mask &  4) =  4) and (@the_tran_type = 'S') ) OR  
              ( ((sc.trans_type_mask &  8) =  8) and (@the_tran_type = 'P') ) OR  
              ( ((sc.trans_type_mask & 16) = 16) and (@the_tran_type = 'I') ) OR  
              ( ((sc.trans_type_mask & 32) = 32) and (@the_tran_type = 'A') )  
            ) AND  
            (a.operation_type_mask & 4) = 4 AND  
            a.entity_name = @the_entity_name  
  
      /* END_ALS_RUN_TOUCH */  
  
      if @the_tran_type != 'E'  
      begin  
         /* BEGIN_TRANSACTION_TOUCH */  
  
         insert dbo.transaction_touch  
         select 'DELETE',  
                @the_entity_name,  
                'DIRECT',  
                convert(varchar(40), d.trade_num),  
                convert(varchar(40), d.order_num),  
                convert(varchar(40), d.item_num),  
                null,  
                null,  
                null,  
                null,  
                null,  
                @atrans_id,  
                @the_sequence  
         from deleted d  
  
         /* END_TRANSACTION_TOUCH */  
      end  
   end  
   else  
   begin  /* if @num_rows > 1 */  
      /* BEGIN_ALS_RUN_TOUCH */  
  
      insert into dbo.als_run_touch   
         (als_module_group_id, operation, entity_name,key1,key2,  
          key3,key4,key5,key6,key7,key8,trans_id,sequence)  
      select a.als_module_group_id,  
             'D',  
             @the_entity_name,  
             convert(varchar(40), d.trade_num),  
             convert(varchar(40), d.order_num),  
             convert(varchar(40), d.item_num),  
             null,  
             null,  
             null,  
             null,  
             null,  
             @atrans_id,  
             it.sequence  
      from dbo.als_module_entity a WITH (NOLOCK),  
           dbo.server_config sc WITH (NOLOCK),  
           deleted d,  
           dbo.icts_transaction it WITH (NOLOCK)  
      where a.als_module_group_id = sc.als_module_group_id AND  
            ( ( ((sc.trans_type_mask &  1) =  1) and (it.type = 'E') ) OR  
              ( ((sc.trans_type_mask &  2) =  2) and (it.type = 'U') ) OR  
              ( ((sc.trans_type_mask &  4) =  4) and (it.type = 'S') ) OR  
              ( ((sc.trans_type_mask &  8) =  8) and (it.type = 'P') ) OR  
              ( ((sc.trans_type_mask & 16) = 16) and (it.type = 'I') ) OR  
              ( ((sc.trans_type_mask & 32) = 32) and (it.type = 'A') )  
            ) AND  
            (a.operation_type_mask & 4) = 4 AND  
            a.entity_name = @the_entity_name AND  
            it.trans_id = @atrans_id  
  
      /* END_ALS_RUN_TOUCH */  
  
      /* BEGIN_TRANSACTION_TOUCH */  
  
      insert dbo.transaction_touch  
      select 'DELETE',  
             @the_entity_name,  
             'DIRECT',  
             convert(varchar(40), d.trade_num),  
             convert(varchar(40), d.order_num),  
             convert(varchar(40), d.item_num),  
             null,  
             null,  
             null,  
             null,  
             null,  
             @atrans_id,  
             it.sequence  
      from dbo.icts_transaction it WITH (NOLOCK),  
           deleted d  
      where it.trans_id = @atrans_id and  
            it.type != 'E'  
  
      /* END_TRANSACTION_TOUCH */  
   end  
  
return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_cash_phy_instrg]
on [dbo].[trade_item_cash_phy]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'TradeItemCashPhy'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where it.trans_id = i.trans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'I',
             @the_entity_name,
             convert(varchar(40),trade_num),
             convert(varchar(40),order_num),
             convert(varchar(40),item_num),
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             @the_sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           inserted i
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (@the_tran_type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (@the_tran_type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (@the_tran_type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (@the_tran_type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (@the_tran_type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (@the_tran_type = 'A') )
            ) AND
            (a.operation_type_mask & 1) = 1 AND
            a.entity_name = @the_entity_name

      /* END_ALS_RUN_TOUCH */

      if @the_tran_type != 'E'
      begin
         /* BEGIN_TRANSACTION_TOUCH */

         insert dbo.transaction_touch
         select 'INSERT',
                @the_entity_name,
                'DIRECT',
                convert(varchar(40),trade_num),
                convert(varchar(40),order_num),
                convert(varchar(40),item_num),
                null,
                null,
                null,
                null,
                null,
                i.trans_id,
                @the_sequence
         from inserted i

         /* END_TRANSACTION_TOUCH */
      end
   end
   else
   begin  /* if @num_rows > 1 */
      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'I',
             @the_entity_name,
             convert(varchar(40),trade_num),
             convert(varchar(40),order_num),
             convert(varchar(40),item_num),
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           inserted i,
           dbo.icts_transaction it WITH (NOLOCK)
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (it.type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (it.type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (it.type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (it.type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (it.type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (it.type = 'A') )
            ) AND
            (a.operation_type_mask & 1) = 1 AND
            a.entity_name = @the_entity_name AND
            i.trans_id = it.trans_id

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'INSERT',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40),trade_num),
             convert(varchar(40),order_num),
             convert(varchar(40),item_num),
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where i.trans_id = it.trans_id and
            it.type != 'E'

      /* END_TRANSACTION_TOUCH */
   end

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_cash_phy_updtrg]  
on [dbo].[trade_item_cash_phy]  
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
   raiserror ('(trade_item_cash_phy) The change needs to be attached with a new trans_id'  ,10,1)
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
      select @errmsg = '(trade_item_cash_phy) New trans_id must be larger than original trans_id.'  
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'  
      raiserror (@errmsg  ,10,1)
      if @@trancount > 0 rollback tran  

      return  
   end  
end  
  
if exists (select * from inserted i, deleted d  
           where i.trans_id < d.trans_id and  
                 i.trade_num = d.trade_num and   
                 i.order_num = d.order_num and   
                 i.item_num = d.item_num )  
begin  
   raiserror ('(trade_item_cash_phy) new trans_id must not be older than current trans_id.'  ,10,1)
   if @@trancount > 0 rollback tran  

   return  
end  
  
/* RECORD_STAMP_END */  
  
if update(trade_num) or   
   update(order_num) or    
   update(item_num)   
begin  
   select @count_num_rows = (select count(*) from inserted i, deleted d  
                             where i.trade_num = d.trade_num and   
                                   i.order_num = d.order_num and   
                                   i.item_num = d.item_num )  
   if (@count_num_rows = @num_rows)  
   begin  
      select @dummy_update = 1  
   end  
   else  
   begin  
      raiserror ('(trade_item_cash_phy) primary key can not be changed.'  ,10,1)
      if @@trancount > 0 rollback tran  

      return  
   end  
end  
  
/* AUDIT_CODE_BEGIN */  
  
if @dummy_update = 0  
   insert dbo.aud_trade_item_cash_phy  
      (trade_num,  
       order_num,  
       item_num,  
       min_qty,  
       min_qty_uom_code,  
       max_qty,  
       max_qty_uom_code,  
       total_settled_qty,  
       settled_qty_uom_code,  
       credit_term_code,  
       pay_days,  
       pay_term_code,  
       trade_imp_rec_ind,  
       trade_exp_rec_ind,  
       margin_conv_factor,  
       cfd_swap_ind,  
       efs_ind, 
       execution_date,
       trans_id,  
       resp_trans_id)  
   select  
      d.trade_num,  
      d.order_num,  
      d.item_num,  
      d.min_qty,  
      d.min_qty_uom_code,  
      d.max_qty,  
      d.max_qty_uom_code,  
      d.total_settled_qty,  
      d.settled_qty_uom_code,  
      d.credit_term_code,  
      d.pay_days,  
      d.pay_term_code,  
      d.trade_imp_rec_ind,  
      d.trade_exp_rec_ind,  
      d.margin_conv_factor,  
      d.cfd_swap_ind,  
      d.efs_ind,
      d.execution_date,
      d.trans_id,  
      i.trans_id      
   from deleted d, inserted i  
   where d.trade_num = i.trade_num and  
         d.order_num = i.order_num and  
         d.item_num = i.item_num   
  
/* AUDIT_CODE_END */  
  
declare @the_sequence       numeric(32, 0),  
        @the_tran_type      char(1),  
        @the_entity_name    varchar(30)  
  
   select @the_entity_name = 'TradeItemCashPhy'  
  
   if @num_rows = 1  
   begin  
      select @the_tran_type = it.type,  
             @the_sequence = it.sequence  
      from dbo.icts_transaction it WITH (NOLOCK),  
           inserted i  
      where it.trans_id = i.trans_id  
  
      /* BEGIN_ALS_RUN_TOUCH */  
  
      insert into dbo.als_run_touch   
         (als_module_group_id, operation, entity_name,key1,key2,  
          key3,key4,key5,key6,key7,key8,trans_id,sequence)  
      select a.als_module_group_id,  
             'U',  
             @the_entity_name,  
             convert(varchar(40),trade_num),  
             convert(varchar(40),order_num),  
             convert(varchar(40),item_num),  
             null,  
             null,  
             null,  
             null,  
             null,  
             i.trans_id,  
             @the_sequence  
      from dbo.als_module_entity a WITH (NOLOCK),  
           dbo.server_config sc WITH (NOLOCK),  
           inserted i  
      where a.als_module_group_id = sc.als_module_group_id AND  
            ( ( ((sc.trans_type_mask &  1) =  1) and (@the_tran_type = 'E') ) OR  
              ( ((sc.trans_type_mask &  2) =  2) and (@the_tran_type = 'U') ) OR  
              ( ((sc.trans_type_mask &  4) =  4) and (@the_tran_type = 'S') ) OR  
              ( ((sc.trans_type_mask &  8) =  8) and (@the_tran_type = 'P') ) OR  
              ( ((sc.trans_type_mask & 16) = 16) and (@the_tran_type = 'I') ) OR  
              ( ((sc.trans_type_mask & 32) = 32) and (@the_tran_type = 'A') )  
            ) AND  
            (a.operation_type_mask & 2) = 2 AND  
            a.entity_name = @the_entity_name  
  
      insert into dbo.als_run_touch   
         (als_module_group_id, operation, entity_name,key1,key2,  
          key3,key4,key5,key6,key7,key8,trans_id,sequence)  
      select a.als_module_group_id,  
             'U',  
             'TradeItem',  
             convert(varchar(40),trade_num),  
             convert(varchar(40),order_num),  
             convert(varchar(40),item_num),  
             null,  
             null,  
             null,  
             null,  
             null,  
             i.trans_id,  
             @the_sequence  
      from dbo.als_module_entity a WITH (NOLOCK),  
           dbo.server_config sc WITH (NOLOCK),  
           inserted i  
      where a.als_module_group_id = sc.als_module_group_id AND  
            ( ( ((sc.trans_type_mask &  1) =  1) and (@the_tran_type = 'E') ) OR  
              ( ((sc.trans_type_mask &  2) =  2) and (@the_tran_type = 'U') ) OR  
              ( ((sc.trans_type_mask &  4) =  4) and (@the_tran_type = 'S') ) OR  
              ( ((sc.trans_type_mask &  8) =  8) and (@the_tran_type = 'P') ) OR  
              ( ((sc.trans_type_mask & 16) = 16) and (@the_tran_type = 'I') ) OR  
              ( ((sc.trans_type_mask & 32) = 32) and (@the_tran_type = 'A') )  
            ) AND  
            (a.operation_type_mask & 2) = 2 AND  
            a.entity_name = 'TradeItem'  
  
      /* END_ALS_RUN_TOUCH */  
  
      /* BEGIN_TRANSACTION_TOUCH */  
  
      if @the_tran_type != 'E'  
      begin  
         /* BEGIN_TRANSACTION_TOUCH */  
  
         insert dbo.transaction_touch  
         select 'UPDATE',  
                @the_entity_name,  
                'DIRECT',  
                convert(varchar(40),trade_num),  
                convert(varchar(40),order_num),  
                convert(varchar(40),item_num),  
                null,  
                null,  
                null,  
                null,  
                null,  
                i.trans_id,  
                @the_sequence  
         from inserted i  
  
         insert dbo.transaction_touch  
         select 'UPDATE',  
                'TradeItem',  
                'INDIRECT',  
                convert(varchar(40),trade_num),  
                convert(varchar(40),order_num),  
                convert(varchar(40),item_num),  
                null,  
                null,  
                null,  
                null,  
                null,  
                i.trans_id,  
                it.sequence  
         from dbo.icts_transaction it WITH (NOLOCK),  
              inserted i  
         where i.trans_id = it.trans_id  
  
         /* END_TRANSACTION_TOUCH */  
      end  
   end  
   else  
   begin  /* if @num_rows > 1 */  
      /* BEGIN_ALS_RUN_TOUCH */  
  
      insert into dbo.als_run_touch   
         (als_module_group_id, operation, entity_name,key1,key2,  
          key3,key4,key5,key6,key7,key8,trans_id,sequence)  
      select a.als_module_group_id,  
             'U',  
             @the_entity_name,  
             convert(varchar(40),trade_num),  
             convert(varchar(40),order_num),  
             convert(varchar(40),item_num),  
             null,  
             null,  
             null,  
             null,  
             null,  
             i.trans_id,  
             it.sequence  
      from dbo.als_module_entity a WITH (NOLOCK),  
           dbo.server_config sc WITH (NOLOCK),  
           inserted i,  
           dbo.icts_transaction it WITH (NOLOCK)  
      where a.als_module_group_id = sc.als_module_group_id AND  
            ( ( ((sc.trans_type_mask &  1) =  1) and (it.type = 'E') ) OR  
              ( ((sc.trans_type_mask &  2) =  2) and (it.type = 'U') ) OR  
              ( ((sc.trans_type_mask &  4) =  4) and (it.type = 'S') ) OR  
              ( ((sc.trans_type_mask &  8) =  8) and (it.type = 'P') ) OR  
              ( ((sc.trans_type_mask & 16) = 16) and (it.type = 'I') ) OR  
              ( ((sc.trans_type_mask & 32) = 32) and (it.type = 'A') )  
            ) AND  
            (a.operation_type_mask & 2) = 2 AND  
            a.entity_name = @the_entity_name AND  
            i.trans_id = it.trans_id  
  
      insert into dbo.als_run_touch   
         (als_module_group_id, operation, entity_name,key1,key2,  
          key3,key4,key5,key6,key7,key8,trans_id,sequence)  
      select a.als_module_group_id,  
             'U',  
             'TradeItem',  
             convert(varchar(40),trade_num),  
             convert(varchar(40),order_num),  
             convert(varchar(40),item_num),  
             null,  
             null,  
             null,  
             null,  
             null,  
             i.trans_id,  
             it.sequence  
      from dbo.als_module_entity a WITH (NOLOCK),  
           dbo.server_config sc WITH (NOLOCK),  
           inserted i,  
           dbo.icts_transaction it WITH (NOLOCK)  
      where a.als_module_group_id = sc.als_module_group_id AND  
            ( ( ((sc.trans_type_mask &  1) =  1) and (it.type = 'E') ) OR  
              ( ((sc.trans_type_mask &  2) =  2) and (it.type = 'U') ) OR  
              ( ((sc.trans_type_mask &  4) =  4) and (it.type = 'S') ) OR  
              ( ((sc.trans_type_mask &  8) =  8) and (it.type = 'P') ) OR  
              ( ((sc.trans_type_mask & 16) = 16) and (it.type = 'I') ) OR  
              ( ((sc.trans_type_mask & 32) = 32) and (it.type = 'A') )  
            ) AND  
            (a.operation_type_mask & 2) = 2 AND  
            a.entity_name = 'TradeItem' AND  
            i.trans_id = it.trans_id  
  
      /* END_ALS_RUN_TOUCH */  
  
      /* BEGIN_TRANSACTION_TOUCH */  
  
      insert dbo.transaction_touch  
      select 'UPDATE',  
             @the_entity_name,  
             'DIRECT',  
             convert(varchar(40),trade_num),  
             convert(varchar(40),order_num),  
             convert(varchar(40),item_num),  
             null,  
             null,  
             null,  
             null,  
             null,  
             i.trans_id,  
             it.sequence  
      from dbo.icts_transaction it WITH (NOLOCK),  
           inserted i  
      where i.trans_id = it.trans_id and  
            it.type != 'E'  
  
      insert dbo.transaction_touch  
      select 'UPDATE',  
             'TradeItem',  
             'INDIRECT',  
             convert(varchar(40),trade_num),  
             convert(varchar(40),order_num),  
             convert(varchar(40),item_num),  
             null,  
             null,  
             null,  
             null,  
             null,  
             i.trans_id,  
             it.sequence  
      from dbo.icts_transaction it WITH (NOLOCK),  
           inserted i  
      where i.trans_id = it.trans_id and  
            it.type != 'E'  
  
      /* END_TRANSACTION_TOUCH */  
   end  
  
return
GO
ALTER TABLE [dbo].[trade_item_cash_phy] ADD CONSTRAINT [trade_item_cash_phy_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_cash_phy] ADD CONSTRAINT [trade_item_cash_phy_fk1] FOREIGN KEY ([credit_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[trade_item_cash_phy] ADD CONSTRAINT [trade_item_cash_phy_fk2] FOREIGN KEY ([pay_term_code]) REFERENCES [dbo].[payment_term] ([pay_term_code])
GO
ALTER TABLE [dbo].[trade_item_cash_phy] ADD CONSTRAINT [trade_item_cash_phy_fk4] FOREIGN KEY ([min_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_cash_phy] ADD CONSTRAINT [trade_item_cash_phy_fk5] FOREIGN KEY ([max_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_cash_phy] ADD CONSTRAINT [trade_item_cash_phy_fk6] FOREIGN KEY ([settled_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[trade_item_cash_phy] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_cash_phy] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_cash_phy] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_cash_phy] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'trade_item_cash_phy', NULL, NULL
GO
