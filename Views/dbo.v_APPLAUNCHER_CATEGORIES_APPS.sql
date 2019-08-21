SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_APPLAUNCHER_CATEGORIES_APPS]
(
	[product],
	[category_title],
	[app_title],
	[tile_group],
	[position]
)
as
select 
	a.[product],
	b.[category_title],
	c.[app_title],
	a.tile_group,
	a.position
from dbo.APPLAUNCHER_CATEGORIES_APPS a
        LEFT OUTER JOIN dbo.APPLAUNCHER_CATEGORIES b
		   ON a.product = b.product and
		      a.category_uid = b.category_uid 
        LEFT OUTER JOIN dbo.APPLAUNCHER_APPS c
		   ON a.product = c.product and
		      a.app_uid = c.app_uid
GO
GRANT SELECT ON  [dbo].[v_APPLAUNCHER_CATEGORIES_APPS] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_APPLAUNCHER_CATEGORIES_APPS] TO [next_usr]
GO
