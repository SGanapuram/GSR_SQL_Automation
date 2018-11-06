CREATE TABLE [dbo].[trade_item_rin]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[rin_impact_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rin_action_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rin_port_num] [int] NULL,
[rin_p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__trade_ite__rin_p__6CAE0B98] DEFAULT ('P'),
[rin_impact_date] [datetime] NULL,
[rin_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[counterparty_qty] [numeric] (20, 8) NOT NULL,
[manual_settled_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__trade_ite__manua__6E96540A] DEFAULT ('Y'),
[settled_cur_y_sqty] [numeric] (20, 8) NOT NULL,
[settled_pre_y_sqty] [numeric] (20, 8) NOT NULL,
[rin_sep_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__trade_ite__rin_s__707E9C7C] DEFAULT ('A'),
[rin_pcent_year] [numeric] (20, 8) NOT NULL,
[py_rin_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[manual_epa_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__trade_ite__manua__7266E4EE] DEFAULT ('N'),
[epa_imp_prod_qty] [numeric] (20, 8) NOT NULL,
[epa_exp_qty] [numeric] (20, 8) NOT NULL,
[manual_commit_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__trade_ite__manua__744F2D60] DEFAULT ('N'),
[committed_sqty] [numeric] (20, 8) NOT NULL,
[rin_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mf_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[manual_rvo_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__trade_ite__manua__763775D2] DEFAULT ('N'),
[rvo_mf_qty] [numeric] (20, 8) NOT NULL,
[rvo_mf_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rins_finalized] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__trade_ite__rins___781FBE44] DEFAULT ('N'),
[impact_begin_year] [smallint] NOT NULL,
[impact_current_year] [smallint] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_rin_deltrg]
on [dbo].[trade_item_rin]
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
                    from master.dbo.sysprocesses with (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(trade_item_rin) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   if @@trancount > 0 rollback tran

   return
end


insert dbo.aud_trade_item_rin
   (trade_num,		
	  order_num,		
	  item_num,		
	  rin_impact_type,
	  rin_action_code,	
	  rin_port_num,		
	  rin_p_s_ind,		
	  rin_impact_date,	
	  rin_cmdty_code,	
	  counterparty_qty,	
	  manual_settled_ind,	
	  settled_cur_y_sqty,	
	  settled_pre_y_sqty,	
	  rin_sep_status,	
	  rin_pcent_year,	
	  py_rin_cmdty_code,	
	  manual_epa_ind,	
	  epa_imp_prod_qty,	
	  epa_exp_qty,		
	  manual_commit_ind,	
	  committed_sqty,	
	  rin_qty_uom_code,	
	  mf_cmdty_code,	
	  manual_rvo_ind,	
	  rvo_mf_qty,		
	  rvo_mf_qty_uom_code,		
	  rins_finalized,	
	  impact_begin_year,	
	  impact_current_year,	
	  trans_id,		
	  resp_trans_id)
select
	 d.trade_num,		
	 d.order_num,		
	 d.item_num,		
	 d.rin_impact_type,
	 d.rin_action_code,	
	 d.rin_port_num,		
	 d.rin_p_s_ind,		
	 d.rin_impact_date,	
	 d.rin_cmdty_code,	
	 d.counterparty_qty,	
	 d.manual_settled_ind,	
	 d.settled_cur_y_sqty,	
	 d.settled_pre_y_sqty,	
	 d.rin_sep_status,	
	 d.rin_pcent_year,	
	 d.py_rin_cmdty_code,	
	 d.manual_epa_ind,	
	 d.epa_imp_prod_qty,	
	 d.epa_exp_qty,		
	 d.manual_commit_ind,	
	 d.committed_sqty,	
	 d.rin_qty_uom_code,	
	 d.mf_cmdty_code,	
	 d.manual_rvo_ind,	
	 d.rvo_mf_qty,		
	 d.rvo_mf_qty_uom_code,		
	 d.rins_finalized,	
	 d.impact_begin_year,	
	 d.impact_current_year,	
	 d.trans_id,	
	 @atrans_id
from deleted d


/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'TradeItemRin'

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
             convert(varchar(40),d.order_num),
             convert(varchar(40),d.item_num),
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

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'DELETE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40),d.trade_num),
             convert(varchar(40),d.order_num),
             convert(varchar(40),d.item_num),
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
             convert(varchar(40),d.trade_num),
             convert(varchar(40),d.order_num),
             convert(varchar(40),d.item_num),
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
             convert(varchar(40),d.order_num),
             convert(varchar(40),d.item_num),
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
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

create trigger [dbo].[trade_item_rin_instrg]
on [dbo].[trade_item_rin]
for insert
as
declare @num_rows        int

select @num_rows = @@rowcount
if @num_rows = 0
   return

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'TradeItemRin'

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
             convert(varchar(40),i.trade_num),
             convert(varchar(40),i.order_num),
             convert(varchar(40),i.item_num),
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
             convert(varchar(40),i.trade_num),
             convert(varchar(40),i.order_num),
             convert(varchar(40),i.item_num),
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
             convert(varchar(40),i.trade_num),
             convert(varchar(40),i.order_num),
             convert(varchar(40),i.item_num),
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
             convert(varchar(40),i.trade_num),
             convert(varchar(40),i.order_num),
             convert(varchar(40),i.item_num),
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


/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'INSERT',
       'TradeItemRin',
       'DIRECT',
       convert(varchar(40),i.trade_num),
       convert(varchar(40),i.order_num),
       convert(varchar(40),i.item_num),
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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_rin_updtrg]
on [dbo].[trade_item_rin]
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
   raiserror ('(trade_item_rin) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(trade_item_rin) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
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
   select @errmsg = '(trade_item_rin) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.trade_num) + ',' + 
                                        convert(varchar, i.order_num) + ',' +
                                        convert(varchar, i.item_num) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
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
      raiserror ('(trade_item_rin) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_trade_item_rin
      (trade_num,		
	     order_num,		
	     item_num,		
	     rin_impact_type,
	     rin_action_code,	
	     rin_port_num,		
	     rin_p_s_ind,		
	     rin_impact_date,	
	     rin_cmdty_code,	
	     counterparty_qty,	
	     manual_settled_ind,	
	     settled_cur_y_sqty,	
	     settled_pre_y_sqty,	
	     rin_sep_status,	
	     rin_pcent_year,	
	     py_rin_cmdty_code,	
	     manual_epa_ind,	
	     epa_imp_prod_qty,	
	     epa_exp_qty,		
	     manual_commit_ind,	
	     committed_sqty,	
	     rin_qty_uom_code,	
	     mf_cmdty_code,	
	     manual_rvo_ind,	
	     rvo_mf_qty,		
	     rvo_mf_qty_uom_code,			
	     rins_finalized,	
	     impact_begin_year,	
	     impact_current_year,	
	     trans_id,		
	     resp_trans_id )
   select
	    d.trade_num,		
	    d.order_num,		
	    d.item_num,		
	    d.rin_impact_type,
	    d.rin_action_code,	
	    d.rin_port_num,		
	    d.rin_p_s_ind,		
	    d.rin_impact_date,	
	    d.rin_cmdty_code,	
	    d.counterparty_qty,	
	    d.manual_settled_ind,	
	    d.settled_cur_y_sqty,	
	    d.settled_pre_y_sqty,	
	    d.rin_sep_status,	
	    d.rin_pcent_year,	
	    d.py_rin_cmdty_code,	
	    d.manual_epa_ind,	
	    d.epa_imp_prod_qty,	
	    d.epa_exp_qty,		
	    d.manual_commit_ind,	
	    d.committed_sqty,	
	    d.rin_qty_uom_code,	
	    d.mf_cmdty_code,	
	    d.manual_rvo_ind,	
	    d.rvo_mf_qty,		
	    d.rvo_mf_qty_uom_code,	
	    d.rins_finalized,	
	    d.impact_begin_year,	
	    d.impact_current_year,	
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

   select @the_entity_name = 'TradeItemRin'

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
      where i.trans_id = it.trans_id

      /* END_TRANSACTION_TOUCH */
   end

return
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [CK__trade_ite__manua__75435199] CHECK (([manual_commit_ind]='N' OR [manual_commit_ind]='Y'))
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [CK__trade_ite__manua__735B0927] CHECK (([manual_epa_ind]='N' OR [manual_epa_ind]='Y'))
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [CK__trade_ite__manua__772B9A0B] CHECK (([manual_rvo_ind]='N' OR [manual_rvo_ind]='Y'))
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [CK__trade_ite__manua__6F8A7843] CHECK (([manual_settled_ind]='N' OR [manual_settled_ind]='Y'))
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [CK__trade_ite__rin_a__6BB9E75F] CHECK (([rin_action_code]=NULL OR [rin_action_code]='N' OR [rin_action_code]='M' OR [rin_action_code]='O' OR [rin_action_code]='X' OR [rin_action_code]='R' OR [rin_action_code]='L' OR [rin_action_code]='C' OR [rin_action_code]='P' OR [rin_action_code]='E' OR [rin_action_code]='I'))
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [CK__trade_ite__rin_i__6AC5C326] CHECK (([rin_impact_type]=NULL OR [rin_impact_type]='R' OR [rin_impact_type]='M' OR [rin_impact_type]='B'))
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [CK__trade_ite__rin_p__6DA22FD1] CHECK (([rin_p_s_ind]='S' OR [rin_p_s_ind]='P'))
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [CK__trade_ite__rin_s__7172C0B5] CHECK (([rin_sep_status]='S' OR [rin_sep_status]='A'))
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [CK__trade_ite__rins___7913E27D] CHECK (([rins_finalized]='N' OR [rins_finalized]='Y'))
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [trade_item_rin_pk] PRIMARY KEY CLUSTERED  ([trade_num], [item_num], [order_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [trade_item_rin_fk1] FOREIGN KEY ([rin_port_num]) REFERENCES [dbo].[portfolio] ([port_num])
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [trade_item_rin_fk2] FOREIGN KEY ([rin_cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [trade_item_rin_fk3] FOREIGN KEY ([py_rin_cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_rin] ADD CONSTRAINT [trade_item_rin_fk4] FOREIGN KEY ([rvo_mf_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[trade_item_rin] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_rin] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_rin] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_rin] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'trade_item_rin', NULL, NULL
GO
