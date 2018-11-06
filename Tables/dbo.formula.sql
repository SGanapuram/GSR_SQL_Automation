CREATE TABLE [dbo].[formula]
(
[formula_num] [int] NOT NULL,
[formula_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[formula_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[formula_use] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[formula_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[formula_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_precision] [tinyint] NULL,
[parent_formula_num] [int] NULL,
[cmnt_num] [int] NULL,
[use_alt_source_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[monthly_pricing_inds] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__formula__monthly__3B60C8C7] DEFAULT ('NN'),
[use_exec_price_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_rounding_level] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[modular_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_assay_final_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_qp_opt_end_date] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[formula_deltrg]
on [dbo].[formula]
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
   select @errmsg = '(formula) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_formula
   (formula_num,
    formula_name,
    formula_type,
    formula_use,
    formula_status,
    formula_curr_code,
    formula_uom_code,
    formula_precision,
    parent_formula_num,
    cmnt_num,
    use_alt_source_ind,
    monthly_pricing_inds,
    use_exec_price_ind,
    formula_rounding_level,
    modular_ind,
    price_assay_final_ind,
    max_qp_opt_end_date,
    trans_id,
    resp_trans_id
)
select
   d.formula_num,
   d.formula_name,
   d.formula_type,
   d.formula_use,
   d.formula_status,
   d.formula_curr_code,
   d.formula_uom_code,
   d.formula_precision,
   d.parent_formula_num,
   d.cmnt_num,
   d.use_alt_source_ind,
   d.monthly_pricing_inds,
   d.use_exec_price_ind,
   d.formula_rounding_level,
   d.modular_ind,
   d.price_assay_final_ind,
   d.max_qp_opt_end_date,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'Formula'

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
             convert(varchar(40),d.formula_num),
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
                convert(varchar(40),d.formula_num),
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
             convert(varchar(40),d.formula_num),
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
             convert(varchar(40),d.formula_num),
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

create trigger [dbo].[formula_instrg]
on [dbo].[formula]
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

   select @the_entity_name = 'Formula'

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
             convert(varchar(40),formula_num),
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
                convert(varchar(40),formula_num),
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
             convert(varchar(40),formula_num),
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
             convert(varchar(40),formula_num),
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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
       
create trigger [dbo].[formula_updtrg]      
on [dbo].[formula]      
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
   raiserror ('(formula) The change needs to be attached with a new trans_id',10,1)      
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
      select @errmsg = '(formula) New trans_id must be larger than original trans_id.'      
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'      
      raiserror (@errmsg,10,1)      
      if @@trancount > 0 rollback tran      
      
      return      
   end      
end      
      
if exists (select * from inserted i, deleted d      
           where i.trans_id < d.trans_id and      
                 i.formula_num = d.formula_num )      
begin      
   raiserror ('(formula) new trans_id must not be older than current trans_id.',10,1)      
   if @@trancount > 0 rollback tran      
      
   return      
end      
      
/* RECORD_STAMP_END */      
      
if update(formula_num)      
begin      
   select @count_num_rows = (select count(*) from inserted i, deleted d      
                             where i.formula_num = d.formula_num )      
   if (@count_num_rows = @num_rows)      
   begin      
      select @dummy_update = 1      
   end      
   else      
   begin      
      raiserror ('(formula) primary key can not be changed.',10,1)      
      if @@trancount > 0 rollback tran      
      
      return      
   end      
end      
      
/* AUDIT_CODE_BEGIN */      
      
if @dummy_update = 0      
   insert dbo.aud_formula      
      (formula_num,      
       formula_name,      
       formula_type,      
       formula_use,      
       formula_status,      
       formula_curr_code,      
       formula_uom_code,      
       formula_precision,      
       parent_formula_num,      
       cmnt_num,      
       use_alt_source_ind,      
       monthly_pricing_inds,      
       use_exec_price_ind,      
       formula_rounding_level,
       modular_ind,    
       price_assay_final_ind, 
       max_qp_opt_end_date,     
       trans_id,      
       resp_trans_id)      
    select      
       d.formula_num,      
       d.formula_name,      
       d.formula_type,      
       d.formula_use,      
       d.formula_status,      
       d.formula_curr_code,      
       d.formula_uom_code,      
       d.formula_precision,      
       d.parent_formula_num,      
       d.cmnt_num,      
       d.use_alt_source_ind,      
       d.monthly_pricing_inds,      
       d.use_exec_price_ind,      
       d.formula_rounding_level,      
       d.modular_ind,    
       d.price_assay_final_ind,
       d.max_qp_opt_end_date,   
       d.trans_id,      
       i.trans_id      
   from deleted d, inserted i      
   where d.formula_num = i.formula_num      
      
/* AUDIT_CODE_END */      
      
declare @the_sequence       numeric(32, 0),      
        @the_tran_type      char(1),      
        @the_entity_name    varchar(30),    
 @trans_id int    
      
   select @the_entity_name = 'Formula'      
       
         select @the_tran_type = it.type,      
             @the_sequence = it.sequence ,    
      @trans_id = i.trans_id     
      from dbo.icts_transaction it WITH (NOLOCK),      
           inserted i      
      where it.trans_id = i.trans_id     
      
   if @num_rows = 1      
   begin      
     
      /* BEGIN_ALS_RUN_TOUCH */      
      
      insert into dbo.als_run_touch       
         (als_module_group_id, operation, entity_name,key1,key2,      
          key3,key4,key5,key6,key7,key8,trans_id,sequence)      
      select a.als_module_group_id,      
             'U',      
             @the_entity_name,      
             convert(varchar(40),formula_num),      
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
                convert(varchar(40),formula_num),      
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
             convert(varchar(40),formula_num),      
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
             convert(varchar(40),formula_num),      
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
    
-- Logic for inserting records into cmf_dependency and cmf_for_price_update tables

if exists ( select 1 from constants where attribute_name = 'IgnorePriceMktOptimization' and attribute_value = 'N' )  
begin

declare @formula_use varchar(8)
    
select @formula_use = formula_use from inserted    
    
if @the_tran_type != 'E' and @formula_use ='B'    
begin    
    
create table #cmf_dependency    
(    
  cmf_num  int  NOT NULL,    
  commkt_key  int  NULL,    
  price_source_code char(8)  NULL,    
  trading_prd  char(8)  NULL,    
  last_trade_date datetime NULL,    
  sub_cmf_num  int  NULL,    
  trans_id  int  NOT NULL    
)    
    
create table #cmf_for_price_update    
(    
  cmf_num   int  NOT NULL,    
  upd_commkt_key  int  NOT NULL,    
  upd_price_source_code char(8)  NOT NULL,    
  upd_trading_prd  char(8)  NOT NULL,    
  upd_price_quote_date datetime NOT NULL,    
  sub_cmf_num  int  NULL,    
  processing_status tinyint  NOT NULL,    
  trans_id  int  NOT NULL    
)            



	declare @formulaNum int    
	select @formulaNum=formula_num from inserted    
    
	if object_id('tempdb..#recalcCmfDependency') is not null    
	     drop table #recalcCmfDependency    
    
	if object_id('tempdb..#cmfUsingFormula') is not null    
	     drop table #cmfUsingFormula    
    
	select cmf_num    
	into #cmfUsingFormula    
	from commodity_market_formula cmf    
	where avg_closed_formula_num=@formulaNum or 
	      low_bid_formula_num=@formulaNum or 
	      high_asked_formula_num=@formulaNum;    
    
	with impactedFormulas as    
	(    
	select cmfd.cmf_num, 
	       cmfd.sub_cmf_num    
 	from cmf_dependency cmfd    
	where cmf_num in (select cmf_num from #cmfUsingFormula)    
	union all    
select child.cmf_num, child.sub_cmf_num    
from cmf_dependency child    
inner join impactedFormulas iform on iform.cmf_num=child.sub_cmf_num    
)    
select cmf_num    
into #recalcCmfDependency     
from impactedFormulas    
    
delete cmf_dependency where cmf_num in (select cmf_num from #recalcCmfDependency)    
    
insert into #cmf_dependency(cmf_num,commkt_key,price_source_code,trading_prd,last_trade_date,sub_cmf_num,trans_id)    
select ucmf.cmf_num as cmf_num, ucmf.commkt_key, ucmf.price_source_code, ucmf.trading_prd, tp.last_trade_date,    
ocmf.cmf_num as sub_cmf_num, @trans_id    
from     
(    
select cmf.cmf_num, fc.commkt_key, fc.trading_prd, fc.price_source_code    
from formula_component fc    
inner join commodity_market_formula cmf on cmf.low_bid_formula_num=fc.formula_num    
where fc.formula_comp_type ='G' and cmf.cmf_num in (select cmf_num from #recalcCmfDependency)    
union    
select cmf.cmf_num, fc.commkt_key, fc.trading_prd, fc.price_source_code    
from formula_component fc    
inner join commodity_market_formula cmf on cmf.high_asked_formula_num=fc.formula_num    
where fc.formula_comp_type='G' and cmf.cmf_num in (select cmf_num from #recalcCmfDependency)    
union    
select cmf.cmf_num, fc.commkt_key, fc.trading_prd, fc.price_source_code    
from formula_component fc    
inner join commodity_market_formula cmf on cmf.avg_closed_formula_num=fc.formula_num    
where fc.formula_comp_type='G' and cmf.cmf_num in (select cmf_num from #recalcCmfDependency)    
union    
select cmf.cmf_num, fc.quote_commkt_key, fc.quote_trading_prd, fc.quote_price_source_code    
from simple_formula fc    
inner join commodity_market_formula cmf on cmf.low_bid_formula_num=fc.simple_formula_num    
where cmf.cmf_num in (select cmf_num from #recalcCmfDependency)    
union    
select cmf.cmf_num, fc.quote_commkt_key, fc.quote_trading_prd, fc.quote_price_source_code    
from simple_formula fc    
inner join commodity_market_formula cmf on cmf.high_asked_simple_formula_num=fc.simple_formula_num    
where cmf.cmf_num in (select cmf_num from #recalcCmfDependency)    
union    
select cmf.cmf_num, fc.quote_commkt_key, fc.quote_trading_prd, fc.quote_price_source_code    
from simple_formula fc    
inner join commodity_market_formula cmf on cmf.avg_closed_simple_formula_num=fc.simple_formula_num    
where cmf.cmf_num in (select cmf_num from #recalcCmfDependency)    
) as ucmf    
left outer join trading_period tp on ucmf.commkt_key=tp.commkt_key and ucmf.trading_prd=tp.trading_prd    
left outer join commodity_market_formula ocmf on ocmf.commkt_key=ucmf.commkt_key    
   and ocmf.price_source_code=ucmf.price_source_code and ocmf.trading_prd=ucmf.trading_prd    
where not exists (select 1 from cmf_dependency cmfd2    
where cmfd2.cmf_num=ucmf.cmf_num and cmfd2.commkt_key=ucmf.commkt_key and cmfd2.price_source_code=ucmf.price_source_code    
and cmfd2.trading_prd=ucmf.trading_prd and isnull(cmfd2.sub_cmf_num,0)=isnull(ocmf.cmf_num,0));    
    
-- finding sub formulas    
with subFormula as     
(    
    select a.formula_num, a.formula_comp_ref , a.formula_num as orig_formula_num, cmf.cmf_num    
    from formula_component a    
    inner join commodity_market_formula cmf on cmf.low_bid_formula_num=a.formula_num    
    where a.formula_comp_type='M' and cmf.cmf_num in (select cmf_num from #recalcCmfDependency)    
union    
select a.formula_num, a.formula_comp_ref , a.formula_num as orig_formula_num, cmf.cmf_num    
    from formula_component a    
inner join commodity_market_formula cmf on cmf.high_asked_formula_num=a.formula_num    
where a.formula_comp_type='M' and cmf.cmf_num in (select cmf_num from #recalcCmfDependency)    
union    
select a.formula_num, a.formula_comp_ref , a.formula_num as orig_formula_num, cmf.cmf_num    
    from formula_component a    
inner join commodity_market_formula cmf on cmf.avg_closed_formula_num=a.formula_num    
where a.formula_comp_type='M' and cmf.cmf_num in (select cmf_num from #recalcCmfDependency)    
    
    union all    
    
    select child.formula_num, child.formula_comp_ref, a.formula_num as orig_formula_num, a.cmf_num    
    from subFormula as a    
        inner join formula_component as child on child.formula_num = a.formula_comp_ref    
        where child.formula_comp_type='M'    
)    
insert into #cmf_dependency(cmf_num,commkt_key,price_source_code,trading_prd,last_trade_date,sub_cmf_num,trans_id)    
select sf.cmf_num, fc.commkt_key,  fc.price_source_code,fc.trading_prd,tp.last_trade_date,    
ocmf.cmf_num as sub_cmf_num,@trans_id    
from subFormula sf    
inner join formula_component fc on sf.formula_comp_ref=fc.formula_num    
left outer join trading_period tp on fc.commkt_key=tp.commkt_key and fc.trading_prd=tp.trading_prd    
left outer join commodity_market_formula ocmf on ocmf.commkt_key=fc.commkt_key    
   and ocmf.price_source_code=fc.price_source_code and ocmf.trading_prd=fc.trading_prd    
where fc.formula_comp_type ='G'    
and not exists (select 1 from cmf_dependency cmfd2    
where cmfd2.cmf_num=sf.cmf_num and cmfd2.commkt_key=fc.commkt_key and cmfd2.price_source_code=fc.price_source_code    
and cmfd2.trading_prd=fc.trading_prd and isnull(cmfd2.sub_cmf_num,0)=isnull(ocmf.cmf_num,0))    
    
insert into #cmf_dependency    
select * from cmf_dependency    
    

insert into #cmf_for_price_update(cmf_num,upd_commkt_key,upd_price_source_code,upd_trading_prd,upd_price_quote_date,sub_cmf_num,processing_status,trans_id)    
select cmf_num, cmfd.commkt_key, cmfd.price_source_code, cmfd.trading_prd, convert(varchar(12), getdate(),101), cmfd.sub_cmf_num, 1, @trans_id    
from cmf_dependency cmfd     
where cmfd.trans_id= @trans_id    
and not exists (select 1 from cmf_for_price_update cpu    
where cpu.cmf_num=cmfd.cmf_num and cpu.upd_commkt_key= cmfd.commkt_key and cpu.upd_price_source_code= cmfd.price_source_code    
and cpu.upd_trading_prd= cmfd.trading_prd and convert(varchar(12), cpu.upd_price_quote_date,101)= convert(varchar(12), getdate(),101))    
    
insert into cmf_for_price_update    
select * from #cmf_for_price_update    
    
 
end      
end    

return 
GO
ALTER TABLE [dbo].[formula] ADD CONSTRAINT [formula_pk] PRIMARY KEY CLUSTERED  ([formula_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [formula_idx1] ON [dbo].[formula] ([parent_formula_num], [formula_name]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [formula_TS_idx90] ON [dbo].[formula] ([parent_formula_num], [formula_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[formula] ADD CONSTRAINT [formula_fk2] FOREIGN KEY ([formula_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[formula] ADD CONSTRAINT [formula_fk3] FOREIGN KEY ([formula_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[formula] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[formula] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[formula] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[formula] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'formula', NULL, NULL
GO
