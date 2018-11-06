CREATE TABLE [dbo].[trade]
(
[trade_num] [int] NOT NULL,
[trader_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[conclusion_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inhouse_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_num] [int] NULL,
[acct_cont_num] [int] NULL,
[acct_short_name] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_ref_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[port_num] [int] NULL,
[concluded_date] [datetime] NULL,
[contr_approv_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_date] [datetime] NULL,
[cr_anly_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cp_gov_contr_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_exch_method] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_cnfrm_method] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_tlx_hold_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_date] [datetime] NOT NULL,
[creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trade_mod_date] [datetime] NULL,
[trade_mod_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[invoice_cap_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[internal_agreement_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_res_exp_date] [datetime] NULL,
[contr_anly_init] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_order_num] [smallint] NULL,
[is_long_term_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__trade__is_long_t__2CC890AD] DEFAULT ('N'),
[special_contract_num] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cargo_id_number] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[internal_parent_trade_num] [int] NULL,
[copy_type] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[product_id] [int] NULL,
[econfirm_status] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_trade_type] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_deltrg]
on [dbo].[trade]
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
   select @errmsg = '(trade) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_trade
   (trade_num,
    trader_init,
    trade_status_code,
    conclusion_type,
    inhouse_ind,
    acct_num,
    acct_cont_num,
    acct_short_name,
    acct_ref_num,
    port_num,
    concluded_date,
    contr_approv_type,
    contr_date,
    cr_anly_init,
    credit_term_code,
    cp_gov_contr_ind,
    contr_exch_method,
    contr_cnfrm_method,
    contr_tlx_hold_ind,
    creation_date,
    creator_init,
    trade_mod_date,
    trade_mod_init,
    invoice_cap_type,
    internal_agreement_ind,
    credit_status,
    credit_res_exp_date,
    contr_anly_init,
    contr_status_code,
    max_order_num,
    is_long_term_ind,
    special_contract_num,
    cargo_id_number,
    internal_parent_trade_num,
    copy_type,
    product_id,
    econfirm_status,
    external_trade_type,
    trans_id,
    resp_trans_id)
select
   d.trade_num,
   d.trader_init,
   d.trade_status_code,
   d.conclusion_type,
   d.inhouse_ind,
   d.acct_num,
   d.acct_cont_num,
   d.acct_short_name,
   d.acct_ref_num,
   d.port_num,
   d.concluded_date,
   d.contr_approv_type,
   d.contr_date,
   d.cr_anly_init,
   d.credit_term_code,
   d.cp_gov_contr_ind,
   d.contr_exch_method,
   d.contr_cnfrm_method,
   d.contr_tlx_hold_ind,
   d.creation_date,
   d.creator_init,
   d.trade_mod_date,
   d.trade_mod_init,
   d.invoice_cap_type,
   d.internal_agreement_ind,
   d.credit_status,
   d.credit_res_exp_date,
   d.contr_anly_init,
   d.contr_status_code,
   d.max_order_num,
   d.is_long_term_ind,
   d.special_contract_num,
   d.cargo_id_number,
   d.internal_parent_trade_num,
   d.copy_type,
   d.product_id,
   d.econfirm_status,
   d.external_trade_type,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'Trade'

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
             convert(varchar(40),d.trade_num),
             null,
             null,
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
                convert(varchar(40),d.trade_num),
                null,
                null,
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
             convert(varchar(40),d.trade_num),
             null,
             null,
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
             convert(varchar(40),d.trade_num),
             null,
             null,
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

create trigger [dbo].[trade_instrg]
on [dbo].[trade]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

   if (select count(*)
       from inserted
       where UPPER(inhouse_ind) = 'Y' and
             UPPER(conclusion_type) = 'C' and
             port_num IS NULL or
             port_num = 0) > 0
   begin
      raiserror ('You must provide a port_num for an inhouse trade!',10,1)
      if @@trancount > 0 rollback tran

      return
   end
   
declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'Trade'

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
             null,
             null,
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
                null,
                null,
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
             null,
             null,
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
             null,
             null,
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

create trigger [dbo].[trade_updtrg]
on [dbo].[trade]
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
   raiserror ('(trade) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(trade) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.trade_num = d.trade_num )
begin
   raiserror ('(trade) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(trade_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.trade_num = d.trade_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(trade) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if (select count(*)
    from inserted
    where UPPER(inhouse_ind) = 'Y' and
          UPPER(conclusion_type) = 'C' and
          port_num IS NULL or
          port_num = 0) > 0
begin
   raiserror ('You must provide a port_num for an inhouse trade!',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_trade
      (trade_num,
       trader_init,
       trade_status_code,
       conclusion_type,
       inhouse_ind,
       acct_num,
       acct_cont_num,
       acct_short_name,
       acct_ref_num,
       port_num,
       concluded_date,
       contr_approv_type,
       contr_date,
       cr_anly_init,
       credit_term_code,
       cp_gov_contr_ind,
       contr_exch_method,
       contr_cnfrm_method,
       contr_tlx_hold_ind,
       creation_date,
       creator_init,
       trade_mod_date,
       trade_mod_init,
       invoice_cap_type,
       internal_agreement_ind,
       credit_status,
       credit_res_exp_date,
       contr_anly_init,
       contr_status_code,
       max_order_num,
       is_long_term_ind,
       special_contract_num,
       cargo_id_number,
       internal_parent_trade_num,
       copy_type,
       product_id,
       econfirm_status,
       external_trade_type,
       trans_id,
       resp_trans_id)
   select
      d.trade_num,
      d.trader_init,
      d.trade_status_code,
      d.conclusion_type,
      d.inhouse_ind,
      d.acct_num,
      d.acct_cont_num,
      d.acct_short_name,
      d.acct_ref_num,
      d.port_num,
      d.concluded_date,
      d.contr_approv_type,
      d.contr_date,
      d.cr_anly_init,
      d.credit_term_code,
      d.cp_gov_contr_ind,
      d.contr_exch_method,
      d.contr_cnfrm_method,
      d.contr_tlx_hold_ind,
      d.creation_date,
      d.creator_init,
      d.trade_mod_date,
      d.trade_mod_init,
      d.invoice_cap_type,
      d.internal_agreement_ind,
      d.credit_status,
      d.credit_res_exp_date,
      d.contr_anly_init,
      d.contr_status_code,
      d.max_order_num,
      d.is_long_term_ind,
      d.special_contract_num,
      d.cargo_id_number,
      d.internal_parent_trade_num,
      d.copy_type,
      d.product_id,
      d.econfirm_status,
      d.external_trade_type,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.trade_num = i.trade_num 

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'Trade'

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
             null,
             null,
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

      /* END_ALS_RUN_TOUCH */

      if @the_tran_type != 'E'
      begin
         /* BEGIN_TRANSACTION_TOUCH */

         insert dbo.transaction_touch
         select 'UPDATE',
                @the_entity_name,
                'DIRECT',
                convert(varchar(40),trade_num),
                null,
                null,
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
             'U',
             @the_entity_name,
             convert(varchar(40),trade_num),
             null,
             null,
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

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'UPDATE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40),trade_num),
             null,
             null,
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
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_pk] PRIMARY KEY CLUSTERED  ([trade_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_idx2] ON [dbo].[trade] ([acct_num], [trade_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_TS_idx90] ON [dbo].[trade] ([creation_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_idx3] ON [dbo].[trade] ([port_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_POSGRID_idx1] ON [dbo].[trade] ([trade_num]) INCLUDE ([acct_num], [contr_date], [creation_date], [inhouse_ind], [port_num], [trade_mod_date], [trader_init]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_idx1] ON [dbo].[trade] ([trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_fk10] FOREIGN KEY ([trade_status_code]) REFERENCES [dbo].[trade_status] ([trade_status_code])
GO
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_fk12] FOREIGN KEY ([product_id]) REFERENCES [dbo].[icts_product] ([product_id])
GO
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_fk2] FOREIGN KEY ([acct_num], [acct_cont_num]) REFERENCES [dbo].[account_contact] ([acct_num], [acct_cont_num])
GO
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_fk3] FOREIGN KEY ([contr_status_code]) REFERENCES [dbo].[contract_status] ([contr_status_code])
GO
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_fk4] FOREIGN KEY ([credit_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_fk5] FOREIGN KEY ([trader_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_fk6] FOREIGN KEY ([cr_anly_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_fk7] FOREIGN KEY ([creator_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_fk8] FOREIGN KEY ([trade_mod_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[trade] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'trade', NULL, NULL
GO
