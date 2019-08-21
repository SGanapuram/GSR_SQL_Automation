SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create view [dbo].[v_CHGHISTORY_profit_center_tags] (currdate) as select getdate()
GO
GRANT SELECT ON  [dbo].[v_CHGHISTORY_profit_center_tags] TO [next_usr]
GO
