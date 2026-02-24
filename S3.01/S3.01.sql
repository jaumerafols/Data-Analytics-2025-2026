
-- USE transactions

## Nivell 1
## Exercici 1
## La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit. La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i "company"). Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit". Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.


CREATE TABLE IF NOT EXISTS credit_card (
    id VARCHAR(15) PRIMARY KEY,       
    iban VARCHAR(34),                 
    pan VARCHAR(20),                  
    pin VARCHAR(4),                   
    cvv VARCHAR(3),                       
    expiring_date VARCHAR(15)       
);
-- Introduim les dades en taula "Credit card"
-- Agreguem una FK després de la creació de la taula "credit"car" a la variable "credit_card_id" de la taula "transactions" cap la vairable "id", que és PK de la taula "credit_card".

ALTER TABLE `transaction`
ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id); 

## Exercici 2
## El departament de Recursos Humans ha identificat un error en el número de compte associat a la targeta de crèdit amb ID CcU-2938. La informació que ha de mostrar-se per a aquest registre és: TR323456312213576817699999. Recorda mostrar que el canvi es va realitzar.
 
UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';

## Visualitzem el canvi
SELECT id, iban
FROM credit_card
WHERE id = 'CcU-2938';

## Exercici 3
## En la taula "transaction" ingressa una nova transacció amb la següent informació:

-- Abans de fer la modifició hem de crear el id de la targeta de credit en "credit_card", i el id en la taula "comnpany"
-- Mirem si existeix el id de la targeta i sinó, introduim les dades a "credit_car" on els altres camps quedaran en nul
SELECT * FROM  credit_card
WHERE id = 'CcU-9999';

-- creeem la targeta,  els altres camps quedaran en nul
INSERT INTO credit_card (id) VALUES ('CcU-9999'); 

-- Mirem si existeix el id de l'empresa i sinó, introduim les dades a "company" on els altres camps quedaran en nul
SELECT * FROM  company
WHERE id = 'b-9999';
-- creeem el id de l'empresa, els altres camps quedaran en nul
INSERT INTO company (id) VALUES ('b-9999'); 

INSERT INTO `transaction` (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined) VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999', NOW(), '111.11', '0');

-- Verificació de la inserció
SELECT * FROM transaction WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';


## Exercici 4
## Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. Recorda mostrar el canvi realitzat.

ALTER TABLE credit_card
DROP COLUMN pan;

-- Mostrem canvi
DESCRIBE credit_card;

## Nivell 2
## Exercici 1
## Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.

DELETE FROM `Transaction`
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- Busquem el registre per confirmar que no existeix
SELECT * FROM `Transaction` WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

## Exercici 2
## La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.

CREATE OR REPLACE VIEW VistaMarketing  AS
SELECT c.company_name AS nom_companyia, c.phone AS telefon, c.country AS pais, AVG(t.amount) AS mitjana_compra
FROM company c
JOIN `Transaction` t ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY c.id, c.country;

-- Mostrem vista

SELECT *
FROM VistaMarketing
ORDER BY mitjana_compra DESC;

## Exercici 3
## Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"

SELECT *
FROM VistaMarketing
WHERE pais = 'Germany';


## Nivell 3
## Exercici 1
## La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip va realitzar modificacions en la base de dades, però no recorda com les va realitzar. Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama:

-- Creació de la taula de dades d'usuari amn "estrctura de datos user"
CREATE TABLE IF NOT EXISTS user (
	id CHAR(10) PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255)    
);


-- Canviem el nom de la taula a data_user, canvi de dades de variable id de CHAR(10) a id, canviem nom de la columna email a personal_email

RENAME TABLE `user` TO data_user;

ALTER TABLE data_user MODIFY COLUMN id INT;

ALTER TABLE data_user RENAME COLUMN email TO personal_email;

DESCRIBE data_user;

-- Mirem si existeix el id "9999" introduit en exercici 3 del nivell 1 i sinó, introduim les dades en la taula "data_user", i on els altres camps quedaran en nul, tot per poder transformar en FK la variable user_id
SELECT * FROM  data_user
WHERE id = '9999';

INSERT INTO data_user (id) VALUES ('9999');

ALTER TABLE `transaction`
ADD FOREIGN KEY (user_id) REFERENCES data_user(id); 

DESCRIBE `transaction`;

-- En taula "credit_card" afegim la columna  fecha_actual DATE a credit_card, i cambiem dades a iban i expiring date

ALTER TABLE credit_card ADD COLUMN fecha_actual DATE; 
ALTER TABLE credit_card MODIFY COLUMN iban VARCHAR(50);
ALTER TABLE credit_card MODIFY COLUMN expiring_date VARCHAR(25);
ALTER TABLE credit_card MODIFY COLUMN cvv INT;

DESCRIBE credit_card;

-- eliminem la columna website a company
ALTER TABLE company DROP COLUMN website;

DESCRIBE company;

/* Exercici 2
L'empresa també us demana crear una vista anomenada "InformeTecnico" que contingui la següent informació:
o	ID de la transacció
o	Nom de l'usuari/ària
o	Cognom de l'usuari/ària
o	IBAN de la targeta de crèdit usada.
o	Nom de la companyia de la transacció realitzada.
o	Assegureu-vos d'incloure informació rellevant de les taules que coneixereu i utilitzeu àlies per canviar de nom columnes segons calgui.
Mostra els resultats de la vista, ordena els resultats de forma descendent en funció de la variable ID de transacció.*/

-- Creem la vista
CREATE OR REPLACE VIEW InformeTecnico AS
SELECT t.id AS id_transaccio, u.name AS nom_usuari, u.surname AS cognom_usuari, cc.iban AS iban_targeta, c.company_name AS nom_companyia
FROM `Transaction` t
JOIN data_user u ON t.user_id = u.id
JOIN credit_card cc ON t.credit_card_id = cc.id
JOIN company c ON t.company_id = c.id;
  
-- La mostrem ordenada per transacció
SELECT *
FROM InformeTecnico
ORDER BY id_transaccio DESC;
