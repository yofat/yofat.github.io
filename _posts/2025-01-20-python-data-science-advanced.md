---
layout: post
title: Python 資料科學入門：從 NumPy 到 Pandas
categories: [人工智能, 深度學習]
tags: [程式語言, Python]
body_class: post-page
---

# Python 資料科學入門：從 NumPy 到 Pandas

Python 已經成為資料科學領域最受歡迎的程式語言之一。本文將介紹 Python 資料科學的核心套件：NumPy 和 Pandas。

## 為什麼選擇 Python？

Python 在資料科學領域受歡迎的原因：

- **豐富的生態系統**：NumPy、Pandas、Scikit-learn、TensorFlow 等
- **簡潔的語法**：易於學習和維護
- **活躍的社群**：豐富的資源和支援
- **跨平台支援**：Windows、macOS、Linux 都能運行

## NumPy 基礎

NumPy（Numerical Python）是 Python 科學計算的基礎套件。

### 安裝 NumPy

```bash
pip install numpy
```

### 基本操作

```python
import numpy as np

# 創建陣列
arr1 = np.array([1, 2, 3, 4, 5])
arr2 = np.zeros((3, 4))  # 3x4 的零矩陣
arr3 = np.ones((2, 3))   # 2x3 的單位矩陣

# 陣列運算
result = arr1 * 2        # 每個元素乘以 2
sum_arr = np.sum(arr1)   # 計算總和
mean_arr = np.mean(arr1) # 計算平均值
```

### 多維陣列

```python
# 創建 2D 陣列
matrix = np.array([[1, 2, 3], [4, 5, 6]])
print(matrix.shape)  # (2, 3)

# 矩陣運算
dot_product = np.dot(matrix, matrix.T)  # 矩陣乘法
```

## Pandas 資料處理

Pandas 提供了強大的資料結構和資料分析工具。

### 安裝 Pandas

```bash
pip install pandas
```

### DataFrame 基礎

```python
import pandas as pd

# 創建 DataFrame
data = {
    'name': ['Alice', 'Bob', 'Charlie'],
    'age': [25, 30, 35],
    'city': ['台北', '台中', '高雄']
}
df = pd.DataFrame(data)

# 基本資訊
print(df.head())      # 前 5 行
print(df.info())      # 資料型別資訊
print(df.describe())  # 統計摘要
```

### 資料操作

```python
# 篩選資料
young_people = df[df['age'] < 30]

# 排序
sorted_df = df.sort_values('age')

# 分組統計
grouped = df.groupby('city').mean()

# 新增欄位
df['age_group'] = df['age'].apply(
    lambda x: 'young' if x < 30 else 'adult'
)
```

### 讀取和寫入資料

```python
# 讀取 CSV 檔案
df_csv = pd.read_csv('data.csv')

# 讀取 Excel 檔案
df_excel = pd.read_excel('data.xlsx')

# 寫入檔案
df.to_csv('output.csv', index=False)
df.to_excel('output.xlsx', index=False)
```

## 資料視覺化

結合 Matplotlib 進行資料視覺化：

```python
import matplotlib.pyplot as plt

# 簡單折線圖
plt.figure(figsize=(10, 6))
plt.plot(df['age'], df['name'])
plt.title('年齡分布')
plt.xlabel('年齡')
plt.ylabel('人員')
plt.show()

# 使用 Pandas 內建繪圖
df['age'].hist(bins=10)
plt.title('年齡直方圖')
plt.show()
```

## 實際案例：股票資料分析

```python
import yfinance as yf

# 下載股票資料
stock = yf.download('2330.TW', start='2024-01-01', end='2024-12-31')

# 計算移動平均線
stock['MA_20'] = stock['Close'].rolling(window=20).mean()
stock['MA_50'] = stock['Close'].rolling(window=50).mean()

# 計算報酬率
stock['Returns'] = stock['Close'].pct_change()

# 視覺化
plt.figure(figsize=(12, 8))
plt.plot(stock.index, stock['Close'], label='收盤價')
plt.plot(stock.index, stock['MA_20'], label='20日移動平均')
plt.plot(stock.index, stock['MA_50'], label='50日移動平均')
plt.legend()
plt.title('台積電股價趨勢')
plt.show()
```

## 效能優化技巧

### 向量化運算

```python
# 避免使用迴圈
# 不好的做法
result = []
for i in range(len(arr)):
    result.append(arr[i] * 2)

# 好的做法
result = arr * 2
```

### 記憶體管理

```python
# 使用適當的資料型別
df['category'] = df['category'].astype('category')

# 批次處理大檔案
chunk_size = 10000
for chunk in pd.read_csv('large_file.csv', chunksize=chunk_size):
    # 處理每個區塊
    process_chunk(chunk)
```

## 學習資源

推薦的學習資源：

1. **官方文檔**
   - [NumPy Documentation](https://numpy.org/doc/)
   - [Pandas Documentation](https://pandas.pydata.org/docs/)

2. **線上課程**
   - Coursera 的資料科學課程
   - edX 的 Python 資料分析課程

3. **實作專案**
   - Kaggle 競賽
   - GitHub 開源專案

## 總結

NumPy 和 Pandas 是 Python 資料科學的基石：

- **NumPy** 提供高效的數值運算
- **Pandas** 提供靈活的資料操作
- **結合使用** 可以處理各種資料科學任務

掌握這些工具將為你的資料科學之路奠定堅實的基礎。記住，熟能生巧，多動手實作才能真正掌握這些技能！
