CREATE TABLE [dbo].[commodity_market_formula]
(
[commkt_key] [int] NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[low_bid_formula_num] [int] NULL,
[high_asked_formula_num] [int] NULL,
[avg_closed_formula_num] [int] NULL,
[low_bid_simple_formula_num] [int] NULL,
[high_asked_simple_formula_num] [int] NULL,
[avg_closed_simple_formula_num] [int] NULL,
[cmf_num] [int] NOT NULL,
[mpt_num] [int] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
      
create trigger [dbo].[commodity_market_formul_deltrg]      
on [dbo].[commodity_market_formula]      
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
   select @errmsg = '(commodity_market_formula) Failed to obtain a valid responsible trans_id.'      
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
      
      
insert dbo.aud_commodity_market_formula      
   (commkt_key,      
    trading_prd,      
    price_source_code,      
    low_bid_formula_num,      
    high_asked_formula_num,      
    avg_closed_formula_num,      
    low_bid_simple_formula_num,      
    high_asked_simple_formula_num,      
    avg_closed_simple_formula_num,      
    cmf_num,      
    mpt_num,      
    trans_id,      
    resp_trans_id)      
select      
   d.commkt_key,      
   d.trading_prd,      
   d.price_source_code,      
   d.low_bid_formula_num,      
   d.high_asked_formula_num,      
   d.avg_closed_formula_num,      
   d.low_bid_simple_formula_num,      
   d.high_asked_simple_formula_num,      
   d.avg_closed_simple_formula_num,      
   d.cmf_num,      
   d.mpt_num,      
   d.trans_id,      
   @atrans_id      
from deleted d      
      
/* AUDIT_CODE_END */      
  
if exists (select 1 
           from dbo.constants 
           where attribute_name = 'IgnorePriceMktOptimization' and 
                 attribute_value = 'N')    
begin          
declare @the_tran_type      char(1)    
      
   select @the_tran_type = it.type    
   from dbo.icts_transaction it WITH (NOLOCK)      
   where it.trans_id = @atrans_id    
    
if @the_tran_type != 'E'    
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
  
  
declare @cmfNum int    
    
select @cmfNum = cmf_num from deleted     
    
if object_id('tempdb..#recalcCmfDependency') is not null
    drop table #recalcCmfDependency;
    
with impactedFormulas as    
(    
select cmfd.cmf_num, cmfd.sub_cmf_num    
from cmf_dependency cmfd    
where cmf_num=@cmfNum    
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
ocmf.cmf_num as sub_cmf_num, @atrans_id    
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
ocmf.cmf_num as sub_cmf_num, @atrans_id    
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
    
  
end    
end  

if object_id('tempdb..#recalcCmfDependency') is not null
    drop table #recalcCmfDependency   
return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 
CREATE trigger [dbo].[commodity_market_formul_updtrg]      
on [dbo].[commodity_market_formula]      
for update      
as      
declare @num_rows         int,      
        @count_num_rows   int,      
        @dummy_update     int,      
        @errorNumber      int,      
        @errmsg           varchar(255)    
     
    
select @num_rows = @@rowcount      
if @num_rows = 0      
   return      
      
select @dummy_update = 0      
      
/* RECORD_STAMP_BEGIN */      
if not update(trans_id)       
begin      
   raiserror ('(commodity_market_formula) The change needs to be attached with a new trans_id',10,1)      
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
      select @errmsg = '(commodity_market_formula) New trans_id must be larger than original trans_id.'      
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'      
      raiserror (@errmsg,10,1)      
      if @@trancount > 0 rollback tran      
      
      return      
   end      
end      
      
if exists (select * from inserted i, deleted d      
           where i.trans_id < d.trans_id and      
                 i.commkt_key = d.commkt_key and       
                 i.trading_prd = d.trading_prd and       
                 i.price_source_code = d.price_source_code )      
begin      
   raiserror ('(commodity_market_formula) new trans_id must not be older than current trans_id.',10,1)      
   if @@trancount > 0 rollback tran      
      
   return      
end      
      
/* RECORD_STAMP_END */      
      
if update(commkt_key) or        
   update(trading_prd) or        
   update(price_source_code)       
begin      
   select @count_num_rows = (select count(*) from inserted i, deleted d      
                             where i.commkt_key = d.commkt_key and       
                                   i.trading_prd = d.trading_prd and       
                                   i.price_source_code = d.price_source_code )      
   if (@count_num_rows = @num_rows)      
   begin      
      select @dummy_update = 1      
   end      
   else      
   begin      
      raiserror ('(commodity_market_formula) primary key can not be changed.',10,1)      
      if @@trancount > 0 rollback tran      
      
      return      
   end      
end      
      
/* AUDIT_CODE_BEGIN */      
      
if @dummy_update = 0      
   insert dbo.aud_commodity_market_formula      
      (commkt_key,      
       trading_prd,      
       price_source_code,      
       low_bid_formula_num,      
       high_asked_formula_num,      
       avg_closed_formula_num,      
       low_bid_simple_formula_num,      
       high_asked_simple_formula_num,      
       avg_closed_simple_formula_num,      
       cmf_num,      
       mpt_num,      
       trans_id,      
       resp_trans_id)      
   select      
      d.commkt_key,      
      d.trading_prd,      
      d.price_source_code,      
      d.low_bid_formula_num,      
      d.high_asked_formula_num,      
      d.avg_closed_formula_num,      
      d.low_bid_simple_formula_num,      
      d.high_asked_simple_formula_num,      
      d.avg_closed_simple_formula_num,      
      d.cmf_num,      
      d.mpt_num,      
      d.trans_id,      
      i.trans_id      
   from deleted d, inserted i      
   where d.commkt_key = i.commkt_key and      
         d.trading_prd = i.trading_prd and      
         d.price_source_code = i.price_source_code       
      
/* AUDIT_CODE_END */    

if exists ( select 1 from constants where attribute_name = 'IgnorePriceMktOptimization' and attribute_value = 'N' )  
begin
      
declare @the_tran_type      char(1),    
        @trans_id int    
      
   select @the_tran_type = it.type , @trans_id = it.trans_id     
   from dbo.icts_transaction it WITH (NOLOCK),inserted i    
   where it.trans_id = i.trans_id    
    
if @the_tran_type != 'E'    
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

declare @cmfNum int    
    
select @cmfNum = cmf_num from inserted;     
    
with impactedFormulas as    
(    
select cmfd.cmf_num, cmfd.sub_cmf_num    
from cmf_dependency cmfd    
where cmf_num=@cmfNum    
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
ocmf.cmf_num as sub_cmf_num, @trans_id    
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
and cpu.upd_trading_prd= cmfd.trading_prd and convert(varchar(12),cpu.upd_price_quote_date,101)=  convert(varchar(12), getdate(),101))    
    
insert into cmf_for_price_update    
select * from #cmf_for_price_update    
    
  
    
end    
end
    
return 
GO
ALTER TABLE [dbo].[commodity_market_formula] ADD CONSTRAINT [commodity_market_formula_pk] PRIMARY KEY CLUSTERED  ([commkt_key], [trading_prd], [price_source_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [commodity_market_formula_POSGRID_idx1] ON [dbo].[commodity_market_formula] ([avg_closed_simple_formula_num]) INCLUDE ([commkt_key], [price_source_code], [trading_prd], [trans_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [commodity_market_formula_idx1] ON [dbo].[commodity_market_formula] ([cmf_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [commodity_market_formula_idx5] ON [dbo].[commodity_market_formula] ([commkt_key], [avg_closed_formula_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [commodity_market_formula_idx3] ON [dbo].[commodity_market_formula] ([commkt_key], [high_asked_formula_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [commodity_market_formula_idx4] ON [dbo].[commodity_market_formula] ([commkt_key], [low_bid_formula_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [commodity_market_formula_idx2] ON [dbo].[commodity_market_formula] ([mpt_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commodity_market_formula] ADD CONSTRAINT [commodity_market_formula_fk5] FOREIGN KEY ([price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[commodity_market_formula] ADD CONSTRAINT [commodity_market_formula_fk9] FOREIGN KEY ([commkt_key], [trading_prd]) REFERENCES [dbo].[trading_period] ([commkt_key], [trading_prd])
GO
GRANT DELETE ON  [dbo].[commodity_market_formula] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[commodity_market_formula] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[commodity_market_formula] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[commodity_market_formula] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'commodity_market_formula', NULL, NULL
GO
