SELECT e.seq, a1.name, c1.value, e.area
    FROM entry AS e
    JOIN cell AS c1 ON (c1.entry_id = e.id)
    JOIN attribute AS a1 ON (c1.attribute_id = a1.id)
    JOIN sheet AS s ON (e.sheet_id = s.id)
    WHERE s.name = 'two'
    ORDER BY e.seq
    LIMIT 10;

-- Convert EAV data into tabular, with each attribute as a separate column.
-- Comment out the columns that you don't need (two places), and set s.name to
-- the sheet you're interested in (also two places). E.g. if you want to query
-- against sheet "four", comment out the category lines for eight and sixteen.
EXPLAIN ANALYZE
SELECT
    ct.cat1, -- one
    ct.cat2, -- two
    ct.cat3, ct.cat4, -- four
    ct.cat5, ct.cat6, ct.cat7, ct.cat8, -- eight
    ct.cat9, ct.cat10, ct.cat11, ct.cat12, ct.cat13, ct.cat14, ct.cat15, ct.cat16, -- sixteen
    e.area
FROM crosstab(
    'SELECT e.seq, a.name, c.value
        FROM entry AS e
        JOIN cell AS c ON (c.entry_id = e.id)
        JOIN attribute AS a ON (c.attribute_id = a.id)
        JOIN sheet AS s ON (e.sheet_id = s.id)
        WHERE s.name = ''sixteen''
        ORDER BY 1
    ') AS ct(
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
