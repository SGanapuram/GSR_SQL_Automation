CREATE TABLE [dbo].[price]
(
[commkt_key] [int] NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_quote_date] [datetime] NOT NULL,
[low_bid_price] [float] NULL,
[high_asked_price] [float] NULL,
[avg_closed_price] [float] NULL,
[open_interest] [float] NULL,
[vol_traded] [float] NULL,
[creation_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[low_bid_creation_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[high_asked_creation_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[avg_closed_creation_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
create trigger [dbo].[price_deltrg]    
on [dbo].[price]    
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
   select @errmsg = '(price) Failed to obtain a valid responsible trans_id.'    
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
    
    
insert dbo.aud_price    
   (commkt_key,    
    price_source_code,    
    trading_prd,    
    price_quote_date,    
    low_bid_price,    
    high_asked_price,    
    avg_closed_price,    
    open_interest,    
    vol_traded,    
    creation_type,    
    low_bid_creation_ind,    
    high_asked_creation_ind,    
    avg_closed_creation_ind,    
    trans_id,    
    resp_trans_id)    
select    
   d.commkt_key,    
   d.price_source_code,    
   d.trading_prd,    
   d.price_quote_date,    
   d.low_bid_price,    
   d.high_asked_price,    
   d.avg_closed_price,    
   d.open_interest,    
   d.vol_traded,    
   d.creation_type,    
   d.low_bid_creation_ind,    
   d.high_asked_creation_ind,    
   d.avg_closed_creation_ind,    
   d.trans_id,    
   @atrans_id    
from deleted d    
    
/* AUDIT_CODE_END */    
    
declare @the_sequence       numeric(32, 0),    
        @the_tran_type      char(1),    
        @the_entity_name    varchar(30),  
        @trans_id int  
    
   select @the_entity_name = 'Price'    
     
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
             'D',    
             @the_entity_name,    
             convert(varchar(40), d.commkt_key),    
             convert(varchar(40), d.price_source_code),    
             convert(varchar(40), d.trading_prd),    
             convert(varchar(40), d.price_quote_date),    
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
                convert(varchar(40), d.commkt_key),    
                convert(varchar(40), d.price_source_code),    
                convert(varchar(40), d.trading_prd),    
                convert(varchar(40), d.price_quote_date),    
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
             convert(varchar(40), d.commkt_key),    
             convert(varchar(40), d.price_source_code),    
             convert(varchar(40), d.trading_prd),    
             convert(varchar(40), d.price_quote_date),    
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
             convert(varchar(40), d.commkt_key),    
             convert(varchar(40), d.price_source_code),    
             convert(varchar(40), d.trading_prd),    
             convert(varchar(40), d.price_quote_date),    
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
    
-- Logic for inserting records into cmf_for_price_update table

if exists ( select 1 from constants where attribute_name = 'IgnorePriceMktOptimization' and attribute_value = 'N' )  
begin

if @the_tran_type != 'E'  
begin  
 declare @commktKey int,  
         @priceSourceCode char(8),  
	 @tPrd char(8),   
	 @quoteDate datetime,  
	 @spotPrd char(8)  

  create table #cmf_for_price_update  
  (  
	 cmf_num		int		NOT NULL,  
	 upd_commkt_key		int		NOT NULL,  
	 upd_price_source_code	char(8)		NOT NULL,  
	 upd_trading_prd	char(8)		NOT NULL,  
	 upd_price_quote_date	datetime	NOT NULL,  
	 sub_cmf_num		int		NULL,  
	 processing_status	tinyint		NOT NULL,  
	 trans_id		int		NOT NULL  
  )    
  
 select  @commktKey = commkt_key,  
	 @priceSourceCode = price_source_code,  
	 @tPrd = trading_prd,  
	 @quoteDate = price_quote_date  
 from deleted  
  
   select @spotPrd = dbo.udf_get_tpcount(@commktKey,@tPrd,@quoteDate);  
     
 with impactedFormulas as
 (  
	select  cmf_num, 
		@commktKey as upd_commkt_key, 
		@priceSourceCode as upd_price_source_code,  
		@tPrd as upd_trading_prd, 
		@quoteDate as upd_price_quote_date, 
		sub_cmf_num, 
		1 as procStatus, 
		@trans_id as transId  
	from cmf_dependency  
	where commkt_key = @commktKey and 
	      price_source_code = @priceSourceCode and 
	      trading_prd in (@tPrd, @spotPrd)  
	union all  
	select  cmfd.cmf_num, 
		@commktKey as upd_commkt_key, 
		@priceSourceCode as upd_price_source_code,  
		@tPrd as upd_trading_prd, 
		@quoteDate as upd_price_quote_date, 
		cmfd.sub_cmf_num, 
		1 as procStatus, 
		@trans_id as transId  
	from impactedFormulas f  
	inner join cmf_dependency cmfd   
	on f.cmf_num=cmfd.sub_cmf_num  
)  
  
insert into #cmf_for_price_update
(cmf_num,upd_commkt_key,upd_price_source_code,upd_trading_prd,upd_price_quote_date,sub_cmf_num,processing_status,trans_id)
select  distinct cmf_num, 
        @commktKey as upd_commkt_key, 
        @priceSourceCode as upd_price_source_code,
	@tPrd as upd_trading_prd, 
	@quoteDate as upd_price_quote_date, 
	null, 1 as procStatus, 
	@atrans_id as transId
from impactedFormulas iform  
where not exists (select 1 from cmf_for_price_update cpu where cpu.cmf_num=iform.cmf_num and 
                  cpu.upd_commkt_key= @commktKey and cpu.upd_price_source_code= @priceSourceCode  
                  and cpu.upd_trading_prd= @tPrd and cpu.upd_price_quote_date= @quoteDate)  
  
insert into cmf_for_price_update
(cmf_num,upd_commkt_key,upd_price_source_code,upd_trading_prd,upd_price_quote_date,sub_cmf_num,processing_status,trans_id)
select cmf_num,upd_commkt_key,upd_price_source_code,upd_trading_prd,upd_price_quote_date,sub_cmf_num,processing_status,trans_id from #cmf_for_price_update  
  
end
end
  
return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[price_instrg]
on [dbo].[price]
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

   select @the_entity_name = 'Price'

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
             convert(varchar(40), i.commkt_key),
             convert(varchar(40), i.price_source_code),
             convert(varchar(40), i.trading_prd),
             convert(varchar(40), i.price_quote_date),
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
                convert(varchar(40), i.commkt_key),
                convert(varchar(40), i.price_source_code),
                convert(varchar(40), i.trading_prd),
                convert(varchar(40), i.price_quote_date),
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
             convert(varchar(40), i.commkt_key),
             convert(varchar(40), i.price_source_code),
             convert(varchar(40), i.trading_prd),
             convert(varchar(40), i.price_quote_date),
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
             convert(varchar(40), i.commkt_key),
             convert(varchar(40), i.price_source_code),
             convert(varchar(40), i.trading_prd),
             convert(varchar(40), i.price_quote_date),
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

CREATE trigger [dbo].[price_updtrg]              
on [dbo].[price]              
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
   raiserror ('(price) The change needs to be attached with a new trans_id',10,1)          
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
      select @errmsg = '(price) New trans_id must be larger than original trans_id.'          
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'          
      raiserror (@errmsg,10,1)          
      if @@trancount > 0 rollback tran          
          
      return          
   end          
end          
          
if exists (select * from inserted i, deleted d          
           where i.trans_id < d.trans_id and          
                 i.commkt_key = d.commkt_key and           
                 i.price_source_code = d.price_source_code and           
                 i.trading_prd = d.trading_prd and           
                 i.price_quote_date = d.price_quote_date )          
begin          
   raiserror ('(price) new trans_id must not be older than current trans_id.',10,1)          
   if @@trancount > 0 rollback tran          
          
   return          
end          
          
/* RECORD_STAMP_END */          
          
if update(commkt_key) or            
   update(price_source_code) or            
   update(trading_prd) or            
   update(price_quote_date)           
begin          
   select @count_num_rows = (select count(*) from inserted i, deleted d          
                             where i.commkt_key = d.commkt_key and           
                                   i.price_source_code = d.price_source_code and           
                                   i.trading_prd = d.trading_prd and           
                                   i.price_quote_date = d.price_quote_date )          
   if (@count_num_rows = @num_rows)          
   begin          
      select @dummy_update = 1          
   end          
   else          
   begin          
      raiserror ('(price) primary key can not be changed.',10,1)          
      if @@trancount > 0 rollback tran          
          
      return          
   end          
end          
          
/* AUDIT_CODE_BEGIN */          
          
if @dummy_update = 0          
   insert dbo.aud_price          
      (commkt_key,          
       price_source_code,          
       trading_prd,          
       price_quote_date,          
       low_bid_price,          
       high_asked_price,          
       avg_closed_price,          
       open_interest,          
       vol_traded,          
       creation_type,          
       low_bid_creation_ind,          
       high_asked_creation_ind,          
       avg_closed_creation_ind,          
       trans_id,          
       resp_trans_id)          
   select          
      d.commkt_key,          
      d.price_source_code,         
      d.trading_prd,          
      d.price_quote_date,          
      d.low_bid_price,          
      d.high_asked_price,          
      d.avg_closed_price,          
      d.open_interest,          
      d.vol_traded,          
      d.creation_type,          
      d.low_bid_creation_ind,          
      d.high_asked_creation_ind,          
      d.avg_closed_creation_ind,          
      d.trans_id,          
      i.trans_id          
   from deleted d, inserted i          
   where d.commkt_key = i.commkt_key and          
         d.price_source_code = i.price_source_code and          
         d.trading_prd = i.trading_prd and          
         d.price_quote_date = i.price_quote_date           
          
/* AUDIT_CODE_END */          
          
declare @the_sequence       numeric(32, 0),          
        @the_tran_type      char(1),          
        @the_entity_name    varchar(30),        
 @trans_id int        
          
   select @the_entity_name = 'Price'          
           
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
             convert(varchar(40), i.commkt_key),          
             convert(varchar(40), i.price_source_code),          
             convert(varchar(40), i.trading_prd),          
             convert(varchar(40), i.price_quote_date),          
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
                convert(varchar(40), i.commkt_key),          
                convert(varchar(40), i.price_source_code),          
                convert(varchar(40), i.trading_prd),          
                convert(varchar(40), i.price_quote_date),          
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
             convert(varchar(40), i.commkt_key),          
             convert(varchar(40), i.price_source_code),          
             convert(varchar(40), i.trading_prd),          
             convert(varchar(40), i.price_quote_date),          
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
             convert(varchar(40), i.commkt_key),          
             convert(varchar(40), i.price_source_code),          
             convert(varchar(40), i.trading_prd),          
             convert(varchar(40), i.price_quote_date),          
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
          
-- Logic for inserting records into cmf_for_price_update table  

if exists ( select 1 from constants where attribute_name = 'IgnorePriceMktOptimization' and attribute_value = 'N' )  
begin
      
if @the_tran_type != 'E'            
begin   
  
  create table #cmf_for_price_update            
  (            
 cmf_num   int     NOT NULL,            
 upd_commkt_key  int     NOT NULL,            
 upd_price_source_code   char(8)     NOT NULL,            
 upd_trading_prd  char(8)     NOT NULL,            
 upd_price_quote_date datetime    NOT NULL,            
 sub_cmf_num  int     NULL,            
 processing_status tinyint     NOT NULL,            
 trans_id  int         NOT NULL            
  )    
  
            
  declare @commktKey int,            
  @priceSourceCode char(8),            
  @tPrd char(8),             
  @quoteDate datetime,            
  @spotPrd char(8)        
            
 select  @commktKey = commkt_key,            
  @priceSourceCode = price_source_code,            
  @tPrd = trading_prd,            
  @quoteDate = price_quote_date          
  from inserted            
            
   select @spotPrd = dbo.udf_get_tpcount(@commktKey,@tPrd,@quoteDate);            
               
            
with impactedFormulas as            
(            
 select cmf_num,   
        @commktKey as upd_commkt_key,   
        @priceSourceCode as upd_price_source_code,            
        @tPrd as upd_trading_prd,   
        @quoteDate as upd_price_quote_date,   
        sub_cmf_num,   
        1 as procStatus,   
        @trans_id as transId            
 from cmf_dependency            
 where commkt_key= @commktKey and   
       price_source_code = @priceSourceCode and   
       trading_prd in (@tPrd, @spotPrd)            
 union all            
 select cmfd.cmf_num,   
        @commktKey as upd_commkt_key,   
        @priceSourceCode as upd_price_source_code,            
        @tPrd as upd_trading_prd,   
        @quoteDate as upd_price_quote_date,   
        cmfd.sub_cmf_num,   
        1 as procStatus,   
        @trans_id as transId            
 from impactedFormulas f            
 inner join cmf_dependency cmfd             
 on f.cmf_num=cmfd.sub_cmf_num            
)            
            
insert into #cmf_for_price_update  
(cmf_num,upd_commkt_key,upd_price_source_code,upd_trading_prd,upd_price_quote_date,sub_cmf_num,processing_status,trans_id)            
select distinct cmf_num,   
                @commktKey as upd_commkt_key,   
  @priceSourceCode as upd_price_source_code,   
  @tPrd as upd_trading_prd,   
  @quoteDate as upd_price_quote_date,   
  null,   
  1 as procStatus,   
  @trans_id as transId            
from impactedFormulas iform            
where not exists (select 1 from dbo.cmf_for_price_update cpu            
where cpu.cmf_num=iform.cmf_num and   
      cpu.upd_commkt_key= @commktKey and   
      cpu.upd_price_source_code= @priceSourceCode and   
      cpu.upd_trading_prd= @tPrd and   
      cpu.upd_price_quote_date= @quoteDate)            
            
insert into cmf_for_price_update  
(cmf_num,upd_commkt_key,upd_price_source_code,upd_trading_prd,upd_price_quote_date,sub_cmf_num,processing_status,trans_id)  
select cmf_num,upd_commkt_key,upd_price_source_code,upd_trading_prd,upd_price_quote_date,sub_cmf_num,processing_status,trans_id from #cmf_for_price_update            
            
end   
end
            
return
GO
ALTER TABLE [dbo].[price] ADD CONSTRAINT [price_pk] PRIMARY KEY CLUSTERED  ([commkt_key], [price_source_code], [trading_prd], [price_quote_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [price_idx3] ON [dbo].[price] ([commkt_key], [trading_prd], [price_quote_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [price_quote_date_idx] ON [dbo].[price] ([price_quote_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [price_idx2] ON [dbo].[price] ([price_source_code], [price_quote_date], [trading_prd], [creation_type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [price_idx4] ON [dbo].[price] ([trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[price] ADD CONSTRAINT [price_fk1] FOREIGN KEY ([price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[price] ADD CONSTRAINT [price_fk2] FOREIGN KEY ([commkt_key], [trading_prd]) REFERENCES [dbo].[trading_period] ([commkt_key], [trading_prd])
GO
GRANT DELETE ON  [dbo].[price] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[price] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[price] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[price] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'price', NULL, NULL
GO
