import pandas as pd
import datetime as dt

# Load CSV
df = pd.read_csv(r"C:\Users\kaleh\Downloads\ONLINE_RETAIL2010-11.csv", encoding='ISO-8859-1')


print("Original Shape:", df.shape)
print(df.head())


# ----------------------------
# Data Cleaning
# ----------------------------

# Rename column (Customer ID me space hai)
df.rename(columns={"Customer ID": "CustomerID"}, inplace=True)

# Remove rows where CustomerID is null
df = df.dropna(subset=["CustomerID"])

# Remove negative or zero Quantity
df = df[df["Quantity"] > 0]

# Remove negative or zero Price
df = df[df["Price"] > 0]

print("After Cleaning Shape:", df.shape)

# Convert InvoiceDate to datetime
df["InvoiceDate"] = pd.to_datetime(df["InvoiceDate"])

print("Date Converted Successfully")


# Create TotalAmount column
# Fix column names
df.rename(columns={
    "Customer ID": "CustomerID",
    "ï»¿Invoice": "Invoice"
}, inplace=True)

df["TotalAmount"] = df["Quantity"] * df["Price"]

print(df.head())



# ---------------------------
# RFM Calculation
# ---------------------------

snapshot_date = df["InvoiceDate"].max()
print("Snapshot Date:", snapshot_date)




# ---------------------------
# Create RFM Table
# ---------------------------

rfm = df.groupby("CustomerID").agg({
    "InvoiceDate": lambda x: (snapshot_date - x.max()).days,
    "Invoice": "nunique",
    "TotalAmount": "sum"
})

rfm.rename(columns={
    "InvoiceDate": "Recency",
    "Invoice": "Frequency",
    "TotalAmount": "Monetary"
}, inplace=True)

print(rfm.head())
print("Total Customers:", rfm.shape)

# -------------------------
# RFM Scoring (1-5 scale)
# -------------------------

rfm["R_score"] = pd.qcut(rfm["Recency"], 5, labels=[5,4,3,2,1])
rfm["F_score"] = pd.qcut(rfm["Frequency"].rank(method="first"), 5, labels=[1,2,3,4,5])
rfm["M_score"] = pd.qcut(rfm["Monetary"], 5, labels=[1,2,3,4,5])

# Combine Scores
rfm["RFM_Score"] = (
    rfm["R_score"].astype(str) +
    rfm["F_score"].astype(str) +
    rfm["M_score"].astype(str)
)

print("\nRFM With Scores:")
print(rfm.head())
# -------------------------
# Customer Segmentation
# -------------------------

def segment_customer(row):
    if row["R_score"] == 5 and row["F_score"] >= 4:
        return "Champions"
    elif row["F_score"] >= 4 and row["M_score"] >= 4:
        return "Loyal Customers"
    elif row["R_score"] >= 4 and row["F_score"] <= 2:
        return "Potential Loyalist"
    elif row["R_score"] <= 2 and row["F_score"] <= 2:
        return "Hibernating"
    else:
        return "Regular"

rfm["Segment"] = rfm.apply(segment_customer, axis=1)

print("\nSegment Distribution:")
print(rfm["Segment"].value_counts())


# -------------------------
# Export Final RFM File
# -------------------------

rfm.reset_index(inplace=True)

rfm.to_csv("rfm_output.csv", index=False)

print("\nRFM file exported successfully!")
