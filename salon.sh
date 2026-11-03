#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?"

MAIN_MENU() {
  SERVICES=$($PSQL "SELECT service_id,name FROM services")

  echo "$SERVICES" | while read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME" | sed 's/ |//'
  done
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ || -z $SERVICE_ID_SELECTED ]]
  then
    echo -e "\nI could not find that service. What would you like today?"
    MAIN_MENU
  else
    SERVICE_EXISTS=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_EXISTS ]]
    then
      echo -e "\nI could not find that service. What would you like today?"
      MAIN_MENU
    fi
  fi
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
}
MAIN_MENU

CUSTOMER_INFO() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  PHONE_EXISTS=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $PHONE_EXISTS ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    $PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')"
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    echo -e "\nWhat time would you like your$SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    $PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')"
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo -e "\nWhat time would you like your$SERVICE_NAME,$CUSTOMER_NAME?"
    read SERVICE_TIME

    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    $PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')"
  fi
}
CUSTOMER_INFO

