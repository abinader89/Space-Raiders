use Mix.Config

# In this file, we keep production configuration that
# you'll likely want to automate and keep away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).
config :space_raiders, SpaceRaidersWeb.Endpoint,
  secret_key_base: "X1of9ihLJK8MuVx+bd8PTcU4/z++UGoMLVfmjwAFBPO7Ctzckt32KiiMJDyWlOSN"

# Configure your database
config :space_raiders, SpaceRaiders.Repo,
  username: "postgres",
  password: "postgres",
  database: "space_raiders_prod",
  pool_size: 15
