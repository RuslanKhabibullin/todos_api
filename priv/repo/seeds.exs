# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#

{:ok, _user} = TodosApi.Accounts.create_user(%{
  email: "user@email.com",
  password: "qweqweqwe"
})

{:ok, _user} = TodosApi.Accounts.create_user(%{
  email: "another_user@email.com",
  password: "qweqweqwe"
})

{:ok, _user} = TodosApi.Accounts.create_user(%{
  email: "third_user@email.com",
  password: "qweqweqwe"
})
