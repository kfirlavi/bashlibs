#!/bin/bash

date_Y_m_d()
{
  local delimiter=${1:-'.'}
  date +%Y${delimiter}%m${delimiter}%d
}

date_hour_H_M()
{
  local delimiter=$1
  date +%H${delimiter}%M
}

date_hour_H_M_S()
{
  local delimiter=$1
  date +%H${delimiter}%M${delimiter}%S
}

date_date_hour()
{
  local delimiter=${1:-'.'}
  local hour_delimiter=${2:-'-'}
  echo $(date_Y_m_d $delimiter)${hour_delimiter}$(date_hour_H_M $delimiter)
}
