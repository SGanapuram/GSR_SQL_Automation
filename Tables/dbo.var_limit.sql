CREATE TABLE [dbo].[var_limit]
(
[oid] [int] NOT NULL IDENTITY(1, 1),
[port_num_list] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[limit_type] [char] (5) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[confidence_level] [numeric] (20, 8) NOT NULL,
[horizon] [int] NULL,
[var_limit] [float] NOT NULL CONSTRAINT [DF__var_limit__var_l__5B196B42] DEFAULT ((0)),
[var_limit_curr_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[last_update_date] [datetime] NOT NULL CONSTRAINT [DF__var_limit__last___5C0D8F7B] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[var_limit_deltrg]  
on [dbo].[var_limit]  
for delete  
as  
declare @num_rows         int
		 
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  

insert dbo.aud_var_limit  
(  
   oid,  
   port_num_list,  
   limit_type,  
   confidence_level,  
   horizon,  
   var_limit,  
   var_limit_curr_code,  
   user_init,  
   last_update_date,  
   operation,  
   userid,  
   date_op    
)  
select   
   d.oid,  
   d.port_num_list,  
   d.limit_type,  
   d.confidence_level,  
   d.horizon,  
   d.var_limit,  
   d.var_limit_curr_code,  
   d.user_init,  
   d.last_update_date,  
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

CREATE TRIGGER [dbo].[var_limit_instrg]  
on [dbo].[var_limit]  
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
  
insert dbo.aud_var_limit  
(  
   oid                ,  
    port_num_list       ,  
    limit_type          ,  
    confidence_level    ,  
    horizon             ,  
    var_limit           ,  
    var_limit_curr_code ,  
    user_init           ,  
    last_update_date    ,  
operation   ,  
userid              ,  
date_op    
)  
select   
i.oid                ,  
    i.port_num_list       ,  
    i.limit_type          ,  
    i.confidence_level    ,  
    i.horizon             ,  
    i.var_limit           ,  
    i.var_limit_curr_code ,  
    i.user_init           ,  
    i.last_update_date    ,  
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

CREATE TRIGGER [dbo].[var_limit_updtrg]  
on [dbo].[var_limit]  
for update  
as  
declare @num_rows         int  
  
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  
    
insert dbo.aud_var_limit  
(  
   oid,  
   port_num_list,  
   limit_type,  
   confidence_level,  
   horizon,  
   var_limit,  
   var_limit_curr_code,  
   user_init,  
   last_update_date,  
   operation,  
   userid,  
   date_op   
)  
select   
   i.oid,  
   i.port_num_list,  
   i.limit_type,  
   i.confidence_level,  
   i.horizon,  
   i.var_limit,  
   i.var_limit_curr_code,  
   i.user_init,  
   i.last_update_date,  
   'UPD',  
   suser_name(),  
   getdate()     
from inserted i  
  
/* AUDIT_CODE_END */  
  
return  
GO
ALTER TABLE [dbo].[var_limit] ADD CONSTRAINT [var_limit_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[var_limit] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[var_limit] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[var_limit] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[var_limit] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'var_limit', NULL, NULL
GO
