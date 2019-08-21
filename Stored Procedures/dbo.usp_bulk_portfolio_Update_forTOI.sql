SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_bulk_portfolio_Update_forTOI]  
(                  
   @trade_nums                  varchar(MAX),                    
   @order_nums                  varchar(MAX),                    
   @item_nums                   varchar(MAX),                    
   @real_port_nums              varchar(MAX),                    
   @use_account_areement_for_EB bit,                    
   @orig_cmdty_code             char(8),
   @login_name                  varchar(100),
   @app_name                    varchar(100) = 'OpsDashboard'
)
AS                    
BEGIN                    
 set nocount on                 
 --Main Declarations                l
 Begin                
    Declare @index int                
    Declare @blockSize int                
    Declare @count int                
    Declare @newTransId bigint                
    Declare @maxTransID bigint                
    DECLARE @IsFX_Exposure_ON CHAR(1)                 
    Declare @risk_mkt_code VARCHAR(8)                
    Declare @cmdty_code VARCHAR(8)                
    Declare @trading_prd VARCHAR(40)     
    DECLARE @orig_commodity_primUOM CHAR(4)                    
    DECLARE @orig_commodity_secUOM CHAR(4)                
 end                
                  
   --Initializations                
 Begin                
    set @index = 1                
    set @count = 0                
    set @maxTransID = 0              
    set @blockSize = 0      
    set @IsFX_Exposure_ON = 'N'    
    set @orig_commodity_primUOM = NULL    
    set @orig_commodity_secUOM = NULL            
 end                
                  
   --Create hashtable to maintain key value pairs for parent tarns_ids              
   IF OBJECT_ID('tempdb..#parentTransIDs') IS NOT NULL            
   BEGIN            
  DROP TABLE #parentTransIDs            
   END              
   create table  #parentTransIDs                   
   (                  
   key1 varchar(400),                
   value bigint                  
   )                 
                    
   --Get all TOIs and ports from the input strings                 
  Begin              
     IF OBJECT_ID('tempdb..#TOIs') IS NOT NULL            
     BEGIN            
  DROP TABLE #TOIs            
     END               
     create table #TOIs(Id int identity(1,1) primary key, trade_num varchar(20), order_num varchar(20), item_num varchar(20), real_port_num varchar(20),    
     cmdty_code varchar(20),risk_mkt_code varchar(20),trading_prd varchar(40),old_port_num varchar(20),prod_Type varchar(1),    
     --cmdty_code varchar(20),risk_mkt_code varchar(20),trading_prd varchar(40),old_port_num varchar(20),port_type varchar(2),prod_Type varchar(1),    
     uom_conv_rate DECIMAL(20,10),is_any_cost_vouchered bit, temp_acct_num INT,acct_num INT,    
     inhouse_ind varchar(1),can_trade_with_booking_comp bit,    
     prim_uom_code CHAR(4),                    
     sec_uom_code  CHAR(4),  target_key1ForMultiplierForBBL varchar(10),target_key1ForMultiplierForMT varchar(10),    
     aMultiplier varchar(20), reciprocal bit,desired_pl_curr_code CHAR(8) )    
         
     create nonclustered index TOIs_idx1    
     on #TOIs(trade_num,order_num,item_num)     
         
     create nonclustered index TOIs_idx2    
     on #TOIs(real_port_num)     
  
     insert into #TOIs(trade_num,order_num,item_num,real_port_num) select * from udf_split_TOIs(@trade_nums,@order_nums,@item_nums,@real_port_nums, ',')                
     select @blockSize = count(*) from #TOIs                
  End                
  --PRINT '@blockSize = ' + CONVERT(varchar(10),@blockSize)        
       
  --Add all TI required values here to #TOI    
   update tois     
   set     
   tois.risk_mkt_code = ti.risk_mkt_code,    
   tois.cmdty_code = ti.cmdty_code,    
   tois.trading_prd = ti.trading_prd,    
   tois.old_port_num = ti.real_port_num,    
   tois.prod_Type = ti.item_type,    
   tois.uom_conv_rate = ti.uom_conv_rate    
   from #TOIs tois, trade_item ti     
   where tois.trade_num = ti.trade_num and  tois.order_num = ti.order_num and tois.item_num = ti.item_num     
       
   --update values for inhouse_ind from trade table             
   update tois     
   set     
   tois.inhouse_ind = t.inhouse_ind FROM #TOIs tois,trade t WHERE t.trade_num = tois.trade_num             
       
   --UPDATE values for is_any_cost_vouchered from cost table    
   update tois     
   set     
   tois.is_any_cost_vouchered =     
   case when (exists(select 1 from cost c where c.cost_owner_key6=tois.trade_num and                     
             c.cost_owner_key7=tois.order_num and                     
             c.cost_owner_key8=tois.item_num and                     
             c.cost_status in ('VOUCHED', 'PAID') and                     
             c.cost_type_code not in ('RB','RC'))) then 1 else 0 end    
   from #TOIs  tois    
     
   --update values for acct_num from portfolio_tag table    
   update tois     
   set     
   tois.acct_num = convert(INT,p.tag_value) FROM #TOIs tois,portfolio_tag p WHERE p.port_num = tois.old_port_num  AND p.tag_name = 'BOOKCOMP'    
     
   --update values for temp_acct_num from portfolio_tag table    
   update tois     
   set     
   tois.temp_acct_num = convert(INT,p.tag_value) FROM #TOIs tois,portfolio_tag p WHERE p.port_num = tois.real_port_num  AND p.tag_name = 'BOOKCOMP'    
       
    --update values for can_trade_with_booking_comp from account_agreement table    
   update tois     
   set     
   tois.can_trade_with_booking_comp =     
    case when ( (tois.prod_Type is not NULL and  tois.inhouse_ind <> 'Y' and  tois.inhouse_ind <> 'I' and @use_account_areement_for_EB = 1)   
    --and  exists(select 1 from account_agreement a where a.product_type = tois.prod_Type and a.target_book_comp_num = tois.temp_acct_num)    
    )     
    then 1 else 0     
    end    
   from #TOIs  tois   
       
   --update values for acct_num conditionally    
   update tois     
   set                             
   tois.acct_num =    
   (case when (tois.temp_acct_num is not NULL and tois.temp_acct_num > 0 and  tois.is_any_cost_vouchered = 0 )   
    then (case when(exists(select 1 from account a where a.acct_type_code ='PEICOMP' and  a.acct_status = 'A' and a.acct_num = tois.temp_acct_num) and    
     (tois.prod_Type is NULL OR tois.can_trade_with_booking_comp = 1)    
    )    
   then tois.temp_acct_num    
   else NULL    
   end)   
 else tois.acct_num    
 end)   
    FROM #TOIs tois    
        
   --update values for #curr_commodity from commodity table    
   update tois     
   set     
   tois.prim_uom_code = c.prim_uom_code,    
   tois.sec_uom_code = c.sec_uom_code    
   FROM #TOIs tois,commodity c WHERE c.cmdty_code =tois.cmdty_code    
          
   --update values for target_key1ForMultiplierForBBL    
   update tois     
   set     
   tois.target_key1ForMultiplierForBBL = et.target_key1      
   FROM #TOIs tois, entity_tag_definition etd, entity_tag et     
   WHERE     
   tois.prim_uom_code is not NULL and tois.sec_uom_code is not NULL     
   and exists( SELECT 1 FROM constants WHERE attribute_name = 'UsePaperConvBBLtoMTForPosConv' and attribute_value = 'Y')     
   and tois.prod_Type = 'F'     
   and etd.oid = et.entity_tag_id and etd.entity_tag_name = 'MultiplierForBBL' AND et.key1 = tois.real_port_num       
       
   --update values for target_key1ForMultiplierForMT    
   update tois     
   set     
   tois.target_key1ForMultiplierForMT = et.target_key1      
   FROM #TOIs tois, entity_tag_definition etd, entity_tag et     
   WHERE     
   tois.prim_uom_code is not NULL and tois.sec_uom_code is not NULL     
   and exists( SELECT 1 FROM constants WHERE attribute_name = 'UsePaperConvBBLtoMTForPosConv' and attribute_value = 'Y')     
   and tois.prod_Type = 'F'     
   and etd.oid = et.entity_tag_id and etd.entity_tag_name = 'MultiplierForMT' AND et.key1 = tois.real_port_num       
      
   --update values for aMultiplier, reciprocal - case1    
   update tois     
   set     
   tois.aMultiplier = (case     
   when (tois.target_key1ForMultiplierForBBL is not NULL) then tois.target_key1ForMultiplierForBBL else tois.target_key1ForMultiplierForMT  end),    
   tois.reciprocal =  (case     
   when (tois.target_key1ForMultiplierForBBL is not NULL) then 0 else 1  end)    
   FROM #TOIs tois    
   where tois.prim_uom_code is not null and tois.sec_uom_code  is not null and tois.prim_uom_code = 'BBL' and tois.sec_uom_code = 'MT'    
   --update values for aMultiplier, reciprocal - case2    
   update tois     
   set     
   tois.aMultiplier = (case     
   when (tois.target_key1ForMultiplierForMT is not NULL) then tois.target_key1ForMultiplierForMT else tois.target_key1ForMultiplierForBBL  end),    
   tois.reciprocal =  (case     
   when (tois.target_key1ForMultiplierForMT is not NULL) then 0 else 1  end)    
   FROM #TOIs tois    
   where tois.prim_uom_code is not null and tois.sec_uom_code  is not null and tois.prim_uom_code = 'MT' and tois.sec_uom_code = 'BBL'    
          
   select @orig_commodity_primUOM = prim_uom_code,    
         @orig_commodity_secUOM = sec_uom_code    
     from commodity where cmdty_code = @orig_cmdty_code             
      
  SELECT @IsFX_Exposure_ON = attribute_value FROM constants WHERE attribute_name = 'FX_Exposure_ON'     
  if(@IsFX_Exposure_ON = 'Y')    
  begin    
  update tois     
  set tois.desired_pl_curr_code = p.desired_pl_curr_code     
  FROM #TOIs tois, portfolio p WHERE p.port_num = tois.real_port_num    
  end    
    
            
   --Set the next num sequence to block size so that trans_id's will be blocked till block size for this action. 
   create table #MaxTransId(max_trans_id bigint)
   
   insert into #MaxTransId               
   EXEC get_new_num trans_id, 0,@blockSize                
   
   select @maxTransID = max_trans_id from #MaxTransId
   drop table #MaxTransId                
   --PRINT '@maxTransID = ' + CONVERT(varchar(10),@maxTransID)                 
                  
   --Iterate thru all Trade items                 
   While(@index <= @blockSize)                
   BEGIN                
  --TI wise declarations                
   Begin                 
      declare @trade_num varchar(12)                
      declare @order_num varchar(12)                
      declare @item_num varchar(12)                
      declare @real_port_num varchar(12)                
      DECLARE  @port_type CHAR(2)                    
      DECLARE @AcctNum INT                    
      DECLARE @desired_pl_curr_code CHAR(8)                    
      DECLARE @reciprocal BIT                    
      DECLARE @target_key1ForMultiplierForBBL VARCHAR(16)                    
      DECLARE @target_key1ForMultiplierForMT VARCHAR(16)                    
      DECLARE @aMultiplier VARCHAR(20)                    
      DECLARE @factor DECIMAL(20,10)                    
      DECLARE @trans_id bigint                    
      DECLARE @curr_commodity_primUOM CHAR(4)                    
      DECLARE @curr_commodity_secUOM CHAR(4)                    
                   
      DECLARE @self_uom_Conv_rate DECIMAL(20,10)                    
      DECLARE @old_port_num INT                  
      DECLARE @updQuery VARCHAR(8000)                  
      DECLARE @updMainQuery VARCHAR(8000)                  
      declare @canUpdateUomConrate BIT                  
      Declare @parentTransIdValue bigint                
      --Declare @loginame varchar(200)                
      Declare @init varchar(200)                
      Declare @temp varchar(400)                
    end                
    --TI wise initializations                
   Begin                
       SET @desired_pl_curr_code = 'USD'                    
       SET @AcctNum = 0                    
       SET @reciprocal = 0                    
       SET @aMultiplier = NULL                    
       SET @factor = NULL                    
       SET @curr_commodity_primUOM = NULL                    
       SET @curr_commodity_secUOM = NULL                    
       SET @updQuery = 'UPDATE ti SET '                  
       SET @self_uom_Conv_rate = NULL                  
       set @canUpdateUomConrate = 0                  
       set @parentTransIdValue = 0                
       --set @loginame = NULL                
       set @init = null                
       SET @temp = null                
       SET @risk_mkt_code = null              
       SET @cmdty_code = null                
       SET @trading_prd = null;      
    end                
                   
  --Process here to build dynamic update query on TI, TID  etc.  
  BEGIN                  
    set @count = @count + 1                
    set @newTransId = @maxTransID - @blockSize + @count;                
    --PRINT '@newTransId = ' + CONVERT(varchar(10),@newTransId)                 
    SET @updQuery = @updQuery + ' ti.real_port_num = t.real_port_num, '                    
    SET @updQuery = @updQuery + ' ti.booking_comp_num = t.AcctNum, '                  
    select  @aMultiplier = aMultiplier,@reciprocal = reciprocal  from #TOIs where Id = @index     
    ----PRINT '@aMultiplier = ' + CONVERT(varchar(20),@aMultiplier)       
    IF(@aMultiplier IS NOT NULL)                    
    BEGIN     
     SET @factor = cast(@aMultiplier as decimal(20,10))                     
     IF(@reciprocal =1 AND @factor > 0)                    
      SET @factor = 1/@factor                    
    END                    
    ----PRINT '@factor = ' + @factor                    
                     
    SET @canUpdateUomConrate   = 0                  
    IF(@factor IS NOT NULL AND @factor > 0)                    
    BEGIN                  
     set @self_uom_Conv_rate = @factor                  
     set @canUpdateUomConrate = 1                  
     --PRINT 'Appended query for updating uom_conv_rate = ' + CONVERT(varchar(100),@factor)                    
    END                    
    ELSE                     
    BEGIN      
     SELECT @self_uom_Conv_rate = uom_conv_rate FROM #TOIs where Id = @index     
     IF(@self_uom_Conv_rate IS NOT NULL)                    
     BEGIN                   
      set @canUpdateUomConrate = 1                   
      SELECT @curr_commodity_primUOM = prim_uom_code,@curr_commodity_secUOM =sec_uom_code  FROM #TOIs where Id = @index                     
      IF((@curr_commodity_primUOM <> @orig_commodity_primUOM) OR (@curr_commodity_secUOM <> @orig_commodity_secUOM))                    
      BEGIN                    
        IF(@self_uom_Conv_rate > 0 AND @curr_commodity_primUOM = @orig_commodity_secUOM AND @curr_commodity_secUOM=@orig_commodity_primUOM)                    
         SET @self_uom_Conv_rate = 1/@self_uom_Conv_rate                    
        ELSE                    
        BEGIN                    
         SET @self_uom_Conv_rate = NULL                    
         --PRINT 'updated uom_Conv_rate is NULL'                    
        END                    
        --PRINT 'Appended query for updating uom_Conv_rate of trade item '                    
      END                    
     END                    
    END                    
    if(@canUpdateUomConrate = 1)                  
    begin                  
     SET @updQuery = @updQuery + ' uom_conv_rate = t.self_uom_Conv_rate, '                   
     set @canUpdateUomConrate = 0                  
    end                   
    
    IF(@IsFX_Exposure_ON = 'Y')                    
    BEGIN                    
     SET @updQuery = @updQuery + ' hedge_curr_code = t.desired_pl_curr_code, '                    
     --PRINT 'Appended query for updating hedge_curr_code = ' + @desired_pl_curr_code                    
    END                    
                               
    --Add values used to build dynamic query to temp table here.                 
    Begin             
     IF OBJECT_ID('tempdb..#myTemp') IS NOT NULL            
     BEGIN            
       DROP TABLE #myTemp            
     END                 
     create table  #myTemp                   
     (                  
      real_port_num INT,                  
      AcctNum INT,                  
      self_uom_Conv_rate DECIMAL(20,10) ,                  
      desired_pl_curr_code CHAR(8) ,                  
      trans_id bigint,                
       trade_num int,                    
       order_num  int,                    
       item_num  INT,                
       old_port_num INT  ,                
       parentTransIdValue bigint,                
       ttype varchar(2),                
       user_init varchar(200),                
       app_name varchar(200),                
       inhouse_ind varchar(1),                
       attr_name varchar(100),                
       last_num int                
     )        
     INSERT INTO #myTemp(real_port_num ,AcctNum ,self_uom_Conv_rate ,desired_pl_curr_code,trans_id,trade_num,order_num, item_num,old_port_num)                
     SELECT real_port_num,acct_num,@self_uom_Conv_rate,desired_pl_curr_code,@newTransId,trade_num,order_num,item_num,old_port_num    
     FROM #TOIs where Id = @index      
         
                    
    end                
                      
    --PRINT '#myTemp table created and populated'                
    SET @updQuery = @updQuery + ' ti.trans_id = t.trans_id from trade_item ti, #myTemp t WHERE ti.trade_num = t.trade_num AND ti.order_num = t.order_num AND ti.item_num = t.item_num '                  
   ---------------------------------------------Update Trade Item distributions here                  
   Begin                
     update #myTemp set inhouse_ind = 'Y'                 
     SET @updQuery = @updQuery +  CHAR(13) +                 
      'UPDATE tid SET tid.real_port_num = t.real_port_num, tid.trans_id = t.trans_id           
       from trade_item_dist tid, #myTemp t           
       WHERE tid.trade_num = t.trade_num AND tid.order_num = t.order_num AND tid.item_num = t.item_num           
       AND NOT EXISTS (SELECT 1 FROM trade tr where tr.trade_num = tid.trade_num and tr.inhouse_ind = t.inhouse_ind AND tr.port_num = tid.real_port_num) '          
                      
     SET @updQuery = @updQuery +  CHAR(13) +               
     'UPDATE tid           
      SET tid.real_port_num = t.real_port_num, tid.trans_id = t.trans_id           
      FROM trade_item_dist tid, #myTemp t           
      WHERE tid.trade_num = t.trade_num AND tid.order_num = t.order_num AND tid.item_num = t.item_num           
      AND EXISTS (SELECT 1 FROM trade tr where tr.trade_num = tid.trade_num and tr.inhouse_ind = t.inhouse_ind AND tid.real_port_num = t.old_port_num) '                  
     --PRINT 'trade_item_dist is added to update with portfolio '                  
   end                
   ----------------------------------------Update positions here----------------------------------                
   --Begin                
   -- SET @updQuery = @updQuery +  CHAR(13) +                 
   -- 'update p           
   --  set p.trans_id = t.trans_id           
   --  from position p, #myTemp t           
   --  where p.pos_num in ( select pos_num from trade_item_dist where trade_num = t.trade_num AND order_num = t.order_num AND item_num = t.item_num and trans_id < t.trans_id) '                
   -- end                
   ----------------------------------------Insert a record into ti_field_modified table as portfolio is updated-------------------------------                
   Begin                
    exec get_new_num ti_field_mod_oid,0                
    update #myTemp set attr_name = 'realPortfolio' , last_num = (select last_num from dbo.new_num where num_col_name = 'ti_field_mod_oid')                
                            
    SET @updQuery = @updQuery +  CHAR(13) +                 
    ' insert into ti_field_modified (trans_id, trade_num, order_num, item_num, oid, attr_name)           
     select trans_id, trade_num, order_num, item_num, last_num, attr_name from #myTemp '          
   end                
   ----------------------------------------Save the transaction id for sequence table to commit.--------------------                
           
   select @risk_mkt_code = risk_mkt_code, @cmdty_code = cmdty_code, @trading_prd = trading_prd, @real_port_num = real_port_num from #TOIs where Id = @index    
   set @updMainQuery = ''                
   begin                
    if(@risk_mkt_code is NULL)              
     set @risk_mkt_code = '0'              
  if(@cmdty_code is NULL)              
     set @cmdty_code = '0'              
    if(@trading_prd is NULL)              
     set @trading_prd = '0'              
                          
    set @temp = @real_port_num + '/' +  ltrim(rtrim(@risk_mkt_code)) + '/' + ltrim(rtrim(@cmdty_code)) + '/' + ltrim(rtrim(@trading_prd))                
    --PRINT ' @temp = ' +  @temp                
    SET @updMainQuery = @updMainQuery +  CHAR(13) + 'begin tran'                  
    if((select 1 from #parentTransIDs where key1 like @temp) = 1)                
    begin                
      select @parentTransIdValue = value from #parentTransIDs where key1 like @temp                 
      update #myTemp set parentTransIdValue = @parentTransIdValue                
      SET @updMainQuery = @updMainQuery +  CHAR(13) +                
      'insert into icts_transaction (parent_trans_id,trans_id,type,user_init,tran_date,app_name, workstation_id)' +                
      'select parentTransIdValue,'                
      update #parentTransIDs set value = @newTransId where key1 = @temp                 
    end                
    else                
    begin                
     SET @updMainQuery = @updMainQuery +  CHAR(13) +                
      'insert into icts_transaction (trans_id,type,user_init,tran_date,app_name, workstation_id) '  +    
      'select  '               
      Insert into #parentTransIDs values(@temp,@newTransId )                
      update #myTemp set parentTransIdValue = @newTransId                
    end                
    ------------------get the user details                
    select @init = null
    
    if @login_name is not null                           
		select @init = user_init from dbo.icts_user where user_logon_id = @login_name
    else
      begin		    
        select @login_name = loginame from master.dbo.sysprocesses with (nolock) where spid = @@spid                  
        select @init = user_init from dbo.icts_user where user_logon_id = @login_name
      end 

    if @init is null  
		select @init = @login_name                
                     
    update #myTemp set ttype = 'U', user_init = @init,app_name = @app_name                
    SET @updMainQuery = @updMainQuery +  CHAR(13) +                 
    ' trans_id, ttype, user_init, getdate(), app_name,NULL from #myTemp '                
                      
    SET @updMainQuery = @updMainQuery +  CHAR(13) + @updQuery                
    SET @updMainQuery = @updMainQuery +  CHAR(13) + 'commit tran'                
    --PRINT 'Final Query for this trade item is ' + @updMainQuery                
   end                
                      
   EXEC (@updMainQuery)                  
   --PRINT '*************************UPDATED*************************************************'                  
   drop table #myTemp                  
     END --end of IF (@port_type IS NOT NULL AND @port_type = 'R')                   
  set @index = @index + 1                
   END--While end                
   --PRINT '[usp_bulk_portfolio_Update_forTOI] ended'                 
 drop table #parentTransIDs               
 drop table #TOIs       
  endofsp:                  
END    
GO
GRANT EXECUTE ON  [dbo].[usp_bulk_portfolio_Update_forTOI] TO [next_usr]
GO
