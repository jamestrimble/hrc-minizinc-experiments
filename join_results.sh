paste <(python summarise_output.py < $1) <(cat $2 | grep '^[0-9]')
