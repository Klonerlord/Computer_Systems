#!/bin/bash

[ -s $1 ]
if [ $? -ne 0 ]; then
    echo Empty file
    exit
fi
dictionary=$(perl -CSDL -lne '$k{$_}++ for split(//); END{print sort keys(%k)}' $1 | busybox fold -w1 | paste -sd � -)
allcharacters=$(bc <<< "$(wc -m $1 | sed 's/\s.*$//')-1")
IFS="�" read -a unreaddic <<< "$dictionary"
sum=0
entropy=0

for i in "${unreaddic[@]}"
do
probability=$(bc <<< "scale=10; $(grep -oF "$i" $1 | wc -l)/$allcharacters")
entropy=$(bc -l <<< "scale=10; "$probability"*(l(1/$probability)/l(2)) + $entropy")
done

probability=$(bc <<< "scale=10; ($(wc -l "$1" | sed 's/\s.*$//')-1)/$allcharacters")
if [ $(echo $probability | awk '{print ($0-int($0)>0)?int($0)+1:int($0)}') -ne 0 ]; then
    entropy=$(bc -l <<< "scale=10; "$probability"*(l(1/$probability)/l(2)) + $entropy")
fi
data=$(bc <<< "scale=10; $entropy*$allcharacters")
size=$(du -b $1 | sed 's/\s.*$//')

echo All characters\   -\  $allcharacters
echo Entropy\  \   \   \   -\  $entropy
echo Data amount\   \   \   -\  $data bits
echo Data amount\   \   \   -\  $(bc <<< "scale=10; $data/8") bytes
echo File size\    \   \   -\  $size bytes
echo \\n\    -\  $(bc <<< "scale=10; ($(wc -l "$1" | sed 's/\s.*$//')-1)/$allcharacters")

for i in "${unreaddic[@]}"
do
echo $i\    -\  $(bc <<< "scale=10; $(grep -oF "$i" $1 | wc -l)/$allcharacters")
sum=$(bc <<< "scale=10; $(grep -oF "$i" $1 | wc -l)/$allcharacters + $sum ")
done

sum=$(bc <<< "scale=10; ($(wc -l "$1" | sed 's/\s.*$//')-1)/$allcharacters + $sum")
echo Summary probability of all characters: \ $sum