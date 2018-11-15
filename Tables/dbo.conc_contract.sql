CREATE TABLE [dbo].[conc_contract]
(
[oid] [int] NOT NULL,
[custom_contract_num] [int] NOT NULL,
[version_num] [int] NOT NULL,
[custom_contract_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_reference] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contractual_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_year] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[book_comp_num] [int] NULL,
[acct_num] [int] NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[conc_brand_id] [int] NULL,
[workflow_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trader_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[traffic_operator] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cargo_conditioning] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[weighing_method_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[orig_contr_qty] [float] NULL,
[total_contr_qty] [float] NULL,
[total_execution_qty] [float] NULL,
[totoal_open_contr_qty] [float] NULL,
[total_contr_min] [float] NULL,
[total_contr_max] [float] NULL,
[main_formula_num] [int] NULL,
[market_formula_num] [int] NULL,
[real_port_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[risk_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fixed_price_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_fixed_price] [float] NULL,
[contract_fixed_price_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_fixed_curr_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[wsmd_settlement_basis] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[wsmd_insp_acct_num] [int] NULL,
[sample_lot_size] [float] NULL,
[sample_lot_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_date] [datetime] NULL,
[contract_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[origin_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[conc_contract_deltrg]
on [dbo].[conc_contract]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   int

set @num_rows = @@rowcount
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
   set @errmsg = '(conc_contract) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      set @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,16,1)
   rollback tran
   return
end


insert dbo.aud_conc_contract
   (
	oid,
	custom_contract_num,
	version_num,
	custom_contract_id,
	external_reference,
	p_s_ind,
	contractual_type,
	contract_year,
	book_comp_num,
	acct_num,
	cmdty_code,
	conc_brand_id,
	workflow_status_code,
	contract_status_code,
	trader_init,
	traffic_operator,
	cargo_conditioning,
	weighing_method_code,
	orig_contr_qty,
	total_contr_qty,
	total_execution_qty,
	totoal_open_contr_qty,
	total_contr_min,
	total_contr_max,
	main_formula_num,
	market_formula_num,
	real_port_num,
	risk_mkt_code,
	fixed_price_ind,
	contract_fixed_price,
	contract_fixed_price_uom,
	contract_fixed_curr_code,
	wsmd_settlement_basis,
	wsmd_insp_acct_num,
	sample_lot_size,
	sample_lot_uom_code,
	creation_date,
	contract_curr_code,
	origin_country_code,
	trans_id,
	resp_trans_id
   )
select
    d.oid,
	d.custom_contract_num,
	d.version_num,
	d.custom_contract_id,
	d.external_reference,
	d.p_s_ind,
	d.contractual_type,
	d.contract_year,
	d.book_comp_num,
	d.acct_num,
	d.cmdty_code,
	d.conc_brand_id,
	d.workflow_status_code,
	d.contract_status_code,
	d.trader_init,
	d.traffic_operator,
	d.cargo_conditioning,
	d.weighing_method_code,
	d.orig_contr_qty,
	d.total_contr_qty,
	d.total_execution_qty,
	d.totoal_open_contr_qty,
	d.total_contr_min,
	d.total_contr_max,
	d.main_formula_num,
	d.market_formula_num,
	d.real_port_num,
	d.risk_mkt_code,
	d.fixed_price_ind,
	d.contract_fixed_price,
	d.contract_fixed_price_uom,
	d.contract_fixed_curr_code,
	d.wsmd_settlement_basis,
	d.wsmd_insp_acct_num,
	d.sample_lot_size,
	d.sample_lot_uom_code,
	d.creation_date,
	d.contract_curr_code,
    d.origin_country_code,	
	d.trans_id,
    @atrans_id
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   set @the_entity_name = 'ConcContract'

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
             convert(varchar(40),d.oid),
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
                convert(varchar(40),d.oid),
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
             convert(varchar(40),d.oid),
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
             convert(varchar(40),d.oid),
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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[conc_contract_instrg]
on [dbo].[conc_contract]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

set @num_rows = @@rowcount
if @num_rows = 0
   return   

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   set @the_entity_name = 'ConcContract'

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
             convert(varchar(40),oid),
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

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'INSERT',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40),oid),
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
   else
   begin  /* if @num_rows > 1 */
      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'I',
             @the_entity_name,
             convert(varchar(40),oid),
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
             convert(varchar(40), oid),
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
      where i.trans_id = it.trans_id

      /* END_TRANSACTION_TOUCH */
   end

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[conc_contract_updtrg]
on [dbo].[conc_contract]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errmsg           varchar(255)

set @num_rows = @@rowcount
if @num_rows = 0
   return

set @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id)
begin
   raiserror ('(conc_contract) The change needs to be attached with a new trans_id',16,1)
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
      set @errmsg = '(conc_contract) New trans_id must be larger than original trans_id.'
      set @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      rollback tran
      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid )
begin
   raiserror ('(conc_contract) new trans_id must not be older than current trans_id.',16,1)
   rollback tran
   return
end

/* RECORD_STAMP_END */

if update(oid)
begin
   set @count_num_rows = (select count(*) from inserted i, deleted d
                          where i.oid = d.oid )
   if (@count_num_rows = @num_rows)
      set @dummy_update = 1
   else
   begin
      raiserror ('(conc_contract) primary key can not be changed.',16,1)
      rollback tran
      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_conc_contract
      (
	   oid,	
	   custom_contract_num,
	   version_num,
	   custom_contract_id,
	   external_reference,
	   p_s_ind,
	   contractual_type,
	   contract_year,
	   book_comp_num,
	   acct_num,
	   cmdty_code,
	   conc_brand_id,
	   workflow_status_code,
	   contract_status_code,
	   trader_init,
	   traffic_operator,
	   cargo_conditioning,
	   weighing_method_code,
	   orig_contr_qty,
	   total_contr_qty,
	   total_execution_qty,
	   totoal_open_contr_qty,
	   total_contr_min,
	   total_contr_max,
	   main_formula_num,
	   market_formula_num,
	   real_port_num,
	   risk_mkt_code,
	   fixed_price_ind,
	   contract_fixed_price,
	   contract_fixed_price_uom,
	   contract_fixed_curr_code,
	   wsmd_settlement_basis,
	   wsmd_insp_acct_num,
	   sample_lot_size,
	   sample_lot_uom_code,
	   creation_date,
	   contract_curr_code,
       origin_country_code,	
	   trans_id,
	   resp_trans_id
	  )
   select
      d.oid,
	  d.custom_contract_num,
	  d.version_num,
	  d.custom_contract_id,
	  d.external_reference,
	  d.p_s_ind,
	  d.contractual_type,
	  d.contract_year,
	  d.book_comp_num,
	  d.acct_num,
	  d.cmdty_code,
	  d.conc_brand_id,
	  d.workflow_status_code,
	  d.contract_status_code,
	  d.trader_init,
	  d.traffic_operator,
	  d.cargo_conditioning,
	  d.weighing_method_code,
	  d.orig_contr_qty,
	  d.total_contr_qty,
	  d.total_execution_qty,
	  d.totoal_open_contr_qty,
	  d.total_contr_min,
	  d.total_contr_max,
	  d.main_formula_num,
	  d.market_formula_num,
	  d.real_port_num,
	  d.risk_mkt_code,
	  d.fixed_price_ind,
	  d.contract_fixed_price,
	  d.contract_fixed_price_uom,
	  d.contract_fixed_curr_code,
	  d.wsmd_settlement_basis,
	  d.wsmd_insp_acct_num,
	  d.sample_lot_size,
	  d.sample_lot_uom_code,
	  d.creation_date,
	  d.contract_curr_code,
      d.origin_country_code,	
	  d.trans_id,
	  i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   set @the_entity_name = 'ConcContract'

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
             convert(varchar(40),oid),
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
                convert(varchar(40),oid),
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
             convert(varchar(40),oid),
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
             convert(varchar(40),oid),
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
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [CK__conc_cont__p_s_i__7C06F46F] CHECK (([p_s_ind]='S' OR [p_s_ind]='P'))
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [CK__conc_cont__wsmd___7CFB18A8] CHECK (([wsmd_settlement_basis]='S' OR [wsmd_settlement_basis]='B' OR [wsmd_settlement_basis]='C'))
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk10] FOREIGN KEY ([cargo_conditioning]) REFERENCES [dbo].[cargo_condition] ([cargo_cond_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk11] FOREIGN KEY ([weighing_method_code]) REFERENCES [dbo].[weighing_method] ([weigh_method_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk12] FOREIGN KEY ([risk_mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk13] FOREIGN KEY ([contract_fixed_price_uom]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk14] FOREIGN KEY ([contract_fixed_curr_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk15] FOREIGN KEY ([sample_lot_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk16] FOREIGN KEY ([contract_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk17] FOREIGN KEY ([origin_country_code]) REFERENCES [dbo].[country] ([country_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk2] FOREIGN KEY ([book_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk3] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk4] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk5] FOREIGN KEY ([conc_brand_id]) REFERENCES [dbo].[conc_brand] ([oid])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk6] FOREIGN KEY ([workflow_status_code]) REFERENCES [dbo].[workflow_status] ([status_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk7] FOREIGN KEY ([contract_status_code]) REFERENCES [dbo].[contract_status] ([contr_status_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk8] FOREIGN KEY ([trader_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk9] FOREIGN KEY ([traffic_operator]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[conc_contract] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[conc_contract] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[conc_contract] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[conc_contract] TO [next_usr]
GO
