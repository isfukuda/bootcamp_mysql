---
footer: CC BY-SA Licensed | Copyright (c) 2022, Internet Initiative Japan Inc.
title: MySQLを触ってみよう
description: MySQLの基本的な操作を通して、RDBMSへの基礎理解の習得を目指します
time: 2.0時間
prior_knowledge: Docker, Docker-Compose の使い方、RDBMSへの興味　
---

<header-table/>

# IIJ BootCamp 2022 MySQLを触ってみよう

## 0.はじめに
### MySQL Image pull
- PROXYの設定を改めて確認してください
- その上でdocker pullを実行してください
```
# docker pull mysql:latest
# docker image list
REPOSITORY                    TAG                 IMAGE ID            CREATED             SIZE
docker.io/mysql               latest              33037edcac9b        2 days ago          444 MB
```

### 本講義の目指すところ
- MySQLを通してRDBMSへの基礎理解と経験値を上げる
- RDBMSへの興味を深掘りするきっかけづくり

### 想定する受講者
- 2022年 技術職の新卒採用者
- IIJグループ会社所属の技術職(あるみんで申し込み可能な方)
- BootCamp事前準備受講者
- 環境OSは問わないが、LinuxVM環境を事前に構築が独力で可能
- git, docker, docker-compose 等々の基本的コマンド操作が独力で行えること

### 講義概要
- 雑談、フリーディスカッション 15min程度
- ハンズズオン 残り全て
### ハンズオン概要
- 環境準備
--　事前に準備したカリキュラムを使う  
- MySQL起動、ログイン、パスワード設定
- Database / Table / Insert … 各種作成
- 各種Query操作
- 応用編 (やれる方/自由課題)

## 1.雑談、フリーディスカッション 15min程度
本日参加した皆さんの状況を教えてください

### 「RDBMS」についてお聞きします
- 使った事ある (✋)
- RDBMSが好きで仕方ない (✋)

### SQL/Queryについてお聞きします
- 何となく知っている/聞いた事はある (✋)
- 常にパフォーマンスを意識してSQLを書いている (✋)

### RDBMSとその仲間についてお聞きします
- PostgreSQL、MySQLはいずれもRDBMSである (✋)
- MongoDBもRDBMSである (✋)

### さて、RDBMSってそもそも何？
- Database とは

  データベース（英: database, DB）とは、検索や蓄積が容易にできるよう整理された情報の集まり 　via Wikipedia 

- Relational とは

  「関係」とは果たして何と何との関係でしょう？

- 人事部がもしRDBMSをつかうとしたら？

  - 社員表(社員番号、指名、年齢、入社日、部門id、給与id)

  - 部門表(部門id、部門名、内線番号、所在地)

  - 給与表(給与id、給与額)

  この表とデータ構造において、何が適切(あるいは不適切か)を様々な視点/要件で捉え、データを使う側の状況応じて柔軟に

  ”関係モデル”を構築するのに適切な「データ保管庫」が ______
  
## 2.MySQL 環境整備

### MySQL 起動、ログイン、ユーザ作成
- MySQL起動まで CP#1
```
# docker run --name mysql8 -e MYSQL_ROOT_PASSWORD=password -d -p 3306:3306 mysql
ba2fd409099f51735be5fcbc1d3ee34406dd0f19793e017fee658c7b7e5ead39
[root@higadocker7jpwb shinichi]# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                               NAMES
ba2fd409099f        mysql               "docker-entrypoint..."   3 seconds ago       Up 2 seconds        0.0.0.0:3306->3306/tcp, 33060/tcp   mysql8
```
- MySQLへログイン, ユーザ作成　CP#2

  - bootcampユーザを作成、パスワードもbootcamp 
  - bootcampユーザにFULL ACCESS権限を付与
```
# docker exec -it mysql8 bash
bash-4.4# mysql -uroot -p
Enter password: 　<MySQLコンテナ起動時に指定したパスワード>

Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 11
Server version: 8.0.29 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> CREATE USER 'bootcamp'@'localhost' IDENTIFIED BY 'bootcamp';
Query OK, 0 rows affected (0.02 sec)

mysql> GRANT ALL PRIVILEGES ON * . * TO 'bootcamp'@'localhost';
Query OK, 0 rows affected, 1 warning (0.01 sec)

mysql> exit
Bye
bash-4.4# exit
```
### DATABASE作成 CP#3
- nginx という名前のDatabaseを作成します
- 以後はbootcampユーザでコンテナの外から実行
```
# docker exec -it mysql8 mysql -u bootcamp -p -e"create database nginx;"
Enter password: 
# docker exec -it mysql8 mysql -u bootcamp -p -e"show databases;"
Enter password: 
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| nginx              |
| performance_schema |
| sys                |
+--------------------+

# docker exec -it mysql8 mysql -u bootcamp -p -e"select * from INFORMATION_SCHEMA.SCHEMATA;"
Enter password: 
+--------------+--------------------+----------------------------+------------------------+----------+--------------------+
| CATALOG_NAME | SCHEMA_NAME        | DEFAULT_CHARACTER_SET_NAME | DEFAULT_COLLATION_NAME | SQL_PATH | DEFAULT_ENCRYPTION |
+--------------+--------------------+----------------------------+------------------------+----------+--------------------+
| def          | mysql              | utf8mb4                    | utf8mb4_0900_ai_ci     |     NULL | NO                 |
| def          | information_schema | utf8mb3                    | utf8_general_ci        |     NULL | NO                 |
| def          | performance_schema | utf8mb4                    | utf8mb4_0900_ai_ci     |     NULL | NO                 |
| def          | sys                | utf8mb4                    | utf8mb4_0900_ai_ci     |     NULL | NO                 |
| def          | nginx              | utf8mb4                    | utf8mb4_0900_ai_ci     |     NULL | NO                 |
+--------------+--------------------+----------------------------+------------------------+----------+--------------------+
```

### カリキュラム用RepositoryをClone CP#4
- Proxy設定を確認の上、下記のURLへアクセス
```
$ env |grep proxy
http_proxy=http://proxy.iiji.jp:8080/
https_proxy=http://proxy.iiji.jp:8080/

$ git clone https://gh.iiji.jp/s-fukuda/bootcamp_mysql.git
$ cd bootcamp_mysql
```
- Group 会社の方は、下記のURLへアクセス
```
$ git clone https://github.com/isfukuda/bootcamp_mysql.git
```
## 3. ハンズオン「IPアドレスを収容する最適なデータ型はvarcharか、intか」 
- ハンズオン実施に際して前提となる条件のまとめ
  - MySQL8 Docker imageを利用する
  - MySQLはデフォルト設定とする
  - サンプルデータ(アクセスログ 100,000件)を事前に用意、これを定義の異なる2つのTableへデータ投入する
    - 上記ログにはIPアドレスが含まれる。一方のTableはIPアドレスを varchar型とする
    - もう一方のTableはIPアドレスを int型とする
  - ぞれぞれのTableに対し「重複するIPアドレスを抽出する」同一のクエリを実行する
### 3.1 varchar型
- IPアドレスを varchar型と定義したTableを作成、サンプルデータをLoadする
  - Q.Tableにデータを追加する命令は？
```
// file copy to Container
# ls 
crate_table_kimetsu.sql  create_table_iplist_char.sql  create_table_iplist_int.sql  create_table_sushi.sql  insert_kimetsu.sql  insert_sushi.sql  load_data_iplist.sql  sample_100k.tsv

# docker cp sample_100k.tsv mysql8:/tmp

//  load file用おまじまい //
# docker exec -it mysql8 mysql -u bootcamp -p nginx -e"SET PERSIST local_infile= 1;"
Enter password: 
# docker exec -it mysql8 mysql -u bootcamp -p nginx -e"SELECT @@local_infile;"
Enter password: 
+----------------+
| @@local_infile |
+----------------+
|              1 |
+----------------+

# docker exec -it mysql8 mysql -u bootcamp -p nginx -e"$(cat create_table_iplist_char.sql);"
Enter password: 

# docker exec -it mysql8 mysql -u bootcamp -p nginx -e"show tables;"
Enter password: 
+-----------------+
| Tables_in_nginx |
+-----------------+
| ip_addr_char    |
+-----------------+

```
- Smaple_100k , load to varchar
```
# docker exec -it mysql8 mysql -u bootcamp -p --local_infile=1 nginx -e"$(cat load_data_iplist.sql);"
Enter password: 

# docker exec -it mysql8 mysql -u bootcamp -p nginx -e"select count(*) from ip_addr_char;"
Enter password: 
+----------+
| count(*) |
+----------+
|   100000 |
+----------+
```
### 3.2 int型
- IPアドレスをint型で定義したTableを別に作成する
- varchar型の時はLoadコマンドを使いましたが、今回はINSERT文を実行します
```
# docker exec -it mysql8 mysql -u bootcamp -p nginx -e"$(cat create_table_iplist_int.sql);"
Enter password: 

#  docker exec -it mysql8 mysql -u bootcamp -p nginx -e"show tables;"
Enter password: 
+-----------------+
| Tables_in_nginx |
+-----------------+
| ip_addr_char    |
| ip_addr_int     |
+----------+
```
- Insert data to int table from char table
```
# docker exec -it mysql8 mysql -u bootcamp -p --local_infile=1 nginx -e"$(cat insert_iplist_int.sql);"
Enter password: 

# docker exec -it mysql8 mysql -u bootcamp -p nginx -e"select count(*) from ip_addr_int;"
Enter password: 
+----------+
| count(*) |
+----------+
|   100000 |
+----------+
```
### 3.3 型の異なるTableへSELECTを実行する
- それぞれのTableへ重複行を調べるQueryを投げてその違い/結果を見ます
- 今回のサンプルデータには意図して重複データを忍ばせてあります
```
# docker exec -it mysql8 bash
bash-4.4# mysql -h localhost -uroot -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 13
Server version: 8.0.29 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
mysql> use nginx
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables
    -> ;
+-----------------+
| Tables_in_nginx |
+-----------------+
| ip_addr_char    |
| ip_addr_int     |
+-----------------+

// まずはvarchar型のTable
mysql> select host,count(host) from ip_addr_char GROUP BY host HAVING COUNT(host) > 1;
+----------------+-------------+
| host           | count(host) |
+----------------+-------------+
| 196.161.227.49 |           2 |
+----------------+-------------+
1 row in set (0.66 sec)

// 次にint型のTable
mysql> select host,count(host) from ip_addr_int GROUP BY host HAVING COUNT(host) > 1;
+------------+-------------+
| host       | count(host) |
+------------+-------------+
| 3298943793 |           2 |
+------------+-------------+
1 row in set (0.18 sec)
```

### 3.4 Query実行結果について調査
- profileingを行い、その内容から推定原因を探る
```
// おまじない
mysql> SET profiling=1;
mysql> select host,count(host) from ip_addr_char GROUP BY host HAVING COUNT(host) > 1;
+----------------+-------------+
| host           | count(host) |
+----------------+-------------+
| 196.161.227.49 |           2 |
+----------------+-------------+
1 row in set (0.59 sec)

mysql> SHOW PROFILE;
+--------------------------------+----------+
| Status                         | Duration |
+--------------------------------+----------+
| starting                       | 0.000108 |
| Executing hook on transaction  | 0.000026 |
| starting                       | 0.000011 |
| checking permissions           | 0.000013 |
| Opening tables                 | 0.000059 |
| init                           | 0.000008 |
| System lock                    | 0.000012 |
| optimizing                     | 0.000013 |
| statistics                     | 0.000020 |
| preparing                      | 0.000018 |
| Creating tmp table             | 0.000054 |
| executing                      | 0.123630 |
| converting HEAP to ondisk      | 0.309585 |
| executing                      | 0.156658 |
| end                            | 0.000024 |
| query end                      | 0.000020 |
| waiting for handler commit     | 0.000393 |
| closing tables                 | 0.000015 |
| freeing items                  | 0.000031 |
| cleaning up                    | 0.000012 |
+--------------------------------+----------+
20 rows in set, 1 warning (0.00 sec)

// int型
mysql> select host,count(host) from ip_addr_int GROUP BY host HAVING COUNT(host) > 1;
+------------+-------------+
| host       | count(host) |
+------------+-------------+
| 3298943793 |           2 |
+------------+-------------+
1 row in set (0.10 sec)

mysql> SHOW PROFILE;
+--------------------------------+----------+
| Status                         | Duration |
+--------------------------------+----------+
| starting                       | 0.000094 |
| Executing hook on transaction  | 0.000007 |
| starting                       | 0.000010 |
| checking permissions           | 0.000009 |
| Opening tables                 | 0.000062 |
| init                           | 0.000008 |
| System lock                    | 0.000012 |
| optimizing                     | 0.000011 |
| statistics                     | 0.000016 |
| preparing                      | 0.000014 |
| Creating tmp table             | 0.000044 |
| executing                      | 0.101680 |
| end                            | 0.000025 |
| query end                      | 0.000009 |
| waiting for handler commit     | 0.003774 |
| closing tables                 | 0.000025 |
| freeing items                  | 0.000033 |
| cleaning up                    | 0.000014 |
+--------------------------------+----------+
18 rows in set, 1 warning (0.00 sec)
```
## 4. ハンズオン[3]の結果から得る考察及び対応策/対応方針を考えましょう
- 参加された方々のそれぞれの立場で最適なアクションはどれでしょうか？
### 4.1 アプリケーション開発者として
- 選択肢
  - a.　Query実装要件からIPアドレスはint型で良いと判断できるので、採用する
  - b.　想定したデータ量及び、SELECT文に見合ったリソースでは無い事を調査、再見積もりを行いDBAと対応策を検討、実装する
  - c.　一時Tableを消費してしまうGROUP BY句では無いSQLに書き換えて限られたリソース内でクエリパフォーマンスを上げる
  - d.　MySQLのパフォーマンスが根本問題なので、今すぐ直せと指示を出す
  - e.　その他
 
### 4.2 DBA（DATABASE管理者）として
- 選択肢
  - a.　闇雲にSELECT文を発行してリソースを食い潰すアプリケーション開発者側へ改修依頼だけを行う
  - b.　heap to diskの原因をアプリケーション開発チームと共有し、SQL改修の検討を含め共同で改修に着手する
  - c.　Heap領域の最適解を実行結果から再見積もり、検証、実証してから新MySQLインスタンスをアプリケーションチームへ提供する
  - d.　MySQLの利用を止めて、その他のRDBMSエンジンを採用する様にProjectマネージャーに進言する
  - e.　MySQLをForkして、ip型をスクラッチで実装する
  - d.　その他
  
## 5. 本日のまとめ
MySQLに触れてみて
- MySQLサーバ環境準備
  docker/docker-composeを使いMySQLサーバ構築を簡略化させてもらいました。MySQL on dockerについては考慮すべきことが多々あります
  この点は頭の片隅に必ず置いて覚えておいて下さい
- 基本的なDatabase操作を経験
  データベースへのアクセスにはmysqlクライアントを使い、基本的な知識抜きに「実践形式」でデータベースオブジェクトを作成、Queryを実行しました
  なお、アプリケーション技術者を目指す方は別途、開発言語/Database Driver経由でデータベースの操作を行う事をお勧めします
- 本日触れなかった事
　　　　- データベース要件に合わせた論理設計、物理設計、運用設計等々全
  - MySQLサーバ初期構築から、rootログインとその後のDatabaseユーザ管理はしっかりと設計と実装が別途必須です
  - MySQLサーバ設定については一切触れていません、ご了承ください
  - 今回の講義ではINDEXあ有効な手段であるかは触れていません。
　　　　　　　　利用するデータ、Query、条件などによって変わります。とても深い内容につき割愛しています

## 参考資料

- [MySQL 8.0 リファレンスマニュアル](https://dev.mysql.com/doc/refman/8.0/ja/)
- [MySQLパフォーマンスチューニング概要](https://www.oracle.com/technetwork/jp/ondemand/database/mysql/mysql-perftun-1484759-ja.pdf)
- [MySQL 8.0の新機能](https://www.mysql.com/jp/why-mysql/white-papers/whats-new-mysql-8-0-jp/)

<credit-footer/>
