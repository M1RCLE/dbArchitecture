package main

import (
	"context"
	"fmt"
	"log"
	"math/rand/v2"
	"os"
	"regexp"
	"slices"
	"strconv"
	"time"

	"github.com/ilyakaznacheev/cleanenv"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var queries = []string{`WITH CrossJoinUseTag AS (SELECT
                               u.userid                AS user_id,
                               u.age                   AS user_age,
                               u.name                  AS username,
                               u.viewedinformation     AS viewed_information,
                               t.photoid               AS tag_photo_id
                           FROM "user" u LEFT JOIN tag t on u.userid = t.userid
                           GROUP BY viewed_information, user_age, username, tag_photo_id, user_id
), CrossJoinPhotoAndLocation AS (SELECT
                                p.userid             AS user_id,
                                p.likes              AS photo_likes,
                                l.name               AS location_name,
                                p.views              AS photo_views,
                                l.shortname          AS location_short_name
                           FROM photo p LEFT JOIN location l on p.locationid = l.locationid
                           GROUP BY photo_likes, photo_views, location_name, location_short_name, p.userid
)

SELECT * FROM CrossJoinPhotoAndLocation a JOIN CrossJoinUseTag b on a.user_id = b.user_id
WHERE a.photo_likes > $1 ORDER BY a.photo_likes, a.photo_views`,

	`WITH ViewsFilter AS(SELECT *
                    FROM photo WHERE views > $1
), LikesFilter AS(SELECT *
                  FROM photo WHERE likes > $1
)

SELECT * FROM ViewsFilter CROSS JOIN LikesFilter`,

	`WITH PhotoUserJoin AS (SELECT u.userid,
                              u.name,
                              u.age,
                              p.views,
                              p.likes,
                              p.photoid,
                              p.instagrampath,
                              p.locationid
                       FROM "user" u
                                JOIN photo p on u.userid = p.userid
                       WHERE p.likes < p.views),
     AlbumOrganizer AS (SELECT p.photoid, p.likes, p.locationid, p.userid, p.albumid
                        FROM photo p
                                 JOIN album a ON p.albumid = a.albumid
                        where p.views > p.likes)


SELECT *
FROM (SELECT *
      FROM PhotoUserJoin p
               JOIN location l ON (p.locationid = l.locationid)
      WHERE p.likes > 498400) as joined cross join AlbumOrganizer
`}

const (
	pattern = `cost=\d+\.\d+\.{2}(\d+\.\d+)`
)

type DbConfig struct {
	Port     string `yaml:"port" env:"DB_PORT" env_default:"5432"`
	Host     string `yaml:"host" env:"DB_HOST" env_default:"localhost"`
	Name     string `yaml:"name" env:"POSTGRES_DB" env_default:"postgres"`
	User     string `yaml:"user" env:"POSTGRES_USER" env_default:"postgres"`
	Password string `yaml:"password" env:"POSTGRES_PASSWORD" env_default:"postgres"`
	SslMode  string `yaml:"sslMode" env:"SSL_MODE" env_default:"disable"`
}

type ExplainAnalyzeResult struct {
	Best  float64
	Worst float64
	Avg   float64
}

func main() {
	var cfg DbConfig

	if err := cleanenv.ReadEnv(&cfg); err != nil {
		log.Fatalf("Failed to read environment variables: %v", err)
	}

	requiredEnvVars := []string{"ANALYZER_COUNT", "AMOUNT_OF_DATA"}
	for _, envVar := range requiredEnvVars {
		if os.Getenv(envVar) == "" {
			log.Fatalf("Environment variable %s is not set or empty", envVar)
		}
	}

	queriesCount, err := strconv.Atoi(os.Getenv("ANALYZER_COUNT"))
	if err != nil {
		log.Fatalf("Invalid ANALYZER_COUNT: %v", err)
	}

	fileName := fmt.Sprintf("logs/%s.log", time.Now().UTC().Format(time.RFC3339))
	file, err := os.Create(fileName)
	if err != nil {
		log.Fatalf("Failed to create log file: %v", err)
	}
	defer file.Close()

	databaseUrl := fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=%s",
		cfg.User, cfg.Password, cfg.Host, cfg.Port, cfg.Name, cfg.SslMode)

	config, err := pgxpool.ParseConfig(databaseUrl)
	if err != nil {
		log.Fatalf("Failed to parse database URL: %v", err)
	}

	pool, err := pgxpool.NewWithConfig(context.Background(), config)
	if err != nil {
		log.Fatalf("Failed to create database connection pool: %v", err)
	}
	defer pool.Close()

	re := regexp.MustCompile(pattern)
	results := make([]ExplainAnalyzeResult, 0, len(queries))

	for i, query := range queries {
		explainQuery := "EXPLAIN ANALYZE " + query
		log.Println(queriesCount)
		costs := make([]float64, 0, queriesCount)
		for j := 0; j < queriesCount; j++ {
			var rows pgx.Rows

			if i == 1 {
				value := rand.IntN(1000) + 490000
				rows, err = pool.Query(context.Background(), explainQuery, value)
			} else if i == 0 {
				value := rand.IntN(250000)
				rows, err = pool.Query(context.Background(), explainQuery, value)
			} else {
				rows, err = pool.Query(context.Background(), explainQuery)
			}

			if err != nil {
				log.Fatalf("Query failed: %v", err)
			}
			if rows.Next() {
				var s string
				if err = rows.Scan(&s); err != nil {
					log.Fatalf("Failed to scan row: %v", err)
				}
				matches := re.FindStringSubmatch(s)
				if len(matches) < 2 {
					log.Fatalf("Failed to parse cost from EXPLAIN output: %s", s)
				}
				cost, err := strconv.ParseFloat(matches[1], 64)
				if err != nil {
					log.Fatalf("Failed to parse float: %v", err)
				}
				costs = append(costs, cost)
			}
			rows.Close()
		}

		var sum float64
		for _, cost := range costs {
			sum += cost
		}
		log.Printf("Query %d done", i)
		results = append(results, ExplainAnalyzeResult{
			Best:  slices.Min(costs),
			Worst: slices.Max(costs),
			Avg:   sum / float64(queriesCount),
		})
	}

	for i, result := range results {
		file.WriteString(fmt.Sprintf("%d\n", i))
		file.WriteString(fmt.Sprintf("best:  %f\n", result.Best))
		file.WriteString(fmt.Sprintf("worst: %f\n", result.Worst))
		file.WriteString(fmt.Sprintf("avg:   %f\n", result.Avg))
	}
}
