## Nivell 1
## Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, almenys 4 taules de les quals puguis realitzar les següents consultes:

CREATE DATABASE IF NOT EXISTS sprint4_db CHARACTER SET utf8mb4; 
USE sprint4_db;


## Creem les diferents taules de la BBDD:
## taula products
CREATE TABLE products (
    product_id VARCHAR (20) PRIMARY KEY,       
	product_name  VARCHAR(100),
    price VARCHAR(20), 
    colour VARCHAR(20),
    weight VARCHAR(20),
    warehouse_id VARCHAR(20)     
);

## taula users
CREATE TABLE IF NOT EXISTS users (
    id_user VARCHAR(20) PRIMARY KEY,
	name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(150),
    email VARCHAR(150),
    birth_date VARCHAR(50),
    country VARCHAR(150),
    city VARCHAR(150),
    postal_code VARCHAR(100),
    address VARCHAR(255)
   );
   

## Creem taula credit_cards
CREATE TABLE IF NOT EXISTS credit_cards  (
    id_credit_card VARCHAR(20) PRIMARY KEY,
    user_id VARCHAR(20),
    iban VARCHAR(34),
    pan VARCHAR(20),
    pin VARCHAR(4),
    cvv VARCHAR(3),
    track1 VARCHAR(255),
    track2 VARCHAR(255),
    expiring_date VARCHAR(20)
);

## creem la taula companies

CREATE TABLE IF NOT EXISTS companies (
 id_company VARCHAR(20) PRIMARY KEY,
 company_name VARCHAR(100),
 phone VARCHAR(25),
 email VARCHAR(100),
 country VARCHAR(50),
 website VARCHAR(100)
);


## creem la taula de transaccions
CREATE TABLE IF NOT EXISTS transactions (
	id_transaction VARCHAR(255) PRIMARY KEY,
	card_id VARCHAR(20),
    business_id VARCHAR(255),
    timestamp DATETIME,
    amount DECIMAL(10,2),
    declined BOOLEAN,
    product_ids VARCHAR(100), 
    user_id VARCHAR(20),
    lat FLOAT,
    longitude FLOAT
    );

-- habilitem en MYSQL la capacitat del servidor per importar fitxers en local.
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

## Carrega de dades a les taules
-- carreguem dades a taula products
LOAD DATA LOCAL INFILE 'C:/Users/jaume/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS
(product_id, product_name, @price, colour, weight, warehouse_id)
SET price = CAST(REPLACE(@price, '$', '') AS DECIMAL(10,2)); -- traiem el símbol del "$" en variable "price" i li assignem tipus decimal. La dada introduïda en @price és una variable temporal

-- Visualitzem les dades carregades
SELECT *
FROM products;


-- carreguem els dades dels fitxers american_users i european_users a taula users
LOAD DATA LOCAL INFILE 'C:/Users/jaume/american_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id_user, name, surname, phone, email, @birth_date, country, city, postal_code, address)
SET birth_date = STR_TO_DATE(@birth_date, '%b %e, %Y'); -- %b (mes en 3 lletres) i %e (dia d'un sol dígit);


LOAD DATA LOCAL INFILE 'C:/Users/jaume/european_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id_user, name, surname, phone, email, @birth_date, country, city, postal_code, address)
SET birth_date = STR_TO_DATE(@birth_date, '%b %e, %Y'); 


-- Visualitzem les dades carregades
SELECT *
FROM USERS;

-- carreguem les dades credit card
LOAD DATA LOCAL INFILE  'C:/Users/jaume/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Visualitzem les dades carregades
SELECT *
FROM credit_cards;

-- carreguem les dades a taula companies

LOAD DATA LOCAL INFILE  'C:/Users/jaume/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS; 
-- Visualitzem les dades carregades
SELECT *
FROM companies;


-- carreguem les dades a transactions
LOAD DATA LOCAL INFILE  'C:/Users/jaume/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'  
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Visualitzem les dades carregades
SELECT *
FROM transactions;


-- Afegim les relacions entre les taules a través de les FK. Les variables business_id, card_id i user_id de la taula transaccions les transformem en FK

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_credit_cards
FOREIGN KEY (card_id) 
REFERENCES credit_cards(id_credit_card); 

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_companies
FOREIGN KEY (business_id) 
REFERENCES companies (id_company); 

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_users
FOREIGN KEY (user_id)
REFERENCES users (id_user); 


## Exercici 1
## Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.


SELECT u.id_user, u.name, u.surname
FROM users u
WHERE EXISTS ( 
    SELECT 1 
    FROM transactions t 
    WHERE t.user_id = u.id_user AND t.declined =0
    GROUP BY t.user_id
    HAVING COUNT(t.id_transaction) > 80
);






## Exercici 2
## Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.
SELECT cc.iban, ROUND(AVG(t.amount), 2) AS mitjana_amount
FROM transactions t
INNER JOIN credit_cards cc ON t.card_id = cc.id_credit_card
INNER JOIN companies c ON t.business_id = c.id_company
WHERE c.company_name = 'Donec Ltd' AND t.declined = 0
GROUP BY cc.iban
ORDER BY mitjana_amount DESC;


## Nivell 2
## Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les tres últimes transaccions han estat declinades aleshores és inactiu, si almenys una no és rebutjada aleshores és actiu. Partint d’aquesta taula respon:
## Exercici 1
## Quantes targetes estan actives?


CREATE TABLE estat_targetes AS -- El contingut de la taula vindrà donat per la següent consulta
SELECT
    card_id,
    CASE
        WHEN SUM(CASE WHEN declined = 1 THEN 1 ELSE 0 END) = 3 THEN 'Inactiva' -- si dona 3 rebutjades posem en inactiva, sino la targeta serà activa
        ELSE 'Activa'
    END AS estat_targeta
FROM (
    SELECT
        t.card_id,
        t.declined,
        ROW_NUMBER() OVER (PARTITION BY t.card_id ORDER BY t.timestamp DESC) AS filtra_transacció -- Ordena les transaccions de cada targeta per data més recent
    FROM transactions t
) ultimes_transaccions
WHERE filtra_transacció  <= 3 -- ens quedem amb com a màxim 3 transaccions per targeta que seran les 3 més recents per tal com s'han ordenat
GROUP BY card_id;

-- Visualitzem la taula creada
SELECT *
FROM estat_targetes;


-- Per afegir al model la taula "estat_targetes" assignem a la variable "card_id" de la taula com PK i FK de la taula "Credit_cards
ALTER TABLE estat_targetes ADD PRIMARY KEY (card_id);

ALTER TABLE estat_targetes
ADD CONSTRAINT fk_estat_targetes_credit_cards
FOREIGN KEY (card_id) 
REFERENCES credit_cards(id_credit_card); 



#Finalment, a partir de la taula creada, fem la consulta per veure quantes targetes estan "Actives"
SELECT estat_targeta, COUNT(*) AS total_targetes
FROM estat_targetes
GROUP BY estat_targeta
HAVING estat_targeta ="Activa";




## Nivell 3
## Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte que des de transaction tens product_ids. Genera la següent consulta:
# Ecercici 1: Necessitem conèixer el nombre de vegades que s'ha venut cada producte.

-- Generem taula intermèdia
CREATE TABLE IF NOT EXISTS transactions_products (  
    id_transaction VARCHAR(255),
    id_products VARCHAR(20),
    PRIMARY KEY (id_transaction, id_products),
    FOREIGN KEY (id_transaction) REFERENCES transactions(id_transaction),
    FOREIGN KEY (id_products) REFERENCES products(product_id)
); 


INSERT INTO transactions_products (id_transaction, id_products) -- introduirem les dades del SELECT
SELECT  t.id_transaction, TRIM(jst.product_ids) AS id_product
FROM transactions t,
   JSON_TABLE(
        CONCAT('["', REPLACE(t.product_ids, ',', '","'), '"]'),
        '$[*]' COLUMNS(product_ids VARCHAR(20) PATH '$') -- transforma l’array JSON en files d’una taula temporal.
    ) AS jst -- genera un Join implícit entre FT i JST, generant una fila per cada producte de cada transacció.
WHERE t.product_ids IS NOT NULL AND t.product_ids <> ''; 

##Visualitzem la taula transaction_products

SELECT *
FROM transactions_products;

-- Finalment calculem el nombre de vegades que s'ha venut cada producte.
SELECT p.product_id,p.product_name, COUNT(tp.id_transaction) AS vegades_venut
FROM products p
JOIN transactions_products tp ON p.product_id = tp.id_products
GROUP BY p.product_id
ORDER BY vegades_venut DESC;



