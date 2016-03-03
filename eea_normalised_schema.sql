DROP TABLE IF EXISTS cell;
DROP TABLE IF EXISTS attribute;
DROP TABLE IF EXISTS entry;
DROP TABLE IF EXISTS sheet;
DROP FUNCTION IF EXISTS create_sheet(text, int, int);
DROP EXTENSION IF EXISTS "tablefunc";
DROP EXTENSION IF EXISTS "uuid-ossp";

CREATE EXTENSION "tablefunc";
CREATE EXTENSION "uuid-ossp";

CREATE TABLE sheet (
    id UUID PRIMARY KEY NOT NULL,
    name text NOT NULL,
    width int NOT NULL
);

CREATE TABLE attribute (
    id UUID PRIMARY KEY NOT NULL,
    sheet_id UUID NOT NULL,
    name text NOT NULL,
    CONSTRAINT entry_sheet_fk FOREIGN KEY (sheet_id) REFERENCES sheet (id)
);

CREATE TABLE entry (
    id UUID PRIMARY KEY NOT NULL,
    sheet_id UUID NOT NULL,
    area real NOT NULL,
    CONSTRAINT entry_sheet_fk FOREIGN KEY (sheet_id) REFERENCES sheet (id)
);

CREATE TABLE cell (
    sheet_id UUID NOT NULL,
    attribute_id UUID NOT NULL,
    entry_id UUID NOT NULL,
    value integer,
    CONSTRAINT entry_sheet_fk FOREIGN KEY (sheet_id) REFERENCES sheet (id),
    CONSTRAINT cell_attribute_fk FOREIGN KEY (attribute_id) REFERENCES attribute (id),
    CONSTRAINT cell_entry_fk FOREIGN KEY (entry_id) REFERENCES entry (id)
);

-- CREATE INDEX

CREATE FUNCTION create_sheet (name text, width int, height int)
RETURNS void
AS $$
    DECLARE
        sid UUID;
        cats text[];
        aid UUID;
    BEGIN
        cats := ARRAY['foo', 'bar', 'baz',
            'qux', 'quux', 'corge',
            'grault', 'garply',
            'waldo', 'fred'];

        INSERT INTO sheet
            VALUES (uuid_generate_v4(), 'sheet', width)
            RETURNING id INTO sid;

        FOR j IN 1..height LOOP
            INSERT INTO entry VALUES (
                uuid_generate_v4(),
                sid,
                random() * 1000);
        END LOOP;

        FOR i IN 1..width LOOP
            INSERT INTO attribute
                VALUES (uuid_generate_v4(), sid, cats[i])
                RETURNING id INTO aid;

            INSERT INTO cell
                SELECT sid, aid, e.id, (random() * 100)::int
                FROM entry AS e
                WHERE e.sheet_id = sid;
        END LOOP;
    END;
$$ LANGUAGE plpgsql;


-- Populate

select create_sheet('sheet', 3, 1000);
