SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
    
CREATE procedure [dbo].[usp_invruns_include_sec_qty]      
(      
   @invnum int = null      
)      
as 
--DECLARE @invnum int = 771     
begin       
set nocount on      
      
create table #invrun      
(      
        id             int IDENTITY(1,1) primary key,      
        bdDate         datetime,      
        bdQty          float,      
        bdAllocNum     int,      
        bdAllocItemNum int,      
        invNum         int,      
        bdType         varchar (8),      
        bdUom          varchar(4),      
        invUom         varchar(4),      
        needConv       bit default 0 null,    
        associatedTrade varchar(40),  
        invBDCost       float ,
        
        secBdQty          float,       
        secBdUom          varchar(4),      
        secInvUom         varchar(4),
        needSecConv       bit default 0 null     
)      
create table #invrunoutput      
(      
        id             int,      
        bdDate         datetime,      
        bdQty          float,      
        bdUom          varchar(4),      
        bdAllocNum     int,      
        bdAllocItemNum int,      
        invNum         int,      
        bdType         varchar (8),      
        runningBal     float,      
        eodBal         float,    
        associatedTrade varchar(40),  
        invBDCost       float,
        
        secBdQty          float,       
        secBdUom          varchar(4),                     
        secRunningBal     float,      
        secEodBal         float         
)      
      
-- @invnum is really mandatory but just return an empty result if it is not present      
if @invnum is null      
begin      
        select      
                i.id,      
                i.bdDate,      
                i.bdQty,      
                i.bdUom,      
                i.bdAllocNum,      
                i.bdAllocItemNum,      
                i.invNum,      
                i.bdType,      
                null as pTradeNum,      
                null as counterpartyName,      
                i.runningBal as 'Running Balance',      
                i.eodBal as 'End of Day Balance',    
                i.associatedTrade,  
                i.invBDCost,
                
                i.secBdQty,
			    i.secBdUom,
				i.secRunningBal as 'Sec Running Balance',      
                i.secEodBal as 'Sec End of Day Balance'
        from      
                #invrunoutput i      
        return      
end      
      
-- opening balance is projected plus actual (actually, I don't think there's such thing as an opening projected quantity)      
insert #invrun      
        (bdDate, bdQty, bdAllocNum, bdAllocItemNum, invNum, bdType, bdUom, invUom, needConv, associatedTrade,invBDCost,secBdQty,secBdUom,secInvUom,needSecConv)      
select      
        i.inv_bal_from_date,      
        i.inv_open_prd_proj_qty + i.inv_open_prd_actual_qty,      
        null,      
        null,      
        i.inv_num,      
        'Open',      
        i.inv_qty_uom_code,      
        i.inv_qty_uom_code,      
        0,    
        null,  
        null,
        
        i.inv_open_prd_proj_sec_qty + i.inv_open_prd_actual_sec_qty,
        i.inv_sec_qty_uom_code,
        i.inv_sec_qty_uom_code,
        0
from      
        dbo.inventory i      
where      
        i.inv_num = @invnum      
      
-- actual builds and draws      
insert #invrun      
        (bdDate, bdQty, bdAllocNum, bdAllocItemNum, invNum, bdType, bdUom, invUom, needConv, associatedTrade, invBDCost,secBdQty,secBdUom,secInvUom,needSecConv)      
select      
        aea.ai_est_actual_date,      
        (case when ti.billing_type = 'G' then aea.ai_est_actual_gross_qty else aea.ai_est_actual_net_qty end),      
        ibd.alloc_num,      
        ibd.alloc_item_num,      
        ibd.inv_num as invNum,      
        (case when ibd.inv_b_d_type = 'D' then 'Draw' else 'Build' end),      
        aea.ai_net_qty_uom_code, -- assumption: net and gross quantity will have same uom      
        ti.contr_qty_uom_code,      
        (case when aea.ai_net_qty_uom_code <> ti.contr_qty_uom_code then 1 else 0 end),    
        ibd.associated_trade,  
        ibd.inv_b_d_cost,
        --secondary
        (case when ti.billing_type = 'G' then aea.secondary_actual_gross_qty else aea.secondary_actual_net_qty end),
        aea.secondary_qty_uom_code,
        inv.inv_sec_qty_uom_code,
        (case when aea.secondary_qty_uom_code <> inv.inv_sec_qty_uom_code then 1 else 0 end)
              
from      
        dbo.inventory_build_draw ibd      
        join dbo.ai_est_actual aea on      
                aea.alloc_num = ibd.alloc_num and      
                aea.alloc_item_num = ibd.alloc_item_num      
        join dbo.allocation_item ai on      
                ai.alloc_num = ibd.alloc_num and      
                ai.alloc_item_num = ibd.alloc_item_num      
        join dbo.trade_item ti on      
                ti.trade_num = ai.trade_num and      
                ti.order_num = ai.order_num and      
                ti.item_num = ai.item_num      
        join dbo.allocation a on      
                a.alloc_num = ibd.alloc_num 
        join dbo.inventory inv on
			    inv.inv_num = ibd.inv_num       
where      
       a.alloc_type_code <> 'J' and      
        aea.ai_est_actual_ind = 'A' and      
        ibd.inv_num = @invnum          
      
-- adjustments      
insert #invrun      
        (bdDate, bdQty, bdAllocNum, bdAllocItemNum, invNum, bdType, bdUom, invUom, needConv, associatedTrade,invBDCost,
        secBdQty,secBdUom,secInvUom,needSecConv)      
select      
        ibd.inv_b_d_date,      
        ibd.adj_qty,      
        ibd.alloc_num,      
        ibd.alloc_item_num,      
        ibd.inv_num,      
        'Adj',      
        ibd.adj_qty_uom_code,      
        i.inv_qty_uom_code,      
        (case when ibd.adj_qty_uom_code <> i.inv_qty_uom_code then 1 else 0 end),    
        ibd.associated_trade,  
        ibd.inv_b_d_cost,
       
        ai.secondary_actual_qty,
        ai.sec_actual_uom_code,
        i.inv_sec_qty_uom_code,
        (case when ai.sec_actual_uom_code <> i.inv_sec_qty_uom_code then 1 else 0 end)      
        
from      
        dbo.inventory_build_draw ibd      
        join dbo.allocation a on      
                a.alloc_num = ibd.alloc_num      
        join dbo.inventory i on      
                i.inv_num = ibd.inv_num 
        join dbo.allocation_item ai on      
                ai.alloc_num = ibd.alloc_num and ai.alloc_item_num = ibd.alloc_item_num
where      
        a.alloc_type_code = 'J' and      
       ibd.adj_type_ind = 'P' and      
        ibd.inv_num = @invnum          
      
-- do simple one-step uom conversion between bdUom and invUom to convert the bdQty if needed and if possible.      
-- these SHOULD be same uom type so commodity is not important, well..., hopefully.      
update #invrun set      
        bdQty = (case when uc.uom_conv_oper = 'M' then bdQty*uc.uom_conv_rate else bdQty/uc.uom_conv_rate end),      
        needConv = 0      
from      
        dbo.uom_conversion uc      
where      
        uc.uom_code_conv_from = bdUom and      
        uc.uom_code_conv_to = invUom and      
        uc.cmdty_code is null and      
        needConv = 1      
      
update #invrun set      
        bdQty = (case when uc.uom_conv_oper = 'M' then bdQty/uc.uom_conv_rate else bdQty*uc.uom_conv_rate end),      
        needConv = 0      
from      
        dbo.uom_conversion uc      
where      
        uc.uom_code_conv_to = bdUom and      
        uc.uom_code_conv_from = invUom and      
        uc.cmdty_code is null and      
        needConv = 1  
        
        
-- do simple one-step uom conversion between secBdUom and secInvUom to convert the secBdQty if needed and if possible.      
-- these SHOULD be same uom type so commodity is not important, well..., hopefully.      
update #invrun set      
        secBdQty = (case when uc.uom_conv_oper = 'M' then secBdQty*uc.uom_conv_rate else secBdQty/uc.uom_conv_rate end),      
        needSecConv = 0      
from      
        dbo.uom_conversion uc      
where      
        uc.uom_code_conv_from = secBdUom and      
        uc.uom_code_conv_to = secInvUom and      
        uc.cmdty_code is null and      
        needSecConv = 1      
      
update #invrun set      
        secBdQty = (case when uc.uom_conv_oper = 'M' then secBdQty/uc.uom_conv_rate else secBdQty*uc.uom_conv_rate end),      
        needSecConv = 0      
from      
        dbo.uom_conversion uc      
where      
        uc.uom_code_conv_to = secBdUom and      
        uc.uom_code_conv_from = secInvUom and      
        uc.cmdty_code is null and      
        needSecConv = 1      
      
-- total up for the output table      
insert #invrunoutput      
        (id, bdDate, bdQty, bdUom, bdAllocNum, bdAllocItemNum, invNum, bdType, runningBal, eodBal, associatedTrade,invBDCost,
        secBdQty,secBdUom, secRunningBal,secEodBal)      
select      
        i.id,      
        i.bdDate,      
        i.bdQty,      
        (case when needConv = 1 then i.bdUom else i.invUom end),      
        i.bdAllocNum,      
        i.bdAllocItemNum,      
        i.invNum,      
        i.bdType,      
        (select isnull(sum(case when bdType='Draw' then bdQty*-1 else bdQty end), 0) from #invrun i2 where datediff(dd, i2.bdDate, i.bdDate) = 0 and id <= i.id),      
        (select isnull(sum(case when bdType='Draw' then bdQty*-1 else bdQty end), 0) from #invrun i2 where datediff(dd, i2.bdDate, i.bdDate) >= 0),    
        i.associatedTrade,  
        i.invBDCost,
        
        i.secBdQty,
        (case when needSecConv = 1 then i.secBdUom else i.secInvUom end),
        (select isnull(sum(case when bdType='Draw' then secBdQty*-1 else secBdQty end), 0) from #invrun i2 where datediff(dd, i2.bdDate, i.bdDate) = 0 and id <= i.id),      
        (select isnull(sum(case when bdType='Draw' then secBdQty*-1 else secBdQty end), 0) from #invrun i2 where datediff(dd, i2.bdDate, i.bdDate) >= 0)    
                       
from      
        #invrun i      
      
-- output the whole table      
select      
        i.id,      
        i.bdDate,      
        i.bdQty,      
        i.bdUom,      
        i.bdAllocNum,      
        i.bdAllocItemNum,      
        i.invNum,      
        i.bdType,      
        null as pTradeNum,      
        null as counterpartyName,      
        i.runningBal as 'Running Balance',      
        i.eodBal as 'End of Day Balance',    
        i.associatedTrade,  
        i.invBDCost,
        
        i.secBdQty,
        i.secBdUom,
		i.secRunningBal as 'Sec Running Balance',      
        i.secEodBal as 'Sec End of Day Balance'      
from      
        #invrunoutput i      
order by      
        i.bdDate desc, i.id desc      
      
drop table #invrun      
drop table #invrunoutput      
end    

GO
GRANT EXECUTE ON  [dbo].[usp_invruns_include_sec_qty] TO [next_usr]
GO
