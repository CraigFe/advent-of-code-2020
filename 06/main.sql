SET client_min_messages TO WARNING;
DROP TABLE IF EXISTS day06 CASCADE;

CREATE TABLE day06 (
    line_number integer NOT NULL GENERATED ALWAYS as IDENTITY,
    line text NOT NULL
);

\COPY day06 (line) FROM 'input.txt';

CREATE VIEW input as (
    SELECT line_number,
        line,
        count(*) FILTER (WHERE line = '') OVER (ORDER BY line_number) as grp
    FROM day06
);

----- Part 1 -------------------------------------------------------------------

SELECT sum(count) as distinct_responses FROM (
    SELECT count(DISTINCT response) FROM input,
    LATERAL unnest(string_to_array(line, NULL)) as response
    GROUP BY grp
) as _
;

----- Part 2 -------------------------------------------------------------------

WITH

group_size (grp, size) as (
    SELECT grp, count(line) FILTER (WHERE line <> '')
    FROM input
    GROUP BY grp
),

group_questions (grp, question, nb_responses) as (
    SELECT grp, response, count(*) FROM input,
    LATERAL unnest(string_to_array(line, NULL)) as response
    GROUP BY grp, response
    ORDER BY grp, response
)

SELECT count(*) as shared_responses
FROM group_questions
JOIN group_size ON group_questions.grp = group_size.grp
WHERE group_questions.count = group_size.size
;

