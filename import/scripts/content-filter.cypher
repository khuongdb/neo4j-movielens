MATCH (u:User)-[r:RATED]->(m:Movie)
// WHERE u.id = 2
WITH u, collect(r) AS rcol
WITH u, head(rcol) AS r1
MATCH (u)-[r1]->(m)
WITH u, m, r1.rating AS actual_rating
LIMIT 100

// Find other movies that target user has rated
MATCH (u)-[r2:RATED]->(m2:Movie)
WHERE m2.id <> m.id
WITH u, m, actual_rating, m2, r2.rating AS r2_rating

// Find the common genres between target movie m and other movies m2
MATCH (m)-[:HAS_GENRE]->(g:Genre)<-[:HAS_GENRE]-(m2)
WITH u, m, actual_rating, 
    m2, r2_rating, 
    COLLECT(g.name) AS genres, COUNT(*) AS shared_genres
ORDER BY shared_genres DESC

// Calculate predicted rating
// based on average rating of similar movies with shared_genres
WITH u, m, actual_rating,
    COLLECT(r2_rating)[0..5] AS r2_ratings

WITH u, m, actual_rating,
    REDUCE(sum = 0, i IN RANGE(0, SIZE(r2_ratings) - 1) | sum + r2_ratings[i]) AS sum,
    SIZE(r2_ratings) AS count_similarity

WITH u, m, actual_rating,
    sum/count_similarity AS predict_rating

// Model evaluation with square error
WITH u, m, actual_rating, predict_rating,
    (predict_rating - actual_rating) * (predict_rating - actual_rating) AS square_error

WITH u.id AS user,
    m.title AS movie,
    actual_rating,
    predict_rating,
    square_error
ORDER BY square_error DESC

//Total RSME of test dataset
WITH COUNT(*) AS count, SUM(square_error) AS sse
RETURN count, SQRT(tofloat(sse)/count) AS RMSE