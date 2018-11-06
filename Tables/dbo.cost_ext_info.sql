CREATE TABLE [dbo].[cost_ext_info]
(
[cost_num] [int] NOT NULL,
[pr_cost_num] [int] NULL,
[prepayment_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voyage_code] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[qty_adj_rule_num] [int] NULL,
[qty_adj_factor] [float] NULL,
[orig_voucher_num] [int] NULL,
[pay_term_override_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[vat_rate] [numeric] (12, 6) NULL,
[discount_rate] [numeric] (12, 6) NULL,
[cost_pl_contribution_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__cost_ext___cost___1A69E950] DEFAULT ('Y'),
[material_code] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[related_cost_num] [int] NULL,
[fx_exp_num] [int] NULL,
[creation_fx_rate] [numeric] (20, 8) NULL,
[creation_rate_m_d_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__cost_ext___creat__1C5231C2] DEFAULT ('M'),
[fx_link_oid] [int] NULL,
[fx_locking_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__cost_ext___fx_lo__1E3A7A34] DEFAULT ('N'),
[fx_compute_ind] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fx_real_port_num] [int] NULL,
[reserve_cost_amt] [numeric] (20, 8) NULL,
[pl_contrib_mod_transid] [int] NULL,
[manual_input_pl_contrib_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__cost_ext___manua__2022C2A6] DEFAULT ('N'),
[cost_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[risk_cover_num] [int] NULL,
[prelim_type_override_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_num] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cost_ext_info_deltrg]
on [dbo].[cost_ext_info]
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
   select @errmsg = '(cost_ext_info) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_cost_ext_info
   (cost_num,
    pr_cost_num,
    prepayment_ind,
    voyage_code,
    trans_id,
    resp_trans_id,
    qty_adj_rule_num,
    qty_adj_factor,
    orig_voucher_num,
    pay_term_override_ind,
    vat_rate,
    discount_rate,
    cost_pl_contribution_ind,
    material_code,
    related_cost_num,
    fx_exp_num,
    creation_fx_rate,
    creation_rate_m_d_ind,
    fx_link_oid,
    fx_locking_status,
    fx_compute_ind,
    fx_real_port_num,
    reserve_cost_amt,
    pl_contrib_mod_transid,
    manual_input_pl_contrib_ind,
    cost_desc,
    risk_cover_num,
    prelim_type_override_ind,
    lc_num)
select
   d.cost_num,
   d.pr_cost_num,
   d.prepayment_ind,
   d.voyage_code,
   d.trans_id,
   @atrans_id,
   d.qty_adj_rule_num,
   d.qty_adj_factor,
   d.orig_voucher_num,
   d.pay_term_override_ind,
   d.vat_rate,
   d.discount_rate,
   d.cost_pl_contribution_ind,
   d.material_code,
   d.related_cost_num,
   d.fx_exp_num,
   d.creation_fx_rate,
   d.creation_rate_m_d_ind,
   d.fx_link_oid,
   d.fx_locking_status,
   d.fx_compute_ind,
   d.fx_real_port_num,
   d.reserve_cost_amt,
   d.pl_contrib_mod_transid,
   d.manual_input_pl_contrib_ind,
   d.cost_desc,
   d.risk_cover_num,
   d.prelim_type_override_ind,
   d.lc_num
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'CostExtInfo'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it
      where it.trans_id = @atrans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'D',
             @the_entity_name,
             convert(varchar(40), d.cost_num),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             @the_sequence
      from dbo.als_module_entity a,
           dbo.server_config sc,
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

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'DELETE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), d.cost_num),
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
   else
   begin  /* if @num_rows > 1 */
      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'D',
             @the_entity_name,
             convert(varchar(40), d.cost_num),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             it.sequence
      from dbo.als_module_entity a,
           dbo.server_config sc,
           deleted d,
           dbo.icts_transaction it
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
             convert(varchar(40), d.cost_num),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             it.sequence
      from dbo.icts_transaction it,
           deleted d
      where it.trans_id = @atrans_id

      /* END_TRANSACTION_TOUCH */
   end

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cost_ext_info_instrg]
on [dbo].[cost_ext_info]
for insert
as
declare @num_rows        int,
        @count_num_rows  int,
        @errmsg          varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'CostExtInfo'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it,
           inserted i
      where it.trans_id = i.trans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'I',
             @the_entity_name,
             convert(varchar(40), cost_num),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             @the_sequence
      from dbo.als_module_entity a,
           dbo.server_config sc,
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
             convert(varchar(40), cost_num),
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
             convert(varchar(40), cost_num),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.als_module_entity a,
           dbo.server_config sc,
           inserted i,
           dbo.icts_transaction it
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
             convert(varchar(40), i.cost_num),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it,
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

create trigger [dbo].[cost_ext_info_updtrg]
on [dbo].[cost_ext_info]
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
   raiserror ('(cost_ext_info) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(cost_ext_info) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.cost_num = d.cost_num )
begin
   raiserror ('(cost_ext_info) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(cost_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.cost_num = d.cost_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(cost_ext_info) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_cost_ext_info
      (cost_num,
       pr_cost_num,
       prepayment_ind,
       voyage_code,
       trans_id,
       resp_trans_id,
       qty_adj_rule_num,
       qty_adj_factor,
       orig_voucher_num,
       pay_term_override_ind,
       vat_rate,
       discount_rate,
       cost_pl_contribution_ind,
       material_code,
       related_cost_num,
       fx_exp_num,
       creation_fx_rate,
       creation_rate_m_d_ind,
       fx_link_oid,
       fx_locking_status,
       fx_compute_ind,
       fx_real_port_num,
       reserve_cost_amt,
       pl_contrib_mod_transid,
       manual_input_pl_contrib_ind,
       cost_desc,
       risk_cover_num,
       prelim_type_override_ind,
       lc_num)
   select
      d.cost_num,
      d.pr_cost_num,
      d.prepayment_ind,
      d.voyage_code,
      d.trans_id,
      i.trans_id,
      d.qty_adj_rule_num,
      d.qty_adj_factor,
      d.orig_voucher_num,
      d.pay_term_override_ind,
      d.vat_rate,
      d.discount_rate,
      d.cost_pl_contribution_ind,
      d.material_code,
      d.related_cost_num,
      d.fx_exp_num,
      d.creation_fx_rate,
      d.creation_rate_m_d_ind,
      d.fx_link_oid,
      d.fx_locking_status,
      d.fx_compute_ind,
      d.fx_real_port_num,
      d.reserve_cost_amt,
      d.pl_contrib_mod_transid,
      d.manual_input_pl_contrib_ind,
      d.cost_desc,
      d.risk_cover_num,
      d.prelim_type_override_ind,
      d.lc_num
   from deleted d, inserted i
   where d.cost_num = i.cost_num 

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'CostExtInfo'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it,
           inserted i
      where it.trans_id = i.trans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'U',
             @the_entity_name,
             convert(varchar(40), cost_num),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             @the_sequence
      from dbo.als_module_entity a,
           dbo.server_config sc,
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

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'UPDATE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), cost_num),
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
             'U',
             @the_entity_name,
             convert(varchar(40), cost_num),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.als_module_entity a,
           dbo.server_config sc,
           inserted i,
           dbo.icts_transaction it
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
             convert(varchar(40), i.cost_num),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it,
           inserted i
      where i.trans_id = it.trans_id

      /* END_TRANSACTION_TOUCH */
   end
   
return
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [CK__cost_ext___cost___1B5E0D89] CHECK (([cost_pl_contribution_ind]='N' OR [cost_pl_contribution_ind]='Y'))
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [CK__cost_ext___creat__1D4655FB] CHECK (([creation_rate_m_d_ind]='D' OR [creation_rate_m_d_ind]='M'))
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [CK__cost_ext___fx_lo__1F2E9E6D] CHECK (([fx_locking_status]='L' OR [fx_locking_status]='U' OR [fx_locking_status]='O' OR [fx_locking_status]='N'))
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [CK__cost_ext___manua__2116E6DF] CHECK (([manual_input_pl_contrib_ind]='N' OR [manual_input_pl_contrib_ind]='Y'))
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [CK__cost_ext___preli__220B0B18] CHECK (([prelim_type_override_ind]='N' OR [prelim_type_override_ind]='Y'))
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [cost_ext_info_pk] PRIMARY KEY CLUSTERED  ([cost_num]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [cost_ext_info_idx1] ON [dbo].[cost_ext_info] ([cost_num], [cost_pl_contribution_ind]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [cost_ext_info_fk3] FOREIGN KEY ([voyage_code]) REFERENCES [dbo].[voyage] ([voyage_code])
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [cost_ext_info_fk6] FOREIGN KEY ([fx_real_port_num]) REFERENCES [dbo].[portfolio] ([port_num])
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [cost_ext_info_fk7] FOREIGN KEY ([fx_link_oid]) REFERENCES [dbo].[fx_linking] ([oid])
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [cost_ext_info_fk8] FOREIGN KEY ([fx_exp_num]) REFERENCES [dbo].[fx_exposure] ([oid])
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [cost_ext_info_fk9] FOREIGN KEY ([risk_cover_num]) REFERENCES [dbo].[risk_cover] ([risk_cover_num])
GO
GRANT DELETE ON  [dbo].[cost_ext_info] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cost_ext_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cost_ext_info] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cost_ext_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'cost_ext_info', NULL, NULL
GO
