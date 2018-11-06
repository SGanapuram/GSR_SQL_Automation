SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[usp_get_inv_template_name]
@voucher_num int,
@debug_ind char(1)='N'
AS
BEGIN


DECLARE @OffsetInd char(1), @cost_prim_sec_ind char(1),@mot_type_code char(1), @formula_ind char(1), @BookingComp int, @template_name nvarchar(255)
DECLARE @voucher_type_code char(8), @formula_type char(1)

create table #voucher_detail
(
        voucher_num int,
		cost_num int,
		trade_num int, 
		order_num int,
		item_num int,
        voucher_type_code char(8), 
        cost_prim_sec_ind char(1) ,
		mot_type_code char(1),
        formula_ind char(1) null, 
		formula_type char(1) null,
        BookingComp int null,
	cost_code char(8) null
)

insert into #voucher_detail
select v.voucher_num, c.cost_num,ti.trade_num, ti.order_num, ti.item_num, v.voucher_type_code,c.cost_prim_sec_ind,mot_type_code , isnull(formula_ind,'N') formula, formula_type,c.cost_book_comp_num, c.cost_code
From voucher v,
cost c
INNER JOIN voucher_cost vc on vc.cost_num=c.cost_num
LEFT OUTER JOIN 
	(select tiwp.trade_num, tiwp.order_num, tiwp.item_num,ai.alloc_num, ai.alloc_item_num,  mot_type_code
	from trade_item_wet_phy tiwp , allocation_item ai, allocation_item_transport ait, mot m
	where tiwp.trade_num=ai.trade_num and tiwp.order_num=ai.order_num and tiwp.item_num=ai.item_num 
	and ai.alloc_num=ait.alloc_num and ai.alloc_item_num=ait.alloc_item_num
	and m.mot_code=ait.transportation
	)
	ti on c.cost_owner_key6=ti.trade_num and c.cost_owner_key7=ti.order_num and c.cost_owner_key8=ti.item_num and ti.alloc_num=c.cost_owner_key1 and ti.alloc_item_num=c.cost_owner_key2
LEFT OUTER JOIN cost c1 on c1.cost_num=vc.cost_num and c1.cost_type_code='PO' and c1.cost_status<>'CLOSED' 
LEFT OUTER JOIN 
	(select formula_ind, formula_type, ti.trade_num, ti.order_num, ti.item_num
	from trade_item ti
	LEFT OUTER JOIN (select trade_num, order_num,item_num,formula_type
			 from trade_formula tf, formula f 
		   	 where f.formula_num=tf.formula_num
			 )fr ON fr.trade_num=ti.trade_num and fr.order_num=ti.order_num and fr.item_num=ti.item_num
	  		 and ti.formula_ind='Y' 
	) a1 on c.cost_owner_key6=a1.trade_num and c.cost_owner_key7=a1.order_num and c.cost_owner_key8=a1.item_num  --and formula_ind='Y'
where v.voucher_num=vc.voucher_num
and v.voucher_num=@voucher_num



--if (select count(*) from #voucher_detail where cost_prim_sec_ind='P' )>=1
--	if (select count(*) from #voucher_detail where cost_prim_sec_ind='S' )=0
--		select @template_name='GRID-INVOICE'
--	ELSE
--		select @template_name='TEMPLATE MULTI SETTLEMENT'

if(select distinct 1 from #voucher_detail where cost_prim_sec_ind='P')=1
BEGIN
	if (select distinct 1 from #voucher_detail where mot_type_code ='B')=1
		select @mot_type_code='B' 
	if (select distinct 1 from #voucher_detail where mot_type_code ='V')=1
		select @mot_type_code='V' 	
	ELSE
		select @mot_type_code='B'


	if(select count(*) from #voucher_detail where mot_type_code ='V')>1
		select @mot_type_code='B' 


	IF(select distinct 1 from #voucher_detail where formula_type='T' )=1
		select @formula_type='T'
	ELSE
	if(select distinct 1 from #voucher_detail where formula_ind='Y' )=1
		select @formula_type='A' 
	ELSE
		select @formula_type='F' 				

END
ELSE
	select @mot_type_code='N', @formula_type='N'

	
--	IF(select 1 from #voucher_detail where cost_prim_sec_ind='P' )=1
--	BEGIN
--	END

/*	(select distinct formula_type from #voucher_detail v, trade_formula tf, formula f 
		where v.trade_num=tf.trade_num
		and v.order_num=tf.order_num
		and v.item_num=tf.item_num
		and f.formula_num=tf.formula_num
		and v.formula_ind='Y' 
	   )
		select @formula_type='T'
	ELSE
		select @formula_type='A'
*/

IF @template_name is null 
BEGIN
select distinct @BookingComp= BookingComp
from #voucher_detail


select distinct @formula_ind= isnull(formula_ind,'N')
from #voucher_detail
where formula_ind='Y'


select @formula_ind=isnull(@formula_ind,'N')


IF (SELECT distinct 1  from #voucher_detail where cost_prim_sec_ind='P')=1
	select  @cost_prim_sec_ind= 'P'
ELSE
	select  @cost_prim_sec_ind= 'S'


-- select * from insert into invoice_template_map select 'FINAL','FINAL',3064,'N','N','3064-RINS'

        SELECT @template_name='3064-RINS' 
	from #voucher_detail where cost_code='RINS'


	IF (SELECT distinct 1  from #voucher_detail where voucher_type_code='FINAL' )=1
	BEGIN
		SELECT @voucher_type_code='FINAL'

	    select @template_name=template_name 
	        from invoice_template_map
	        where booking_comp=@BookingComp
	        and voucher_type_code=@voucher_type_code
		and price_ind=@formula_type
		and mot_type=@mot_type_code
		and @template_name is null
	END
	ELSE
	BEGIN
		SELECT @voucher_type_code='PRELIMIN'
		select @template_name=template_name 
        from invoice_template_map
        where booking_comp=@BookingComp
        and voucher_type_code=@voucher_type_code
		and @template_name is null
	END





END



IF @debug_ind='Y' 
begin 
	select @voucher_num voucher_num, @voucher_type_code voucher_type_code, @BookingComp BookingComp,@mot_type_code mot_type_code,@formula_type formula_type, @template_name template_name
	select * From #voucher_detail
end

select case when @template_name is null  then '511-F-B-A'
	else @template_name
	end
                'TemplateName'



END

GO
GRANT EXECUTE ON  [dbo].[usp_get_inv_template_name] TO [next_usr]
GO
