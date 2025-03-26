#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  local MESSAGE=$1

  while true; do
    if [[ $MESSAGE ]]; then
      echo -e "\n$MESSAGE"
    fi

    # Display list of menu items
    echo -e "\n~~~~~ THE GREATEST SALON OF ALL TIME ~~~~~\n"
    SERVICES_RESULT=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
    
    echo "$SERVICES_RESULT" | while read ID BAR NAME; do
      echo "$ID) $NAME"
    done

    read SERVICE_ID_SELECTED

    # Validate input
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
      MESSAGE="Please enter a valid number."
      continue
    fi

    # Check if service ID exists
    SELECTION_RESULT=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")

    if [[ -z $SELECTION_RESULT ]]; then
      MESSAGE="I could not find that service. What would you like today?"
      continue
    fi

    break  # Exit the loop when a valid service ID is selected
  done

  # Get customer phone number
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE

  PHONE_RESULT=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  if [[ -z $PHONE_RESULT ]]; then
    # New customer, ask for name
    echo -e "\nWhat is your name?"
    read CUSTOMER_NAME

    # Insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  else
    CUSTOMER_NAME=$PHONE_RESULT
  fi
  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^ //')
  SELECTION_RESULT_FORMATTED=$(echo $SELECTION_RESULT | sed 's/^ //')
  
  # Retrieve customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # Ask for appointment time
  echo -e "\nWhat time would you like to come in for the appointment?"
  read SERVICE_TIME

  INSERT_APPOINTMENT_RESULTS=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")

  if [[ -z $INSERT_APPOINTMENT_RESULTS ]]; then
    echo -e "\nAppointment could not be created."
  else
    echo -e "\nI have put you down for a $SELECTION_RESULT_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  fi
}



MAIN_MENU
