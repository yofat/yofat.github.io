---
layout: post
title: Bypass WAF 學習筆記
categories: [紅隊學習]
tags: ["red team", "web", "bypass waf"]
date: 2023-01-14
excerpt: "Bypass WAF 學習筆記。"
body_class: post-page
---

# Bypass WAF 學習筆記
---
## 來源：
> https://www.hacking8.com/MiscSecNotes/bypass-waf.html
> https://www.oracle.com/tw/security/cloud-security/what-is-waf/
---

## 什麼是WAF (Web 應用程式防火牆)
### WAF的定義
> Web 應用程式防火牆可協助保護 Web 應用程式免於遭受惡意攻擊和不必要的網際網路流量，包括機器人、注入和應用程式層拒絕服務 (DoS)。WAF 可協助您建立及管理避免網際網路威脅的規則，包括 IP 位址、HTTP 標頭、HTTP 主體、URI 字串、跨網站命令檔 (XSS)、SQL 隱碼攻擊及其他 OWASP 定義的漏洞。建置 Web 應用程式防火牆以保護 Web 公開的應用程式，並收集存取日誌，以滿足相容性和分析的需求。

### WAF的功能
*
    透過網域名稱系統 (DNS) 進行的動態流量路由：運用以 DNS 為基礎的流量路由演算法，考量全球數千個位置的使用者延遲以判斷最低延遲的路由。
*
    WAF 服務的高可用性：設定 Web 應用程式傳遞時，WAF 可提供數個能夠新增多個來源伺服器的高可用性組態選項。當主要來源伺服器離線或未正確回應狀況檢查時，可以使用這些設定。
*
    管理原則的彈性方法：WAF 組態可讓您設定及管理功能，以滿足組織的需求。
*
    監督及報告：WAF 可讓使用者存取與內容庫相關的報告功能，以進行規範與分析。
*
    呈報：WAF 的資訊可讓支援小組根據緊急性發出及呈報票證。

### WAF的優點
> Web 應用程式防火牆 (WAF) 可篩選掉對 Web 應用程式或 API 有惡意的要求。它也更清楚地了解流量來自何處，而降低第 7 層分散式阻斷服務 (DDos) 攻擊風險，以協助取得應用程式可用性，以及更妥善地強制執行規範要求。

> 機器人管理解決方案使用 IP 速率限制、CAPTCHA、裝置指紋測定以及人工互動挑戰等偵測技術，識別和封鎖不良和 / 或可疑的機器人活動，避免您的網站競爭性資料混淆。同時，WAF 可以允許來自 Google、Facebook 和其他公司的合法機器人流量，使其能夠依照預期用途持續存取您的 Web 應用程式。WAF 會使用資料導向演算法來即時定義指定使用者的最佳全球網路連接點 (PoP) 的智慧型網域名稱系統 (DNS)。如此一來，使用者便可避開全域網路問題和潛在的延遲，同時提供最佳正常運作時間與服務等級。

## 1. 架構層繞過WAF
### 1.1 尋找源站

**如果流量都沒有經過WAF，WAF當然無法攔截攻擊請求。**

![](https://i.imgur.com/MsQvypo.png)

**假設我們是攻擊者，如何繞過WAF的安全檢測呢？
從雲WAF架構考慮，如果HTTP請求都沒有經過WAF集群直接到達源站，順理成章bypass WAF。所以關鍵在於發現源站的IP地址。常用方法如下，可能還有很多很多思路**

*
	•    1.信息洩露發現源站IP。信息洩露的途徑很多:
	
	•        網站頁面註銷是否包含源站IP。
	
	•        GIHUB源代碼洩露是否包含源站IP。
	
	•        未接入WAF前，真實IP地址是否被搜索引擎等服務收錄。
*
    2.窮舉IP地址，根據特徵發現服務器真實IP地址。對於國內的服務器，窮舉國內的IP，訪問每個IP的HTTP服務，根據頁面特徵檢測響應頁面，判斷IP是否為源站IP地址。
    
---

### 1.2 利用同網段

> 一些在雲服務商的站點，同時使用雲服務商提供的WAF服務。當流量不是通過DNS解析引流到WAF，流量必須經過WAF的檢測，這是不能通過發行源站進行繞過。可以考慮在雲服務商買一台VPS，通過VPS攻擊目標站點，因為流量是局域網，可能不經過WAF檢測，實現繞過。能不能成功，關鍵在於雲服務商的網絡配置。

![](https://i.imgur.com/woT35fk.png)

---

### 1.3利用邊界漏洞

> 如果未能發現源站IP，可以嘗試尋找子站的SSRF漏洞。如果子站訪問目標站不經過WAF集群，可以利用SSRF漏洞來繞過WAF。

https://ithelp.ithome.com.tw/articles/10242449

---

## 2. 資源限制角度繞過WAF

> 這是眾所周知、而又難以解決的問題。如果HTTP請求POST BODY太大，檢測所有的內容，WAF集群消耗太大的CPU、內存資源。因此許多WAF只檢測前面的幾K字節、1M、或2M。對於攻擊者而然，只需要在POST BODY前面添加許多無用數據，把攻擊payload放在最後即可繞過WAF檢測。

---

## 3. 協議層面繞過WAF的檢測

> 即使流量都確保經過WAF，如果WAF的防禦策略根本就沒有檢測payload，那麼也就能繞過WAF。協議層面繞過WAF，利用WAF解析協議的問題，使得payload被認為不是請求的HTTP請求的內容。從個人經驗總結出WAF解析協議的常出現問題的三個方向。

*
    協議覆蓋不全。
*
    協議解析不正確。
*
    協議解析後與WEB容器的協議解析不一致。

以下以實例說明利用協議繞過WAF的方法。通過CASE解析什麼是協議覆蓋不全、協議解析不正確、協議解析不一致。

---

### 3.1 協議未覆蓋繞過WAF

POST 請求常用有2種參數提交方式：

*
    Content-Type: application/x-www-form-urlencoded;
*
    Content-Type: multipart/form-data;
    
> Waf未能覆蓋Content-Type: multipart/form-data從而導致被繞過。或者WAF會認為它是文件上傳請求，從而只檢測文件上傳，導致被繞過。如圖，加速樂的WAF就存在被繞過的情況，是典型的協議未覆蓋。

![](https://i.imgur.com/mnyyyGH.png)


**普通攻擊請求被攔截**

![](https://i.imgur.com/DhG3RFj.png)

**協議未覆蓋導致繞過**

---

### 3.2 利用協議解析不一致繞過WAF的典型例子

> 如圖中的payload，WAF解析出來上傳的文件名是test3.jpg，而PHP解析到的文件名是”test3.jpg\nf/shell.php”，因為”/”是目錄分隔符，上傳的文件名變為shell.php，從而繞過WAF的防禦。當時這個方法幾乎通殺所有WAF，可見利用協議層繞過WAF的威力。就文件上傳而言，還有更多因為協議解析導致繞過，見3.3節。

![](https://i.imgur.com/sT3nF9z.png)

WAF與PHP解析文件上傳協議不一致導致繞過

---

### 3.3 利用協議解析問題繞過WAF文件上傳

> WAF的文件上傳規則使用正則表達式匹配上傳的文件名是否包含“0x00”等，所以正面繞過正則表達式匹配幾乎不可能。如果不從規則角度考慮，利用協議解析問題讓WAF無法匹配到正確的文件名，就能繞過WAF實現文件上傳。

#### 3.3.1 協議解析不正確-文件名覆蓋(一)

> 在multipart協議中，一個文件上傳塊存在多個Content-Disposition，將以最後一個Content-Disposition的filename值作為上傳的文件名。許多WAF解析到第一個Content-Disposition就認為協議解析完畢，獲得上傳的文件名，從而導致被繞過。如圖，加速樂的WAF解析得到文件名是”sp.pho”，但PHP解析結果是”sp.php”，導致被繞過。

![](https://i.imgur.com/i5CtH9l.png)

---

#### 3.3.2 協議解析不正確-文件名覆蓋（二）

> 在一個Content-Disposition 中，存在多個filename ，協議解析應該使用最後的filename值作為文件名。如果WAF解析到filename="p3.txt"認為解析到文件名，結束解析，將導致被繞過。因為後端容器解析到的文件名是t3.jsp。

`Content-Disposition: form-data;name="myfile"; filename="p3.txt";filename="t3.jsp"`

---

#### 3.3.3 協議解析不正確-遺漏文件名

> 當WAF遇到“name=”myfile";;”時，認為沒有解析到filename。而後端容器繼續解析到的文件名是t3.jsp，導致WAF被繞過。

`Content-Disposition: form-data;name="myfile";; filename="t3.jsp"`

---

#### 3.3.4 協議解析不正確-未解析所有文件

> multipart協議中，一個POST請求可以同時上傳多個文件。如圖，許多WAF只檢查第一個上傳文件，沒有檢查上傳的所有文件，而實際後端容器會解析所有上傳的文件名，攻擊者只需把paylaod放在後面的文件PART，即可繞過。

![](https://i.imgur.com/JiaiTn2.png)

![](https://i.imgur.com/DvVTXmT.png)

---

#### 3.3.5 協議解析不一致-文件名解析兼容性

> multipart協議中，文件名的形式為“filename="abc.php"”。但是Tomcat、PHP等容器解析協議時會做一些兼容，能正確解析”filename="abc.php”、”filename=abc.php”、 ”filename='abc.php'”。而WAF只按照協議標準去解析，無法解析文件名，但是後端容器能正確獲得文件名，從而導致被繞過。場景的繞過形式：

*
    Content-Disposition: form-data; name="file"; filename=abc.php
*
    Content-Disposition: form-data; name="file"; filename="abc.php
*
    Content-Disposition: form-data; name="file"; filename='abc.php'
    
---

### 3.4 參數污染

> 請求中包含2個參數名相同的參數typeid，第一個是正常參數的值，第二個參數才是payload。如果WAF解析參數使用第一個值，沒檢查第二個值，將導致繞過。這是很久很久的一個CASE，現在幾乎沒有WAF存在這個問題。

`/forum.php?typeid=644&typeid=if(now()%3dsysdate()%2csleep(19.844)%2c0)/*'XOR(if(now()%3dsysdate()%2csleep(19.844)%2c0))OR'%22XOR(if(now()%3dsysdate()%2csleep(19.844)%2c0))OR%22*/`

---

### 3.5 小結

> 當想到利用協議解析繞過WAF檢測時，並不敢確定效果，經過實踐檢驗，協議解析繞過WAF的思路可行且有效。在研究利用協議繞過WAF時，需要大膽地猜測WAF解析協議時容易犯什麼錯誤，科學地一點點驗證。通過分析PHP、tomcat的協議解析源碼，找出它們與HTTP標準協議的差異是發現繞過WAF的快速有效方法。
> 
> 本節利用multipart/form-data協議解析過問題文件上傳的思路，思路同樣可用於繞過multipart/form-data協議POST FROM表單提交參數的檢測。

---

## 4. 規則層面的繞過

對基於正則表達式的WAF，繞過WAF規則主要思考安全工程師寫WAF規則時在想什麼，容易忽略什麼，推斷一些可能繞過的方式，然後多次嘗試進行驗證。比起完整羅列繞過CASE，我更喜歡分析繞過思路。這次以最受關注的SQL注入、文件包含為例，分析一下繞過思路。

---

### 4.1. SQL注入繞過

> 繞過SQL注入規則主要利用WAF規則本身的問題、未考慮到SQL語法變形、及後端數據庫SQL語句語法特性。不同的數據庫雖然遵守SQL標準，但是通常會加入特有的語法。WAF的防禦策略要兼顧各種數據庫的特殊語法，容易遺漏，從而被利用繞過WAF。以下MySQL為例，分析繞過SQL注入的一些思路。

#### 4.1.1 註釋符繞過

> `/*xxx*/是註釋，也可以充當空白符。因為 /**/可使得MySQL對sql語句( union/**/select)詞法解析成功。事實上許多WAF都考慮到/**/可以作為空白分，但是waf檢測 /\*.*\*/很消耗性能，工程師會折中，可能在檢測中間引入一些特殊字符，例如：/*\w+*/。或者，WAF可能只中間檢查n個字符/\*.{,n}\*/。根據以上想法，可以逐步測試繞過方法：`

*
    先測試最基本的：union/**/select
*
    再測試中間引入特殊字：union/*aaaa%01bbs*/select
*
    最後測試註釋長度：union/*aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa*/select
    
同理，對於/*!xxx*/，可以採取類似的思路繞過WAF。

---

#### 4.1.2 空白符繞過

> 基於正則表達式的WAF， SQL注入規則使用正則表達式的“\s”匹配空格，例如”select\s+union”。利用正則表達式的空白符與MySQL空白符的不同可繞過WAF規則。如何這些MySQL的特性？通過fuzz,每次更改正常SQL語句的某部分，替換為其他字符，判斷語法是否正確，即可判斷出來MySQL語法特性。當然，也可以通過分析MySQL詞法來發現語法特性，從而找到繞過方法。
> 
> 利用空白符進行繞過，測試WAF時盡可能減少其他原因的影響，例如”union select”被攔截，只需把中間空白符替換為”%250C”, “%25A0”進行繞過測試。

*    union%250Cselect
*    union%25A0select

![](https://i.imgur.com/5YCk31K.png)

---

#### 4.1.3 函數分隔符

> 對基於正則表達式的WAF，我們猜測安全工程師寫WAF規則時，可能不知道函數名與左括號之間可以存在特殊字符，或者遺漏可以存在特殊字符。例如匹配函數”concat()”的規則寫法，“concat(”或者”concat\s*(”，就沒有考慮到一些特殊字符。相應的繞過方法，在特殊位置引入特殊的分隔符，逐個測試。這些特殊分隔符發現也是通過Fuzz出來的。

*    concat%2520(
*    concat/**/(
*    concat%250c(
*    concat%25a0(

---

#### 4.1.4 浮點數詞法解析

> 利用MySQL解析浮點數的特點，正則表達式無法匹配出單詞union，但是MySQL詞法解析成功解析出浮點數、sql關鍵字union

*    select * from users where id=8E0union select 1,2,3,4,5,6,7,8,9,0
*    select * from users where id=8.0union select 1,2,3,4,5,6,7,8,9,0
*    select * from users where id=\Nunion select 1,2,3,4,5,6,7,8,9,0

---

#### 4.1.5 利用error-based進行SQL注入

> Error-based的SQL注入函數非常容易被忽略，導致WAF規則過濾不完整。隨著對MySQL研究越來越深，被發現可用於error-based SQL注入的函數越來越多，同時也給繞過WAF造就了更多機會。常見的函數：

*    extractvalue(1, concat(0x5c,md5(3)));
*    updatexml(1, concat(0x5d,md5(3)),1);
*    GeometryCollection((select from(select from(select@@version)f)x))
*    polygon((select*from(select name_const(version(),1))x))
*    linestring()
*    multipoint()
*    multilinestring()
*    multipolygon()

利用Error-based的SQL注入函數進行繞過時，可以結合函數分隔符，或其他方法靈活運用。

---

#### 4.1.6 Mysql特殊語法

> 最有效的發現手段，還是去讀讀MySQL詞法分析源代碼。和協議繞過類似，挖掘SQL標準與MySQL的詞法分析差異是發現WAF SQL注入繞過的有效手段。以下是MySQL語法的一個特寫(ps:不是我發現的)：

`select{x table_name}from{x information_schema.tables};`

---

#### 4.1.7 綜合利用實例以上

> 綜合利用實例以上都是SQL注入繞過中的技術點，在實際滲透測試中，需要靈活綜合利用才能達到完整繞過，讀取數據數據。以下給出完整繞過WAF SQ注入檢測的實例。如圖，本例中綜合多個繞過技術點，最終實現完整繞過實現讀取數據。

*    利用浮點數詞法解析，繞過union select 的檢測。
*    同樣，函數分隔符思想集和浮點數詞法解析，繞過關鍵字from的檢測。
*    最後空白分分割繞過INFORMATION_SCHEMA.TABLES的檢查

![](https://i.imgur.com/Xqzt2Rk.png)

---

### 4.2 文件包含

> 文件包含分為相對路徑、絕對路徑文件包含。在相對路徑文件包含中，最終根據Linux虛擬文件系統(vfs)的規則查找文件，通過分析vfs的文件路徑解析規則，提取其中規則特點，用這些特點去繞過WAF。在絕對文件路徑包含中，主要是根據攻擊場景，WAF未過濾一些協議、未過濾某些特殊路徑。

#### 4.2.1 相對路徑的繞過

> 寫WAF文件包含規則時，如果檢測單一的”../”，誤報會非常多，所以WAF文件包含規則通常會檢測連續的“../"。根據vfs解析路徑的語法，解析到“//”文件路徑不變，解析到“/./”文件路徑依然。通過避免連續的"../"，從而繞過WAF文件包含規則。
> Eg: ././..///./.././/../etc//passwd，它等價於../../../etc/passwd。如圖，一個實際的繞過WAF文件包含的CASE

![](https://i.imgur.com/gOY5mH9.png)

---

#### 4.2.2 絕對路徑的繞過（一）

> WAF沒有考慮到路徑中插入“/./”、“//”對於vfs解析路徑是等價的，導致可被繞過。例如/etc/./passwd 與/etc/passwd 是等價的。還可以通過組合“/./”、“//”進行繞過，
> Eg:. /etc///.//././/passwd。

![](https://i.imgur.com/sL5Gl8C.png)

> 對於絕對路徑文件包含，WAF一般會攔截常見路徑，而不會防御所有的絕對路徑。因此，在滲透測試中，可以包含其他的路徑下一些文件，例如/usr/local/nginx/conf/nginx.conf。

![](https://i.imgur.com/ZwBcFol.png)

> 如果WAF只檢測連續的../，檢查開始路徑為Linux的目錄名，可以採用/wtt/../繞過WAF文件包含檢測。例如，“/wtt/../etc/passwd”， wtt不是Linux標準目錄，不會被規則匹配。WAF只檢測連續的../，但是只使用一個../，不被攔截。最終讀取/etc/passwd文件。

---

#### 4.2.2 絕對路徑的繞過（二）

利用WAF未檢測的協議。PHP 文件包含支持的協議，在滲透測試中，看環境選擇可行的方法

*    file:// — Accessing local filesystem
*    http:// — Accessing HTTP(s) URLs
*    ftp:// — Accessing FTP(s) URLs
*    php:// — Accessing various I/O streams
*    zlib:// — Compression Streams data:// — Data (RFC 2397)
*    glob:// — Find pathnames matching pattern
*    phar:// — PHP Archive
*    ssh2:// — Secure Shell 2
*    rar:// — RAR
*    ogg:// — Audio streams
*    expect:// — Process Interaction Streams

---
