# Reassure.us

You're not alone.

# What
Build week project by the Health Lab. Let's talk about weird things to make ourselves feel better.

# Install and test locally
1) pull

2) `bundle install`

3) Create `.env` file with the following vars
```
ENVIRONMENT=development
FACEBOOK_APP_ID
FACEBOOK_APP_SECRET
SECRET
DATABASE_URL
```

4) Create a local Postgres database

5) Setup local DB with `foreman run rake db:migrate`

6) Run locally with `foreman run rackup` > check it out at `http://localhost:9292`

7) Once you log in and answer the question, you won't be able to view the /question page anymore because you'll redirected right to the answer page. In order to reset things you have to remove your response from the databse like so:
- `foreman run tux` #to get into open a console within the app environment
- `Answer.all.delete_all` #to remove your response

Then you can test it again from scratch.
