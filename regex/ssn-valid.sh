#!/bin/bash

#SSN='000-00-0000'
SSN='XXX-xx-XXXx'

pattern='^[0-9]{3}\-[0-9]{2}\-[0-9]{4}$|^[XX]{3}\-[Xx]{2}\-[Xx]{4}$'

[[ $SSN =~ $pattern ]] && echo good || echo bad
