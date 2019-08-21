SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[update_account_exposure] 
(
   @acct_num int,
   @trans_id bigint
)
as
begin
declare @now datetime
declare @a_number1 float
declare @a_number2 float

declare @acct_exp_pay_amt float
declare @acct_exp_recv_amt float
declare @acct_exp_profit_amt float
declare @acct_exp_loss_amt float
declare @acct_exp_gross_amt float
declare @acct_flw_pay_amt float
declare @acct_flw_rec_amt float
declare @acct_exp_profit_qty float
declare @acct_exp_loss_qty float

declare @acct_rexp_pay_amt float
declare @acct_rexp_recv_amt float
declare @acct_rexp_profit_amt float
declare @acct_rexp_loss_amt float
declare @acct_rexp_gross_amt float
declare @acct_rflw_pay_amt float
declare @acct_rflw_rec_amt float
declare @acct_rexp_profit_qty float
declare @acct_rexp_loss_qty float

declare @acct_sexp_pay_amt float
declare @acct_sexp_recv_amt float
declare @acct_sexp_profit_amt float
declare @acct_sexp_loss_amt float
declare @acct_sexp_gross_amt float
declare @acct_sflw_pay_amt float
declare @acct_sflw_rec_amt float
declare @acct_sexp_profit_qty float
declare @acct_sexp_loss_qty float

select @now = getdate()

/* remember all exposure numbers for the account */
create table #exposure_nums (
    exposure_num    int, 
    exp_secur_ind   char(1), 
    exp_pastdue_ind char(1) NULL)

/* get all of today's exposures for account */
insert #exposure_nums 
select distinct exposure_num, exp_secur_ind ,exp_pastdue_ind
from exposure 
where exp_acct_num = @acct_num
 
/*******************  cash exposure **********************/

create table #amount_sums (
    rec_amt float, 
    pay_amt float)

/*********  non-reserved non-secured *********/
truncate table #amount_sums

insert #amount_sums
select isnull(sum(cash_exp_rec_amt),0),
       isnull(sum(cash_exp_pay_amt),0)
from cash_exposure c
where exposure_num in (select exposure_num 
                       from #exposure_nums 
                       where exp_secur_ind != 'R'
                             and exp_secur_ind != 'S'
			     and exp_pastdue_ind = 'N')
      and cash_is_due_code = 'N'
      and convert(varchar(10),cash_exp_date,112) >= convert(varchar(10),@now,112)
group by convert(char(10),cash_exp_date,112)

select @acct_exp_recv_amt = max(rec_amt) from #amount_sums
select @acct_exp_pay_amt = max(pay_amt) from #amount_sums

truncate table #amount_sums

insert #amount_sums
select isnull(sum(cash_exp_rec_amt),0),
       isnull(sum(cash_exp_pay_amt),0)
from cash_exposure c
where exposure_num in (select exposure_num 
                       from #exposure_nums 
                       where exp_secur_ind != 'R'
                             and exp_secur_ind != 'S'
			     and exp_pastdue_ind = 'Y')
       and cash_is_due_code = 'Y'
       and convert(varchar(10),cash_exp_date,112) < convert(varchar(10),@now,112)

declare @tmp float

select @tmp =  sum(rec_amt) from #amount_sums
select @acct_exp_recv_amt =  isnull(@tmp,0) + isnull(@acct_exp_recv_amt,0)

select @tmp =  sum(pay_amt) from #amount_sums
select @acct_exp_pay_amt = isnull(@tmp,0) + isnull(@acct_exp_pay_amt,0)

/*********  reserved *********/
truncate table #amount_sums

insert #amount_sums
select isnull(sum(cash_exp_rec_amt),0),
       isnull(sum(cash_exp_pay_amt),0)
from cash_exposure c
where exposure_num in (select exposure_num 
                       from #exposure_nums 
                       where exp_secur_ind = 'R')
      and cash_is_due_code = 'N'
      and convert(varchar(10),cash_exp_date,112) >= convert(varchar(10),@now,112)
group by convert(char(10),cash_exp_date,112)

insert #amount_sums
select isnull(sum(cash_exp_rec_amt),0),
       isnull(sum(cash_exp_pay_amt),0)
from cash_exposure c
where exposure_num in (select exposure_num 
                       from #exposure_nums 
                       where exp_secur_ind = 'R')
      and cash_is_due_code = 'Y'
      and convert(varchar(10),cash_exp_date,112) < convert(varchar(10),@now,112)

select @acct_rexp_recv_amt = max(rec_amt) from #amount_sums
select @acct_rexp_pay_amt = max(pay_amt) from #amount_sums

/*********  secured *********/
truncate table #amount_sums

insert #amount_sums
select isnull(sum(cash_exp_rec_amt),0),
       isnull(sum(cash_exp_pay_amt),0)
from cash_exposure c
where exposure_num in (select exposure_num from #exposure_nums where exp_secur_ind = 'S')
      and cash_is_due_code = 'N'
      and convert(varchar(10),cash_exp_date,112) >= convert(varchar(10),@now,112)
group by convert(char(10),cash_exp_date,112)

insert #amount_sums
select isnull(sum(cash_exp_rec_amt),0),
       isnull(sum(cash_exp_pay_amt),0)
from cash_exposure c
where exposure_num in (select exposure_num 
                       from #exposure_nums 
                       where exp_secur_ind = 'S')
      and cash_is_due_code = 'Y'
      and convert(varchar(10),cash_exp_date,112) < convert(varchar(10),@now,112)

select @acct_sexp_recv_amt = max(rec_amt) from #amount_sums
select @acct_sexp_pay_amt = max(pay_amt) from #amount_sums

/*******************  cash flow **********************/

/*********  non-reserved non-secured *********/
truncate table #amount_sums

insert #amount_sums
select isnull(sum(cash_exp_rec_amt),0),
       isnull(sum(cash_exp_pay_amt),0)
from cash_exposure c
where exposure_num in (select exposure_num 
                       from #exposure_nums 
                       where exp_secur_ind != 'R'
                             and exp_secur_ind != 'S')
      and cash_is_due_code = 'Y'
group by convert(char(10),cash_exp_date,112)

select @acct_flw_rec_amt = sum(rec_amt) from #amount_sums
select @acct_flw_pay_amt = sum(pay_amt) from #amount_sums

/*********  reserved *********/
truncate table #amount_sums

insert #amount_sums
select isnull(sum(cash_exp_rec_amt),0),
       isnull(sum(cash_exp_pay_amt),0)
from cash_exposure c
where exposure_num in (select exposure_num 
                       from #exposure_nums 
                       where exp_secur_ind= 'R')
      and cash_is_due_code = 'Y'
group by convert(char(10),cash_exp_date,112)

 
select @acct_rflw_rec_amt = sum(rec_amt) from #amount_sums
select @acct_rflw_pay_amt = sum(pay_amt) from #amount_sums

/*********  secured *********/
truncate table #amount_sums

insert #amount_sums
select isnull(sum(cash_exp_rec_amt),0),
       isnull(sum(cash_exp_pay_amt),0)
from cash_exposure c
where exposure_num in (select exposure_num 
                       from #exposure_nums 
                       where exp_secur_ind = 'S')
      and cash_is_due_code = 'Y'
group by convert(char(10),cash_exp_date,112)

select @acct_sflw_rec_amt = sum(rec_amt) from #amount_sums
select @acct_sflw_pay_amt = sum(pay_amt) from #amount_sums

/*******************  profit/loss amounts **********************/

/*********  non-reserved non-secured *********/
/*** Profit ***/
select @acct_exp_profit_amt = sum(mtm_exp_profit_amt)
from mtm_exposure
where exposure_num in (select exposure_num 
                       from #exposure_nums 
                       where exp_secur_ind != 'R'
                             and exp_secur_ind != 'S')

/*** Loss ***/
select @acct_exp_loss_amt = sum(mtm_exp_loss_amt) 
from mtm_exposure
where exposure_num in (select exposure_num 
                       from #exposure_nums 
                       where exp_secur_ind != 'R'
                             and exp_secur_ind != 'S')

select @acct_exp_gross_amt = @acct_exp_profit_amt - @acct_exp_loss_amt

/*********  reserved *********/
/*** Profit ***/
select @acct_rexp_profit_amt = sum(mtm_exp_profit_amt)
from mtm_exposure
where exposure_num in (select exposure_num 
                       from #exposure_nums 
                       where exp_secur_ind = 'R')

/*** Loss ***/
select @acct_rexp_loss_amt = sum(mtm_exp_loss_amt)
from mtm_exposure
where exposure_num in (select exposure_num 
                       from #exposure_nums 
                       where exp_secur_ind = 'R')

select @acct_rexp_gross_amt = @acct_rexp_profit_amt - @acct_rexp_loss_amt

/*********  secured *********/
/*** Profit ***/
select @acct_sexp_profit_amt = sum(mtm_exp_profit_amt)
from mtm_exposure
where exposure_num in (select exposure_num 
                       from #exposure_nums 
                       where exp_secur_ind = 'S')

/*** Loss ***/
select @acct_sexp_loss_amt = sum(mtm_exp_loss_amt)
from mtm_exposure
where exposure_num in (select exposure_num 
                       from #exposure_nums 
                       where exp_secur_ind = 'S')

select @acct_sexp_gross_amt = @acct_sexp_profit_amt - @acct_sexp_loss_amt

/*******************  profit/loss qty **********************/

/*********  non-reserved non-secured *********/
/*** Profit ***/
select @acct_exp_profit_qty = sum(mtm_exp_profit_qty)
from mtm_exposure
where exposure_num in (select exposure_num 
                       from #exposure_nums 
                       where exp_secur_ind != 'R'
                             and exp_secur_ind != 'S')

/*** Loss ***/
select @acct_exp_loss_qty = sum(mtm_exp_loss_qty)
from mtm_exposure
where exposure_num in (select exposure_num 
                       from #exposure_nums 
                       where exp_secur_ind != 'R'
                             and exp_secur_ind != 'S')

/*********  reserved *********/
/*** Profit ***/
select @acct_rexp_profit_qty = sum(mtm_exp_profit_qty)
from mtm_exposure
where exposure_num in (select exposure_num 
                       from #exposure_nums 
                        where exp_secur_ind = 'R')

/*** Loss ***/
select @acct_rexp_loss_qty = sum(mtm_exp_loss_qty)
from mtm_exposure
where exposure_num in (select exposure_num 
                       from #exposure_nums 
                       where exp_secur_ind = 'R')

/*********  secured *********/
/*** Profit ***/
select @acct_sexp_profit_qty = sum(mtm_exp_profit_qty)
from mtm_exposure
where exposure_num in (select exposure_num 
                       from #exposure_nums 
                       where exp_secur_ind = 'S')

/*** Loss ***/
select @acct_sexp_loss_qty = sum(mtm_exp_loss_qty)
from mtm_exposure
where exposure_num in (select exposure_num 
                       from #exposure_nums 
                       where exp_secur_ind = 'S')

drop table #amount_sums
drop table #exposure_nums

/* Create account_exposure if none exists */
if not exists (select acct_num 
               from account_exposure 
               where acct_num = @acct_num)
begin
   insert account_exposure (acct_num, trans_id)
   select @acct_num, 1
end

update account_exposure 
set acct_exp_pay_amt = @acct_exp_pay_amt,
    acct_exp_recv_amt = @acct_exp_recv_amt,
    acct_exp_profit_amt = @acct_exp_profit_amt,
    acct_exp_loss_amt = @acct_exp_loss_amt,
    acct_exp_gross_amt = @acct_exp_gross_amt,
    acct_flw_pay_amt = @acct_flw_pay_amt,
    acct_flw_rec_amt = @acct_flw_rec_amt,
    acct_exp_profit_qty = @acct_exp_profit_qty,
    acct_exp_loss_qty = @acct_exp_loss_qty,
    acct_rexp_pay_amt = @acct_rexp_pay_amt,
    acct_rexp_recv_amt = @acct_rexp_recv_amt,
    acct_rexp_profit_amt = @acct_rexp_profit_amt,
    acct_rexp_loss_amt = @acct_rexp_loss_amt,
    acct_rexp_gross_amt = @acct_rexp_gross_amt,
    acct_rflw_pay_amt = @acct_rflw_pay_amt,
    acct_rflw_rec_amt = @acct_rflw_rec_amt,
    acct_rexp_profit_qty = @acct_rexp_profit_qty,
    acct_rexp_loss_qty = @acct_rexp_loss_qty,
    acct_sexp_pay_amt = @acct_sexp_pay_amt,
    acct_sexp_recv_amt = @acct_sexp_recv_amt,
    acct_sexp_profit_amt = @acct_sexp_profit_amt,
    acct_sexp_loss_amt = @acct_sexp_loss_amt,
    acct_sexp_gross_amt = @acct_sexp_gross_amt,
    acct_sflw_pay_amt = @acct_sflw_pay_amt,
    acct_sflw_rec_amt = @acct_sflw_rec_amt,
    acct_sexp_profit_qty = @acct_sexp_profit_qty,
    acct_sexp_loss_qty = @acct_sexp_loss_qty,
    trans_id = @trans_id
where acct_num = @acct_num
end
GO
GRANT EXECUTE ON  [dbo].[update_account_exposure] TO [next_usr]
GO
