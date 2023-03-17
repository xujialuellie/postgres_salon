#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to my salon, how can I help you?\n"

MAIN_MENU() {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  if [[ -z $SERVICE ]]
  then
    echo -e "\nSorry, we don't have any service right now."
  else
    echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  fi
  
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    #return to main menu
    MAIN_MENU "Sorry, that is invalid input. Please try again."
  else
    CURRENT_SERVICE=$($PSQL "SELECT service_id, name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
    if [[ -z $CURRENT_SERVICE ]]
    then
      #return to main menu
      MAIN_MENU "I could not find that service. What else can I do for you?"
    else
      echo -e "\nWhat is your phone number?"
      read CUSTOMER_PHONE
      CURRENT_PHONE=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")

      if [[ -z $CURRENT_PHONE ]]
      then
        echo -e "\nI don't have a record for that phone number. What is your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_NAME_AND_PHONE=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      else
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
        echo -e "\nWhat time would you like your$SERVICE_NAME?"
        read SERVICE_TIME
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        INSERT_APPOINTMENT_TIME=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
      fi
    fi
  fi
}

MAIN_MENU
