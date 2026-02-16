 CREATE DATABASE IF NOT EXISTS transactions;
    USE transactions;

    -- Creem la taula company
    CREATE TABLE IF NOT EXISTS company (
        id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );


    -- Creem la taula transaction
    CREATE TABLE IF NOT EXISTS transaction (
        id VARCHAR(255) PRIMARY KEY,
        credit_card_id VARCHAR(15) REFERENCES credit_card(id),
        company_id VARCHAR(20), 
        user_id INT REFERENCES user(id),
        lat FLOAT,
        longitude FLOAT,
        timestamp TIMESTAMP,
        amount DECIMAL(10, 2),
        declined BOOLEAN,
        FOREIGN KEY (company_id) REFERENCES company(id) 
    );
    
   
-- Les consultes a realitzar en l'Sprint 2:

## Exercici 2
# Utilitzant JOIN realitzaràs les següents consultes:
# Llistat dels països que estan fent compres.
SELECT DISTINCT c.country
FROM company c
JOIN `Transaction` t ON c.id = t.company_id;


# Des de quants països es realitzen les compres.
SELECT COUNT(DISTINCT c.country) AS total_paisos 
FROM company c
JOIN `Transaction` t ON c.id = t.company_id;

  
# Identifica la companyia amb la mitjana més gran de vendes.

SELECT c.company_name, ROUND(AVG(t.amount),2) AS mitjana_vendes
FROM company c
JOIN `Transaction` t ON c.id = t.company_id
WHERE t.declined=0 -- Només tenim en compte les finalitzades
GROUP BY c.company_name
ORDER BY mitjana_vendes DESC
LIMIT 1;

-- Exercici 3
-- Utilitzant només subconsultes (sense utilitzar JOIN):

-- Mostra totes les transaccions realitzades per empreses d'Alemanya.

SELECT t.id
FROM `Transaction` t
WHERE EXISTS ( 
    SELECT 1
    FROM company c
    WHERE t.company_id=c.id AND c.country = 'Germany'
);

-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.

SELECT c.company_name
FROM company c
WHERE EXISTS ( 
    SELECT 1
    FROM `Transaction` t
    WHERE t.company_id=c.id AND t.amount > (
        SELECT AVG(t.amount)
        FROM `Transaction` t
    )
);

-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
SELECT c.company_name
FROM company c
WHERE NOT EXISTS (
    SELECT 1
    FROM `Transaction` t
    WHERE t.company_id = c.id
);


# Nivell 2


## Exercici 1
## Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.

SELECT  DATE(t.timestamp) AS data_transaccio, SUM(t.amount) AS total_ingressos
FROM `Transaction` t
WHERE t.declined=0
GROUP BY DATE(t.timestamp)
ORDER BY total_ingressos DESC
LIMIT 5;

## Exercici 2
##Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.

SELECT c.country, ROUND (AVG(t.amount),2) AS mitjana_vendes
FROM company c
JOIN `Transaction` t ON c.id = t.company_id
WHERE t.declined=0
GROUP BY c.country
ORDER BY mitjana_vendes DESC;

## Exercici 3
## En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.
## Mostra el llistat aplicant JOIN i subconsultes.

SELECT t.id, c.country
FROM `Transaction` t
JOIN company c ON t.company_id = c.id
WHERE c.country = (
    SELECT c.country
    FROM company c
    WHERE c.company_name = 'Non Institute'
);

## Mostra el llistat aplicant solament subconsultes.
 SELECT t.id
FROM `Transaction` t
WHERE EXISTS (
    SELECT c.id
    FROM company c
    WHERE t.company_id=c.id AND c.country = (
        SELECT c.country
        FROM company c
        WHERE c.company_name = 'Non Institute'
    )
);



## Nivell 3
## Exercici 1
## Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 350 i 400 euros i en alguna d'aquestes dates: 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024. Ordena els resultats de major a menor quantitat.

SELECT c.company_name, c.phone, c.country, DATE(t.timestamp) AS data_transaccio, t.amount as Quantitat_ventes
FROM company c
JOIN `Transaction` t ON c.id = t.company_id
WHERE t.amount BETWEEN 350 AND 400
  AND DATE(t.timestamp) IN (
      '2015-04-29',
      '2018-07-20',
      '2024-03-13'
  )
ORDER BY t.amount DESC;

## Exercici 2
## Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 400 transaccions o menys.

SELECT c.id, c.company_name, COUNT(t.id) AS total_transaccions,
    IF(COUNT(t.id) > 400, 'Més de 400 transaccions', 'Menys de 400 transaccions') AS nivell_transaccions
FROM company c
JOIN `Transaction` t
  ON c.id = t.company_id
WHERE t.declined=0
GROUP BY c.id, c.company_name
ORDER BY total_transaccions ASC;