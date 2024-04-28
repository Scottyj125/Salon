#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -A -c"

echo -e "\n~~~~~ SALON AUTOMATED APPOINTMENT PROGRAM ~~~~~"

MAIN_MENU() {
  
  # PRINT ERROR MESSAGE if one is supplied
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # PRINT MENU
  echo "$($PSQL "SELECT * FROM services")" | while IFS='|' read  SERVICE_ID SERVICE
  do
    echo "$SERVICE_ID) $SERVICE" 
  done
  # GET SERVICE ID
  read SERVICE_ID_SELECTED

  # VALIDATE SERVICE ID: NUMBER
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # not a number
    MAIN_MENU "Service number must be a number."
  fi

  # get service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  # check if service exists
  if [[ -z $SERVICE_NAME ]] 
  then
    # no service
    MAIN_MENU "Service not found."
  fi

  # get additional info
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE

  if [[ -z $CUSTOMER_PHONE ]]
  then
    # MAIN_MENU "Please enter a valid phone number"
    exit
  fi

  # GET CUSTOMER ID
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  # CHECK IF PHONE_NUMBER matches an existing customer
  if [[ -z $CUSTOMER_NAME ]]
  then
    # no match
    echo -e "\nNo matching customer data in the database.\nPlease input a name for registration:"
    read CUSTOMER_NAME

    if [[ -z $CUSTOMER_NAME ]]
    then
      # MAIN_MENU "Invalid name!"
      exit
    fi

    #INSERT
    ADD_NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    if [[ $ADD_NEW_CUSTOMER_RESULT != "INSERT 0 1" ]]
    then
      # INSERT FAILED
      # MAIN_MENU "New Customer registration failed. Please input valid customer details"
      exit
    fi
  fi

  # Get customer ID for later
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  echo -e "\nPlease input your preferred time for your service, $SERVICE_NAME:"
  read SERVICE_TIME

  #ADD APPOINTMENT
  ADD_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  if [[ $ADD_APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    exit ## added to complete test 1.16
    # Tests are no longer functionin so I find a more approriate fix
  fi
}

MAIN_MENU "Please select a service:\n"
