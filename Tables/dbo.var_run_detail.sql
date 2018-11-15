CREATE TABLE [dbo].[var_run_detail]
(
[oid] [int] NOT NULL IDENTITY(1, 1),
[var_run_id] [int] NOT NULL,
[key1] [char] (5) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[key2] [numeric] (20, 8) NULL,
[key3] [int] NULL,
[detail_value1] [float] NULL,
[detail_value2] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[detail_value3] [datetime] NOT NULL CONSTRAINT [DF__var_run_d__detai__668B1DEE] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[var_run_detail_deltrg]  
on [dbo].[var_run_detail]  
for delete  
as  
declare @num_rows         int
		 
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  

insert dbo.aud_var_run_detail  
(  
   oid,  
   var_run_id,  
   key1,  
   key2,  
   key3,  
   detail_value1,  
   detail_value2,  
   detail_value3,  
   operation,  
   userid,  
   date_op    
)  
select   
   d.oid,  
   d.var_run_id,  
   d.key1,  
   d.key2,  
   d.key3,  
   d.detail_value1,  
   d.detail_value2,  
   d.detail_value3,  
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

CREATE TRIGGER [dbo].[var_run_detail_instrg]  
on [dbo].[var_run_detail]  
for insert  
as  
  
declare @num_rows         int  
  
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  
    
insert dbo.aud_var_run_detail  
(  
   oid,  
   var_run_id,  
   key1,  
   key2,  
   key3,  
   detail_value1,  
   detail_value2,  
   detail_value3,  
   operation,  
   userid,  
   date_op    
)  
select   
   i.oid,  
   i.var_run_id,  
   i.key1,  
   i.key2,  
   i.key3,  
   i.detail_value1,  
   i.detail_value2,  
   i.detail_value3,  
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

CREATE TRIGGER [dbo].[var_run_detail_updtrg]  
on [dbo].[var_run_detail]  
for update  
as   
declare @num_rows         int

select @num_rows = @@rowcount
if @num_rows = 0
   return
  
insert dbo.aud_var_run_detail  
(  
   oid,  
   var_run_id,  
   key1,  
   key2,  
   key3,  
   detail_value1,  
   detail_value2,  
   detail_value3,  
   operation,  
   userid,  
   date_op   
)  
select   
   i.oid,  
   i.var_run_id,  
   i.key1,  
   i.key2,  
   i.key3,  
   i.detail_value1,  
   i.detail_value2,  
   i.detail_value3,  
   'UPD',  
   suser_name(),  
   getdate()     
from inserted i  
  
/* AUDIT_CODE_END */  
  
return  
GO
ALTER TABLE [dbo].[var_run_detail] ADD CONSTRAINT [var_run_detail_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[var_run_detail] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[var_run_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[var_run_detail] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[var_run_detail] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'var_run_detail', NULL, NULL
GO
