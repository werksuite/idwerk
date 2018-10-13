# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     IdWerk.Repo.insert!(%IdWerk.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias IdWerk.{Accounts, Services, Authorizations}

{:ok, user} =
  Accounts.create_user(%{username: "sam", email: "sam@example.com", password: "123456"})

{:ok, service} = Services.create_service(%{name: "docker-images.local"})
