CREATE CONSTRAINT FOR (m:Movie) REQUIRE m.id IS UNIQUE;

CREATE CONSTRAINT FOR (u:User) REQUIRE u.id IS UNIQUE;

LOAD CSV WITH HEADERS FROM "file:///movies.csv" AS line
WITH line, SPLIT(line.genres, "|") AS Genres
CREATE (m:Movie { id: TOINTEGER(line.`movieId`), title: line.`title` })
WITH Genres, m
UNWIND RANGE(0, SIZE(Genres)-1) as i
MERGE (g:Genre {name: toUpper(Genres[i])})
CREATE (m)-[r:HAS_GENRE {position:i+1}]->(g);

LOAD CSV WITH HEADERS FROM "file:///ratings.csv" AS line
WITH line
MATCH (m:Movie { id: TOINTEGER(line.`movieId`) })
MERGE (u:User { id: TOINTEGER(line.`userId`) })
CREATE (u)-[r:RATED {rating:TOFLOAT(line.`rating`)}]->(m);
