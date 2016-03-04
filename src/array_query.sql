\echo 'Basic extraction of entry data, just 10 rows'
SELECT e.seq, e.cells, e.area
    FROM entry AS e
    JOIN sheet AS s ON (e.sheet_id = s.id)
    WHERE s.name = 'two'
    ORDER BY e.seq
    LIMIT 10;

-- Convert array data into tabular, with each item in a separate column.
-- Comment out the columns that you don't need, and set s.name to
-- the sheet you're interested in. E.g. if you want to query against sheet
-- "four", comment out the category lines from six - sixteen.
\echo 'Unpacking columns using array subscript'
SELECT
    e.cells[1] AS cat1, -- one
    e.cells[2] AS cat2, -- two
    e.cells[3] AS cat3, e.cells[4] AS cat4, -- four
    e.cells[5] AS cat5, e.cells[6] AS cat6, -- six
    e.cells[7] AS cat7, e.cells[8] AS cat8, -- eight
    e.cells[9] AS cat9, e.cells[10] AS cat10, -- ten
    e.cells[11] AS cat11, e.cells[12] AS cat12, -- twelve
    e.cells[13] AS cat13, e.cells[14] AS cat14, -- fourteen
    e.cells[15] AS cat15, e.cells[16] AS cat16, -- sixteen
    e.area
FROM entry AS e
JOIN sheet AS s ON (e.sheet_id = s.id)
WHERE s.name = 'sixteen'
ORDER BY 1, 2, 3, 4
;

-- As above, but filter on a couple of columns
\echo 'Unpack columns using subscript and filter a couple of columns'
SELECT
    e.cells[1] AS cat1, -- one
    e.cells[2] AS cat2, -- two
    e.cells[3] AS cat3, e.cells[4] AS cat4, -- four
    e.cells[5] AS cat5, e.cells[6] AS cat6, -- six
    e.cells[7] AS cat7, e.cells[8] AS cat8, -- eight
    e.cells[9] AS cat9, e.cells[10] AS cat10, -- ten
    e.cells[11] AS cat11, e.cells[12] AS cat12, -- twelve
    e.cells[13] AS cat13, e.cells[14] AS cat14, -- fourteen
    e.cells[15] AS cat15, e.cells[16] AS cat16, -- sixteen
    e.area
FROM entry AS e
JOIN sheet AS s ON (e.sheet_id = s.id)
WHERE s.name = 'sixteen'
    AND e.cells[1] BETWEEN 20 AND 30
    AND e.cells[2] BETWEEN 10 AND 20
ORDER BY 1, 2, 3, 4
;

\echo 'Again, but just two columns from a large set'
SELECT
    e.cells[1] AS cat1, -- one
    e.cells[2] AS cat2, -- two
    e.area
FROM entry AS e
JOIN sheet AS s ON (e.sheet_id = s.id)
WHERE s.name = 'sixteen'
    AND e.cells[1] BETWEEN 20 AND 30
    AND e.cells[2] BETWEEN 10 AND 20
ORDER BY 1, 2
;

\echo 'Again, but without decomposing the array'
SELECT
    e.cells,
    e.area
FROM entry AS e
JOIN sheet AS s ON (e.sheet_id = s.id)
WHERE s.name = 'sixteen'
    AND e.cells[1] BETWEEN 20 AND 30
    AND e.cells[2] BETWEEN 10 AND 20
ORDER BY 1, 2
;

-- Convert array data into tabular, with each item in a separate column.
-- Unnest it to the same form as the EAV table first, then use a table function
-- to pivot it back to column form. This test has much less IO than the pure
-- EAV test, so it might give a hint about whether EAV is processor or disk
-- bound.
-- Comment out the columns that you don't need, and set s.name to
-- the sheet you're interested in. E.g. if you want to query against sheet
-- "four", comment out the category lines from six - sixteen.
\echo 'Unnesting array to EAV and then pivoting to multi-column table'
\echo 'The result should be equivalent to the array subscript method'
SELECT
    ct.cat1, -- one
    ct.cat2, -- two
    ct.cat3, ct.cat4, -- four
    ct.cat5, ct.cat6, ct.cat7, ct.cat8, -- eight
    ct.cat9, ct.cat10, ct.cat11, ct.cat12, ct.cat13, ct.cat14, ct.cat15, ct.cat16, -- sixteen
    e.area
FROM crosstab($$
    SELECT e.seq, c.i, c.value
        FROM entry AS e
        LEFT JOIN LATERAL unnest(e.cells) WITH ORDINALITY AS c(value, i) ON TRUE
        JOIN sheet AS s ON (e.sheet_id = s.id)
        WHERE s.name = 'sixteen'
        ORDER BY 1
    $$) AS ct(
        row_id int
        , cat1 int -- one
        , cat2 int -- two
        , cat3 int, cat4 int -- four
        , cat5 int, cat6 int, cat7 int, cat8 int -- eight
        , cat9 int, cat10 int, cat11 int, cat12 int, cat13 int, cat14 int, cat15 int, cat16 int -- sixteen
    )
JOIN entry AS e ON (e.seq = ct.row_id)
JOIN sheet AS s ON (e.sheet_id = s.id)
WHERE s.name = 'sixteen'
ORDER BY 1, 2, 3, 4
;
