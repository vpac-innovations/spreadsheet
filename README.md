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
\timing on
\i /src/eav_schema.sql

\o /dev/null
\i /src/eav_query.sql
```

And then:

```
\timing on
\i /src/array_schema.sql

\o /dev/null
\i /src/array_query.sql
```

The `\o` command is optional; it hides the query output so you can concentrate
on the timings. Run `\o` with no arguments to let the query output be shown on
the screen again. Note that some commands like `\l` will display no output
until you stop the redirection.

Edit the query file to your liking and run it again (e.g. to change which sheet
to query). The SQL files are mounted as a Docker volume, so your changes should
show up straight away.

## Array

The array tests store all cells of a row as an [`ARRAY`] in a single row in the
database. Thus a spreadsheet with 16 columns and 10,000 rows will require
1 row in the `attribute` table and 10,000 rows in the `entry` table.

![Entity diagram][arr-ed]

## EAV

The EAV tests use a more normalised form, where each column is stored as an
*attribute*, and *cells* are stored as the intersection of an *entry* and
an attribute. Thus a spreadsheet with 16 columns and 10,000 rows will require
16 rows in the `attribute` table, 10,000 rows in the `entry` table, and
160,000 rows in the `cell` table. The table function [`crosstab`] is used to
pivot the data back into a spreadsheet.

![Entity diagram][eav-ed]

See [discussion] for results.

[`ARRAY`]: http://www.postgresql.org/docs/9.4/static/arrays.html
[`crosstab`]: http://www.postgresql.org/docs/9.1/static/tablefunc.html
[arr-ed]: doc/array.png
[eav-ed]: doc/eav.png
[discussion]: doc/discussion.md
