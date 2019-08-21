SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_new_voyage_num]
(
   @alloc_type  varchar(1) = null,
   @cmdty_code  varchar(8) = null,
   @year        varchar(4) = null
)
as
set nocount on
set xact_abort on            
declare @rowcount    int,
        @next_num    int,
        @trans_id    bigint,
        @gdv_num     int,
        @gdd_num     int,
        @retval      int,
        @loginame    sysname,
        @init        char(3),
        @proc_name   char(16)

    create table #temp_table 
    (
       gdv_num     int           NOT NULL,
       attr1_name  varchar(255)  NOT NULL,
       attr2_name  varchar(255)  NOT NULL,
       attr3_name  varchar(255)  NOT NULL
     )

    /* default retval is no-op */
    select @retval = 1

    insert #temp_table (gdv_num, attr1_name, attr2_name, attr3_name)
    select gdv1.gdv_num, gdv1.string_value, gdv2.string_value, gdv3.string_value
    from dbo.generic_data_values gdv1, 
         dbo.generic_data_values gdv2, 
         dbo.generic_data_values gdv3, 
         dbo.generic_data_definition gdd1, 
         dbo.generic_data_definition gdd2, 
         dbo.generic_data_definition gdd3, 
         dbo.generic_data_name gdn
    where gdd1.gdd_num = gdv1.gdd_num and
          gdd2.gdd_num = gdv2.gdd_num and
          gdd3.gdd_num = gdv3.gdd_num and
          gdv1.gdv_num = gdv2.gdv_num and
          gdv2.gdv_num = gdv3.gdv_num and
          gdd1.gdn_num = gdn.gdn_num and
          gdd2.gdn_num = gdn.gdn_num and
          gdd3.gdn_num = gdn.gdn_num and
          gdd1.attr_name = 'cmdty_group' and
          gdd2.attr_name = 'year' and
          gdd3.attr_name = 'alloc_type' and
          gdn.data_name = 'voyage'

    select @gdv_num = gdv_num 
    from #temp_table 
    where attr1_name = @cmdty_code and 
          attr2_name = @year and 
          attr3_name = @alloc_type
    select @rowcount = @@rowcount
    if (@rowcount = 1)
    begin
       select @gdd_num = gdd.gdd_num 
       from dbo.generic_data_definition gdd, 
            dbo.generic_data_name gdn 
       where gdd.gdn_num = gdn.gdn_num and 
             gdn.data_name = 'voyage' and 
             gdd.attr_name = 'new_num'

       BEGIN TRANSACTION
       select @init = null
       select @loginame = loginame,
              @proc_name = program_name 
       from master..sysprocesses 
       where spid = @@spid

       select @init = user_init 
       from dbo.icts_user 
       where user_logon_id = @loginame
 
       if @init is null  select @init = @loginame
  
       update dbo.icts_trans_sequence
       set last_num = last_num + 1
       where oid = 1
       select @rowcount = @@rowcount
       if (@rowcount = 1)
       begin
          select @trans_id = last_num
          from dbo.icts_trans_sequence
          where oid = 1

          insert into dbo.icts_transaction
               (trans_id, type, user_init, tran_date,
                app_name, app_revision, spid, workstation_id)
            values (@trans_id, 'U', @init, getdate(), @proc_name, NULL, @@spid, NULL)
          select @rowcount = @@rowcount
          if (@rowcount = 1)
          begin
             update dbo.generic_data_values
             set int_value = int_value + 1,
                 trans_id = @trans_id
             where gdv_num = @gdv_num and 
                   gdd_num = @gdd_num
             select @rowcount = @@rowcount
             if (@rowcount = 1)
             begin
                select @next_num = int_value
                from dbo.generic_data_values
                where gdv_num = @gdv_num and 
                      gdd_num = @gdd_num

                select @next_num
                COMMIT TRANSACTION

                select @retval = 0
             end
             else
             begin
                ROLLBACK TRANSACTION
                select @retval = -1
             end
          end
          else
          begin
             ROLLBACK TRANSACTION
             select @retval = -1
          end
       end
       else
       begin
          ROLLBACK TRANSACTION
          select @retval = -1
       end
    end
    drop table #temp_table
    return @retval
GO
GRANT EXECUTE ON  [dbo].[get_new_voyage_num] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[get_new_voyage_num] TO [next_usr]
GO
