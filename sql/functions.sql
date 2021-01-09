CREATE OR REPLACE PACKAGE p_pachet1
AS

    --afisati toate mancarurile care merg bine cu un tip de bere produs intr-o regiune introdusa de la tastatura si returnati numarul acestora
    FUNCTION mancare( v_regiune locations.country%TYPE)
    RETURN number;
    
    --afisati berile, tipurile si preturile acestora, cumparate de fiecare merchant
    PROCEDURE bere_cerere;
    
    --profitul scos dintr-o anumita bere pe luna
    FUNCTION monthly_profit(v_bere beer.beer_id%TYPE)
    RETURN NUMBER;
    
    --afisati numele fiecarei beri, numele locatiei in care este produsa, numele producatorului, cantitatea cumparate un merchant al carui nume este dat, , dar si fiecare fel de mancare si cantitatea mancarii comandata de acesta. –toate informatiile utile legate de cererea unui merchant.
    PROCEDURE usefull_information(v_mer merchants.merchant_name%TYPE);
    
END p_pachet1;
/

select * from locations;
select * from beermaker;
select * from merchants;
select * from beer;
select * from food;

CREATE OR REPLACE PACKAGE BODY p_pachet1
AS

    --afisati toate mancarurile care sunt o combinatie buna pentru un tip de bere produs intr-o regiune introdusa de la tastatura si returnati numarul acestora
    FUNCTION mancare (v_regiune locations.country%TYPE)
    RETURN number
    IS
        v_var locations.country%TYPE;
        v_nr NUMBER;
        TYPE tablou_indexat IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
        t tablou_indexat;
        e EXCEPTION;
        no_data EXCEPTION;
    BEGIN
        SELECT count(*) INTO v_nr
        FROM locations
        WHERE country = v_regiune;
        
        IF v_nr = 0
        THEN 
            RAISE e;
        END IF;
    
        SELECT f.food_id BULK COLLECT INTO t
        FROM food f JOIN good_with_food gwf ON f.food_id = gwf.food_id
                    JOIN beer b ON gwf.beer_id = b.beer_id
                    JOIN beermaker be ON b.beermaker_id = be.beermaker_id
                    JOIN locations l ON l.location_id = be.location_id
        WHERE l.country = v_regiune;
    
        SELECT count(description_) INTO v_nr
        FROM food f JOIN good_with_food gwf ON f.food_id = gwf.food_id
                    JOIN beer b ON gwf.beer_id = b.beer_id
                    JOIN beermaker be ON b.beermaker_id = be.beermaker_id
                    JOIN locations l ON l.location_id = be.location_id
        WHERE l.country = v_regiune;
        
        IF v_nr = 0
        THEN 
            RAISE no_data;
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Country : ' || v_regiune);
        FOR i IN t.first .. t.last
        LOOP
            SELECT description_ INTO v_var
            FROM food
            WHERE food_id = t(i);
            
            DBMS_OUTPUT.PUT_LINE( ' -  ' || v_var);
        END LOOP;
        
        RETURN v_nr;
    EXCEPTION
    
        WHEN no_data
        THEN
            RAISE_APPLICATION_ERROR(-20001,'No food in the database goes well with the beer in that country');
        WHEN e
        THEN
            RAISE_APPLICATION_ERROR(-20001,'The introduced country is not in the database');
    END;
    
    --afisati berile, tipurile si preturile acestora, cumparate de fiecare merchant
    PROCEDURE bere_cerere
    IS
        v_mn merchants.merchant_name%TYPE;
        v_ok NUMBER;
        CURSOR c IS
            SELECT merchant_name, count(beer_id)
            FROM contract RIGHT JOIN merchants USING(merchant_id)
            GROUP BY merchant_name;
    BEGIN
        OPEN c;
        LOOP
            FETCH c INTO v_mn, v_ok;
            EXIT WHEN c%NOTFOUND;
            IF(v_ok > 0)
            THEN
                DBMS_OUTPUT.PUT_LINE('The merchant ' || v_mn || ' demands:');
                FOR i IN (SELECT b.beer_id, b.beer_name, b.type_, b.price
                          FROM beer b JOIN contract c ON b.beer_id = c.beer_id
                                      JOIN merchants m ON c.merchant_id = m.merchant_id
                          WHERE m.merchant_name LIKE v_mn)
                    LOOP
                        DBMS_OUTPUT.PUT_LINE(' Name: ' || i.beer_id || ' ' ||i.beer_name || ' | Type: ' || i.type_ || ' | Price: ' || i.price);
                END LOOP;
            ELSE
                DBMS_OUTPUT.PUT_LINE('The merchant ' || v_mn || ' does not demand anything');
            END IF;
            DBMS_OUTPUT.PUT_LINE(' --------------- ');
        END LOOP;
        CLOSE c;
    END;
    
    --profitul scos dintr-o anumita bere pe luna
    FUNCTION monthly_profit(v_bere beer.beer_id%TYPE)
    RETURN NUMBER
    IS
        v_nr_beri_vandute NUMBER;
        v_nr_litri_bere_vanduti NUMBER;
        v_waste_bere_vanduta NUMBER;
        v_win_bere_vanduta NUMBER;
        v_pret_bere_vanduta NUMBER;
        v_profit NUMBER;
        e EXCEPTION;
    BEGIN
        SELECT sum(beer_quantity) INTO v_nr_beri_vandute
        FROM contract
        WHERE beer_id = v_bere;
    
        SELECT price INTO v_profit
        FROM beer
        WHERE beer_id = v_bere;
        
        IF v_profit is not null AND v_nr_beri_vandute is null
        THEN 
            RAISE e;
        END IF;
    
        SELECT sum(c.beer_quantity),  round(sum(c.beer_quantity)*b.quantity+0.49), round(sum(c.beer_quantity)*b.quantity+0.49)*bm.price_per_liter INTO v_nr_beri_vandute, v_nr_litri_bere_vanduti, v_waste_bere_vanduta     
        FROM contract c JOIN beer b ON b.beer_id = c.beer_id
                        JOIN beermaker bm ON b.beermaker_id = bm.beermaker_id
        WHERE c.beer_id = v_bere
        GROUP BY b.quantity, bm.price_per_liter;
        
        SELECT price INTO v_pret_bere_vanduta
        FROM beer
        WHERE beer_id = v_bere;
        
        v_win_bere_vanduta := v_nr_beri_vandute * v_pret_bere_vanduta;
        --DBMS_OUTPUT.PUT_LINE(v_nr_beri_vandute || ' ' || v_nr_litri_bere_vanduti || ' ' || v_waste_bere_vanduta || ' ' ||  v_pret_bere_vanduta);
        --DBMS_OUTPUT.PUT_LINE(v_win_bere_vanduta);
        v_profit := v_win_bere_vanduta - v_waste_bere_vanduta;
        RETURN v_profit;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RAISE_APPLICATION_ERROR(-20001,'The introduced code does not define a beer in our database.');
        WHEN e
        THEN
            RAISE_APPLICATION_ERROR(-20001,'The introduced beer does not sell at the moment.');    
    END;
    
    
    
    --afisati numele fiecarei beri, numele locatiei in care este produsa, numele producatorului, cantitatea cumparate un merchant al carui nume este dat, , dar si fiecare fel de mancare si cantitatea mancarii comandata de acesta. –toate informatiile utile legate de cererea unui merchant.
    PROCEDURE usefull_information(v_mer merchants.merchant_name%TYPE)
    IS
        v_name beer.beer_name%TYPE;
        v_bmname beermaker.beermaker_name%TYPE;
        v_con locations.country%TYPE;
        v_food food.description_%TYPE;
        v_fcount NUMBER;
        v_nr NUMBER;
        v_bcount NUMBER;
        v_merchant merchants.merchant_id%TYPE;
    BEGIN
        SELECT merchant_id INTO v_merchant
        FROM merchants
        WHERE lower(merchant_name) = lower(v_mer);
        
        SELECT count(beer_id) INTO v_nr
               FROM contract
               WHERE merchant_id = v_merchant;
    
        IF v_nr > 0 
        THEN 
            DBMS_OUTPUT.PUT_LINE('The merchant ' || v_merchant || ' ' || INITCAP(v_mer) || ' buys:');
        
            FOR i IN (SELECT beer_id
                      FROM contract
                      WHERE merchant_id = v_merchant)
            LOOP
                SELECT beer_name, beermaker_name, country INTO v_name, v_bmname, v_con
                FROM beer b JOIN beermaker bm ON b.beermaker_id = bm.beermaker_id
                            JOIN locations l ON bm.location_id = l.location_id
                WHERE beer_id = i.beer_id;
                
                SELECT sum(beer_quantity) INTO v_bcount
                FROM contract
                WHERE merchant_id = v_merchant AND beer_id = i.beer_id;
                
                DBMS_OUTPUT.PUT_LINE(v_bcount || ' ' || INITCAP(v_name) || ' made by ' || INITCAP(v_bmname) || ' in ' || INITCAP(v_con));
                END LOOP;
            
            SELECT count(food_id) INTO v_fcount
                   FROM contract
                   WHERE merchant_id = v_merchant;
            
            IF v_fcount > 0
            THEN
                DBMS_OUTPUT.PUT('And food: ');
                
                FOR i IN (SELECT food_id
                          FROM contract
                          WHERE merchant_id = v_merchant)
                LOOP
                    IF i.food_id is not null
                    THEN
                        SELECT description_ INTO v_food
                        FROM food 
                        WHERE food_id = i.food_id;
                        
                        SELECT sum(beer_quantity) INTO v_bcount
                        FROM contract
                        WHERE merchant_id = v_merchant AND food_id = i.food_id;
                        
                        DBMS_OUTPUT.PUT(v_bcount || ' ' ||v_food || ' ');
                    END IF;
                END LOOP;
                
                DBMS_OUTPUT.NEW_LINE;
            ELSE
                DBMS_OUTPUT.PUT_LINE('And they do not buy any food.');
            END IF;
        ELSE
            DBMS_OUTPUT.PUT_LINE('The merchant ' || v_merchant || ' ' || INITCAP(v_mer) || ' does not buy anything.');
        END IF;
        
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RAISE_APPLICATION_ERROR(-20001,'The introduced merchant in not our database.');
        WHEN TOO_MANY_ROWS
        THEN
            RAISE_APPLICATION_ERROR(-20002,'The introduced name defines more than one merchants on our database.');
 
     END;
END p_pachet1;
/

DECLARE
    x NUMBER;
    c VARCHAR2(40) := INITCAP('&country');
BEGIN
    x := p_pachet1.mancare(c);
    --dbms_output.put_line(x);
END;
/

EXECUTE p_pachet1.bere_cerere;

select * from locations;
select * from beermaker;
select * from merchants;
select * from contract;
select * from beer;
select * from food;
desc beermaker;
desc beer;

INSERT INTO merchants
VALUES(sec_merchants.nextval, 'FUNNY_STORE');

INSERT INTO beer
VALUES(sec_beer.nextval, 1, 'blonde', null, 'Ursus1', 1.30, to_date('1-2-1961','dd-mm-yyyy'), 0.5);

DECLARE
    x NUMBER;
BEGIN
    x := p_pachet1.monthly_profit(4);
    dbms_output.put_line(x);
END;
/

SELECT * FROM merchants;

EXECUTE p_pachet1.usefull_information('Galeo');
EXECUTE p_pachet1.usefull_information('fantastique');
EXECUTE p_pachet1.usefull_information('funny_store');
EXECUTE p_pachet1.usefull_information('Rustic');
EXECUTE p_pachet1.usefull_information('SEAFOOD_JOE');
EXECUTE p_pachet1.usefull_information('test');

INSERT INTO merchants
VALUES(6,'test');

INSERT INTO merchants
VALUES(7,'test');









