--amNevoieDeAjutor1

CREATE TABLE beer_types (type_ VARCHAR2(40) PRIMARY KEY,
                         bitterness VARCHAR2(40),
                         strength NUMBER(4,2));
                         
select * from beer_types;
desc beer_types;
 
INSERT INTO beer_types 
VALUES ('blonde', 'low', '4.6');

INSERT INTO beer_types 
VALUES ('brown', 'medium', '5.0');

INSERT INTO beer_types 
VALUES ('black', 'high', '6.5');

INSERT INTO beer_types 
VALUES ('pilsner', 'low', '5.8');

CREATE SEQUENCE  sec_rating  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;

-----------------------

CREATE TABLE rating (rating_id NUMBER(4) PRIMARY KEY,
                     grade NUMBER(2),
                     small_description VARCHAR2(50));
                     
select * from rating;
desc rating;

----------------------

CREATE SEQUENCE  sec_locations  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;

drop sequence sec_locations;

CREATE TABLE locations(location_id NUMBER(4) PRIMARY KEY,
                       country VARCHAR2(20) NOT NULL);
                       
INSERT INTO locations 
VALUES (sec_locations.NEXTVAL, 'Romania');
    
INSERT INTO locations 
VALUES (sec_locations.NEXTVAL, 'Czech Republic');

INSERT INTO locations 
VALUES (sec_locations.NEXTVAL, 'Netherlands');
                
select * from locations;
desc locations;         
                
----------------------

CREATE SEQUENCE  sec_beermaker  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 3 CACHE 20 NOORDER  NOCYCLE ;

CREATE TABLE beermaker(beermaker_id NUMBER(4) PRIMARY KEY,
                       beermaker_name VARCHAR2(20),
                       location_id NUMBER(4),
                       CONSTRAINT fk_loc FOREIGN KEY (location_id) REFERENCES locations(location_id));    
                    
INSERT INTO beermaker
VALUES (sec_beermaker.NEXTVAL, 'Ursus', 1);
     
INSERT INTO beermaker
VALUES (sec_beermaker.NEXTVAL, 'Staropramen', 2);   

INSERT INTO beermaker
VALUES (sec_beermaker.NEXTVAL, 'Heineken', 3);   

INSERT INTO beermaker
VALUES (sec_beermaker.NEXTVAL, 'Neumarkt', 1);   
    
INSERT INTO beermaker
VALUES (sec_beermaker.NEXTVAL, 'Ciuc', 1); 
                
select * from beermaker;
desc beermaker;     
                
----------------------            
 
CREATE SEQUENCE  sec_beer  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE;                
                
CREATE TABLE beer(beer_id NUMBER(4) PRIMARY KEY,
                  beermaker_id NUMBER(20) REFERENCES beermaker(beermaker_id) NOT NULL,
                  type_ VARCHAR2(40) REFERENCES beer_types(type_) NOT NULL,
                  rating_id NUMBER(4) REFERENCES rating(rating_id),
                  beer_name VARCHAR2(50) NOT NULL,
                  price NUMBER(4,2) CONSTRAINT check_price CHECK (price>0),
                  release_date DATE DEFAULT sysdate,
                  quantity NUMBER(5,2) CONSTRAINT check_quantity CHECK (quantity>0)); 
         
INSERT INTO beer (beer_id, beermaker_id, type_, beer_name, price, quantity)
VALUES(sec_beer.NEXTVAL, 4, 'blonde', 'Neumarkt1', 1.25, 0.5);
   
INSERT INTO beer (beer_id, beermaker_id, type_, beer_name, price, release_date, quantity)
VALUES(sec_beer.NEXTVAL, 3, 'blonde', 'Heineken1', 1.45, to_date('1873','yyyy'), 0.33);
   
INSERT INTO beer (beer_id, beermaker_id, type_, beer_name, price, release_date, quantity)
VALUES(sec_beer.NEXTVAL, 2, 'black', 'Staropramen1', 1.45, to_date('1869','yyyy'), 0.33);       
   
INSERT INTO beer (beer_id, beermaker_id, type_, beer_name, price, release_date, quantity)
VALUES(sec_beer.NEXTVAL, 2, 'brown', 'Staropramen2', 1.65, to_date('1869','yyyy'), 0.33);  
         
select beer_id, beermaker_id, type_, rating_id, beer_name, price, to_char(release_date,'yyyy') as release_date, quantity 
from beer;

desc beer;              
                
----------------------    

CREATE SEQUENCE  sec_merchants  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 5 CACHE 20 NOORDER  NOCYCLE;
              
CREATE TABLE merchants(merchant_id NUMBER(4) PRIMARY KEY,
                       merchant_name VARCHAR2(20) NOT NULL);             
                
INSERT INTO merchants
VALUES(sec_merchants.NEXTVAL, 'Kaufland');
   
INSERT INTO merchants
VALUES(sec_merchants.NEXTVAL, 'Walmart');
   
INSERT INTO merchants
VALUES(sec_merchants.NEXTVAL, 'LIDL');
        
INSERT INTO merchants
VALUES(sec_merchants.NEXTVAL, 'SEAFOOD_JOE');
        
select * from merchants;
desc merchants;

---------------------- 

CREATE TABLE to_merchants(beer_id NUMBER(4) REFERENCES beer(beer_id),
                          merchant_id NUMBER(4) REFERENCES merchants(merchant_id),
                          start_date date DEFAULT sysdate,
                          end_date date,
                          quantity_per_month NUMBER(10) NOT NULL,
                          CONSTRAINT pk_compus_merchants PRIMARY KEY(beer_id, merchant_id));  

INSERT INTO to_merchants
VALUES(1, 2, sysdate, to_date('2021-12-8','yy-mm-dd'), 30);

INSERT INTO to_merchants
VALUES(1, 3, sysdate, to_date('2023-1-8','yy-mm-dd'), 50);

INSERT INTO to_merchants
VALUES(4, 3, sysdate, to_date('2023-1-8','yy-mm-dd'), 100);

INSERT INTO to_merchants
VALUES(2, 1, sysdate, to_date('2021-2-1','yy-mm-dd'), 15);

INSERT INTO to_merchants
VALUES(4, 4, sysdate, to_date('2021-2-1','yy-mm-dd'), 25);

select * from to_merchants;
desc to_merchants;

---------------------- 

CREATE SEQUENCE  sec_food  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE;

CREATE TABLE food(food_id NUMBER(4) PRIMARY KEY,
                  description_ VARCHAR2(50) NOT NULL);             
                
INSERT INTO food
VALUES(sec_food.NEXTVAL, 'Mici');
   
INSERT INTO food
VALUES(sec_food.NEXTVAL, 'Romanian traditionals(sarmale, mamaliga)');
   
INSERT INTO food
VALUES(sec_food.NEXTVAL, 'Seafood');
        
select * from food;
desc food;

---------------------- 

CREATE TABLE good_with_food(beer_id NUMBER(4) REFERENCES beer(beer_id),
                            food_id NUMBER(4) REFERENCES food(food_id),
                            comments VARCHAR2(75),
                            CONSTRAINT pk_compus_foods PRIMARY KEY(beer_id, food_id));  

INSERT INTO good_with_food
VALUES(1, 2, 'romanian beer is usually good with romanian food.');

INSERT INTO good_with_food
VALUES(4, 3, 'brown beer tastes well with fish.');

select * from good_with_food;
desc good_with_foods;

---------------------- 

select * from food;

ALTER TABLE food
ADD price NUMBER(5,2) DEFAULT 0;

UPDATE food
SET price = 4 
WHERE food_id = 1; 

UPDATE food
SET price = 6 
WHERE food_id = 2; 

UPDATE food
SET price = 5.7 
WHERE food_id = 3; 

select * from contract;

ALTER TABLE contract
ADD food_id NUMBER(4) REFERENCES food(food_id);

ALTER TABLE contract
ADD food_quantity NUMBER(5);

UPDATE contract
SET food_id = 3 
WHERE beer_id = 4 AND merchant_id = 4; 

UPDATE contract
SET food_quantity = 10 
WHERE beer_id = 4 AND merchant_id = 4; 

select * from merchants;

UPDATE merchants
SET merchant_name = 'Rustic' 
WHERE merchant_id = 1; 

UPDATE merchants
SET merchant_name = 'Galeo' 
WHERE merchant_id = 2; 

UPDATE merchants
SET merchant_name = 'Fantastique' 
WHERE merchant_id = 3; 

select * from food;

UPDATE food
SET description_ = 'Sandwitches' ,
    price = 3.5
WHERE food_id = 2; 

commit; 

select * from contract;
select * from beer;
select * from merchants;
select * from food;
                
INSERT INTO contract
VALUES (3,3,sysdate, to_date('2021-12-8','yy-mm-dd'), 55, 2, 15);
                
INSERT INTO contract
VALUES (3,1,sysdate, to_date('2021-2-1','yy-mm-dd'), 50, 2, 15);               
                
INSERT INTO contract
VALUES (3,4,sysdate, to_date('2021-2-1','yy-mm-dd'), 20, null, null);                
                
INSERT INTO contract
VALUES (2,4,sysdate, to_date('2021-6-1','yy-mm-dd'), 30, null, null);                
                
INSERT INTO contract
VALUES (2,3,sysdate, to_date('2021-6-8','yy-mm-dd'), 75, 1, 25);

select * from beermaker;

ALTER TABLE beermaker
ADD starting_price NUMBER(5,2) DEFAULT 0.75;

UPDATE beermaker
SET starting_price = 1
WHERE beermaker_id = 2;

UPDATE beermaker
SET starting_price = 1.25
WHERE beermaker_id = 3;