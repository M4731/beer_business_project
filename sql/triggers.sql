select * from contract;

CREATE TABLE beer_inventar(merchant_id NUMBER PRIMARY KEY,
                           total_quantity NUMBER,
                           total_price NUMBER);
                        
--10
--trigger-ul va completa tabelul beer_inventar de fiecare data cand se creeaza/modifica un contract, beer_inventar va avea id_ul merchantului din contract si cantitatea totala de bere cumparata si pretul platit de el pe acestea.)

CREATE OR REPLACE TRIGGER trigger_1
AFTER INSERT OR UPDATE ON CONTRACT
BEGIN
    FOR i IN (SELECT con.merchant_id, sum(con.beer_quantity) suma, sum(con.beer_quantity)*b.price pret
                FROM contract con JOIN beer b ON b.beer_id = con.beer_id
                GROUP BY merchant_id, price)
    LOOP
        UPDATE beer_inventar
        SET total_quantity = i.suma,
            total_price = i.pret
        WHERE merchant_id = i.merchant_id;
        
        IF SQL%NOTFOUND
        THEN
            INSERT INTO beer_inventar
            VALUES(i.merchant_id, i.suma, i.pret);
        END IF;
    END LOOP;
    
END;
/

select * from contract;
select * from beer_inventar;

INSERT INTO contract
VALUES(1,6,sysdate, sysdate, 2, null, null);

DELETE FROM contract 
WHERE merchant_id = 6;

--11
--daca nota ratingului introdus este mai mic decat 1 sau mai mare decat 10 raise exception

CREATE OR REPLACE TRIGGER trigger_2
AFTER INSERT OR UPDATE ON rating
FOR EACH ROW
BEGIN
    IF :NEW.grade > 10 OR :NEW.grade < 1
    THEN
        RAISE_APPLICATION_ERROR(-20001,'The rating grade has to be between 1 and 10');
    END IF;
END;
/
insert into rating values(50, 0,'ddd');

--daca un contract este adaugat pe o durata mai mica de 30 de zile raise exception 
CREATE OR REPLACE TRIGGER trigger_3
AFTER INSERT OR UPDATE ON contract
FOR EACH ROW
DECLARE
    v_dat NUMBER;
BEGIN
    v_dat := :NEW.end_date - sysdate;
    
    IF v_dat < 30
    THEN
        RAISE_APPLICATION_ERROR(-20001,'The minimum contract duration is 30 days.');
    END IF;
END;
/

insert into contract values(2, 6,sysdate, sysdate, 400, null, null);

CREATE TABLE table_system(t_user varchar2(50),
                          action varchar2(50),
                          table_name varchar2(50));

--12
--de fiecare data cand un utilizator altereaza/creeaza/sterge un tabel adauga informatia cu actiunea in table_system

CREATE OR REPLACE TRIGGER trigger_4
    BEFORE CREATE or ALTER or DROP ON DATABASE
BEGIN
    IF ora_sysevent = 'CREATE' 
    THEN
        INSERT INTO table_system
        VALUES(ora_login_user,'created',ora_dict_obj_name);
    ELSIF ora_sysevent = 'ALTER' 
    THEN
        INSERT INTO table_system
        VALUES(ora_login_user,'altered',ora_dict_obj_name);
    ELSIF ora_sysevent = 'DROP' 
    THEN
        INSERT INTO table_system
        VALUES(ora_login_user,'dropped',ora_dict_obj_name);
    END IF;
END;
/

create table tabel_test as select * from locations;
alter table tabel_test drop column country;
drop table tabel_test;

select * from table_system;


