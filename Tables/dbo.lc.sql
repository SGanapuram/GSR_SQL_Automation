CREATE TABLE [dbo].[lc]
(
[lc_num] [int] NOT NULL,
[lc_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_exp_imp_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_usage_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_final_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_evergreen_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_evergreen_roll_days] [smallint] NULL,
[lc_evergreen_ext_days] [smallint] NULL,
[lc_stale_doc_allow_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_stale_doc_days] [smallint] NULL,
[lc_loi_presented_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_negotiate_clause] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_confirm_reqd_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_confirm_date] [datetime] NULL,
[lc_issue_date] [datetime] NULL,
[lc_request_date] [datetime] NULL,
[lc_exp_date] [datetime] NULL,
[lc_exp_event] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_exp_days] [smallint] NULL,
[lc_exp_days_oper] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_office_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_short_cmnt] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_cr_analyst_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_transact_or_blanket] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_applicant] [int] NULL,
[lc_beneficiary] [int] NULL,
[lc_advising_bank] [int] NULL,
[lc_issuing_bank] [int] NULL,
[lc_negotiating_bank] [int] NULL,
[lc_confirming_bank] [int] NULL,
[trans_id] [int] NOT NULL,
[guarantor_acct_num] [int] NULL,
[pcg_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[collateral_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_netting_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__lc__lc_netting_i__61516785] DEFAULT ('N'),
[lc_template_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__lc__lc_template___6339AFF7] DEFAULT ('N'),
[other_lcs_rel_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__lc__other_lcs_re__6521F869] DEFAULT ('N'),
[lc_template_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_template_creator] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_ref_key] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_dispute_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_dispute_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_priority] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_custom_column1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_custom_column2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[lc_deltrg]
on [dbo].[lc]
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
   select @errmsg = '(lc) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_lc
   (lc_num,
    lc_type_code,
    lc_exp_imp_ind,
    lc_usage_code,
    lc_status_code,
    lc_final_ind,
    lc_evergreen_status,
    lc_evergreen_roll_days,
    lc_evergreen_ext_days,
    lc_stale_doc_allow_ind,
    lc_stale_doc_days,
    lc_loi_presented_ind,
    lc_negotiate_clause,
    lc_confirm_reqd_ind,
    lc_confirm_date,
    lc_issue_date,
    lc_request_date,
    lc_exp_date,
    lc_exp_event,
    lc_exp_days,
    lc_exp_days_oper,
    lc_office_loc_code,
    lc_short_cmnt,
    lc_cr_analyst_init,
    lc_transact_or_blanket,
    lc_applicant,
    lc_beneficiary,
    lc_advising_bank,
    lc_issuing_bank,
    lc_negotiating_bank,
    lc_confirming_bank,
    guarantor_acct_num, 
    pcg_type_code,
    collateral_type_code,
    lc_netting_ind,
    lc_template_ind,
    other_lcs_rel_ind,
    lc_template_name,
    lc_template_creator,
    external_ref_key,
    lc_dispute_ind,
    lc_dispute_status,
    lc_priority,
    lc_custom_column1,
    lc_custom_column2,
    trans_id,
    resp_trans_id)
select
   d.lc_num,
   d.lc_type_code,
   d.lc_exp_imp_ind,
   d.lc_usage_code,
   d.lc_status_code,
   d.lc_final_ind,
   d.lc_evergreen_status,
   d.lc_evergreen_roll_days,
   d.lc_evergreen_ext_days,
   d.lc_stale_doc_allow_ind,
   d.lc_stale_doc_days,
   d.lc_loi_presented_ind,
   d.lc_negotiate_clause,
   d.lc_confirm_reqd_ind,
   d.lc_confirm_date,
   d.lc_issue_date,
   d.lc_request_date,
   d.lc_exp_date,
   d.lc_exp_event,
   d.lc_exp_days,
   d.lc_exp_days_oper,
   d.lc_office_loc_code,
   d.lc_short_cmnt,
   d.lc_cr_analyst_init,
   d.lc_transact_or_blanket,
   d.lc_applicant,
   d.lc_beneficiary,
   d.lc_advising_bank,
   d.lc_issuing_bank,
   d.lc_negotiating_bank,
   d.lc_confirming_bank,
   d.guarantor_acct_num, 
   d.pcg_type_code,
   d.collateral_type_code,
   d.lc_netting_ind,
   d.lc_template_ind,
   d.other_lcs_rel_ind,
   d.lc_template_name,
   d.lc_template_creator,
   d.external_ref_key,
   d.lc_dispute_ind,
   d.lc_dispute_status,
   d.lc_priority,
   d.lc_custom_column1,
   d.lc_custom_column2,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'Lc'

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
             convert(varchar(40), d.lc_num),
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
                convert(varchar(40), d.lc_num),
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
             convert(varchar(40), d.lc_num),
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
             convert(varchar(40), d.lc_num),
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

create trigger [dbo].[lc_instrg]
on [dbo].[lc]
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

   select @the_entity_name = 'Lc'

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
             convert(varchar(40), i.lc_num),
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
                convert(varchar(40), i.lc_num),
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
             convert(varchar(40), i.lc_num),
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
             convert(varchar(40), i.lc_num),
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

create trigger [dbo].[lc_updtrg]
on [dbo].[lc]
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
   raiserror ('(lc) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(lc) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.lc_num = d.lc_num )
begin
   raiserror ('(lc) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(lc_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.lc_num = d.lc_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(lc) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_lc
      (lc_num,
       lc_type_code,
       lc_exp_imp_ind,
       lc_usage_code,
       lc_status_code,
       lc_final_ind,
       lc_evergreen_status,
       lc_evergreen_roll_days,
       lc_evergreen_ext_days,
       lc_stale_doc_allow_ind,
       lc_stale_doc_days,
       lc_loi_presented_ind,
       lc_negotiate_clause,
       lc_confirm_reqd_ind,
       lc_confirm_date,
       lc_issue_date,
       lc_request_date,
       lc_exp_date,
       lc_exp_event,
       lc_exp_days,
       lc_exp_days_oper,
       lc_office_loc_code,
       lc_short_cmnt,
       lc_cr_analyst_init,
       lc_transact_or_blanket,
       lc_applicant,
       lc_beneficiary,
       lc_advising_bank,
       lc_issuing_bank,
       lc_negotiating_bank,
       lc_confirming_bank,
       guarantor_acct_num, 
       pcg_type_code,
       collateral_type_code,
       lc_netting_ind,
       lc_template_ind,
       other_lcs_rel_ind,
       lc_template_name,
       lc_template_creator,
       external_ref_key,
       lc_dispute_ind,
       lc_dispute_status,
       lc_priority,
       lc_custom_column1,
       lc_custom_column2,
       trans_id,
       resp_trans_id)
   select
      d.lc_num,
      d.lc_type_code,
      d.lc_exp_imp_ind,
      d.lc_usage_code,
      d.lc_status_code,
      d.lc_final_ind,
      d.lc_evergreen_status,
      d.lc_evergreen_roll_days,
      d.lc_evergreen_ext_days,
      d.lc_stale_doc_allow_ind,
      d.lc_stale_doc_days,
      d.lc_loi_presented_ind,
      d.lc_negotiate_clause,
      d.lc_confirm_reqd_ind,
      d.lc_confirm_date,
      d.lc_issue_date,
      d.lc_request_date,
      d.lc_exp_date,
      d.lc_exp_event,
      d.lc_exp_days,
      d.lc_exp_days_oper,
      d.lc_office_loc_code,
      d.lc_short_cmnt,
      d.lc_cr_analyst_init,
      d.lc_transact_or_blanket,
      d.lc_applicant,
      d.lc_beneficiary,
      d.lc_advising_bank,
      d.lc_issuing_bank,
      d.lc_negotiating_bank,
      d.lc_confirming_bank,
      d.guarantor_acct_num, 
      d.pcg_type_code,
      d.collateral_type_code,
      d.lc_netting_ind,
      d.lc_template_ind,
      d.other_lcs_rel_ind,
      d.lc_template_name,
      d.lc_template_creator,
      d.external_ref_key,
      d.lc_dispute_ind,
      d.lc_dispute_status,
      d.lc_priority,
      d.lc_custom_column1,
      d.lc_custom_column2,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.lc_num = i.lc_num 

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'Lc'

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
             convert(varchar(40), i.lc_num),
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
                convert(varchar(40), i.lc_num),
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
             convert(varchar(40), i.lc_num),
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
             convert(varchar(40), i.lc_num),
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
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [CK__lc__lc_dispute_s__670A40DB] CHECK (([lc_dispute_status]='REJECTED' OR [lc_dispute_status]='RESOLVED' OR [lc_dispute_status]='SUBMITTED'))
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [CK__lc__lc_netting_i__62458BBE] CHECK (([lc_netting_ind]='N' OR [lc_netting_ind]='Y'))
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [CK__lc__lc_priority__67FE6514] CHECK (([lc_priority]='URGENT' OR [lc_priority]='HIGH' OR [lc_priority]='NORMAL'))
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [CK__lc__lc_template___642DD430] CHECK (([lc_template_ind]='N' OR [lc_template_ind]='Y'))
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [CK__lc__other_lcs_re__66161CA2] CHECK (([other_lcs_rel_ind]='N' OR [other_lcs_rel_ind]='Y'))
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_pk] PRIMARY KEY CLUSTERED  ([lc_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [lc_TS_idx90] ON [dbo].[lc] ([lc_issuing_bank]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk1] FOREIGN KEY ([lc_applicant]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk10] FOREIGN KEY ([lc_usage_code]) REFERENCES [dbo].[lc_usage] ([lc_usage_code])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk11] FOREIGN KEY ([lc_office_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk12] FOREIGN KEY ([collateral_type_code]) REFERENCES [dbo].[collateral_type] ([collateral_type_code])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk13] FOREIGN KEY ([lc_template_creator]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk2] FOREIGN KEY ([lc_beneficiary]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk3] FOREIGN KEY ([lc_advising_bank]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk4] FOREIGN KEY ([lc_issuing_bank]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk5] FOREIGN KEY ([lc_negotiating_bank]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk6] FOREIGN KEY ([lc_confirming_bank]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk7] FOREIGN KEY ([lc_cr_analyst_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk8] FOREIGN KEY ([lc_status_code]) REFERENCES [dbo].[lc_status] ([lc_status_code])
GO
ALTER TABLE [dbo].[lc] ADD CONSTRAINT [lc_fk9] FOREIGN KEY ([lc_type_code]) REFERENCES [dbo].[lc_type] ([lc_type_code])
GO
GRANT DELETE ON  [dbo].[lc] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[lc] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[lc] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[lc] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'lc', NULL, NULL
GO
