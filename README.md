## Schema Testing for Spreadsheets

This is a collection of tests for benchmarking variable-column schema. The use
case is storage of spreadsheets, where the columns are defined at runtime.
Although the columns are variable, the data is not sparse: every cell has a
value.

To run the tests, start a new test container:

```bash
sudo docker-compose run --rm pg_test
```

Then in the psql in the container:

```
\i /src/eea_normalised_schema.sql

-- Optional
--SET enable_seqscan = OFF;

\i /src/eea_normalised_query.sql
```

Edit the query file to your liking and run it again (e.g. to change which sheet
to query). The SQL files are mounted as a Docker volume, so your changes should
show up straight away.
