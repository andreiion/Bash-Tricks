
#Contains the process ID of the most recently executed background pipeline
echo $!

rm $(!!)

##########
echo 'test' > /tmp/a
cat !$ #output '/tmp/a'


#########
echo $$ #prints current sell process

# delete every file that has one char
rm a/?

# delete every file that has two chars
rm a/??
