# Discussion

The EAV model produces about 170,000 rows for the 16x10,000 spreadsheet,
while the array model produces about 10,000 rows for the same data. In total
(all sheets), EAV uses almost 200MB, while array uses almost 35MB.

Execution time for insert and query are an order of magnitude faster with
the array model (20ms vs 250ms). However, when increasing the sheet dimensions
both models seem to scale linearly with the types of queries that were
performed - so EAV *may* be suitable if the base performance is considered good
enough.

None of the queries used multiple joins, although the EAV queries
used a table function that does something like joining internally. An
application making use of the data would need to do something similar, even if
it just pulled the data out in a raw unjoined form - and even that kind of raw
query was considerably slower when using EAV.

The tests were all run on databases that were warm and vacuumed. It might be
worth running more tests with disk cache flushes in between to get a more
realistic picture of the IO resources used.
