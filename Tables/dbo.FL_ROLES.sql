CREATE TABLE [dbo].[FL_ROLES]
(
[roleName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[description] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[role_alias_ft1] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[FL_ROLES_DEL]
on [dbo].[FL_ROLES]
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

insert dbo.AUD_FL_ROLES
(
roleName ,
description ,
role_alias_ft1 ,
operation		 ,
userid              ,
date_op		
)
select 
d.roleName ,
d.description ,
d.role_alias_ft1 ,
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
CREATE TRIGGER [dbo].[FL_ROLES_INS]
on [dbo].[FL_ROLES]
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

insert dbo.AUD_FL_ROLES
(
roleName ,
description ,
role_alias_ft1 ,
operation		 ,
userid              ,
date_op		
)
select 
i.roleName ,
i.description ,
i.role_alias_ft1 ,
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
CREATE TRIGGER [dbo].[FL_ROLES_UPD]
on [dbo].[FL_ROLES]
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

insert dbo.AUD_FL_ROLES
(
roleName ,
description ,
role_alias_ft1 ,
operation		 ,
userid              ,
date_op		
)
select 
i.roleName ,
i.description ,
i.role_alias_ft1 ,
'UPD',
@utenza,
@operation_date 		
from inserted i

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[FL_ROLES] ADD CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED  ([roleName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FL_ROLES] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[FL_ROLES] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[FL_ROLES] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[FL_ROLES] TO [next_usr]
GO
