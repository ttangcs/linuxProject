#!/bin/bash

todoItemCount=0
argument1=${1:-0}
argument2=${2:-0}
validInput="no"

#Check if there is not a todo directory if not make one
if [ ! -d "/todo" ]
then
  mkdir todo
fi


#Check if there is not a todo completed directory if not make one 
if [ ! -d "/todo.completed" ]
then
  mkdir todo.completed

fi


# Functions
function printWelcome()
{
  echo "Welcome to to-do list manager! Here are your current items."
}


function printOptions()
{
  if [ $todoItemCount -gt 0 ]
  then
    echo "1-$todoItemCount) See more information on this item"
    echo "A) Mark an item as completed"
  fi
  echo "B) Add a new item"
  echo "C) See completed items"

  echo ""
  echo "Q) Quit"

}


function addNewItem()
{
  read -p 'Enter title : ' newTitle
  read -p 'Enter additional text: ' newAddiText

  newTitle="${newTitle// /_}"

  echo "$newAddiText" > ./todo/$newTitle
  updateTodoList
}

function addNewItemCli()
{
  newTitle=$1

  newAddiText=`cat /dev/stdin`

  newTitle="${newTitle// /_}"

  echo "$newAddiText" > ./todo/$newTitle
  updateTodoList
}

function markComplete()
{
  fileName=`ls todo | grep "^$1,"`
  mv ./todo/$fileName ./todo.completed/$fileName
  updateTodoList
}


function previewItem()
{
  echo ""
  echo `ls todo | grep "^$1,"`
  echo "-----"
  cat ./todo/`ls todo | grep "^$1,"`
  echo ""
}


function listTodo()
{
  updateTodoList
  for todo in ./todo/*
  do [ -e "$todo" ] || continue
    todo="${todo:7}"
    todo="${todo/,/)}"
    echo "$todo"
  done

  echo ""
}

function listCompletedTodos()
{
  echo ""
  for todo in ./todo.completed/*
  do [ -e "$todo" ] || continue
    todo="${todo:17}"
    todoCut=$(echo $todo | cut -f2 -d,)
    echo "$todoCut"
  done
  echo ""
}


function updateTodoList()
{
  let todoItemCount=0

  for todo in ./todo/*
  do [ -e "$todo" ] || continue
    ((++todoItemCount))
    if [[ $todo =~ "," ]]
    then
      todoCut=$(echo $todo | cut -f2 -d,)
    else
      todoCut="${todo:7}"
    fi
    string="$todoItemCount,$todoCut"
    mv $todo ./todo/$string
  done
}


function getHelp()
{
  echo "list - list uncompleted items"
  echo "complete number - number being a number corresponding to a todo item"
  echo "list completed - lists the completed items"
  echo "add title - adds a new item with the given title; whatever is sent to standard input would be the additional text."
}

function updatePermissions()
{
  chmod -R 700 ./todo/
  chmod -R 700 ./todo.completed/
}






if [ "$argument1" == "help" ] 
then
  getHelp
fi

if [ "$argument1" == "list" ] 
then
  if [ "$argument2" == "completed" ]
  then
    listCompletedTodos
  else
    listTodo
  fi
fi

if [ "$argument1" == "complete" ] 
then
  markComplete $argument2
fi

if [ "$argument1" == "add" ] 
then
  addNewItemCli $argument2
fi

while [ $argument1 -eq 0 ]; do
  echo ""
  printWelcome
  listTodo
  printOptions

  validInput="n"

  read -p 'Enter Choice : ' userInput

  if ((userInput >= 1 && userInput <= todoItemCount)) 
  then
    validInput="y"
    previewItem $userInput
  fi

  if [ "$userInput" == "A" ] 
  then
    validInput="y"
    echo "Mark which one?"
    listTodo

    read -p 'Enter number : ' completeInputNumber
    markComplete $completeInputNumber
  fi

  if [ "$userInput" == "B" ] 
  then
    validInput="y"
    addNewItem
  fi

  if [ "$userInput" == "C" ]
  then
    validInput="y"
    listCompletedTodos
  fi
  updatePermissions
  if [ "$userInput" == "Q" ]
  then
    validInput="y"
    let argument1=1
    exit
  fi

  if [ "$validInput" == "n" ] 
  then
    echo "Invalid input : $userInput"
  fi

done

updatePermissions

