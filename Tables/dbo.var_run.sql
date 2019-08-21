CREATE TABLE [dbo].[var_run]
(
[oid] [int] NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[run_date] [datetime] NOT NULL,
[execute_date] [datetime] NOT NULL,
[no_of_iterations] [int] NULL,
[horizon] [int] NULL,
[min_obs_date_vol] [datetime] NULL,
[max_obs_date_vol] [datetime] NULL,
[port_num_list] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[min_obs_date_corr] [datetime] NULL,
[max_obs_date_corr] [datetime] NULL,
[min_obs_date_his] [datetime] NULL,
[max_obs_date_his] [datetime] NULL,
[parameter_est_method] [smallint] NULL,
[var_method] [smallint] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[var_run_deltrg]  
on [dbo].[var_run]  
for delete  
as    
declare @num_rows         int
		 
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  
     
insert dbo.aud_var_run  
(  
   oid,  
   user_init,  
   run_date,  
   execute_date,  
   no_of_iterations,  
   horizon,  
   min_obs_date_vol,  
   max_obs_date_vol,  
   port_num_list,  
   min_obs_date_corr,  
   max_obs_date_corr,  
   min_obs_date_his,  
   max_obs_date_his,  
   parameter_est_method,  
   var_method,  
   operation,  
   userid,  
   date_op    
)  
select   
   d.oid,  
   d.user_init,  
   d.run_date,  
   d.execute_date,  
   d.no_of_iterations,  
   d.horizon,  
   d.min_obs_date_vol,  
   d.max_obs_date_vol,  
   d.port_num_list,  
   d.min_obs_date_corr,  
   d.max_obs_date_corr,  
   d.min_obs_date_his,  
   d.max_obs_date_his,  
   d.parameter_est_method,  
   d.var_method,  
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

CREATE TRIGGER [dbo].[var_run_instrg]  
on [dbo].[var_run]  
for insert  
as  
declare @num_rows         int
  
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  
  
insert dbo.aud_var_run  
(  
   oid,  
   user_init,  
   run_date,  
   execute_date,  
   no_of_iterations,  
   horizon,  
   min_obs_date_vol,  
   max_obs_date_vol,  
   port_num_list,  
   min_obs_date_corr,  
   max_obs_date_corr,  
   min_obs_date_his,  
   max_obs_date_his,  
   parameter_est_method,  
   var_method,  
   operation,  
   userid,  
   date_op    
)  
select   
   i.oid,  
   i.user_init,  
   i.run_date,  
   i.execute_date,  
   i.no_of_iterations,  
   i.horizon,  
   i.min_obs_date_vol,  
   i.max_obs_date_vol,  
   i.port_num_list,  
   i.min_obs_date_corr,  
   i.max_obs_date_corr,  
   i.min_obs_date_his,  
   i.max_obs_date_his,  
   i.parameter_est_method,  
   i.var_method,  
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

CREATE TRIGGER [dbo].[var_run_updtrg]
on [dbo].[var_run]  
for update  
as  
declare @num_rows         int
  
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  
  
insert dbo.aud_var_run  
(  
   oid,  
   user_init,  
   run_date,  
   execute_date,  
   no_of_iterations,  
   horizon,  
   min_obs_date_vol,  
   max_obs_date_vol,  
   port_num_list,  
   min_obs_date_corr,  
   max_obs_date_corr,  
   min_obs_date_his,  
   max_obs_date_his,  
   parameter_est_method,  
   var_method,  
   operation,  
   userid,  
   date_op   
)  
select   
   i.oid,  
   i.user_init,  
   i.run_date,  
   i.execute_date,  
   i.no_of_iterations,  
   i.horizon,  
   i.min_obs_date_vol,  
   i.max_obs_date_vol,  
   i.port_num_list,  
   i.min_obs_date_corr,  
   i.max_obs_date_corr,  
   i.min_obs_date_his,  
   i.max_obs_date_his,  
   i.parameter_est_method,  
   i.var_method,  
   'UPD',  
   suser_name(),  
   getdate()     
from inserted i  
  
/* AUDIT_CODE_END */  
  
return  
GO
ALTER TABLE [dbo].[var_run] ADD CONSTRAINT [chk_var_run_parameter_est_method] CHECK (([parameter_est_method]=NULL OR [parameter_est_method]=(2) OR [parameter_est_method]=(1)))
GO
ALTER TABLE [dbo].[var_run] ADD CONSTRAINT [chk_var_run_var_method] CHECK (([var_method]=NULL OR [var_method]=(2) OR [var_method]=(1)))
GO
ALTER TABLE [dbo].[var_run] ADD CONSTRAINT [var_run_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[var_run] ADD CONSTRAINT [var_run_fk1] FOREIGN KEY ([user_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[var_run] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[var_run] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[var_run] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[var_run] TO [next_usr]
GO
