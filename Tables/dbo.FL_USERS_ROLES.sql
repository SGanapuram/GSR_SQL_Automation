CREATE TABLE [dbo].[FL_USERS_ROLES]
(
[fleetimeUser] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[roleName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[options] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[FL_USERS_ROLES_DEL]
on [dbo].[FL_USERS_ROLES]
for delete
as

declare @num_rows         int,
        @count_num_rows   int,
        @operation_date   datetime,
	@utenza	          varchar(256)

select @num_rows = @@rowcount
if @num_rows = 0
   return


select @operation_date   = getdate()
select @utenza  = user

insert dbo.AUD_FL_USERS_ROLES
(
fleetimeUser   ,
roleName       ,
options        ,
operation	 ,
userid              ,
date_op		
)
select 
d.fleetimeUser   ,
d.roleName       ,
d.options        ,
'DEL',
@utenza,
@operation_date 		
from deleted d

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[FL_USERS_ROLES_INS]
on [dbo].[FL_USERS_ROLES]
for insert
as

declare @num_rows         int,
        @count_num_rows   int,
        @operation_date   datetime,
	@utenza	          varchar(256)

select @num_rows = @@rowcount
if @num_rows = 0
   return


select @operation_date   = getdate()
select @utenza  = user

insert dbo.AUD_FL_USERS_ROLES
(
fleetimeUser   ,
roleName       ,
options        ,
operation	 ,
userid              ,
date_op		
)
select 
i.fleetimeUser   ,
i.roleName       ,
i.options        ,
'INS',
@utenza,
@operation_date 		
from inserted i

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[FL_USERS_ROLES_UPD]
on [dbo].[FL_USERS_ROLES]
for update
as

declare @num_rows         int,
        @count_num_rows   int,
        @operation_date   datetime,
	@utenza	          varchar(256)

select @num_rows = @@rowcount
if @num_rows = 0
   return


select @operation_date   = getdate()
select @utenza  = user

insert dbo.AUD_FL_USERS_ROLES
(
fleetimeUser   ,
roleName       ,
options        ,
operation	 ,
userid              ,
date_op		
)
select 
i.fleetimeUser   ,
i.roleName       ,
i.options        ,
'UPD',
@utenza,
@operation_date 		
from inserted i

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[FL_USERS_ROLES] ADD CONSTRAINT [PK_RoleUsers] PRIMARY KEY CLUSTERED  ([fleetimeUser], [roleName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FL_USERS_ROLES] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[FL_USERS_ROLES] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[FL_USERS_ROLES] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[FL_USERS_ROLES] TO [next_usr]
GO
