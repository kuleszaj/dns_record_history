# DNS Record History

## Getting Started

 - Add a config file at `config/config.yml` following the pattern in `config/config.yml.example`.
 - Set a `DATABASE_URL` environment variable with a Postgres connection string.
 - Or have a default Postgres database available (localhost:5432/userid)
 - Run `bundle install`
 - Run `bundle exec rake dns:track_records`
