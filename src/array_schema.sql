\ir drop_schema.sql

CREATE TABLE sheet (
    id integer PRIMARY KEY,
    cols text[]
);

CREATE TABLE entry (
    sheet_id integer,
    cells integer[],
    area real,
    CONSTRAINT entry_sheet_fk FOREIGN KEY (sheet_id) REFERENCES sheet (id)
);

-- Populate

INSERT INTO sheet VALUES (1, '{"foo", "bar", "baz"}');

INSERT INTO entry SELECT id, cells, area FROM (
    SELECT
        generate_series(1, 1000) AS seq,
        1 AS id,
        ARRAY[
            (random() * 100)::int,
            (random() * 100)::int,
            (random() * 100)::int
        ] AS cells,
        random() * 1000 AS area
) AS temp;
