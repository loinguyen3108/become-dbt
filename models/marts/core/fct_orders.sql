with customers as (

    select * from {{ ref('stg_jaffle_shop__customers')}}

),

orders as (

    select * from {{ ref('stg_jaffle_shop__orders') }}

),

payments as (

    select * from {{ ref('stg_stripe__payments') }}

),

order_payments as (
    select
        order_id,
        sum(case when payment_status = 'success' then payment_amount end) as amount

    from payments
    group by 1
),

final as (

    select
        customer_id,
        order_id,
        amount
    from orders
    left join order_payments using (order_id)

)

select * from final