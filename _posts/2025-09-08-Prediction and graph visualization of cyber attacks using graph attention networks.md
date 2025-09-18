---
layout: post
title: Prediction and graph visualization of cyber attacks using graph attention networks
categories: [論文, 機器學習]
tags: ["論文筆記", "論文", "GAT", "is1ab讀書會AI論文組"]
date: 2025-09-08
excerpt: "透過圖注意力機制預測出攻擊者的攻擊路徑，並且將路徑視覺化"
body_class: post-page
---

# Prediction and graph visualization of cyber attacks using graph attention networks

## Introduction

1. 資料複雜性： 網路攻擊資料來源多樣，格式不一，呈現動態且異質的結構，傳統方法難以有效分析。
2. 缺乏洞察力： 安全專家難以從龐大且複雜的網路攻擊資料中獲得深入洞察，從而阻礙了有效防禦策略的制定。
3. 傳統方法不足： 現有的網路安全方法已無法應對複雜且不斷演變的網路威脅。

## 主要方法

![image](https://hackmd.io/_uploads/rkAO6dz9ll.png)

### 1. 資料使用及清洗
#### 資料集使用 UNSW-NB15

1. 測試平台配置了三個虛擬伺服器（兩個用於正常流量，一個用於異常/惡意活動）、兩個路由器和一個防火牆。
2. 攻擊行為則根據 CVE 網站的資訊更新，以真實反映現代威脅環境。
3. 資料共捕獲了 100 GB。
4. 前 50 GB 每秒生成一次攻擊，後 50 GB 每秒生成十次攻擊，以反映不同的網路流量速度和現代攻擊利用方式。

#### 特徵提取與分析：
1. 特徵數量與分類：UNSW-NB15 資料集包含 49 個特徵（屬性），分為「基本特徵」、「內容特徵」和「時間特徵」。
2. 額外生成特徵：資料集還增加了十二個額外特徵，分為「通用特徵」（例如，源/目的 IP 和埠是否相同）和「連接特徵」（例如，特定服務或 IP 地址在 100 次連接中的頻率）。
3. 資料標籤：資料集透過攻擊報告進行標籤化，將每條記錄標記為「正常」（0）或「攻擊」（1）。攻擊還細分為九個類別
4. 模糊器 (Fuzzers)、分析 (Analysis)、後門 (Backdoors)、阻斷服務 (DoS)、漏洞利用 (Exploits)、通用 (Generic)、偵察 (Reconnaissance)、Shellcode 和蠕蟲 (Worms)。
5. 資料分佈：UNSW-NB15 包含 2,218,761 條正常記錄和 299,068 條攻擊記錄，攻擊記錄分佈於九個不同的家族。

### 2. 資料清理：
1. 使用 Python 的 pandas 庫導入資料集。
2. 刪除不相關的欄位（如使用者 ID 或不相關的分類變數）。
3. 識別並糾正或刪除缺失或錯誤的資料（例如，負值、異常值、格式錯誤的條目）。

### 3. 資料組織：
1. 將資料表示為同質圖 (homogeneous graph)，以視覺化資料集中的元素關係和互動。

### 4. 時間切片：
1. 攻擊具時間性，系統把流量依時段切成快照，之後可回看任一時點的互動圖。

### 5. 資料組織：
1. 使用 PyTorch Geometric:Heterodata 物件將同質圖形轉換為異質圖形。
2. 圖形資料結構包括節點特徵 (x)、邊緣表示 (edge-index) 和可選的類別標籤 (y)。
3. 由於網路攻擊涉及時間資料，因此在特定時間間隔捕獲並分析資料，從而實現基於時間間隔的視覺化步驟。
4. 執行標籤化並將欄位轉換為[張量](https://medium.com/hunter-cheng/%E6%A9%9F%E4%BD%95%E7%82%BA%E5%BC%B5%E9%87%8F-tensor-%E4%B8%89%E5%88%86%E9%90%98%E5%9C%96%E8%A7%A3%E9%A1%9E%E7%A5%9E%E7%B6%93%E7%B6%B2%E8%B7%AF%E5%9F%BA%E6%9C%AC%E8%B3%87%E6%96%99%E7%B5%90%E6%A7%8B-ab0ccd115aff)，以準備模型訓練。

![image](https://hackmd.io/_uploads/SkZqCjfcll.png)

### 6. 圖形注意力網路 (GAT) 模型的應用

![image](https://hackmd.io/_uploads/B1waRjG5gx.png)

| 模型 | 聚合方式 | 特點 |
| -------- | -------- | -------- |
| GCN     | 平均 (mean) + 線性轉換     | 簡單、效率高，但表達力弱，易過平滑     |
| GIN     | 加總 (sum) + MLP	表達力強    | 理論上最接近圖同構測試     |
| GAT     | 注意力加權 (learned weights)     | 可自動學習鄰居重要性，靈活但計算量大     |

1. GAT 模型用於分析資料組織步驟中獲得的異構和時間性快照。
2. 與傳統模型（如 GCN）可能對所有相鄰節點給予同等權重不同，GAT 模型透過注意力機制強調更重要的連接，從而提供更敏感和準確的分析，這對於網路威脅和異常行為的判斷至關重要。
3. 分析後的資料（使用 PyTorch 庫）透過 Flask 框架作為 HTML 服務提供，並與 Sigma.js 庫整合，以便視覺化分析結果

### 7. 圖形實施：
1. 使用 Sigma.js 和 Graphology 庫進行圖形視覺化。
2. Sigma.js 是一種 JavaScript 庫，專為在網頁瀏覽器中建立和互動圖形而設計，利用 HTML5 Canvas 和 WebGL 高效顯示大型資料集。
3. [Graphology](https://graphology.github.io/) 用於管理圖形資料模型和演算法。
4. 將相同節點之間的相同攻擊類型分組並新增攻擊計數，以減少圖形的複雜性。

![image](https://hackmd.io/_uploads/HkmXynz5ex.png)

- 節點：主機/使用者
- 邊：連線或攻擊行為
- 綠色邊 = 正常連線
- 紅色邊 = 攻擊連線
- 邊上標示攻擊類型 & 次數

### 8. 圖形改進：
1. 各種技術使圖形更有意義，例如透過視覺化或識別子結構。
2. 互動式功能，如當滑鼠懸停在節點上時，顯示連接的邊，以區分攻擊連接和正常連接

![image](https://hackmd.io/_uploads/SyvU13Mclx.png)

### 算式
![image](https://hackmd.io/_uploads/rJd-1Shqxg.png)

---

## 實驗設計與結果

1. 模型與訓練比例：在不同訓練比例（20/40/60/80%）下測 Macro-F1 與 Micro-F1。
2. Macro-F1 = 0.9117/0.9125/0.9125/0.9058；Micro-F1 = 0.9315/0.9216/0.9213/0.9177。
3. 訓練占比到 60% 前維持穩定，80% 時 Macro-F1 略降；Micro-F1 以20% 最高，其後小幅波動，顯示資料分佈與泛化能力之間存在張力。

![image](https://hackmd.io/_uploads/rJE6J3zqxl.png)

常見圖資料集（Cora/CiteSeer/PubMed）的統計與在這些資料集上 GAT 相較 MLP/GCN 的公認表現
![image](https://hackmd.io/_uploads/HJc6J3zqgx.png)

---

## 問題點

1. 前處理成本高：異質大數據清理與特徵整理耗時且關乎成敗。
2. 計算資源昂貴：大規模圖的 GAT 推論成本高，若要即時化需進一步最佳化。
3. 可視化取捨：為避免視覺爆炸而做「邊聚合／分段繪圖」，但細節可能流失；後續可引入更進階的聚合與過濾互動。
4. 泛化能力：目前主要在 UNSW-NB15 驗證，仍需更多異質資安資料集測試。且 UNSW-NB15 為 2015 年的論文

---