-- We'll insert some sample data, this will create a new suite and
-- With the trigger will create a new suite status

INSERT INTO "suites" ("price","type","rooms","beds")
VALUES (1000,"luxury",3,6),(300,"business",2,4),(50,"family",3,6);

SELECT suites.id,suites.price,suites.type,suite_status.status FROM "suites"
JOIN "suite_status" ON suites.id = suite_status.suite_id;

-- Alice registers to the hotel website.
INSERT INTO "clients" ("first_name","last_name","phone_number","email")
VALUES ("Alice","TheFirst","+1-555-01-23","alicethefirst@duck.com");

SELECT * FROM clients;

-- We hire someone to clean.
INSERT INTO "staff" ("first_name","last_name","job")
VALUES ("Arwin","Quentin","Cleaner");

SELECT * FROM "staff";

-- Alice will be booking some days in the hotel.
INSERT INTO "bookings" ("suite_id","client_id","check_in","check_out")
VALUES (1,1,'2024-12-03 13:00','2024-12-10 13:00');

-- check status
SELECT * FROM "suite_status";


-- After 2 days we get a new customer
INSERT INTO "clients" ("first_name","last_name","phone_number","email")
VALUES ("Bob","TheSecond","+1-555-02-23","bobtherealdeal@duck.com");

-- check what is available
SELECT * FROM "available_suites";

INSERT INTO "bookings" ("suite_id","client_id","check_in","check_out")
VALUES (1,2,'2024-12-05 13:00','2024-12-12 13:00');

INSERT INTO "bookings" ("suite_id","client_id","check_in","check_out")
VALUES (2,2,'2024-12-05 13:00','2024-12-12 13:00');

-- Alice goes and apartment needs to be clenaed.
UPDATE "suite_status" SET "status" = 'cleaning'
WHERE "suite_id" = (SELECT suite_id FROM bookings WHERE id = 1);

-- Status of the suites
 SELECT * FROM "suite_status";

-- We call Arwin to clean
INSERT INTO "staff_activity" ("staff_id","suite_id","tasks")
VALUES ("1",(SELECT suite_id FROM suite_status WHERE "status" = 'cleaning'),"clean");

-- We can see the tasks of your employees
SELECT * FROM "staff_activity";

-- We can see the suites that are ready
SELECT * FROM "suite_status";

-- Finally we have luxury and family suite available for new bookings
SELECT * FROM "available_suites";

-- We have noticed that nobody rents family suite, we'll delete it from our data base while we transform it into a luxury suite

DELETE FROM "suite_status" WHERE "suite_id" = (
    SELECT "id" FROM "suites" WHERE "type" = 'family');
DELETE FROM "suites" WHERE "type" = 'family';

SELECT * FROM "available_suites";

SELECT * FROM "bookings";

-- Now let's see the results of our business
SELECT * FROM "income_by_suite";
