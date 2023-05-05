with customers as (

    select * from {{ ref('stg_jaffle_shop__customers')}}

),

orders as (

    select * from {{ ref('stg_jaffle_shop__orders') }}

),

payments as (

    select * from {{ ref('stg_stripe__payments') }}

),

employees as (
    select * from {{ ref('employees') }}
),

customer_orders as (

    select
        customer_id,
        employee_id is not null as is_employee,
        min(order_placed_at) as first_order_date,
        max(order_placed_at) as most_recent_order_date,
        count(order_id) as number_of_orders,
        sum(payment_amount) as lifetime_value
    from orders
    left join payments using (order_id)
    left join employees using (customer_id)
    group by customer_id, employee_id

),

final as (
    select
        customers.customer_id,
        customers.customer_first_name,
        customers.customer_last_name,
        customer_orders.first_order_date,
        customer_orders.most_recent_order_date,
        coalesce(customer_orders.number_of_orders, 0) as number_of_orders,
        customer_orders.lifetime_value
    from customers
    left join customer_orders using (customer_id)
)

select * from final