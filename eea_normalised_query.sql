SELECT e.id, a1.name, c1.value, e.area
    FROM entry AS e
    JOIN cell AS c1 ON (c1.entry_id = e.id)
    JOIN attribute AS a1 ON (c1.attribute_id = a1.id)
    WHERE e.sheet_id = 1
    LIMIT 10;

EXPLAIN ANALYZE SELECT e.id, ct.cat1, ct.cat2, ct.cat3, ct.cat4, ct.cat5, e.area
FROM crosstab(
    'SELECT e.id, a.name, c.value
        FROM entry AS e
        JOIN cell AS c ON (c.entry_id = e.id)
        JOIN attribute AS a ON (c.attribute_id = a.id)
        WHERE e.sheet_id = 1
        ORDER BY 1
    ') AS ct(row_id int, cat1 int, cat2 int, cat3 int, cat4 int, cat5 int)
JOIN entry AS e ON (e.id = ct.row_id)
WHERE e.sheet_id = 1;
