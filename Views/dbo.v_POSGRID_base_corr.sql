SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_POSGRID_base_corr]
(
   cmdty_code,
   commkt_key,
   commkt
)
as
select
	 ca.cmdty_code,
	 cast(ca.cmdty_alias_name as int),
	 convert(varchar, cm.cmdty_code) + '/' + convert(varchar, cm.mkt_code)
from dbo.commodity_alias ca with (nolock)
        join dbo.commodity_market cm with (nolock)
           on ca.cmdty_alias_name = cast(cm.commkt_key as varchar)
where ca.alias_source_code = 'BASECORR' and
      ca.cmdty_code is not null and
      ca.cmdty_alias_name is not null
GO
GRANT SELECT ON  [dbo].[v_POSGRID_base_corr] TO [next_usr]
GO
