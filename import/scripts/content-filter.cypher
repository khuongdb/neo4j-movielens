MATCH (u:User)-[r:RATED]->(m:Movie)
// WHERE u.id = 10
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

// // Calculate predicted rating
// // based on average rating of similar movies with shared_genres
// WITH u, m, actual_rating,
//     COLLECT(r2_rating)[0..5] AS r2_ratings

// WITH u, m, actual_rating,
//     REDUCE(sum = 0, i IN RANGE(0, SIZE(r2_ratings) - 1) | sum + r2_ratings[i]) AS sum,
//     SIZE(r2_ratings) AS count_similarity
// WITH u, m, actual_rating,
//     sum/count_similarity AS predict_rating
// WITH u, m, actual_rating,
//     ROUND(predict_rating * 2) / 2 AS predict_rating

// // Calculate predict rating
// // base on the mode of m2.rating
// WITH u, m, actual_rating,
//     r2_rating,
//     COUNT(r2_rating) AS r2_freq
//     ORDER BY r2_freq DESC

// WITH u, m, actual_rating,
//     COLLECT(r2_rating) AS r2_ratings

// WITH u, m, actual_rating,
//     (r2_ratings[0..1]) AS predict_ratings

// UNWIND(predict_ratings) AS predict_rating


// Calculate predict rating 
// based on the median of similar movies
WITH u, m, actual_rating, 
    COLLECT(r2_rating) AS r2_ratings

WITH u, m, actual_rating,
    CASE 
        WHEN size(r2_ratings) % 2 = 0 
        THEN (r2_ratings[size(r2_ratings) / 2 - 1] + r2_ratings[size(r2_ratings) / 2]) / 2.0
        ELSE r2_ratings[size(r2_ratings) / 2]
    END AS predict_rating


// Model evaluation with square error
WITH u, m, actual_rating, predict_rating,
    (predict_rating - actual_rating) * (predict_rating - actual_rating) AS square_error

WITH u.id AS user,
    m.title AS movie,
    actual_rating,
    predict_rating,
    square_error
ORDER BY square_error DESC

// RETURN user, movie, actual_rating, predict_rating, square_error

//Total RSME of test dataset
// WITH COUNT(*) AS count, SUM(square_error) AS sse
// RETURN count, SQRT(tofloat(sse)/count) AS RMSE