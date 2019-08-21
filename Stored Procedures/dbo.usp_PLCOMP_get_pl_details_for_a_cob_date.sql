SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[usp_PLCOMP_get_pl_details_for_a_cob_date]                        
(                          
   @cob_date            datetime,                          
   @first_date_flag     bit = 1,                          
   @debugon             bit = 0                          
)                          
as                          
set nocount on                          
declare @status            int,                          
        @smsg              varchar(800),                          
        @rows_affected     int,                          
        @time_started      varchar(20),                          
        @time_finished     varchar(20)                          
                                  
   set @status = 0                          
                             
   set @time_started = (select convert(varchar, getdate(), 109))                          
                          
   begin try                          
   if @first_date_flag = 1                          
     select                            
        pl_record_key,                                                                                  
        pl.pl_asof_date,                                                                                   
        pl.real_port_num,                           
        pl.cost_num,                                                                                     
        pl.pos_num,                            
        pl_owner_code,                                                                                
        pl.pl_owner,                                                                                  
        pl.trade_key,                     
        --ADSO-3127                                                                              
        case when pl_owner_code = 'P' then inv.trade_num         
    when pl_owner_code = 'IPO' then oinv.trade_num else pl.pl_secondary_owner_key1 end,   /* trade_num */                          
        case when pl_owner_code = 'P' then inv.order_num         
    when pl_owner_code = 'IPO' then oinv.order_num else pl.pl_secondary_owner_key2 end,/* order_num */                          
        case when pl_owner_code = 'P' then inv.sale_item_num         
    when pl_owner_code = 'IPO' then oinv.sale_item_num else pl.pl_secondary_owner_key3 end, /* item_num */                      
        pl.trade_cost_type,                                                        
        pl.pl_type,                                                                              
        pl.pl_type_desc,                                                                                
        case when @first_date_flag = 1 then null                          
             when pl_owner_code in ('I', 'P')                           
                then 'INVENTORY'                                
             else isnull(isnull(case when ti.order_type_code in ('SWAP','SWAPFLT')                           
                                        then 'SWAP'                                                       
                                     when pl_owner_sub_code in ('ADDLA', 'ADDLAA', 'ADDLAI',                           
                                                                'ADDLP', 'ADDLSWAP', 'ADDLTI',                           
                                                                'BC', 'FBC', 'JV', 'MEMO',                           
                                                                'OBC', 'PS', 'PTS', 'SAC',                           
                                                                'SPP', 'STC', 'SWBC', 'TAC',                           
                                                                'TPP', 'WAP', 'WO', 'WS','ICO')                           
                                        then 'SERVICES'                                                           
                                     else                           
                              ti.order_type_code                           
     end, ti.trade_status_code), 'OTHER')                                                       
        end,    /* trade_type */                      
        --ADSO-3127                         
        /*case when @first_date_flag = 1                           
                then pl_primary_owner_key1                          
             when pl_owner_sub_code = 'D'                           
                then pl_primary_owner_key1                                                      
             when pl_owner_sub_code = 'WPP' and                           
             c.cost_owner_code != 'TI'                           
                then                           
                   c.cost_owner_key1                           
             else pl_primary_owner_key1                           
        end,                                                  
        case when @first_date_flag = 1                           
                then pl_primary_owner_key2                       
             when pl_owner_sub_code = 'D'                           
                then pl_primary_owner_key2                                                                                   
             when pl_owner_sub_code = 'WPP' and                           
                  c.cost_owner_code != 'TI'                           
                then                           
            c.cost_owner_key2                           
             else pl_primary_owner_key2                           
        end,   */                   
         case when @first_date_flag = 1                           
                then ai.alloc_num                          
             when pl_owner_code = 'C' and c.cost_owner_code != 'TI' then c.cost_owner_key1                   
             when pl_owner_code = 'C' and c.cost_owner_code = 'TI' then ai.alloc_num                           
             when pl_owner_code = 'I' then pl_primary_owner_key1                  
             when pl_owner_code = 'P' then ai.alloc_num                           
             else ai.alloc_num                           
        end,  /* alloc_num */                                                                                 
        case when @first_date_flag = 1                           
                then ai1.alloc_item_num                         
             when pl_owner_code = 'C' and c.cost_owner_code != 'TI' then c.cost_owner_key2                   
             when pl_owner_code = 'C' and c.cost_owner_code = 'TI' then ai1.alloc_item_num                            
             when pl_owner_code = 'I' then pl_primary_owner_key2                  
             when pl_owner_code = 'P' then ai1.alloc_item_num                           
             else ai1.alloc_item_num                           
        end,      /* alloc_item_num */                                              
        pl_amt,  /* pl_amt */                    
        --   ADSO-2438                 
        /*case when @first_date_flag = 1                           
                then pl_record_qty                          
    when pl_record_qty is null and                           
                  pl_owner_sub_code is null                                                                         
                then                           
                 pos.long_qty - pos.short_qty                                                                         
             when pl_record_qty is null and                           
                  pl_owner_sub_code is not null                                                                         
                then case when ti.p_s_ind = 'S' then -1                           
                          else 1                           
                     end * ti.contr_qty                           
             else                           
                pl_record_qty                     
        end,  */                       
                case when ti.p_s_ind = 'S' then -1                           
                          else 1                           
                     end *(                
                                  case when pl_owner_code = 'I' and pl_owner_sub_code = 'D' and pl_record_qty is not null and pl_record_qty > 0  then                
          --case when pl_owner_code in ('I', 'P') and pl_record_qty is not null and pl_record_qty > 0  then                
                  
          (case when pl_type  ='U'  Then                
            (case when pl_amt != 0 then                
            (pl_amt /( (pl_amt +(select tempPHist.pl_amt from pl_history as tempPHist where tempPHist.pl_record_key= pl.pl_record_key          
                          and  tempPHist.pl_type ='R' and tempPHist.pl_owner_code in ('I', 'P')  and tempPHist.pl_asof_date = pl.pl_asof_date and pl.real_port_num=tempPHist.real_port_num and tempPHist.pl_owner_code =pl.pl_owner_code))/pl.pl_record_qty))          
            else 0 end)                
          else                
            (case when pl_type  ='R' then                
              (case when pl_amt != 0 then                 
               (pl_amt /( (pl_amt +(select tempPHist.pl_amt from pl_history as tempPHist where tempPHist.pl_record_key= pl.pl_record_key       
       and  tempPHist.pl_type ='U' and tempPHist.pl_owner_code in ('I', 'P')  and tempPHist.pl_asof_date = pl.pl_asof_date and pl.real_port_num=tempPHist.real_port_num and tempPHist.pl_owner_code =pl.pl_owner_code))/pl.pl_record_qty ))     
              else 0 end)                
            else                
           pl_record_qty                
            end)                
          end)         
                  
          when pl_owner_code ='P' and pl_owner_sub_code is NULL  then         
              (case when pl_amt != 0 then pos.long_qty - pos.short_qty else 0 end)        
          else                
            (case when pl_record_qty is not null and pl_record_qty >0 then                 
             (case when pl_amt is not null and pl_amt > 0 then  pl_record_qty                 
              else 0                 
              end )                
             else                
            ( case when ti.contr_qty is not null then ti.contr_qty   else   0  end )                            
           end)                
       end) ,  /* contr_qty */                        
                      
  case when ti.p_s_ind = 'S' then -1                          
  else 1                           
                     end * ti.sch_qty,    /* sch_qty */                           
                           
        case when ti.p_s_ind = 'S' then -1                           
                          else 1                           
                     end * ti.open_qty,     /* open_qty */                       
                               
                        
        case when @first_date_flag = 1                           
                then pl_record_qty_uom_code                          
             when pl_record_qty_uom_code is null and                    
                  pl_owner_sub_code is null                           
                then pos.qty_uom_code                                                                                  
             when pl_record_qty_uom_code is null and                           
                  pl_owner_sub_code is not null                           
                then ti.contr_qty_uom_code                                                                                  
             when pl_owner_sub_code in ('CPP', 'CPR')                           
                then cost_price_curr_code                                                                         
             else                           
                pl_record_qty_uom_code                           
        end,   /* qty_uom */                             
        price_uom_code,                                                                  
        case when @first_date_flag = 1                           
                then null                          
             when pl_owner_sub_code = 'SPP'                           
                then 'STORAGE'                                                                         
             when pl_owner_sub_code in ('ADDLA', 'ADDLAA', 'ADDLAI', 'ADDLP',                          
                                    'ADDLSWAP', 'ADDLTI', 'BC', 'FBC',                          
                                        'JV', 'MEMO', 'OBC', 'PS', 'PTS',                           
                                        'SAC', 'SPP', 'STC', 'SWBC', 'TAC',                           
                                        'TPP',  'WAP', 'WO', 'WS','ICO')                                                                          
                then                           
                   c.cost_code                           
             else                           
                pos.cmdty_short_name                           
        end,    /* cmdty_short_name */                                                                                  
        case when @first_date_flag = 1                           
                then null                          
             else                           
                pos.mkt_short_name                          
        end,    /* mkt_short_name */                                                                                  
        case when @first_date_flag = 1                           
                then null                          
             when ti.order_type_code in ('SWAP', 'SWAPFLT')                           
            then convert(char(3), upper(datename(mm, ti.quote_end_date))) + '-' +                           
                     substring(convert(char, datepart(yy, ti.quote_end_date)), 3, 4)                          
          when pos.trading_prd_desc like 'W-%'                           
            then 'W-' + convert(varchar, datepart(wk, pos.first_del_date)) + ' (' +                          
                    substring(pos.trading_prd_desc, 7, 5) + ') ' + substring(pos.trading_prd_desc, 13, 5)                          
          else                           
             pos.trading_prd_desc                           
        end,                     /* trading_prd_desc */                                                                                  
        case when @first_date_flag = 1                           
                then null                          
             when ti.order_type_code in ('SWAP', 'SWAPFLT')                           
      then ti.quote_end_date                          
            else pos.last_issue_date                          
        end,                                  /* trading_prd_date */                                                                         
       
case when ti.order_type_code='SWAP' and ABS(ISNULL(tidmtmswap.trade_value,1)) <> 0 and ABS(ISNULL(tidmtmswap.avg_price,1)) <>0 then (case when ti.p_s_ind = 'P' then -1 else 1 end * ISNULL(tidmtmswap.avg_price,1) * ISNULL(pl.currency_fx_rate,1)) + ISNULL(
pl_amt,0) /(ABS(ISNULL(tidmtmswap.trade_value,1))/ABS(ISNULL(tidmtmswap.avg_price,1)))  
else pl.pl_mkt_price end as pl_mkt_price, /* pl_mkt_price */        
                                                                                      
   case when @first_date_flag = 1                           
                then null                          
             else ti.contr_date                          
        end,                                  /* contr_date */                                                                                  
       case when @first_date_flag = 1                           
                then null                          
             else             
                ti.trade_mod_date                          
        end,                                  /* trade_mod_date */                                                                                  
        case when pl_owner_sub_code in ('P', 'I')                           
                then pos.avg_purch_price                  
             when ti.order_type_code = 'SWAP' and ti.contr_qty <> 0             
      then  case when ti.p_s_ind = 'P' then -1                           
                          else 1                           
                     end * CONVERT(FLOAT, case when isnumeric(sfp.swap_fixedPrice)=1 then sfp.swap_fixedPrice else '0' end)                                                                              
             else ti.avg_price                           
        end,                                  /* avg_price */                                                                                  
        case when @first_date_flag = 1                           
                then pl.currency_fx_rate                          
             when pl.currency_fx_rate is null                           
                then 1                           
             else pl.currency_fx_rate                           
        end,                                  /* fx_rate */                                                              
        case when @first_date_flag = 1                           
                then null                          
             else                          
                ti.inhouse_ind                          
        end,                        /* inhouse_ind */                                                               
        case when @first_date_flag = 1                           
                then pl_realization_date                          
             else                          
                isnull(isnull(c.cost_eff_date, pos.last_trade_date), pl_realization_date)                          
        end,                               /* pl_realization_date */                                                                         
        case when @first_date_flag = 1                    
                then null                          
             when pl.pl_owner_code = 'C'                           
                then isnull(c.cost_counterparty_name, ti.trade_counterparty_name)                            
             when ti.inhouse_ind = 'I'                           
                then 'INTERNAL-' + convert(varchar, ti.port_num)                                                                         
        end,                               /* counterparty */                             
        case when @first_date_flag = 1                           
                then null                          
             else                          
                ti.clearing_brkr_name                          
        end,           /* clearing_brkr */                                                                      
        case when @first_date_flag = 1                           
                then null                          
             else                          
                isnull(c.cost_price_curr_code, ti.price_curr_code)                          
        end,                               /* price_curr_code */                                                                  
        case when @first_date_flag = 1                           
                then null                          
             else c.alloc_creation_date                          
        end,                               /* alloc_creation_date */                                                                    
        case when @first_date_flag = 1                           
                then null                          
             else                           
                c.alloc_trans_id                          
        end,               /* alloc_trans_id */                                           
        case when @first_date_flag = 1                           
                then null                          
             else                          
                c.cost_creation_date                         
        end,                              /* cost_creation_date */                                                           
        case when @first_date_flag = 1                           
                then null                          
             else                           
       c.cost_trans_id                          
        end,                              /* cost_trans_id */                                         
        case when @first_date_flag = 1                           
                then null                          
             else ti.trans_id                          
        end,                              /* trade_trans_id */                                                   
        pl.trans_id,                      /* pl_trans_id */                                    
        case when @first_date_flag = 1                           
                then null                          
             when c.cost_prim_sec_ind = 'S'                           
                then c.creator_init                                                                 
             when c.cost_owner_code in ('A', 'AA', 'AI') and                           
                  c.cost_prim_sec_ind = 'P'                           
                then c.sch_init                                                                
             when c.cost_owner_code in ('TI') and                           
                  c.cost_prim_sec_ind = 'P'                           
                then ti.creator_init                                                    
        end,                               /* creator_init */                          
        ti.trader_name      
   ,NULL          
        ,NULL /*ship_id*/          
  ,NULL/*parcel*/                        
  --ADSO-3127                  
        --,ai.transfer_price,                        
  -- a.transfer_price       
  ,case  when pl_owner_code = 'IPO' and pl_owner_sub_code = 'B' then pl.pl_primary_owner_key1 end as pl_inv_num /* Inv Num*/                      
  
  ,case  when pl_owner_code = 'IPO' and pl_owner_sub_code = 'B' then pl.pl_primary_owner_key2 end as pl_inv_bd_num /* Inv BD Num*/  
                         
                        
     from #pl_hist1 pl WITH (NOLOCK)                                                                             
             left outer join dbo.v_PLCOMP_position_info pos                           
                on pl.pos_num = pos.pos_num                    
                              
             left outer join dbo.v_PLCOMP_trade_item_info ti                          
                on ti.trade_num = pl.pl_secondary_owner_key1 and                           
                   ti.order_num = pl.pl_secondary_owner_key2 and                           
                   ti.item_num = pl.pl_secondary_owner_key3 and             
                   not(ti.open_qty = 0 and ti.order_type_code = 'PHYSICAL' and pl.pl_owner_code = 'T' and pl.pl_record_qty is null)  and                           
                   pl.real_port_num=case when ti.inhouse_ind='Y' then                   
           case when pl.real_port_num=ti.port_num then                   
           ti.port_num                   
           else                   
           ti.real_port_num                   
           end                    
         else                   
          ti.real_port_num                   
         end /*[I#NBLO-3865]added check for inhouse trade*/                                               
  --ADSO-3127                                               
             LEFT OUTER JOIN (select max(alloc_num) alloc_num , trade_num,order_num,item_num from allocation_item group by trade_num,order_num,item_num) ai                   
      ON ai.trade_num=ti.trade_num and ai.order_num=ti.order_num and ai.item_num=ti.item_num                    
    left outer join (select min(alloc_item_num) alloc_item_num , trade_num,order_num,item_num,alloc_num from allocation_item group by trade_num,order_num,item_num,alloc_num) ai1                                                                              
 
    
      
        
          
            
              
                
                             
      ON ai1.trade_num=ti.trade_num and ai1.order_num=ti.order_num and ai1.item_num=ti.item_num  and ai1.alloc_num = ai.alloc_num                  
             left outer join dbo.v_PLCOMP_cost_info c                           
                on c.cost_num = pl.pl_record_key and                           
  pl.pl_owner_code = 'C'                   
             --ADSO-3127                        
             left outer join  dbo.inventory inv                  
                on inv.pos_num = pl.pl_record_key and                  
                     pl.pl_owner_code = 'P'         
             left outer join  dbo.inventory oinv         
                on oinv.inv_num = pl.pl_record_owner_key and        
                     pl.pl_owner_code = 'IPO'                
             left outer join   (select ti.trade_num,ti.order_num,ti.item_num,formula_body_string              
, isnull(formula_body_string,'0') as swap_fixedPrice               
 from formula_body fb              
inner join trade_formula tf on tf.formula_num=fb.formula_num and fb.formula_body_type='M'              
inner join trade_item ti on ti.trade_num=tf.trade_num and ti.order_num=tf.order_num and ti.item_num=tf.item_num              
inner join trade_order tor on tor.trade_num=ti.trade_num and tor.order_num=ti.order_num and tor.order_type_code='SWAP'              
and tf.fall_back_ind='N' ) sfp on ti.trade_num=sfp.trade_num and ti.order_num=sfp.order_num              
and ti.item_num=sfp.item_num          
--ADSO-8983 - taking contract quantity from tid_mark_to_market which already converted in price uom      
LEFT OUTER JOIN tid_mark_to_market  tidmtmswap          ON tidmtmswap.dist_num=pl.pl_record_owner_key      
  AND tidmtmswap.trade_num=pl.pl_primary_owner_key1      
  AND tidmtmswap.order_num=pl.pl_primary_owner_key2      
  AND tidmtmswap.item_num=pl.pl_primary_owner_key3        
     AND tidmtmswap.mtm_pl_asof_date = CASE  WHEN exists(SELECT 1 FROM tid_mark_to_market tidmtm2 WHERE tidmtm2.dist_num=pl.pl_record_owner_key and tidmtm2.mtm_pl_asof_date =pl.pl_asof_date) Then       
                        pl.pl_asof_date ELSE (SELECT max(mtm_pl_asof_date) FROM tid_mark_to_market tidmtm3 WHERE tidmtm3.dist_num=pl.pl_record_owner_key ) END      
                                                                                        
 --ADSO-3127 - Commented below                  
    /*left outer join dbo.allocation_item ai                       
   on ai.trade_num = pl.pl_secondary_owner_key1 and                           
   ai.order_num = pl.pl_secondary_owner_key2 and                           
                ai.item_num =  pl.pl_secondary_owner_key3                                                                                
     left outer join dbo.allocation a               
    on ai.alloc_num = a.alloc_num   */                                                                             
     else                          
          select                            
        pl_record_key,                                                                                  
        pl.pl_asof_date,                                                                                   
        pl.real_port_num,                           
 pl.cost_num,                                                                                     
        pl.pos_num,                            
        pl_owner_code,                                                                                
        pl.pl_owner,                                                                                  
        pl.trade_key,                     
        --ADSO-3127               
        case when pl_owner_code = 'P' then inv.trade_num         
    when pl_owner_code = 'IPO' then oinv.trade_num else pl.pl_secondary_owner_key1 end,   /* trade_num */                          
        case when pl_owner_code = 'P' then inv.order_num         
    when pl_owner_code = 'IPO' then oinv.order_num else pl.pl_secondary_owner_key2 end,/* order_num */                          
        case when pl_owner_code = 'P' then inv.sale_item_num         
    when pl_owner_code = 'IPO' then oinv.sale_item_num else pl.pl_secondary_owner_key3 end, /* item_num */                      
        pl.trade_cost_type,                                                        
        pl.pl_type,                                                                              
        pl.pl_type_desc,                                                                                
        case when @first_date_flag = 1                           
               then null                          
             when pl_owner_code in ('I', 'P')                           
                then 'INVENTORY'                                
             else isnull(isnull(case when ti.order_type_code in ('SWAP','SWAPFLT')                           
                                        then 'SWAP'                                                       
                                     when pl_owner_sub_code in ('ADDLA', 'ADDLAA', 'ADDLAI',                           
                             'ADDLP', 'ADDLSWAP', 'ADDLTI',                           
                                                                'BC', 'FBC', 'JV', 'MEMO',                           
                                                                'OBC', 'PS', 'PTS', 'SAC',                           
                                               'SPP', 'STC', 'SWBC', 'TAC',                           
                                                                'TPP', 'WAP', 'WO', 'WS','ICO')             
                                        then 'SERVICES'                           
                                     else                           
                                        ti.order_type_code                           
                                end, ti.trade_status_code), 'OTHER')                                                       
        end,    /* trade_type */                      
        --ADSO-3127                                                                                     
        /*case when @first_date_flag = 1                           
                then null                          
             when pl_owner_sub_code = 'D'                           
                then pl_primary_owner_key1                                                                                   
           when pl_owner_sub_code = 'WPP' and                           
                  c.cost_owner_code != 'TI'           
                then                           
                   c.cost_owner_key1                           
             else pl_primary_owner_key1                           
        end,                                                                                 
        case when @first_date_flag = 1 then null                          
             when pl_owner_sub_code = 'D' then pl_primary_owner_key2                                                                                   
             when pl_owner_sub_code = 'WPP' and c.cost_owner_code != 'TI' then c.cost_owner_key2                           
             else pl_primary_owner_key2                           
        end,                               */                  
        case when @first_date_flag = 1       
                then ai.alloc_num                          
             when pl_owner_code = 'C' and c.cost_owner_code != 'TI' then c.cost_owner_key1                   
             when pl_owner_code = 'C' and c.cost_owner_code = 'TI' then ai.alloc_num                           
             when pl_owner_code = 'I' then pl_primary_owner_key1                  
             when pl_owner_code = 'P' then ai.alloc_num                           
             else ai.alloc_num                           
        end,  /* alloc_num */                                                                                 
        case when @first_date_flag = 1                           
                then ai1.alloc_item_num                         
             when pl_owner_code = 'C' and c.cost_owner_code != 'TI' then c.cost_owner_key2                   
             when pl_owner_code = 'C' and c.cost_owner_code = 'TI' then ai1.alloc_item_num                           
             when pl_owner_code = 'I' then pl_primary_owner_key2                  
             when pl_owner_code = 'P' then ai1.alloc_item_num                           
             else ai1.alloc_item_num                           
        end,      /* alloc_item_num */                                 
        pl_amt,  /* pl_amt */                  
        /*                                                                               
        case when @first_date_flag = 1         
                then pl_record_qty                          
             when pl_record_qty is null and                           
                  pl_owner_sub_code is null                                             
                then                           
                   pos.long_qty - pos.short_qty                                                                         
             when pl_record_qty is null and                           
                  pl_owner_sub_code is not null                                                                         
                then case when ti.p_s_ind = 'S' then -1                           
                          else 1                           
                     end * ti.contr_qty                           
   else                           
                pl_record_qty                           
        end,*/                
                  case when ti.p_s_ind = 'S' then -1                           
                          else 1                           
                     end *(                
                                  case when pl_owner_code = 'I' and pl_owner_sub_code = 'D' and pl_record_qty is not null and pl_record_qty > 0  then                
          --case when pl_owner_code in ('I', 'P') and pl_record_qty is not null and pl_record_qty > 0  then                
                  
          (case when pl_type  ='U'  Then                
            (case when pl_amt != 0 then                
            (pl_amt /( (pl_amt +(select tempPHist.pl_amt from pl_history as tempPHist where tempPHist.pl_record_key= pl.pl_record_key          
                          and  tempPHist.pl_type ='R' and tempPHist.pl_owner_code in ('I', 'P')  and tempPHist.pl_asof_date = pl.pl_asof_date and pl.real_port_num=tempPHist.real_port_num and tempPHist.pl_owner_code =pl.pl_owner_code))/pl.pl_record_qty))          
            else 0 end)                
          else                
            (case when pl_type  ='R' then                
              (case when pl_amt != 0 then                 
               (pl_amt /( (pl_amt +(select tempPHist.pl_amt from pl_history as tempPHist where tempPHist.pl_record_key= pl.pl_record_key       
       and  tempPHist.pl_type ='U' and tempPHist.pl_owner_code in ('I', 'P')  and tempPHist.pl_asof_date = pl.pl_asof_date and pl.real_port_num=tempPHist.real_port_num and tempPHist.pl_owner_code =pl.pl_owner_code))/pl.pl_record_qty ))     
              else 0 end)                
            else                
           pl_record_qty                
            end)                
          end)         
                  
          when pl_owner_code ='P' and pl_owner_sub_code is NULL  then         
              (case when pl_amt != 0 then pos.long_qty - pos.short_qty else 0 end)        
          else                
            (case when pl_record_qty is not null and pl_record_qty >0 then                 
             (case when pl_amt is not null and pl_amt > 0 then  pl_record_qty                 
              else 0                 
              end )                
             else                
            ( case when ti.contr_qty is not null then ti.contr_qty   else   0  end )                            
           end)                
       end) ,    /* contr_qty */                
                      
  case when ti.p_s_ind = 'S' then -1                          
                  else 1                           
                     end * ti.sch_qty,    /* sch_qty */                           
                           
        case when ti.p_s_ind = 'S' then -1                           
                          else 1                           
                     end * ti.open_qty,     /* open_qty */                       
                                              
        case when @first_date_flag = 1                           
                then pl_record_qty_uom_code                          
             when pl_record_qty_uom_code is null and                           
                  pl_owner_sub_code is null                           
                then pos.qty_uom_code                                                                                  
             when pl_record_qty_uom_code is null and                           
                  pl_owner_sub_code is not null                           
                then ti.contr_qty_uom_code                                           
             when pl_owner_sub_code in ('CPP', 'CPR')                   
                then cost_price_curr_code                                                                                  
             else                           
                pl_record_qty_uom_code                           
        end,   /* qty_uom */                     
        price_uom_code,                                                                                
        case when @first_date_flag = 1                           
                then null                          
             when pl_owner_sub_code = 'SPP'                           
                then 'STORAGE'                                                                         
             when pl_owner_sub_code in ('ADDLA', 'ADDLAA', 'ADDLAI', 'ADDLP',                          
                                        'ADDLSWAP', 'ADDLTI', 'BC', 'FBC',                          
                                        'JV', 'MEMO', 'OBC', 'PS', 'PTS',                           
                                        'SAC', 'SPP', 'STC', 'SWBC', 'TAC',                           
                                        'TPP',  'WAP', 'WO', 'WS','ICO')                                                                          
                then                           
                   c.cost_code                           
             else                           
                pos.cmdty_short_name                           
        end,    /* cmdty_short_name */                       
        case when @first_date_flag = 1                           
                then null                          
             else                           
                pos.mkt_short_name                          
        end,    /* mkt_short_name */                                                                                  
        case when @first_date_flag = 1                           
                then null                          
             when ti.order_type_code in ('SWAP', 'SWAPFLT')                           
            then convert(char(3), upper(datename(mm, ti.quote_end_date))) + '-' +                           
                     substring(convert(char, datepart(yy, ti.quote_end_date)), 3, 4)                          
          when pos.trading_prd_desc like 'W-%'                           
            then 'W-' + convert(varchar, datepart(wk, pos.first_del_date)) + ' (' +                          
                    substring(pos.trading_prd_desc, 7, 5) + ') ' + substring(pos.trading_prd_desc, 13, 5)                          
          else                           
  pos.trading_prd_desc                           
        end,                                  /* trading_prd_desc */                                                                                  
        case when @first_date_flag = 1                           
                then null                          
             when ti.order_type_code in ('SWAP', 'SWAPFLT')                           
            then ti.quote_end_date                          
            else pos.last_issue_date                          
        end,                                  /* trading_prd_date */        
                
case when ti.order_type_code='SWAP' and ABS(ISNULL(tidmtmswap.trade_value,1)) <> 0 and ABS(ISNULL(tidmtmswap.avg_price,1)) <>0 then (case when ti.p_s_ind = 'P' then -1 else 1 end * ISNULL(tidmtmswap.avg_price,1) * ISNULL(pl.currency_fx_rate,1)) + ISNULL(
pl_amt,0) /(ABS(ISNULL(tidmtmswap.trade_value,1))/ABS(ISNULL(tidmtmswap.avg_price,1)))  
else pl.pl_mkt_price end as pl_mkt_price, /* pl_mkt_price */      
              
        case when @first_date_flag = 1                     
            then null                          
             else ti.contr_date                          
        end,                                  /* contr_date */                                                                                  
        case when @first_date_flag = 1                           
                then null                          
             else           
                ti.trade_mod_date                          
        end,                                  /* trade_mod_date */                                 
        case when pl_owner_sub_code in ('P', 'I')                           
                then pos.avg_purch_price                   
             when ti.order_type_code = 'SWAP' and ti.contr_qty <> 0             
               then  case when ti.p_s_ind = 'P' then -1                           
                          else 1                           
                     end * CONVERT(FLOAT, case when isnumeric(sfp.swap_fixedPrice)=1 then sfp.swap_fixedPrice else '0' end)                                                                              
             else ti.avg_price                           
        end,                                  /* avg_price */                                                                                  
        case when @first_date_flag = 1                           
                then pl.currency_fx_rate                          
             when pl.currency_fx_rate is null                           
                then 1                           
             else pl.currency_fx_rate                           
        end,                                  /* fx_rate */                                                              
        case when @first_date_flag = 1                           
             then null                          
             else                          
   ti.inhouse_ind                          
        end,                               /* inhouse_ind */                                           
        case when @first_date_flag = 1                           
                then pl_realization_date                          
             else                          
                isnull(isnull(c.cost_eff_date, pos.last_trade_date), pl_realization_date)                          
        end,                               /* pl_realization_date */                                                                         
        case when @first_date_flag = 1                           
                then null                          
             when pl.pl_owner_code = 'C'                           
                then isnull(c.cost_counterparty_name, ti.trade_counterparty_name)                            
             when ti.inhouse_ind = 'I'                           
                then 'INTERNAL-' + convert(varchar, ti.port_num)                                                                         
        end,                               /* counterparty */                             
        case when @first_date_flag = 1                           
                then null                          
             else                          
                ti.clearing_brkr_name                          
        end,                               /* clearing_brkr */                                                                      
        case when @first_date_flag = 1                                 then null                          
             else                          
                isnull(c.cost_price_curr_code, ti.price_curr_code)                          
        end,                               /* price_curr_code */                                                                  
        case when @first_date_flag = 1                           
                then null                          
             else c.alloc_creation_date                          
        end,                               /* alloc_creation_date */                                                                    
        case when @first_date_flag = 1                           
                then null                          
             else                           
                c.alloc_trans_id                          
        end,                               /* alloc_trans_id */                                           
        case when @first_date_flag = 1                           
                then null                          
             else                          
                c.cost_creation_date                          
        end,                              /* cost_creation_date */                                                           
        case when @first_date_flag = 1                           
                then null                          
             else                           
                c.cost_trans_id                          
        end,                    /* cost_trans_id */                                         
        case when @first_date_flag = 1                           
                then null                          
             else ti.trans_id                          
        end,                              /* trade_trans_id */                                                   
        pl.trans_id,                      /* pl_trans_id */                                    
        case when @first_date_flag = 1                           
                then null                          
             when c.cost_prim_sec_ind = 'S'                           
                then c.creator_init                                                                 
             when c.cost_owner_code in ('A', 'AA', 'AI') and                           
                  c.cost_prim_sec_ind = 'P'                           
                then c.sch_init                                                                
   when c.cost_owner_code in ('TI') and                           
                  c.cost_prim_sec_ind = 'P'                           
                then ti.creator_init                                                                
        end,                               /* creator_init */                          
        ti.trader_name    
   ,NULL          
        ,NULL /*ship_id*/          
  ,NULL/*parcel*/                       
  --ADSO-3127                  
        --,ai.transfer_price,                        
        --a.transfer_price    
 ,case  when pl_owner_code = 'IPO' and pl_owner_sub_code = 'B' then pl.pl_primary_owner_key1 end as pl_inv_num /* Inv Num*/                      
  
 ,case  when pl_owner_code = 'IPO' and pl_owner_sub_code = 'B' then pl.pl_primary_owner_key2 end as pl_inv_bd_num /* Inv BD Num*/    
          
from #pl_hist2 pl WITH (NOLOCK)                                                                             
left outer join dbo.v_PLCOMP_position_info pos                           
on pl.pos_num = pos.pos_num           
          
left outer join dbo.v_PLCOMP_trade_item_info ti                          
on ti.trade_num = pl.pl_secondary_owner_key1 and ti.order_num = pl.pl_secondary_owner_key2           
and ti.item_num = pl.pl_secondary_owner_key3           
and  not(ti.open_qty = 0 and ti.order_type_code = 'PHYSICAL' and pl.pl_owner_code = 'T' and pl.pl_record_qty is null)  /*[#ADSO-5124]*/          
and  pl.real_port_num=case when ti.inhouse_ind='Y' then           
case when pl.real_port_num=ti.port_num then ti.port_num           
else ti.real_port_num end  else ti.real_port_num end /*[I#NBLO-3865]added check for inhouse trade*/                                        
          
--ADSO-3127                        
LEFT OUTER JOIN (select max(alloc_num) alloc_num , trade_num,order_num,item_num           
from allocation_item group by trade_num,order_num,item_num) ai                   
ON ai.trade_num=ti.trade_num and ai.order_num=ti.order_num and ai.item_num=ti.item_num                    
          
left outer join (select min(alloc_item_num) alloc_item_num , trade_num,order_num,item_num,alloc_num           
from allocation_item group by trade_num,order_num,item_num,alloc_num) ai1                                                                                         
ON ai1.trade_num=ti.trade_num and ai1.order_num=ti.order_num and ai1.item_num=ti.item_num  and ai1.alloc_num = ai.alloc_num                                                                             
          
left outer join dbo.v_PLCOMP_cost_info c                           
on c.cost_num = pl.pl_record_key and                           
pl.pl_owner_code = 'C'   
--ADSO-3127                    
left outer join  dbo.inventory inv on inv.pos_num = pl.pl_record_key and pl.pl_owner_code = 'P'        
left outer join  dbo.inventory oinv on oinv.inv_num = pl.pl_record_owner_key and pl.pl_owner_code = 'IPO'                
             
left outer join   (select ti.trade_num,ti.order_num,ti.item_num,formula_body_string              
, isnull(formula_body_string,'0') as swap_fixedPrice from formula_body fb             
           
inner join trade_formula tf on tf.formula_num=fb.formula_num and fb.formula_body_type='M'              
          
inner join trade_item ti on ti.trade_num=tf.trade_num and ti.order_num=tf.order_num and ti.item_num=tf.item_num              
          
inner join trade_order tor on tor.trade_num=ti.trade_num and tor.order_num=ti.order_num and tor.order_type_code='SWAP'              
and tf.fall_back_ind='N' ) sfp on ti.trade_num=sfp.trade_num and ti.order_num=sfp.order_num  and ti.item_num=sfp.item_num                                                                                            
      
--ADSO-8983 - taking contract quantity from tid_mark_to_market which already converted in price uom      
LEFT OUTER JOIN tid_mark_to_market  tidmtmswap        
  ON tidmtmswap.dist_num=pl.pl_record_owner_key      
  AND tidmtmswap.trade_num=pl.pl_primary_owner_key1      
  AND tidmtmswap.order_num=pl.pl_primary_owner_key2      
  AND tidmtmswap.item_num=pl.pl_primary_owner_key3        
     AND tidmtmswap.mtm_pl_asof_date = CASE  WHEN exists(SELECT 1 FROM tid_mark_to_market tidmtm2 WHERE tidmtm2.dist_num=pl.pl_record_owner_key and tidmtm2.mtm_pl_asof_date =pl.pl_asof_date) Then       
                       pl.pl_asof_date ELSE (SELECT max(mtm_pl_asof_date) FROM tid_mark_to_market tidmtm3 WHERE tidmtm3.dist_num=pl.pl_record_owner_key ) END      
          
   --ADSO-3127                  
/* left outer join dbo.allocation_item ai on                         
ai.trade_num = pl.pl_secondary_owner_key1 and                           
ai.order_num = pl.pl_secondary_owner_key2 and                           
ai.item_num =  pl.pl_secondary_owner_key3                                                                                
left outer join dbo.allocation a on                         
ai.alloc_num = a.alloc_num   */              
                                                                                                                                      
     set @rows_affected = @@rowcount                          
   end try                          
   begin catch                          
     set @smsg = '=> Failed to retrieve PL details for the COB date ''' + convert(varchar, @cob_date, 101) + ''' due to the error:'                          
     RAISERROR (@smsg, 0, 1) WITH NOWAIT                          
     set @smsg = '==> ERROR: ' + ERROR_MESSAGE()                          
     RAISERROR (@smsg, 0, 1) WITH NOWAIT                          
     goto endofsp                                
   end catch                          
   if @debugon = 1                          
   begin                          
     RAISERROR ('**********************', 0, 1) WITH NOWAIT                              
     set @smsg = '=> ' + cast(@rows_affected as varchar) + ' records having PL details were retrieved for the COB DATE ''' + convert(varchar, @cob_date, 101) + ''''                          
     RAISERROR (@smsg, 0, 1) WITH NOWAIT                          
     set @time_finished = (select convert(varchar, getdate(), 109))                          
     set @smsg = '==> Started : ' + @time_started                          
     RAISERROR (@smsg, 0, 1) WITH NOWAIT                          
     set @smsg = '==> Finished: ' + @time_finished                          
     RAISERROR (@smsg, 0, 1) WITH NOWAIT                               
   end                          
                             
endofsp:                          
return @status          

GO
GRANT EXECUTE ON  [dbo].[usp_PLCOMP_get_pl_details_for_a_cob_date] TO [next_usr]
GO
