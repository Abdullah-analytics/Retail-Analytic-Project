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
df["TotalAmount"] = df["Quantity"] * df["Price"]

print(df.head())
