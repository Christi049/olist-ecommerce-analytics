import os
import streamlit as st
import pandas as pd
import plotly.express as px
from sqlalchemy import create_engine
from urllib.parse import quote_plus
from dotenv import load_dotenv

st.set_page_config(page_title="Olist E-Commerce Analytics", layout="wide")

# =========================================================
# STYLING — compact layout, dark sidebar, plain-text nav,
# white collapse-arrow icon
# =========================================================
st.markdown("""
    <style>
    /* Compact overall page padding */
    .block-container {
        padding-top: 1.5rem;
        padding-bottom: 1rem;
        padding-left: 2rem;
        padding-right: 2rem;
    }

    /* Compact KPI metrics */
    [data-testid="stMetricValue"] {
        font-size: 1.3rem;
    }
    [data-testid="stMetricLabel"] {
        font-size: 0.72rem;
    }

    /* Compact headings */
    h1 {
        font-size: 1.7rem;
        margin-bottom: 0.4rem;
    }
    h2 {
        font-size: 1.3rem;
        margin-bottom: 0.3rem;
    }
    h3 {
        font-size: 1.05rem;
        margin-top: 0.2rem;
        margin-bottom: 0.2rem;
    }

    /* Sidebar background */
    section[data-testid="stSidebar"] {
        background-color: #1E1E2F;
    }
    section[data-testid="stSidebar"] h2 {
        color: #FFFFFF;
        font-weight: 600;
    }

    /* Plain-text nav buttons */
    section[data-testid="stSidebar"] .stButton button {
        background-color: transparent;
        border: none;
        color: #FFFFFF;
        font-size: 15px;
        text-align: left;
        width: 100%;
        padding: 6px 4px;
        box-shadow: none;
        transition: font-size 0.15s ease;
    }
    section[data-testid="stSidebar"] .stButton button:hover {
        background-color: transparent;
        color: #FFFFFF;
        font-size: 17px;
        text-decoration: underline;
        text-underline-offset: 4px;
    }
    section[data-testid="stSidebar"] .stButton button:focus {
        background-color: transparent;
        box-shadow: none;
        outline: none;
    }
    section[data-testid="stSidebar"] .stButton button:active {
        background-color: transparent;
        color: #FFFFFF;
    }
    
    /* Sidebar collapse arrow — nuclear option: target every possible layer */
    [data-testid="stSidebarCollapseButton"],
    [data-testid="stSidebarCollapseButton"] *,
    [data-testid="collapsedControl"],
    [data-testid="collapsedControl"] *,
    header[data-testid="stHeader"] button svg,
    header[data-testid="stHeader"] button svg path {
        fill: #FFFFFF !important;
        stroke: #FFFFFF !important;
        color: #FFFFFF !important;
        background-color: transparent !important;
    }
    /* Keep the collapse button visible always, not just on hover */
    [data-testid="stSidebarCollapseButton"],
    [data-testid="collapsedControl"],
    header[data-testid="stHeader"] button {
        opacity: 1 !important;
        visibility: visible !important;
    }

    /* Tighten default vertical gaps between Streamlit blocks */
    div[data-testid="stVerticalBlock"] > div {
        gap: 0.4rem;
    }
    </style>
""", unsafe_allow_html=True)

# =========================================================
# DB CONNECTION
# =========================================================
load_dotenv()

password = quote_plus(os.getenv("DB_PASSWORD"))
user = os.getenv("DB_USER", "root")
host = os.getenv("DB_HOST", "localhost")
db = os.getenv("DB_NAME", "olist_analytics")

engine = create_engine(f"mysql+mysqlconnector://{user}:{password}@{host}/{db}")

@st.cache_data
def run_query(query):
    return pd.read_sql(query, engine)

# Shared compact chart layout applied to every figure
def compact(fig, height=210):
    fig.update_layout(
        height=height,
        margin=dict(l=10, r=10, t=25, b=10),
        font=dict(size=11),
    )
    return fig

# =========================================================
# SIDEBAR NAVIGATION
# =========================================================
st.sidebar.markdown("## Olist Analytics")
st.sidebar.markdown("---")

if "page" not in st.session_state:
    st.session_state.page = "Executive Overview"

nav_options = ["Executive Overview", "Sales & Products", "Customer Analytics", "Operations & Experience"]

for option in nav_options:
    if st.sidebar.button(option, key=f"nav_{option}"):
        st.session_state.page = option

page = st.session_state.page

# =========================================================
# PAGE 1 — EXECUTIVE OVERVIEW
# =========================================================
if page == "Executive Overview":
    st.title("Executive Overview")

    kpi_query = """
    SELECT
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(SUM(oit.order_total_value), 2) AS total_revenue,
        ROUND(AVG(oit.order_total_value), 2) AS avg_order_value,
        (SELECT ROUND(AVG(review_score), 2) FROM order_reviews) AS avg_rating,
        (SELECT ROUND(100.0 * SUM(CASE WHEN delivery_delay_days <= 0 THEN 1 ELSE 0 END) / COUNT(*), 2)
         FROM orders WHERE is_delivered = 1) AS pct_on_time
    FROM orders o
    JOIN order_item_totals oit ON o.order_id = oit.order_id
    WHERE o.is_delivered = 1
    """
    kpis = run_query(kpi_query).iloc[0]

    col1, col2, col3, col4, col5 = st.columns(5)
    col1.metric("Total Revenue", f"R$ {kpis['total_revenue']:,.0f}")
    col2.metric("Total Orders", f"{kpis['total_orders']:,}")
    col3.metric("Avg Order Value", f"R$ {kpis['avg_order_value']:.2f}")
    col4.metric("Avg Rating", f"{kpis['avg_rating']:.2f} / 5")
    col5.metric("On-Time Delivery", f"{kpis['pct_on_time']:.1f}%")

    st.markdown("##### Revenue Trend")
    trend_query = """
    SELECT o.order_year_month, ROUND(SUM(oit.order_total_value),2) AS revenue
    FROM orders o
    JOIN order_item_totals oit ON o.order_id = oit.order_id
    WHERE o.is_delivered = 1
    GROUP BY o.order_year_month
    ORDER BY o.order_year_month
    """
    trend = run_query(trend_query)
    fig = px.line(trend, x="order_year_month", y="revenue", markers=True)
    st.plotly_chart(compact(fig, 200), use_container_width=True)

    col_a, col_b = st.columns(2)
    with col_a:
        st.markdown("##### Revenue by State")
        state_query = """
        SELECT c.customer_state, ROUND(SUM(oit.order_total_value),2) AS revenue
        FROM orders o
        JOIN customers c ON o.customer_id = c.customer_id
        JOIN order_item_totals oit ON o.order_id = oit.order_id
        WHERE o.is_delivered = 1
        GROUP BY c.customer_state
        ORDER BY revenue DESC
        LIMIT 10
        """
        state_df = run_query(state_query)
        fig2 = px.bar(state_df, x="customer_state", y="revenue")
        st.plotly_chart(compact(fig2, 190), use_container_width=True)

    with col_b:
        st.markdown("##### Top Categories by Revenue")
        cat_query = """
        SELECT p.product_category_name_english AS category, ROUND(SUM(oi.price),2) AS revenue
        FROM order_items oi
        JOIN products p ON oi.product_id = p.product_id
        JOIN orders o ON oi.order_id = o.order_id
        WHERE o.is_delivered = 1
        GROUP BY category
        ORDER BY revenue DESC
        LIMIT 10
        """
        cat_df = run_query(cat_query)
        fig3 = px.bar(cat_df, x="revenue", y="category", orientation="h")
        st.plotly_chart(compact(fig3, 190), use_container_width=True)

# =========================================================
# PAGE 2 — SALES & PRODUCTS
# =========================================================
elif page == "Sales & Products":
    st.title("Sales & Product Performance")

    cat_growth_query = """
    SELECT
        p.product_category_name_english AS category,
        SUM(CASE WHEN o.order_year = 2017 THEN oi.price ELSE 0 END) AS revenue_2017,
        SUM(CASE WHEN o.order_year = 2018 THEN oi.price ELSE 0 END) AS revenue_2018
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.is_delivered = 1 AND o.order_year IN (2017, 2018)
    GROUP BY category
    HAVING revenue_2017 > 1000
    ORDER BY (revenue_2018 - revenue_2017) DESC
    LIMIT 15
    """
    growth_df = run_query(cat_growth_query)
    st.markdown("##### Category Growth: 2017 vs 2018")
    fig = px.bar(growth_df, x="category", y=["revenue_2017", "revenue_2018"], barmode="group")
    st.plotly_chart(compact(fig, 300), use_container_width=True)

    st.markdown("##### Category Revenue Table")
    st.dataframe(growth_df, use_container_width=True, height=180)

# =========================================================
# PAGE 3 — CUSTOMER ANALYTICS
# =========================================================
elif page == "Customer Analytics":
    st.title("Customer Analytics")

    segment_query = """
    WITH customer_metrics AS (
        SELECT
            c.customer_unique_id,
            COUNT(DISTINCT o.order_id) AS frequency,
            ROUND(SUM(oit.order_total_value), 2) AS monetary,
            DATEDIFF(
                (SELECT MAX(order_purchase_timestamp) FROM orders WHERE is_delivered = 1),
                MAX(o.order_purchase_timestamp)
            ) AS recency_days
        FROM customers c
        JOIN orders o ON c.customer_id = o.customer_id
        JOIN order_item_totals oit ON o.order_id = oit.order_id
        WHERE o.is_delivered = 1
        GROUP BY c.customer_unique_id
    ),
    thresholds AS (
        SELECT AVG(monetary) AS avg_monetary, AVG(recency_days) AS avg_recency
        FROM customer_metrics
    ),
    segmented AS (
        SELECT
            cm.*,
            CASE
                WHEN cm.frequency >= 2 THEN 'Loyal / Repeat'
                WHEN cm.frequency = 1 AND cm.monetary >= t.avg_monetary AND cm.recency_days <= t.avg_recency THEN 'Recent High-Value'
                WHEN cm.frequency = 1 AND cm.monetary < t.avg_monetary AND cm.recency_days <= t.avg_recency THEN 'Recent Low-Value'
                WHEN cm.frequency = 1 AND cm.monetary >= t.avg_monetary AND cm.recency_days > t.avg_recency THEN 'Lapsed High-Value'
                ELSE 'Lapsed Low-Value'
            END AS customer_segment
        FROM customer_metrics cm
        CROSS JOIN thresholds t
    )
    SELECT customer_segment, COUNT(*) AS num_customers, ROUND(SUM(monetary),2) AS total_revenue
    FROM segmented
    GROUP BY customer_segment
    ORDER BY total_revenue DESC
    """
    seg_df = run_query(segment_query)

    col1, col2 = st.columns(2)
    with col1:
        fig = px.pie(seg_df, names="customer_segment", values="total_revenue", title="Revenue by Segment")
        st.plotly_chart(compact(fig, 260), use_container_width=True)
    with col2:
        fig2 = px.bar(seg_df, x="customer_segment", y="num_customers", title="Customers by Segment")
        st.plotly_chart(compact(fig2, 260), use_container_width=True)

    st.dataframe(seg_df, use_container_width=True, height=150)

# =========================================================
# PAGE 4 — OPERATIONS & CUSTOMER EXPERIENCE
# =========================================================
elif page == "Operations & Experience":
    st.title("Operations & Customer Experience")

    col1, col2 = st.columns(2)

    with col1:
        st.markdown("##### Delivery Delay vs Review Score")
        delay_review_query = """
        SELECT
            CASE WHEN o.delivery_delay_days > 0 THEN 'Late' ELSE 'On-time or Early' END AS status,
            ROUND(AVG(r.review_score),2) AS avg_score,
            COUNT(*) AS num_orders
        FROM orders o
        JOIN order_reviews r ON o.order_id = r.order_id
        WHERE o.is_delivered = 1
        GROUP BY status
        """
        dr_df = run_query(delay_review_query)
        fig = px.bar(dr_df, x="status", y="avg_score", text="avg_score")
        st.plotly_chart(compact(fig, 190), use_container_width=True)

    with col2:
        st.markdown("##### Late Delivery % by State")
        late_state_query = """
        SELECT c.customer_state,
               ROUND(100.0 * SUM(CASE WHEN o.delivery_delay_days > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_late
        FROM orders o
        JOIN customers c ON o.customer_id = c.customer_id
        WHERE o.is_delivered = 1
        GROUP BY c.customer_state
        ORDER BY pct_late DESC
        """
        late_df = run_query(late_state_query)
        fig2 = px.bar(late_df, x="customer_state", y="pct_late")
        st.plotly_chart(compact(fig2, 190), use_container_width=True)

    st.markdown("##### Review Score by Category (Worst 15)")
    cat_review_query = """
    SELECT p.product_category_name_english AS category, ROUND(AVG(r.review_score),2) AS avg_score, COUNT(*) AS num_reviews
    FROM order_reviews r
    JOIN orders o ON r.order_id = o.order_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.is_delivered = 1
    GROUP BY category
    HAVING num_reviews >= 50
    ORDER BY avg_score ASC
    LIMIT 15
    """
    cat_rev_df = run_query(cat_review_query)
    fig3 = px.bar(cat_rev_df, x="category", y="avg_score")
    st.plotly_chart(compact(fig3, 220), use_container_width=True)