CREATE TABLE [dbo].[var_ext_position]
(
[rowid] [int] NOT NULL IDENTITY(1, 1),
[as_of_date] [datetime] NOT NULL,
[real_port_num] [int] NOT NULL,
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[position] [float] NOT NULL,
[position_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[what_if_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_var_ext_position_what_if_ind] DEFAULT ('N'),
[creation_date] [datetime] NOT NULL CONSTRAINT [df_var_ext_position_creation_date] DEFAULT (getdate()),
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_key] [int] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[var_ext_position_deltrg]  
on [dbo].[var_ext_position]  
for delete  
as  
declare @num_rows         int
		 
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  
  
insert dbo.aud_var_ext_position  
(  
   rowid,  
   as_of_date,  
   real_port_num,  
   order_type_code,  
   cmdty_code,  
   mkt_code,  
   price_source_code,  
   [position],  
   position_uom_code,  
   p_s_ind,  
   what_if_ind,  
   creation_date,  
   trading_prd,  
   commkt_key,  
   trans_id,  
   operation,  
   userid,  
   date_op    
)  
select   
   d.rowid,  
   d.as_of_date,  
   d.real_port_num,  
   d.order_type_code,  
   d.cmdty_code,  
   d.mkt_code,  
   d.price_source_code,  
   d.[position],  
   d.position_uom_code,  
   d.p_s_ind,  
   d.what_if_ind,  
   d.creation_date,  
   d.trading_prd,  
   d.commkt_key,  
   d.trans_id,  
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

CREATE TRIGGER [dbo].[var_ext_position_instrg]  
on [dbo].[var_ext_position]  
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
  
insert dbo.aud_var_ext_position  
(  
  rowid          ,  
    as_of_date       ,  
    real_port_num    ,  
    order_type_code  ,  
    cmdty_code       ,  
    mkt_code         ,  
    price_source_code ,  
    [position]        ,  
    position_uom_code ,  
    p_s_ind           ,  
    what_if_ind       ,  
    creation_date     ,  
    trading_prd       ,  
    commkt_key        ,  
    trans_id          ,  
operation   ,  
userid              ,  
date_op    
)  
select   
i.rowid ,  
    i.as_of_date       ,  
    i.real_port_num    ,  
    i.order_type_code  ,  
    i.cmdty_code       ,  
    i.mkt_code         ,  
    i.price_source_code ,  
    i.[position]        ,  
    i.position_uom_code ,  
    i.p_s_ind           ,  
    i.what_if_ind       ,  
    i.creation_date     ,  
    i.trading_prd       ,  
    i.commkt_key        ,  
    i.trans_id          ,  
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

CREATE TRIGGER [dbo].[var_ext_position_updtrg] 
on [dbo].[var_ext_position]  
for update  
as  
declare @num_rows         int
  
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  
    
insert dbo.aud_var_ext_position  
(  
   rowid,  
   as_of_date,  
   real_port_num,  
   order_type_code,  
   cmdty_code,  
   mkt_code,  
   price_source_code,  
   [position],  
   position_uom_code,  
   p_s_ind,  
   what_if_ind,  
   creation_date,  
   trading_prd,  
   commkt_key,  
   trans_id,  
   operation,  
   userid,  
   date_op   
)  
select   
   i.rowid,  
   i.as_of_date,  
   i.real_port_num,  
   i.order_type_code,  
   i.cmdty_code,  
   i.mkt_code,  
   i.price_source_code,  
   i.[position],  
   i.position_uom_code,  
   i.p_s_ind,  
   i.what_if_ind,  
   i.creation_date,  
   i.trading_prd,  
   i.commkt_key,  
   i.trans_id,  
   'UPD',  
   suser_name(),  
   getdate()     
from inserted i  
  
/* AUDIT_CODE_END */  
  
return  
GO
ALTER TABLE [dbo].[var_ext_position] ADD CONSTRAINT [chk_var_ext_position_p_s_ind] CHECK (([p_s_ind]='P' OR [p_s_ind]='S'))
GO
ALTER TABLE [dbo].[var_ext_position] ADD CONSTRAINT [chk_var_ext_position_what_if_ind] CHECK (([what_if_ind]='Y' OR [what_if_ind]='N'))
GO
ALTER TABLE [dbo].[var_ext_position] ADD CONSTRAINT [var_ext_position_pk] PRIMARY KEY CLUSTERED  ([rowid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[var_ext_position] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[var_ext_position] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[var_ext_position] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[var_ext_position] TO [next_usr]
GO
