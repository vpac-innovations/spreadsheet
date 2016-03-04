# Schema Testing for Spreadsheets

This is a collection of tests for benchmarking variable-column schema. The use
case is storage of spreadsheets, where most of the columns are defined at
runtime. Although the columns are variable, the data is not sparse: every cell
has a value.

To run the tests, start a new test container:

```
sudo docker-compose run --rm pg_test
```

Then at the `psql` prompt in the container:

```
\i /src/eav_schema.sql
\i /src/eav_query.sql
```

Edit the query file to your liking and run it again (e.g. to change which sheet
to query). The SQL files are mounted as a Docker volume, so your changes should
show up straight away.

## Array

The array tests store all cells of a row as an [`ARRAY`] in a single row in the
database. Thus a spreadsheet with 16 columns and 10,000 rows will require
1 row in the `attribute` table and 10,000 rows in the `entry` table.

## EAV

The EAV tests use a more normalised form, where each column is stored as an
*attribute*, and *cells* are stored as the intersection of an *entry* and
an attribute. Thus a spreadsheet with 16 columns and 10,000 rows will require
16 rows in the `attribute` table, 10,000 rows in the `entry` table, and
160,000 rows in the `cell` table. The table function [`crosstab`] is used to
pivot the data back into a spreadsheet.

[Entity diagram][eav-ed]

[`ARRAY`]: http://www.postgresql.org/docs/9.4/static/arrays.html
[`crosstab`]: http://www.postgresql.org/docs/9.1/static/tablefunc.html
[eav-ed]: doc/eav.svg
