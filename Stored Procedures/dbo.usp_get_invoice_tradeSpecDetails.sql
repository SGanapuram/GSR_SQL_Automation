SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_get_invoice_tradeSpecDetails]
(
   @voucherNum    int,      
   @executor      varchar(15),        
   @isPriliminary char(1) = 'N'   
)                         
as
set nocount on
   
   select fbm.*,
          dbo.udf_get_formulabody_invoiceDescription(fbm.formula_num,fbm.formula_body_num,line_item_invoice_desc) as lineInvoiceDescription,
          cpd.fb_value,
          cpd.unit_price,
          cpd.price_curr_code as PriceCurrCode,  
          cpd.price_uom_code as PriceUomCode,  
          deductionType = case when basis_cmdty_code like 'TC' then 'Treatment charges'  
                               when basis_cmdty_code like 'RC%' then 'Refinig'  
                               else 'Penalty'  
                          end  
   from dbo.voucher v 
           left outer join dbo.voucher_cost vc            
              on v.voucher_num = vc.voucher_num       
           left outer join dbo.cost c            
              on vc.cost_num = c.cost_num       
           left outer join dbo.trade_formula tf      
              on tf.trade_num = c.cost_owner_key6 AND 
                 tf.order_num = c.cost_owner_key7 AND 
                 tf.item_num = c.cost_owner_key8 and 
                 tf.fall_back_ind = @isPriliminary  
           left outer join dbo.fb_modular_info fbm 
              on fbm.formula_num = tf.formula_num  
           left outer join dbo.cost_price_detail cpd 
              on cpd.formula_num = fbm.formula_num and 
                 cpd.formula_body_num = fbm.formula_body_num and 
                 cpd.cost_num = (select cost_num 
                                 from dbo.cost 
                                 where cost_type_code = 'PR' and 
                                       cost_num = c.cost_num)    
   where v.voucher_num = @voucherNum
GO
GRANT EXECUTE ON  [dbo].[usp_get_invoice_tradeSpecDetails] TO [next_usr]
GO
