#!/bin/sh


cat <<\EOF
The code quality inspection process is running.
Thanks for waiting a few minutes. (~2mn)
EOF

PROJECT=$1
#Check for updated files

FILES=$(git diff --cached --name-status | awk -v PROJECT=$PROJECT '{if ( $1 != "D" ) { print PROJECT"/"$2"," }}' | sed "s/\n//")
FILES2=$(echo $FILES |sed "s/.$//")

#Call Task runner

LOGS=$(docker exec apache-upgrade-presta-dev gulp dev-task-runner-v1 --file "${FILES2}" --project "${PROJECT}")
AUX=$(echo ${LOGS##* } | iconv -t utf8)
QUALITY=$(echo ${AUX##* })
# echo $QUALITY
if ([ "$QUALITY" != 'OK' ] && [ "$QUALITY" != 'WARN' ])
then
cat <<\EOF
Quality Gates ERROR : Your code does not meet all the required quality rules
Please check the report in sonar
EOF
exit 1
fi

if ([ "$QUALITY" == 'WARN' ])
then
cat <<\EOF
You have reached the minimal quality gate limit, Please review your code and correct some issues.
EOF
fi

cat <<\EOF
  _______     ______      ______    ________            ___    ______    _______
 /" _   "|   /    " \    /    " \  |"      "\          |"  |  /    " \  |   _  "\
(: ( \___)  // ____  \  // ____  \ (.  ___  :)         ||  | // ____  \ (. |_)  :)
 \/ \      /  /    ) :)/  /    ) :)|: \   ) ||         |:  |/  /    ) :)|:     \/
 //  \ ___(: (____/ //(: (____/ // (| (___\ ||      ___|  /(: (____/ // (|  _  \\
(:   _(  _|\        /  \        /  |:       :)     /  :|_/ )\        /  |: |_)  :)
 \_______)  \"_____/    \"_____/   (________/     (_______/  \"_____/   (_______/
EOF