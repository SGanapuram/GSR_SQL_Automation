CREATE TABLE [dbo].[var_output]
(
[oid] [numeric] (32, 0) NOT NULL IDENTITY(1, 1),
[var_run_id] [int] NOT NULL,
[bucket_type] [int] NOT NULL,
[bucket_tag] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[confidence_level] [numeric] (20, 8) NOT NULL,
[var_period] [datetime] NULL,
[var_amount] [numeric] (20, 8) NULL,
[port_run_list] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cvar_amount] [numeric] (20, 8) NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[var_output_deltrg]  
on [dbo].[var_output]  
for delete  
as  
declare @num_rows         int
		 
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  
  
insert dbo.aud_var_output  
(  
   oid,  
   var_run_id,  
   bucket_type,  
   bucket_tag,  
   confidence_level,  
   var_period,  
   var_amount,  
   port_run_list,  
   cvar_amount,  
   operation,  
   userid,  
   date_op    
)  
select   
   d.oid,  
   d.var_run_id,  
   d.bucket_type,  
   d.bucket_tag,  
   d.confidence_level,  
   d.var_period,  
   d.var_amount,  
   d.port_run_list,  
   d.cvar_amount,  
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

CREATE TRIGGER [dbo].[var_output_instrg]  
on [dbo].[var_output]  
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
  
insert dbo.aud_var_output  
(  
 oid             ,  
    var_run_id   ,  
    bucket_type  ,  
    bucket_tag   ,  
    confidence_level ,  
    var_period       ,  
    var_amount       ,  
    port_run_list    ,  
    cvar_amount      ,  
operation   ,  
userid              ,  
date_op    
)  
select   
i.oid                ,  
    i.var_run_id   ,  
    i.bucket_type  ,  
    i.bucket_tag   ,  
    i.confidence_level ,  
    i.var_period       ,  
    i.var_amount       ,  
    i.port_run_list    ,  
    i.cvar_amount      ,  
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

CREATE TRIGGER [dbo].[var_output_updtrg]
on [dbo].[var_output]  
for update  
as   
declare @num_rows         int 
  
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  
    
insert dbo.aud_var_output  
(  
   oid,  
   var_run_id,  
   bucket_type,  
   bucket_tag,  
   confidence_level,  
   var_period,  
   var_amount,  
   port_run_list,  
   cvar_amount,  
   operation,  
   userid,  
   date_op   
)  
select   
   i.oid,  
   i.var_run_id,  
   i.bucket_type,  
   i.bucket_tag,  
   i.confidence_level,  
   i.var_period,  
   i.var_amount,  
   i.port_run_list,  
   i.cvar_amount,  
   'UPD',  
   suser_name(),  
   getdate()     
from inserted i  
  
/* AUDIT_CODE_END */  
  
return  
GO
ALTER TABLE [dbo].[var_output] ADD CONSTRAINT [var_output_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[var_output] ADD CONSTRAINT [var_output_fk1] FOREIGN KEY ([var_run_id]) REFERENCES [dbo].[var_run] ([oid])
GO
GRANT DELETE ON  [dbo].[var_output] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[var_output] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[var_output] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[var_output] TO [next_usr]
GO
