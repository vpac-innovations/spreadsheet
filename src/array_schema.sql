\ir drop_schema.sql

CREATE TABLE sheet (
    id UUID PRIMARY KEY NOT NULL,
    name text NOT NULL,
    cols text[] NOT NULL
);

CREATE TABLE entry (
    id UUID PRIMARY KEY NOT NULL,
    seq int NOT NULL,
    sheet_id UUID NOT NULL,
    cells integer[] NOT NULL,
    area real NOT NULL,
    CONSTRAINT entry_sheet_fk FOREIGN KEY (sheet_id) REFERENCES sheet (id)
);
CREATE INDEX ON entry (sheet_id);

CREATE FUNCTION create_sheet (name text, width int, height int)
RETURNS text
AS $$
    DECLARE
        sid UUID;
        cats text[];
        aid UUID;
    BEGIN
        RAISE NOTICE 'Creating sheet % with % cells', name, width * height;

        cats := ARRAY[
            'foo', 'bar', 'baz',
            'qux', 'quux', 'corge',
            'grault', 'garply',
            'waldo', 'fred',
            'plugh', 'xyzzy', 'thud',
            'wibble', 'wobble', 'wubble'];

        INSERT INTO sheet
            VALUES (uuid_generate_v4(), name, cats[1:width])
            RETURNING id INTO sid;

        FOR j IN 1..height LOOP
            INSERT INTO entry
                SELECT
                    uuid_generate_v4(),
                    j,
                    sid,
                    array_agg(c.cell),
                    random() * 1000
                FROM (
                    SELECT
                        generate_series(1, width) AS i,
                        (random() * 30)::int AS cell
                ) AS c;
        END LOOP;

        RETURN name;
    END;
$$ LANGUAGE plpgsql;


-- Populate

select create_sheet('PAD0', 8, 10000);
select create_sheet('PAD1', 8, 10000);
select create_sheet('two', 2, 10000);
select create_sheet('PAD2', 8, 10000);
select create_sheet('PAD3', 8, 10000);
select create_sheet('four', 4, 10000);
select create_sheet('PAD4', 8, 10000);
select create_sheet('PAD5', 8, 10000);
select create_sheet('eight', 8, 10000);
select create_sheet('PAD6', 8, 10000);
select create_sheet('PAD7', 8, 10000);
select create_sheet('sixteen', 16, 10000);
select create_sheet('PAD8', 8, 10000);
select create_sheet('PAD9', 8, 10000);

VACUUM ANALYZE;
\l+ postgres
