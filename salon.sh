#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

SALON() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  ALL_SERVICES=$($PSQL "SELECT service_id,name FROM services")
  while IFS="|" read ID NAME
  do
    echo "$ID) $NAME"
  done <<< "$ALL_SERVICES"

  read SERVICE_ID_SELECTED
  if [[ "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]]
  then
    SERVICE_CHOICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  else
    SALON "I could not find that service. What would you like today?"
    return
  fi

  if [[ -z $SERVICE_CHOICE ]]
  then
    SERVICE_ID_SELECTED=""
    SALON "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    PHONE_RESULT=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $PHONE_RESULT ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    else
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi
    echo -e "\nWhat time would you like your $SERVICE_CHOICE, $CUSTOMER_NAME?"
    read SERVICE_TIME
    NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_CHOICE at $SERVICE_TIME, $CUSTOMER_NAME.\n"
  fi
}

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"
SALON
