DROP TABLE IF EXISTS graph_dump;
CREATE TABLE graph_dump AS
SELECT
    *
FROM
    json_tree(readfile('/Users/hessammehr/Code/DB/heck_graph.json'))
;

DROP TABLE IF EXISTS xdl_dump;
CREATE TABLE xdl_dump AS
SELECT
    *
FROM
    json_tree(readfile('/Users/hessammehr/Code/DB/heck_reaction_xdl.json'))
;

DROP TABLE IF EXISTS devices;
CREATE TABLE devices AS
SELECT
    json_extract(value, '$.internalId') as id,
    json_extract(value, '$.name') as name,
    json_extract(value, '$.class') as class,
    value as properties
FROM
    graph_dump
WHERE
    path = '$.nodes'
;

DROP TABLE IF EXISTS connections;
CREATE TABLE connections AS
SELECT
    json_extract(value, '$.id') as id,
    json_extract(value, '$.source') as "from",
    json_extract(value, '$.target') as "to",
    json_extract(value, '$.port') as "port",
    value as properties
FROM
    graph_dump
WHERE
    path = '$.links'
;

DROP TABLE IF EXISTS device_props;
CREATE TABLE device_props AS
SELECT 
    devices.id,
    "key" AS property,
    value
FROM 
    devices, json_each(devices.properties)
;

-- WITH ids AS (
-- SELECT value as "id", parent FROM node_dump WHERE "key"='internalId'
-- )
-- SELECT
--     ids.id, "key" as property, value
-- FROM
--     node_dump
-- INNER JOIN ids ON node_dump.parent = ids.parent
-- ;

DROP TABLE IF EXISTS components;
CREATE TABLE components AS
SELECT
    json_extract(value, '$.@id') as id,
    json_extract(value, '$.@type') as type
FROM
    xdl_dump
WHERE
    path = '$.Synthesis.Hardware'
;


DROP TABLE IF EXISTS steps;
CREATE TABLE steps AS
SELECT
    xdl_dump.ROWID as step_id,
    xdl_dump.key AS step,
    substr(vals.key, 2) as property,
    vals.value
FROM
    xdl_dump, json_tree(xdl_dump.value) AS vals
WHERE
    xdl_dump.path = '$.Synthesis.Procedure' AND
    vals.key LIKE '@%'
;

-- SELECT * FROM devices;
-- SELECT * FROM connections;
-- SELECT * FROM device_props;
-- SELECT * FROM components;
-- SELECT * FROM steps;
-- SELECT * FROM xdl_dump;
