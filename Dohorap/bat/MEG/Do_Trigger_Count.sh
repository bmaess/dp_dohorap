
if [ $# -lt 2 ]
then
   echo "usage: Do_Trigger_Count.sh <subject> <suffix>"
	echo "Example: Do_Trigger_Count.sh dh02a ${SUFFIX}"
   exit 1
   fi
SUBJECT=$1;
SUFFIX=$2;
shift

echo -n "Portcodes: 211, 212, 221, 222: "
egrep " (221|222|211|212)$" ${EXPDIR}${SUBJECT}/${SUBJECT}?${SUFFIX}.eve|wc -l
echo -n "Trigger: 101                   :  "
egrep " 101$" ${EXPDIR}${SUBJECT}/${SUBJECT}?${SUFFIX}.eve|wc -l
echo -n "Trigger: 102                   :  "
egrep " 102$" ${EXPDIR}${SUBJECT}/${SUBJECT}?${SUFFIX}.eve|wc -l
echo -n "Trigger: 211                   :  "
egrep " 211$" ${EXPDIR}${SUBJECT}/${SUBJECT}?${SUFFIX}.eve|wc -l
echo -n "Trigger: 212                   :  "
egrep " 212$" ${EXPDIR}${SUBJECT}/${SUBJECT}?${SUFFIX}.eve|wc -l
echo -n "Trigger: 221                   :  "
egrep " 221$" ${EXPDIR}${SUBJECT}/${SUBJECT}?${SUFFIX}.eve|wc -l
echo -n "Trigger: 222                   :  "
egrep " 222$" ${EXPDIR}${SUBJECT}/${SUBJECT}?${SUFFIX}.eve|wc -l

triggers="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76"
for t in $triggers
do
perl -e 'printf "Trigger: %3d                 :  ",$ARGV[0];' $t
perl -ne 'BEGIN{$c=shift @ARGV;} if (/\s+$c$/) {printf "%s",$_}' $t ${EVEDIR}${SUBJECT}/block?${SUFFIX}.eve | wc -l
done
