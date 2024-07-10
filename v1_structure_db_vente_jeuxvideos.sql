/* 
@ Code   : Pour SQL Oracle Database 21c
@ Auteur : Patrick Saint-Louis 
@ Date   : 2024
*/
--1-CREATE A DATABASE 
--1-CREER UNE BASE DE DONNEES 
--Create a new user account (Replace admin123 by your own password)
--Créer un nouveau compte utilisateur (Remplacez admin123 par votre propre mot de passe)
CREATE USER c##final_project IDENTIFIED BY admin_patricksl_0123 DEFAULT TABLESPACE USERS;

--Assign privileges and roles to the new user
--Assigner des privilèges et roles au nouvel l'utilisateur
GRANT UNLIMITED TABLESPACE TO c##final_project;

GRANT CONNECT,
RESOURCE TO c##final_project;

GRANT CREATE VIEW 
TO c##final_project;


--2-CREATE THE PHYSICAL MODEL CODE (including TABLES, COLUMNS, ASSOCIATIONS, AND CARDINALITIES)
--2-CREER LE CODE DU MODELE PHYSIQUE (incluant des TABLES, COLONNES, ASSOCIATIONS ET CARDINALITES)

--Delete permanently the tables if they already exist
--Supprimer le table de maniere permanente si elles existent 

DROP TABLE DETAILSCOMMANDES;
DROP TABLE COMMANDES;
DROP TABLE JEUXVIDEOS;
DROP TABLE FOURNISSEURS;
DROP TABLE CLIENTS;
DROP TABLE ADRESSE;


--Create the tables 
--Créer les tables 

-- Create the Table ADRESSEE 
CREATE TABLE ADRESSE
(ADDID VARCHAR2(7) CONSTRAINT ADDID_ADRESSE_PK PRIMARY KEY,
STREET VARCHAR2(75) CONSTRAINT STREET_ADRESSE_NN NOT NULL,
CITY VARCHAR2(35) DEFAULT('MONTREAL') CONSTRAINT CITY_ADRESSE_NN NOT NULL,
STATE VARCHAR2(2) DEFAULT('QC') CONSTRAINT STATE_ADRESSE_CHK CHECK(STATE IN('AB', 'BC', 'MB', 'NB', 'NS', 'NU', 'ON', 'PE', 'QC', 'SK', 'NL', 'NT', 'YT')),
CODE VARCHAR2(7) CONSTRAINT CODE_ADRESSE_NN NOT NULL,
COUNTRY VARCHAR2(25) DEFAULT('CANADA') CONSTRAINT COUNTRY_ADRESSE_NN NOT NULL, CONSTRAINT COUNTRY_ADRESSE_CHK CHECK(COUNTRY IN('CANADA')) 
);

-- Create the Table CLIENTS 
CREATE TABLE CLIENTS
(CID VARCHAR2(6) CONSTRAINT CID_CLIENTS_PK PRIMARY KEY,
FNAME VARCHAR2(30) CONSTRAINT FNAME_CLIENTS_NN NOT NULL,
LNAME VARCHAR2(30) CONSTRAINT LNAME_CLIENTS_NN NOT NULL,
PHONE VARCHAR2(15) CONSTRAINT PHONE_CLIENTS_CHK CHECK (REGEXP_LIKE (PHONE,'^[2-9]+[0-9]+[0-9]+[-]+[2-9]+[0-9]+[0-9]+[-]+[0-9]{4}')),
EMAIL VARCHAR2(20) CONSTRAINT EMAIL_CLIENTS_CHK CHECK (REGEXP_LIKE (EMAIL,'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$')),
CLIADD VARCHAR2(7), CONSTRAINT CLIADD_CLIENTS_FK FOREIGN KEY(CLIADD) REFERENCES ADRESSE(ADDID)
);

-- Create the Table FOURNISSEURS
CREATE TABLE FOURNISSEURS
(SID NUMBER(8) CONSTRAINT SID_FOURNISSEURS_PK PRIMARY KEY,
FNAME VARCHAR2(30) CONSTRAINT FNAME_FOURNISSEURS_NN NOT NULL,
LNAME VARCHAR2(30) CONSTRAINT LNAME_FOURNISSEURS_NN NOT NULL,
PHONE VARCHAR2(15) CONSTRAINT PHONE_FOURNISSEURS_CHK CHECK (REGEXP_LIKE (PHONE,'^[2-9]+[0-9]+[0-9]+[-]+[2-9]+[0-9]+[0-9]+[-]+[0-9]{4}')),
EMAIL VARCHAR2(20) CONSTRAINT EMAIL_FOURNISSEURS_CHK CHECK (REGEXP_LIKE (EMAIL,'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$')),
SUPADD VARCHAR2(7), CONSTRAINT SUPADD_FOURNISSEURS_FK FOREIGN KEY(SUPADD) REFERENCES ADRESSE(ADDID)
);

-- Create the Table JEUX_VIDEOS
CREATE TABLE JEUXVIDEOS
(VGID NUMBER(8) CONSTRAINT VGID_JEUXVIDEOS_PK PRIMARY KEY,
TITLE VARCHAR2(70) CONSTRAINT TITLE_JEUXVIDEOS_NN NOT NULL,
AUTHORS VARCHAR2(50) CONSTRAINT AUTHORS_JEUXVIDEOS_NN NOT NULL,
DESCRIPTION VARCHAR2(600),
CATEGORY VARCHAR2(50)  CONSTRAINT CATEGORY_JEUXVIDEOS_NN NOT NULL, CONSTRAINT CATEGORY_JEUXVIDEOS_CHK CHECK(CATEGORY IN('ACTION','ACTION-ADVENTURE','ADVENTURE','ROLE-PLAYING','SIMULATION','STRATEGY','SPORTS','PUZZLE','IDLE','OTHER')),
PUBLIDATE DATE CONSTRAINT PUBLIDATE_JEUXVIDEOS_NN NOT NULL, CONSTRAINT PUBLIDATE_JEUXVIDEOS_CHK CHECK(PUBLIDATE>TO_DATE('2015-12-31','yyyy-mm-dd')),
PURCHPRICE NUMBER(8) CONSTRAINT PURCHPRICE_JEUXVIDEOS_NN NOT NULL, CONSTRAINT PURCHPRICE_JEUXVIDEOS_CHK CHECK(PURCHPRICE>0),
CATALPRICE NUMBER(10) CONSTRAINT CATALPRICE_JEUXVIDEOS_CHK CHECK(CATALPRICE>0),
STOCKNUMBER NUMBER(6) CONSTRAINT STOCKNUMBER_JEUXVIDEOS_CHK CHECK(STOCKNUMBER>0),
SID NUMBER(8), CONSTRAINT SID_JEUXVIDEOS_FK FOREIGN KEY (SID) REFERENCES FOURNISSEURS(SID)
);

-- Create the Table COMMANDES
CREATE TABLE COMMANDES
(OID VARCHAR2(6) CONSTRAINT OID_COMMANDES_PK PRIMARY KEY,
PLACDATE DATE DEFAULT SYSDATE CONSTRAINT PLACDATE_COMMANDES_NN NOT NULL,
PAYTYPE VARCHAR2(25) CONSTRAINT PAYTYPE_COMMANDES_NN NOT NULL, CONSTRAINT PAYTYPE_COMMANDES_CHK CHECK(PAYTYPE IN('MASTERCARD','VISA','PAYPAL','BANK TRANSFER')),
SHIPADD VARCHAR2(7) CONSTRAINT SHIPADD_COMMANDES_NN NOT NULL, CONSTRAINT SHIPADD_COMMANDES_FK FOREIGN KEY (SHIPADD) REFERENCES ADRESSE(ADDID), 
CID VARCHAR(6), CONSTRAINT CID_COMMANDES_FK FOREIGN KEY(CID) REFERENCES CLIENTS(CID)
);

-- Create the Table DETAILS_COMMANDES
CREATE TABLE DETAILSCOMMANDES
(QUANTITY NUMBER(10) DEFAULT '1' CONSTRAINT QUANTITY_DETAILSCOMMANDES_NN NOT NULL, CONSTRAINT QUANTITY_DETAILSCOMMANDES_CHK CHECK(QUANTITY>0),
QCTAXRATE NUMBER(6) DEFAULT('0.09975') CONSTRAINT QCTAXRATE_DETAILSCOMMANDES_CHK CHECK(QCTAXRATE IN(0,0.09975)),
CANTAXRATE NUMBER(6) DEFAULT('0.05') CONSTRAINT CANTAXRATE_DETAILSCOMMANDES_CHK CHECK(CANTAXRATE IN(0,0.05)),
SALPRICE NUMBER(10),
OID VARCHAR2(6),CONSTRAINT OID_DETAILSCOMMANDES_FK FOREIGN KEY(OID) REFERENCES COMMANDES(OID),
VGID NUMBER(8), CONSTRAINT VGID_DETAILSCOMMANDES_FK FOREIGN KEY(VGID) REFERENCES JEUXVIDEOS(VGID),
TOTAL NUMBER(15)
);


--Tables comments
--Commentaires sur les tables
COMMENT ON TABLE CLIENTS IS 'Enregistre des informations sur chaque potentiel acheteur ayant passé une commande de jeu vidéos';
COMMENT ON TABLE FOURNISSEURS IS 'Enregistre des informations sur chaque fournisseur de jeu vidéos';
COMMENT ON TABLE JEUXVIDEOS IS 'Enregistre des informations sur chaque jeu vidéos vendu et à vendre';
COMMENT ON TABLE COMMANDES IS 'Enregistre des informations sur chaque commande passée par un client';
COMMENT ON TABLE DETAILSCOMMANDES IS 'Enregistre des informations sur chaque produit dans une commande passée par un client';
COMMENT ON TABLE ADRESSE IS 'Enregistre des informations sur l''adresse de chaque chaque potentiel acheteur ayant passé une commande et chaque fournisseur des jeu vidéos vendus et à vendre';



--3-CONFIRM THE CREATION OF THE PHYSICAL MODEL
--3-CONFIRMER LA CREATION DU MODELE PHYSIQUE
--Show all user account tables to confirm the tables was successfully created
--Afficher toutes les tables de l'utilisateur pour confirmer la creation des tables 
SELECT
  table_name
FROM
  user_tables
ORDER BY
  table_name ASC;

--Show the table columns
--Afficher les colonnes des tables
DESC DETAILS_COMMANDES;
DESC COMMANDES;
DESC JEUX_VIDEOS;
DESC FOURNISSEURS;
DESC CLIENTS;
DESC ADRESSEE;

--Show info about the column integrity constraints
--Afficher les informations sur des contraintes d'integrité des colonnes
SELECT
  *
FROM
  user_cons_columns
WHERE
  table_name IN (
    SELECT
      table_name
    FROM
      user_tables
  );

--Show the table comments
--Afficher les commentaires des table
SELECT
  *
FROM
  user_tab_comments
WHERE
  table_name IN (
    SELECT
      table_name
    FROM
      user_tables
  );
