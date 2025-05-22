/* Проект «Секреты Тёмнолесья»
 * Цель проекта: изучить влияние характеристик игроков и их игровых персонажей 
 * на покупку внутриигровой валюты «райские лепестки», а также оценить 
 * активность игроков при совершении внутриигровых покупок
 * 
 * Автор: Ложникова Елена 
 * Дата: 16.12.2024 
*/


--1. Разведочный анализ данных

--1.1. Выведите названия всех таблиц схемы fantasy
--
SELECT table_name
FROM information_schema.tables
WHERE table_schema= 'fantasy';


--table_name|
------------+
--classes   |
--country   |
--events    |
--items     |
--race      |
--skills    |
--users     |

--Схема fantasy содержит семь таблиц: classes, country, users, events, items, skills, race. В них собрана основная информация об игроках и их активности.


--1.2. Получите информацию о названии полей таблицы users и типе данных в них, а также присоедините информацию о первичных и внешних ключах.
--
SELECT c.table_schema,
       c.table_name,
       c.column_name,
       c.data_type,
       k.constraint_name
FROM information_schema.columns AS c
LEFT JOIN information_schema.key_column_usage AS k on c.table_schema = k.table_schema AND c.table_name = k.table_name AND c.column_name = k.column_name
WHERE c.table_schema = 'fantasy' AND c.table_name = 'users'; 

--table_schema|table_name|column_name    |data_type        |constraint_name    |
--------------+----------+---------------+-----------------+-------------------+
--fantasy     |users     |id             |character varying|users_pkey         |
--fantasy     |users     |tech_nickname  |character varying|                   |
--fantasy     |users     |class_id       |character varying|users_class_id_fkey|
--fantasy     |users     |ch_id          |character varying|users_ch_id_fkey   |
--fantasy     |users     |birthdate      |character varying|                   |
--fantasy     |users     |pers_gender    |character varying|                   |
--fantasy     |users     |registration_dt|character varying|                   |
--fantasy     |users     |server         |character varying|                   |
--fantasy     |users     |race_id        |character varying|users_race_id_fkey |
--fantasy     |users     |payer          |integer          |                   |
--fantasy     |users     |loc_id         |character varying|users_loc_id_fkey  |

--Таблица users содержит 11 полей, и большинство из них хранят текстовые данные. При этом поле id с идентификатором игрока — это первичный ключ таблицы, 
--а четыре поля class_id, ch_id, race_id и loc_id — внешние ключи. Можно предположить, что таблица users связана с таблицами classes, skills, race и country.



--1.3. Познакомьтесь с данными — выведите первые пять строк таблицы users. При этом в выдачу добавьте поле row_count с подсчётом общего количества строк в таблице.
--
SELECT *, 
(SELECT COUNT (*) FROM fantasy.users) AS row_count
FROM fantasy.users
LIMIT 5;

--id        |tech_nickname      |class_id|ch_id|birthdate|pers_gender|registration_dt|server  |race_id|payer|loc_id|row_count|
------------+-------------------+--------+-----+---------+-----------+---------------+--------+-------+-----+------+---------+
--00-0037846|DivineBarbarian4154|9RD     |JJR2 |6/4/1994 |Male       |1/20/2005      |server_1|B1     |    0|US    |    22214|
--00-0041533|BoldInvoker7693    |Z3Q     |HQ9N |6/29/1987|Male       |4/8/2022       |server_1|R2     |    0|US    |    22214|
--00-0045747|NobleAlchemist7633 |382     |IXBW |7/29/1992|Male       |10/12/2013     |server_1|K3     |    0|US    |    22214|
--00-0055274|SteadfastArcher8318|ZD0     |QSUB |9/14/1985|Female     |4/10/2008      |server_1|R2     |    0|US    |    22214|
--00-0076100|RadiantProphet353  |YC8     |HQ9N |4/11/1997|Female     |9/29/2013      |server_2|K4     |    1|US    |    22214|

--Теперь можно зафиксировать содержимое строк и отметить возможные сложности, например формат представления даты. Всего данные содержат информацию о 22214 игроках.



--1.4. Проверьте пропуски в полях, которые понадобятся при анализе: class_id, ch_id, pers_gender, server, race_id, payer, loc_id.
--
SELECT COUNT (*)
FROM fantasy.users
WHERE class_id IS NULL OR ch_id IS NULL OR pers_gender IS NULL OR server IS NULL OR race_id IS NULL OR  payer IS NULL OR loc_id IS NULL;

--count|
-------+
--    0|

--Пропусков данных нет.



--1.5. Таблица users содержит информацию об игроках. В данных можно выделить такие категории: 
--характеристика персонажа, его пол, класс, легендарный навык, а также страна регистрации игрока или игровой сервер.
--Выведите уникальные значения в поле server таблицы users и для каждого сервера найдите количество строк.
--
SELECT DISTINCT server,
       COUNT (*)
FROM fantasy.users
GROUP BY SERVER;

--server  |count|
----------+-----+
--server_1|16715|
--server_2| 5499|

--Игрокам доступно два сервера. При этом на первом сервере примерно в три раза больше игроков, чем на втором.



--1.6. Вторая таблица, с которой вам нужно поработать, — это таблица с информацией о внутриигровых покупках events. 
--Изучите её более внимательно, как это делали с таблицей users.
--Выведите названия всех полей, их тип данных и информацию о ключевых полях таблицы events.
--
-- Выводим названия полей, их тип данных и метку о ключевом поле таблицы events
SELECT c.table_schema,
       c.table_name,
       c.column_name,
       c.data_type,
       k.constraint_name
FROM information_schema.columns AS c 
-- Присоединяем данные с ограничениями полей
LEFT JOIN information_schema.key_column_usage AS k 
    USING(table_name, column_name, table_schema)
-- Фильтруем результат по названию схемы и таблицы
WHERE c.table_schema='fantasy' AND c.table_name='events'-- Напишите критерии фильтрации данных здесь
ORDER BY c.table_name;

--table_schema|table_name|column_name   |data_type        |constraint_name      |
--------------+----------+--------------+-----------------+---------------------+
--fantasy     |events    |transaction_id|character varying|events_pkey          |
--fantasy     |events    |id            |character varying|events_id_fkey       |
--fantasy     |events    |date          |character varying|                     |
--fantasy     |events    |time          |character varying|                     |
--fantasy     |events    |item_code     |integer          |events_item_code_fkey|
--fantasy     |events    |amount        |real             |                     |
--fantasy     |events    |seller_id     |character varying|                     |

--Таблица events содержит семь полей, и большинство из них хранит текстовые данные. 
--При этом поле transaction_id с идентификатором транзакции — это первичный ключ таблицы, а два поля id и item_code — внешние ключи, связывающие данные с таблицами users и items.
--Тип данных у полей с датой date и временем time — character varying, а это не совсем корректно. Эту особенность нужно учитывать при работе с датой и временем.



--1.7. Выведите первые пять строк таблицы events. При этом в выдачу добавьте поле row_count с подсчётом общего количества строк в таблице, как делали при изучении таблицы users.
--
SELECT *,
(SELECT COUNT(*) FROM fantasy.events) AS row_count
FROM fantasy.events
LIMIT 5;

--transaction_id|id        |date      |time    |item_code|amount|seller_id|row_count|
----------------+----------+----------+--------+---------+------+---------+---------+
--2129235853    |37-5938126|2021-01-03|16:31:49|     6010| 21.41|220381   |  1307678|
--2129237617    |37-5938126|2021-01-03|16:49:00|     6010| 64.98|54680    |  1307678|
--2129239381    |37-5938126|2021-01-03|21:05:29|     6010| 50.68|888909   |  1307678|
--2129241145    |37-5938126|2021-01-03|22:03:02|     6010| 46.49|888902   |  1307678|
--2129242909    |37-5938126|2021-01-03|22:04:26|     6010| 18.72|888905   |  1307678|

--Игроки совершили больше миллиона внутриигровых покупок — есть что анализировать. 
--id продавца отличается по структуре от id игрока. Видимо, для продажи эпических предметов игрок должен зарегистрироваться как продавец.



--1.8. Проверьте данные в таблице events на возможные ошибки и начните с пропусков. 
--Напишите запрос и найдите количество строк с пропусками в полях, которые будут использоваться при анализе: date, time, amount, seller_id.
--
SELECT COUNT (*)
FROM fantasy.events
WHERE date IS NULL OR time IS NULL OR amount IS NULL OR seller_id IS NULL;

--count |
--------+
--508186|

--В 508186 строках из 1307678 встречаются пропуски хотя бы в одном из полей. Теперь можно проверить, что это за поля.



--1.9. Теперь детально изучите строки с пропусками в каждом из полей — это поможет узнать количество пропущенных значений в каждом столбце. 
--Выведите количество данных в каждом из полей date, time, amount, seller_id. 
--
-- Считаем количество строк с данными в каждом поле
SELECT COUNT (date) AS t1,
  COUNT (time) AS t2,
  COUNT (amount) AS t3,
  COUNT (seller_id) AS t14-- Напишите ваш код здесь
FROM fantasy.events
WHERE date IS NULL
  OR time IS NULL
  OR amount IS NULL
  OR seller_id IS NULL;
 
 --t1    |t2    |t3    |t14|
---------+------+------+---+
---508186|508186|508186|  0|
 
--Все 508186 пропусков содержатся только в поле seller_id, то есть в данных нет информации о продавце. 
--Видимо, в таком случае покупка совершалась в игровом магазине, а не у других продавцов.



-- Часть 2. Исследовательский анализ данных
-- Задача 1. Исследование доли платящих игроков

-- 2.1.1. Доля платящих пользователей по всем данным:
-- 
SELECT COUNT(id) AS count_users, -- общее количество игроков, зарегистрированных в игре;
       (SELECT COUNT(payer) FROM fantasy.users WHERE payer=1) AS count_payer, -- количество платящих игроков;
       ROUND(AVG (payer), 4) AS share_payer -- доля платящих игроков от общего количества пользователей, зарегистрированных в игре.
FROM fantasy.users;


--сount_users|count_payer|share_payer|
-------------+-----------+-----------+
---     22214|       3929|     0.1769|




-- 2.1.2. Доля платящих пользователей в разрезе расы персонажа:
-- найдем общее кол-во игроков
WITH count_total AS 
      (SELECT race,
      COUNT (payer) AS count_total 
      FROM fantasy.users AS u 
      LEFT JOIN fantasy.race AS r ON u.race_id = r.race_id 
      GROUP BY race),
--найдем кол-во платящих игроков в разрезе расы        
count_payer_users AS 
      (SELECT race,
      COUNT(payer) AS count_payer_users 
      FROM fantasy.users AS u 
      LEFT JOIN fantasy.race AS r USING (race_id)
      WHERE payer=1 
      GROUP BY race) 
SELECT ct.race,
       ct.count_total,
       ROUND((SELECT count_total::numeric/COUNT(id) FROM fantasy.users), 4) AS share_race_users, --доли игроков в сегменте от общего количества игроков
cpu.count_payer_users,
       ROUND((count_payer_users::numeric/count_total), 4) AS share_payer_users  -- доля платящих игроков от общего количества пользователей, зарегистрированных в игре в разрезе расы 
FROM count_total AS ct 
JOIN count_payer_users AS cpu USING (race);


--race    |count_total|share_race_users|count_payer_users|share_payer_users|
---------+-----------+----------------+-----------------+-----------------+
--Angel   |       1327|          0.0597|              229|           0.1726|
--Elf     |       2501|          0.1126|              427|           0.1707|
--Demon   |       1229|          0.0553|              238|           0.1937|
--Orc     |       3619|          0.1629|              636|           0.1757|
--Human   |       6328|          0.2849|             1114|           0.1760|
--Northman|       3562|          0.1603|              626|           0.1757|
--Hobbit  |       3648|          0.1642|              659|           0.1806|



      
-- Задача 2. Исследование внутриигровых покупок
-- 2.2.1. Статистические показатели по полю amount:
 SELECT COUNT(amount) AS count_amount, --общее количество покупок;
        SUM (amount) AS  sum_amount, --общая стоимость всех покупок;
        MIN (amount) AS  min_amount,  
        CEIL(MAX (amount)) AS  max_amount, 
        CEIL(AVG (amount)) AS avg_amount, --среднее значение покупок
        (SELECT PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY amount) FROM fantasy.events) AS med_amount,--медианa
        ROUND(STDDEV (amount::numeric), 4) AS stand_dev --стандартное отклонение стоимости покупки
 FROM fantasy.events;


--count_amount|sum_amount|min_amount|max_amount|avg_amount|med_amount|stand_dev|
-------------+----------+----------+----------+----------+----------+---------+
---    1307678| 686615040|       0.0|  486616.0|     526.0|     74.86|2517.3464|




-- 2.2.2.: Аномальные нулевые покупки:
WITH tab1 AS
    (SELECT COUNT(amount) AS count_amount ,
            (SELECT COUNT(amount) FROM fantasy.events WHERE amount=0) AS null_amount
     FROM fantasy.events)     
SELECT count_amount,
       null_amount,
       null_amount::float/count_amount AS share_null_amount --доля нулевых покупок от общего числа покупок
FROM tab1; 


--count_amount|null_amount|share_null_amount |
--------------+-----------+------------------+
--     1307678|        907|0.0006935958240484|




-- 2.2.3: Сравнительный анализ активности платящих и не платящих игроков:
WITH tab1 AS
    (SELECT payer,
            COUNT (DISTINCT u.id) AS count_users,
            COUNT (amount) AS count_amount,
            SUM (amount) AS sum_amount
     FROM fantasy.events AS e
            LEFT JOIN fantasy.users AS u USING (id)
            WHERE amount>0
            GROUP BY payer)
SELECT CASE WHEN payer = 1 THEN 'Платящий' ELSE 'Неплатящий' END AS payer, 
       count_users,
       count_amount,
       CEIL (count_amount::REAL/count_users) AS avg_count_payer, --среднее количество покупок 
       CEIL (sum_amount/count_users) AS avg_sum --средняя суммарная стоимость покупок на одного игрока
FROM tab1;

--payer     |count_users|count_amount|avg_count_payer|avg_sum|
------------+-----------+------------+---------------+-------+
--Неплатящий|      11348|     1107145|           98.0|48589.0|
--Платящий  |       2444|      199626|           82.0|55468.0|


    

-- Изучите популярность эпических предметов. 
--Для каждого предмета посчитайте общее количество внутриигровых продаж в абсолютном и относительном значениях. 
--Относительное значение должно быть долей продажи каждого предмета от всех продаж. 
--Найдите также долю игроков, которые хотя бы раз покупали этот предмет. 
--Результат отфильтруйте по популярности эпического предмета среди игроков.
-- 2.2.4: Популярные эпические предметы:
-- 
 WITH tab1 AS
     (SELECT
     COUNT(DISTINCT e.id) AS total_users, 
     COUNT (transaction_id) AS total_orders
FROM fantasy.events AS e
WHERE amount>0) 
SELECT
      i.game_items AS game_items,
      COUNT (transaction_id) AS total_orders,
      (COUNT(e.transaction_id)::real / (SELECT total_orders FROM tab1)*100)::numeric(6,4) AS otn_amount, -- доля продажи каждого предмета от всех продаж
      (COUNT(DISTINCT e.id)::real / (SELECT total_users FROM tab1)*100)::numeric(6,4) AS share_player -- доля игроков, которая хотя бы раз купила магический предмет
FROM fantasy.events AS e
LEFT JOIN fantasy.items AS i USING (item_code)
WHERE amount>0
GROUP BY game_items
ORDER BY total_orders DESC;

--game_items               |total_orders|otn_amount|share_player|
---------------------------+------------+----------+------------+
--Book of Legends          |     1004516|   76.8701|     88.4136|
--Bag of Holding           |      271875|   20.8051|     86.7749|
--Necklace of Wisdom       |       13828|    1.0582|     11.7967|
--Gems of Insight          |        3833|    0.2933|      6.7140|
--Treasure Map             |        3183|    0.2436|      5.9382|
--Amulet of Protection     |        1078|    0.0825|      3.2265|
--Silver Flask             |         795|    0.0608|      4.5896|
--Strength Elixir          |         580|    0.0444|      2.3999|
--Glowing Pendant          |         563|    0.0431|      2.5667|
--Gauntlets of Might       |         514|    0.0393|      2.0374|
--Sea Serpent Scale        |         458|    0.0350|      0.4278|
--Ring of Wisdom           |         379|    0.0290|      2.2477|
--Potion of Speed          |         375|    0.0287|      1.6749|
--Magic Ornament           |         282|    0.0216|      0.8193|
--Ring of Invisibility     |         252|    0.0193|      1.3341|
--Magical Lantern          |         247|    0.0189|      0.7396|
--Herbs for Potions        |         241|    0.0184|      1.0731|
--Potion of Acceleration   |         230|    0.0176|      1.3051|
--Feather of Writing       |         222|    0.0170|      1.1166|
--Enemy Traps              |         168|    0.0129|      0.6816|
--Time Artifact            |         168|    0.0129|      1.0731|
--Scroll of Magic          |         162|    0.0124|      0.8483|
--Monster Compendium       |         151|    0.0116|      1.0006|
--Water of Life            |         142|    0.0109|      0.8846|
--Pegasus Feather          |         138|    0.0106|      0.1885|
--Trap Chest               |         137|    0.0105|      0.8701|
--Magic Key                |         127|    0.0097|      0.5873|
--Dungeon Map              |         108|    0.0083|      0.5365|
--Runes of Power           |         106|    0.0081|      0.5293|
--Antidote Potion          |          89|    0.0068|      0.3408|
--Robe of the Magi         |          85|    0.0065|      0.5800|
--Druid's Staff            |          83|    0.0064|      0.4423|
--Mystic Compass           |          83|    0.0064|      0.3915|
--Magic Dust               |          82|    0.0063|      0.5220|
--Treasure Box             |          79|    0.0060|      0.3335|
--Boots of Levitation      |          73|    0.0056|      0.3988|
--Chimera Scale            |          67|    0.0051|      0.3988|
--Enhanced Weapon          |          60|    0.0046|      0.2973|
--Helm of Insight          |          57|    0.0044|      0.2320|
--Phoenix Feather          |          56|    0.0043|      0.1378|
--Orb of Time              |          56|    0.0043|      0.2828|
--Potion of Intelligence   |          50|    0.0038|      0.3408|
--Scroll of Summoning      |          49|    0.0037|      0.2683|
--Orc Tusk                 |          45|    0.0034|      0.2538|
--Quiver of Endless Arrows |          45|    0.0034|      0.1378|
--Elf Ears                 |          44|    0.0034|      0.2828|
--Shield of Valor          |          38|    0.0029|      0.2030|
--Succubus Kiss            |          35|    0.0027|      0.1813|
--Potion of Fortitude      |          31|    0.0024|      0.2030|
--Boots of Swiftness       |          29|    0.0022|      0.1740|
--Potion of Transformation |          28|    0.0021|      0.1595|
--Scroll of Resurrection   |          27|    0.0021|      0.1523|
--Transformation Potion    |          26|    0.0020|      0.1740|
--Pendant of Healing       |          25|    0.0019|      0.1595|
--Medallion of Magic       |          24|    0.0018|      0.1378|
--Fire Resistance Potion   |          22|    0.0017|      0.1088|
--Fairy Dust               |          21|    0.0016|      0.0943|
--Mirror of Divination     |          21|    0.0016|      0.1378|
--Armor of Magic Resistance|          21|    0.0016|      0.1523|
--Potion of Regeneration   |          20|    0.0015|      0.1233|
--Nature's Strength Potion |          20|    0.0015|      0.1305|
--Enchanter's Amulet       |          19|    0.0015|      0.1378|
--Crown of Kings           |          18|    0.0014|      0.1305|
--Cloak of Shadows         |          15|    0.0011|      0.1088|
--Dragon Cart              |          15|    0.0011|      0.0798|
--Shield of Protection     |          14|    0.0011|      0.1015|
--Potion of Light          |          13|    0.0010|      0.0798|
--Kraken Ink               |          13|    0.0010|      0.0798|
--Invisibility Potion      |          12|    0.0009|      0.0725|
--Stone of Power           |          12|    0.0009|      0.0798|
--Wyvern Claw              |          11|    0.0008|      0.0435|
--Magic Animal             |          11|    0.0008|      0.0725|
--Hydra Tooth              |          10|    0.0008|      0.0653|
--Defender's Guard         |          10|    0.0008|      0.0508|
--Traveler's Supplies      |          10|    0.0008|      0.0435|
--Vampire Fang             |          10|    0.0008|      0.0580|
--Potion of Wisdom         |           9|    0.0007|      0.0580|
--Protective Cloak         |           9|    0.0007|      0.0435|
--Staff of Flames          |           9|    0.0007|      0.0580|
--Potion of Darkness       |           8|    0.0006|      0.0508|
--Ancient Artifact         |           8|    0.0006|      0.0290|
--Unicorn Horn             |           8|    0.0006|      0.0290|
--Ethereal Horse           |           7|    0.0005|      0.0435|
--Weapon Oil               |           7|    0.0005|      0.0290|
--Mystic Bracelets         |           6|    0.0005|      0.0363|
--Book of Spells           |           6|    0.0005|      0.0363|
--Book of Curses           |           6|    0.0005|      0.0363|
--Amulet of Time           |           6|    0.0005|      0.0435|
--Griffin Feather          |           6|    0.0005|      0.0290|
--Luminescent Gem          |           6|    0.0005|      0.0363|
--Sorcerer's Stone         |           5|    0.0004|      0.0363|
--Magic Sand               |           5|    0.0004|      0.0145|
--Potion of Clarity        |           5|    0.0004|      0.0290|
--Shovel of Secrets        |           5|    0.0004|      0.0290|
--Silver Talons            |           5|    0.0004|      0.0363|
--Weapon Decoration        |           5|    0.0004|      0.0290|
--Ring of Strength         |           4|    0.0003|      0.0218|
--Talisman of Luck         |           4|    0.0003|      0.0145|
--Healer's Kit             |           4|    0.0003|      0.0290|
--Diviner's Tarot Deck     |           4|    0.0003|      0.0218|
--Wand of Lightning        |           4|    0.0003|      0.0290|
--Crystal of Wisdom        |           4|    0.0003|      0.0218|
--Magic Orb                |           4|    0.0003|      0.0290|
--Prophet's Scroll         |           4|    0.0003|      0.0290|
--Gold Coins               |           4|    0.0003|      0.0290|
--Cleansing Potion         |           3|    0.0002|      0.0145|
--Quill of Enchantment     |           3|    0.0002|      0.0145|
--Compass of Truth         |           3|    0.0002|      0.0073|
--Ring of Regeneration     |           3|    0.0002|      0.0218|
--Boots of Haste           |           3|    0.0002|      0.0218|
--Flask of Endless Water   |           3|    0.0002|      0.0218|
--Cloak of Invisibility    |           2|    0.0002|      0.0145|
--Paladin's Hammer         |           2|    0.0002|      0.0145|
--Mystic's Rune Stones     |           2|    0.0002|      0.0145|
--Necromancer's Wand       |           2|    0.0002|      0.0145|
--Medusa's Snake           |           2|    0.0002|      0.0145|
--Warlock's Grimoire       |           2|    0.0002|      0.0145|




-- Часть 3. Решение ad hoc-задач
-- Задача 1. Зависимость активности игроков от расы персонажа:
--общее количество зарегистрированных игроков;
--количество игроков, которые совершают внутриигровые покупки, и их доля от общего количества;
--доля платящих игроков от количества игроков, которые совершили покупки;
--среднее количество покупок на одного игрока;
--средняя стоимость одной покупки на одного игрока;
--средняя суммарная стоимость всех покупок на одного игрока.
--
  WITH gamers_stat AS
(SELECT race,
        COUNT(u.id) AS count_players
FROM fantasy.users AS u
LEFT JOIN fantasy.race AS r USING (race_id)
GROUP BY race),
  events_stat AS 
(SELECT race,
        u.payer AS payer,
        e.id AS user_id,
        COUNT(e.transaction_id) AS count_orders, 
        SUM(e.amount) AS total_amount 
 FROM fantasy.events AS e
 LEFT JOIN fantasy.users AS u USING (id)
 LEFT JOIN fantasy.race AS r USING (race_id)
 WHERE e.amount>0
 GROUP BY race,u.payer, e.id),
   total_stat AS
 (SELECT race,
         COUNT(count_orders) AS count_amount, 
         SUM(total_amount) AS sum_orders,
         AVG(payer) AS avg_purch_one_payer,  
         AVG(count_orders::real) AS avg_sum_amount_one_player, 
         AVG(total_amount) AS avg_amount_one_player,
         SUM(total_amount)/SUM(count_orders) AS avg_total_purch_sum 
 FROM events_stat AS es
 GROUP BY race) 
 SELECT gs.race,
        count_players,
        count_amount,
        ROUND((count_amount::numeric/count_players), 4) AS users_purch_share, --доля игроков, совершивших внутриигровые покупки от общего количества
        ROUND(avg_purch_one_payer, 4) AS payers_purch_share, --доля платящих игроков, совершивших покупки от общего количества игроков, совершивших покупки
        ROUND(avg_sum_amount_one_player::numeric, 4) AS avg_count_purch_one_player, --среднее количество покупок на одного игрока
        ROUND(avg_amount_one_player::numeric, 4) AS avg_totalsum_one_player, --средняя суммарная стоимость всех покупок на одного игрока
        ROUND(avg_total_purch_sum::numeric, 4) AS avg_purch_sum_one_player  --средняя стоимость одной покупки на одного игрока
FROM total_stat AS u
LEFT JOIN gamers_stat AS gs USING (race)
ORDER BY gs.race;


--race    |count_players|count_amount|users_purch_share|payers_purch_share|avg_count_purch_one_player|avg_totalsum_one_player|avg_purch_sum_one_player|
----------+-------------+------------+-----------------+------------------+--------------------------+-----------------------+------------------------+
--Angel   |         1327|         820|           0.6179|            0.1671|                  106.8049|             48668.6537|                455.6781|
--Demon   |         1229|         737|           0.5997|            0.1995|                   77.8697|             41197.3796|                529.0550|
--Elf     |         2501|        1543|           0.6170|            0.1627|                   78.7907|             53761.6536|                682.3345|
--Hobbit  |         3648|        2266|           0.6212|            0.1770|                   86.1289|             47620.9231|                552.9031|
--Human   |         6328|        3921|           0.6196|            0.1801|                  121.4022|             48941.0099|                403.1318|
--Northman|         3562|        2229|           0.6258|            0.1821|                   82.1018|             62520.6593|                761.5006|
--Orc     |         3619|        2276|           0.6289|            0.1740|                   81.7381|             41760.0406|                510.8995|

