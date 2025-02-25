-- This is the schema of the Mateus Hotel Data base.

-- Information tables: First, we'll create the tables that contain the main data or information.
CREATE TABLE "suites"(
    "id" INTEGER,
    "price" INTEGER NOT NULL,
    "type" TEXT NOT NULL CHECK ("type" IN ('luxury','business','family')), --Luxury, business, family
    "rooms" INTEGER NOT NULL,
    "beds" INTEGER NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "clients"(
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "phone_number" TEXT UNIQUE,
    "email" TEXT UNIQUE,
    PRIMARY KEY("id")
);

CREATE TABLE "staff"(
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "job" TEXT NOT NULL UNIQUE,
    PRIMARY KEY("id")
);

-- Actions tables: These represent relationships and processes.
CREATE TABLE "bookings" (
    "id" INTEGER,
    "suite_id" INTEGER,
    "client_id" INTEGER,
    "check_in" NUMERIC NOT NULL,
    "check_out" NUMERIC NOT NULL,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("suite_id") REFERENCES "suites"("id"),
    FOREIGN KEY ("client_id") REFERENCES "clients"("id")
);

CREATE TABLE "suite_status" (
    "suite_id" INTEGER,
    "status" TEXT DEFAULT 'ready' CHECK ("status" IN('ready','booked', 'cleaning')), -- Ready, booked, cleaning
    FOREIGN KEY ("suite_id") REFERENCES "suites"("id")
);

CREATE TABLE "staff_activity"(
    "staff_id" INTEGER NOT NULL,
    "suite_id" INTEGER,
    "tasks" TEXT NOT NULL,
    FOREIGN KEY ("suite_id") REFERENCES "suites"("id"),
    FOREIGN KEY ("staff_id") REFERENCES "staff"("id")
);

-- Creating indexes for expected frequently queried items.
CREATE INDEX "fast_suite_status" ON "suite_status"("suite_id");
CREATE INDEX "fast_bookings" ON "bookings"("suite_id", "client_id");


-- This trigger will avoid to book suites that are not available.
CREATE TRIGGER "check_availability"
BEFORE INSERT ON "bookings"
FOR EACH ROW
BEGIN -- https://sqlite.org/syntax/raise-function.html
    SELECT RAISE(ABORT, 'The suite is not available for booking')
    WHERE (SELECT "status" FROM "suite_status" WHERE suite_id = NEW.suite_id) != 'ready';
END;


-- Adds the new suite to the status table
CREATE TRIGGER "new_suite_status"
AFTER INSERT ON "suites"
FOR EACH ROW
BEGIN
    INSERT INTO "suite_status" ("suite_id", "status")
    VALUES (NEW.id,'ready');
END;

-- This trigger will update the suite status to booked when someone takes it.
CREATE TRIGGER "booked_suite"
AFTER INSERT ON "bookings"
FOR EACH ROW
BEGIN
    UPDATE "suite_status" SET "status" = 'booked'
    WHERE suite_id = NEW.suite_id;
END;

-- When a staff member reports a clean room it will automatically turn it to ready.
CREATE TRIGGER "cleaned_room_ready"
AFTER INSERT ON "staff_activity"
FOR EACH ROW
BEGIN
    UPDATE "suite_status" SET "status" = 'ready'
    WHERE suite_id = NEW.suite_id AND NEW.tasks = 'clean';
END;

-- Check the available suites and their properties quickly.
-- This would be useful for a clerk at the reception.
CREATE VIEW "available_suites" AS
    SELECT "id","type","rooms","beds","price" FROM "suites"
    WHERE "id" IN(SELECT "suite_id" FROM "suite_status" WHERE "status" = 'ready');

-- Total earnings by suite
-- https://www.sqlite.org/lang_expr.html Cast function
-- https://www.techonthenet.com/sqlite/functions/julianday.php JulianDay

CREATE VIEW "income_by_suite" AS
    SELECT bookings.suite_id, suites.price AS 'Price per night',
            -- We take check out - check in as integers to ensure the calculation works
           CAST((JULIANDAY(bookings.check_out)- JULIANDAY(bookings.check_in)) AS INTEGER) AS 'Total_nights',
           CAST((JULIANDAY(bookings.check_out)- JULIANDAY(bookings.check_in)) AS INTEGER) * suites.price AS 'Total_earnings'
    FROM "bookings" JOIN "suites" ON bookings.suite_id = suites.id;
