#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=highscore -t --no-align -c"
RANDOM_NUMBER=$(($RANDOM % 1000))

echo "Enter your username:"
read USERNAME

CHECK_USERNAME=$($PSQL "SELECT score_id FROM scores WHERE name='$USERNAME'")
if [[ -z $CHECK_USERNAME ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  ADD_PLAYER=$($PSQL "INSERT INTO scores(name, score, games) VALUES('$USERNAME',1000,0)")
  CURRENT_SCORE=1000
  CURRENT_GAMES=0
else
  CURRENT_SCORE=$($PSQL "SELECT score FROM scores WHERE name='$USERNAME'")
  CURRENT_GAMES=$($PSQL "SELECT games FROM scores WHERE name='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $CURRENT_GAMES games, and your best game took $CURRENT_SCORE guesses."
fi
CURRENT_ID=$($PSQL "SELECT score_id FROM scores WHERE name='$USERNAME'")
GUESS_GAME(){
  if [[ -z $1 ]]
  then
    echo "Guess the secret number between 1 and 1000:"
    CURRENT_GUESSES=0
  else
    echo $1
  fi
  read GUESS
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS < $RANDOM_NUMBER ]]
    then
      CURRENT_GUESSES=$(($CURRENT_GUESSES+1))
      GUESS_GAME "It's higher than that, guess again:"
    elif [[ $GUESS > $RANDOM_NUMBER ]]
    then
      CURRENT_GUESSES=$(($CURRENT_GUESSES+1))
      GUESS_GAME "It's lower than that, guess again:"
    else
      CURRENT_GUESSES=$(($CURRENT_GUESSES+1))
      echo "You guessed it in $CURRENT_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
      if [[ $CURRENT_GUESSES -lt $CURRENT_SCORE ]]
      then
        UPDATE_SCORE=$($PSQL "UPDATE scores SET score = $CURRENT_GUESSES WHERE score_id = $CURRENT_ID")
      fi
      CURRENT_GAMES=$(($CURRENT_GAMES+1))
      UPDATE_GAMES=$($PSQL "UPDATE scores SET games=$CURRENT_GAMES WHERE score_id=$CURRENT_ID")
    fi
  else
    GUESS_GAME "That is not an integer, guess again:"
  fi
}

GUESS_GAME
