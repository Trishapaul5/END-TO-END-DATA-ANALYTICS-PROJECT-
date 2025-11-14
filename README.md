# 🛍️ Customer Shopping Behavior Analytics

> End-to-End Data Analytics Project | Python • SQL • Machine Learning • Power BI

## 📋 Project Overview

A comprehensive analytics project analyzing **3,900 customer records** to uncover actionable insights for revenue optimization, customer retention, and marketing efficiency. This project demonstrates a complete workflow from data cleaning to predictive modeling and interactive dashboards.

**Key Results:**
- 💰 **$127,173** in revenue opportunities identified
- 🎯 **86.28%** ML model accuracy for subscription prediction
- 📊 **11 RFM segments** created for precision marketing
- ⚠️ **$93,619** at-risk customer revenue identified

## 🎯 Business Impact

| Initiative | Target | Expected ROI |
|------------|--------|--------------|
| Churn Prevention | 1,560 At-Risk customers | **$28,085** |
| Subscription Growth | 847 high-probability leads | **$36,338** |
| Customer Upselling | 974 High Value → Premium | **$47,750** |
| Discount Optimization | 43% discount rate reduction | **$15,000** |
| **TOTAL** | | **$127,173** |

## 🗂️ Project Structure

```
├── data/                   # Raw and processed datasets
├── notebooks/              # Jupyter notebooks for analysis
├── sql/                    # SQL scripts and queries
├── powerbi/               # Power BI dashboard files
├── reports/               # Generated reports and insights
├── src/                   # Source code for analysis
└── venv/                  # Virtual environment
```

## 🔬 Methodology

### Phase 1: Data Cleaning & EDA
- Cleaned 3,900 customer records
- Handled 37 missing values
- Created 5 engineered features

### Phase 2: Customer Segmentation
- **CLV Analysis**: Segmented customers into 4 tiers (Premium, High, Medium, Low)
- **RFM Segmentation**: Created 11 actionable customer segments
- **Statistical Testing**: Validated subscription uplift (34.5%, p < 0.001)

### Phase 3: Predictive Modeling
- Built **Logistic Regression** model with 86.28% accuracy
- Achieved **99.53% recall** for subscription prediction
- Identified 847 high-conversion targets

### Phase 4: Database Deployment
- Deployed to **MySQL** production database
- Created optimized SQL views for dashboards
- Built indexed queries for performance

### Phase 5: Power BI Dashboard
- 4-page interactive dashboard
- Executive overview, customer segmentation, product analytics, subscription insights
- Real-time KPIs and actionable recommendations

## 🛠️ Technologies Used

**Languages & Libraries:**
- Python (Pandas, NumPy, Scikit-learn, Matplotlib, Seaborn)
- SQL (MySQL)

**Tools:**
- Jupyter Notebook
- Power BI Desktop
- SQLAlchemy
- Git

## 🚀 Quick Start

1. **Clone the repository**
```bash
git clone https://github.com/Trishapaul5/END-TO-END-DATA-ANALYTICS-PROJECT-
cd customer-shopping-analytics
```

2. **Set up environment**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

3. **Run analysis**
```bash
jupyter notebook notebooks/
```

4. **Set up database**
```bash
python setup_project_structure.py
python test_connection.py
```

## 📊 Key Findings

✅ **Subscription Value**: Subscribers spend 34.5% more per transaction (statistically significant)

✅ **Churn Risk**: 1,560 "At Risk" customers worth $93,619 identified

✅ **Discount Inefficiency**: 43% discount rate has no impact on basket size (p > 0.05)

✅ **Predictive Targeting**: ML model identifies 847 high-probability conversion targets

✅ **Revenue Concentration**: Top 50% of customers generate 65.9% of total revenue

## 💡 Business Recommendations

1. **Launch immediate win-back campaign** for 1,560 at-risk customers
2. **Deploy ML-driven subscription campaign** targeting 847 high-probability leads
3. **Implement CLV-based upselling** to move High Value customers to Premium tier
4. **Optimize discount strategy** by eliminating blanket discounts

## 📈 Results Summary

- **Total Revenue Analyzed**: $233,081
- **Customer Segments**: 11 RFM segments
- **Model Performance**: 86.28% accuracy, 99.53% recall
- **Revenue Opportunities**: $127,173 quantified

## 🔮 Future Enhancements

- [ ] Cohort analysis and survival modeling
- [ ] Market basket analysis for cross-selling
- [ ] Time series forecasting
- [ ] Automated ML pipeline deployment
- [ ] Real-time dashboard with alerting

## 👤 Author

**TRISHA PAUL**  
Data Analyst | Python • SQL • Machine Learning • Power BI

📧 trishapaul2502@gmail.com

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments
- **Tools**: Open-source communities of Pandas, Scikit-learn, and MySQL

---

⭐ **If you found this project helpful, please consider giving it a star!**

**Last Updated**: November 2025  
**Status**: ✅ Complete & Production-Ready