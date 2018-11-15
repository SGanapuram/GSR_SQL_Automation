CREATE TABLE [dbo].[var_pnl_distribution]
(
[oid] [int] NOT NULL,
[var_run_id] [int] NOT NULL,
[bucket_type] [int] NOT NULL,
[bucket_tag] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mean] [numeric] (20, 8) NULL,
[stdev] [numeric] (20, 8) NULL,
[max] [numeric] (20, 8) NULL,
[min] [numeric] (20, 8) NULL,
[skew] [numeric] (20, 8) NULL,
[kurtosis] [numeric] (20, 8) NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[var_pnl_distribution_deltrg]  
on [dbo].[var_pnl_distribution]  
for delete  
as   
declare @num_rows         int
		 
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  
  
insert dbo.aud_var_pnl_distribution  
(  
   oid,  
   var_run_id,  
   bucket_type,  
   bucket_tag,  
   mean,  
   stdev,  
   [max],  
   [min],  
   skew,  
   kurtosis,  
   operation,  
   userid,  
   date_op    
)  
select   
   d.oid,  
   d.var_run_id,  
   d.bucket_type,  
   d.bucket_tag,  
   d.mean,  
   d.stdev,  
   d.[max],  
   d.[min],  
   d.skew,  
   d.kurtosis,  
   'DEL',  
   suser_name(),  
   getdate()     
from deleted d  
  
/* AUDIT_CODE_END */  
  
return  
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[var_pnl_distribution_instrg]  
on [dbo].[var_pnl_distribution]  
for insert  
as  
  
declare @num_rows         int,  
        @count_num_rows   int,  
        @operation_date   datetime,  
 @utenza           varchar(256)  
  
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  
  
  
select @operation_date   = getdate()  
select @utenza  = user  
  
insert dbo.aud_var_pnl_distribution  
(  
oid        ,  
    var_run_id  ,  
    bucket_type ,  
    bucket_tag  ,  
    mean        ,  
    stdev       ,  
    [max]       ,  
    [min]       ,  
    skew        ,  
    kurtosis    ,  
operation   ,  
userid              ,  
date_op    
)  
select   
i.oid                ,  
   i.var_run_id  ,  
    i.bucket_type ,  
    i.bucket_tag  ,  
    i.mean        ,  
    i.stdev       ,  
    i.[max]       ,  
    i.[min]       ,  
    i.skew        ,  
    i.kurtosis    ,  
'INS',  
   suser_name(),  
   getdate()    
from inserted i  
  
/* AUDIT_CODE_END */  
  
return  
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[var_pnl_distribution_updtrg] 
on [dbo].[var_pnl_distribution]  
for update  
as    
declare @num_rows         int
  
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  
    
insert dbo.aud_var_pnl_distribution  
(  
   oid,  
   var_run_id,  
   bucket_type,  
   bucket_tag,  
   mean,  
   stdev,  
   [max],  
   [min],  
   skew,  
   kurtosis,  
   operation,  
   userid,  
   date_op   
)  
select   
   i.oid,  
   i.var_run_id,  
   i.bucket_type,  
   i.bucket_tag,  
   i.mean,  
   i.stdev,  
   i.[max],  
   i.[min],  
   i.skew,  
   i.kurtosis,  
   'UPD',  
   suser_name(),  
   getdate()     
from inserted i  
  
/* AUDIT_CODE_END */  
  
return  
GO
ALTER TABLE [dbo].[var_pnl_distribution] ADD CONSTRAINT [var_pnl_distribution_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[var_pnl_distribution] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[var_pnl_distribution] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[var_pnl_distribution] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[var_pnl_distribution] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'var_pnl_distribution', NULL, NULL
GO
