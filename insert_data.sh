#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#delete previous data
$PSQL "TRUNCATE TABLE games, teams"

#query teams name in data file
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONNENT_GOALS
do
if [[ $YEAR != "year" ]]
then 
  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  #if team do not exist yet
  if [[ -z $TEAM_ID ]]
  then
      #insert team into teams table
      INSERT_TEAM_ID=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")
  fi
  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'") 
  #if team do not exist yet
  if [[ -z $TEAM_ID ]]
  then
      #insert team into teams table
      INSERT_TEAM_ID=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")
  fi
fi
done

#query games from data file
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    GAME_ID=$($PSQL "SELECT game_id FROM games LEFT JOIN teams as t1 ON winner_id = t1.team_id LEFT JOIN teams as t2 ON opponent_id = t2.team_id WHERE t1.name = '$WINNER' AND t2.name = '$OPPONENT'")
    #if game does not exist yet 
    if [[ -z $GAME_ID ]]
    then 
      #Query teams ID
      WINNER_ID=$($PSQL "SELECT team_id from teams where name='$WINNER'");
      OPPONENT_ID=$($PSQL "SELECT team_id from teams where name='$OPPONENT'");
      #Insert game into games table
      INSERT_GAME_ID=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    fi
  fi
done
