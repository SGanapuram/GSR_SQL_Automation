CREATE TABLE [dbo].[QUERIES]
(
[fldchrQueryName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fldtxtQuery] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[category] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[QUERIES_DEL]
on [dbo].[QUERIES]
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

insert dbo.AUD_QUERIES
(
fldchrQueryName ,
category,
operation	,
userid          ,
date_op		
)
select 
d.fldchrQueryName , 
d.category,
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
CREATE TRIGGER [dbo].[QUERIES_INS]
on [dbo].[QUERIES]
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

insert dbo.AUD_QUERIES
(
fldchrQueryName ,
category,
operation	,
userid          ,
date_op		
)
select 
i.fldchrQueryName , 
i.category,
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
CREATE TRIGGER [dbo].[QUERIES_UPD]
on [dbo].[QUERIES]
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

insert dbo.AUD_QUERIES
(
fldchrQueryName ,
category,
operation	,
userid          ,
date_op		
)
select 
i.fldchrQueryName , 
i.category,
'UPD',
@utenza,
@operation_date 		
from inserted i

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[QUERIES] ADD CONSTRAINT [QUERIES_PK] PRIMARY KEY CLUSTERED  ([fldchrQueryName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[QUERIES] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[QUERIES] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[QUERIES] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[QUERIES] TO [next_usr]
GO
