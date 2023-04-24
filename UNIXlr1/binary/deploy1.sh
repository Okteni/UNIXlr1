#!/bin/bash

WEB_APPS_TOMCAT_DIR=webapps
tomcat_path=/home/okteni/tomcat
filename=demo.war
war_name=/home/okteni/Downloads/mydemo/binary/Unix.war
B_dir=/home/okteni/Downloads/mydemo/backups
B_name=Unix-$(date +%Y%m%d%H%M%S).war

# Проверяем, существует ли каталог tomcat
if [[ ! -d "$tomcat_path" ]]; then
  echo "Tomcat directory not found: $tomcat_path"
  exit 1
fi

for opt in "$@"; do
    case "$opt" in
        -u | --undeploy )
          file_deployed="$tomcat_path"/"$WEB_APPS_TOMCAT_DIR"/"$filename"
          if [ ! -f "$file_deployed" ]; then
            echo "File not found: $file_deployed"
            exit 1
          fi
          rm -R "${file_deployed%.*}"
          rm "$file_deployed"
          printf "File %s was removed: %s/%s\n%s" \
          $filename $tomcat_path $WEB_APPS_TOMCAT_DIR "$(ls "$webapp_directory")"
          ls "$tomcat_path"/"$WEB_APPS_TOMCAT_DIR"/
          ;;
        -d | --deploy )
          if [ ! -f "$filename" ]; then
            printf "File not found: %s", $file_deployed
            exit 1
          fi
          webapp_directory="$tomcat_path"/"$WEB_APPS_TOMCAT_DIR"/
          cp "$filename" "$webapp_directory"
          printf "%s was placed in %s:\n%s\n" $filename $webapp_directory "$(ls "$webapp_directory")"
          ;;
        -p | --path )
          # reading $2 grabs the *next* fragment
          tomcat_path="$2"
          ;;
        -f | --filename )
          # reading $2 grabs the *next* fragment
          filename="$2"
          ;;
        -s | --start )
          eval "$tomcat_path"/bin/startup.sh
          ;;
        -sh | --stop )
          eval "$tomcat_path"/bin/shutdown.sh
          ;;

        -b | --backup)
           echo "Creating backup of $war_name..."
            mkdir -p $B_dir
            cp $war_name $B_dir/$B_name
          ;;

        -dc | --deploy-curl )

          full_file_name=$(realpath "$filename")

          eval curl -u \'"$username":"$password"\' \
          -T \""$full_file_name"\" \
          \""http://localhost:""$port"/manager/text/deploy?path="$endpoint""&update=true"\"
          ;;
        -uc | --undeploy-curl )
          eval curl -u \'"$username":"$password"\' \
           \""http://localhost:""$port"/manager/text/undeploy?path="$endpoint""&update=true"\"
          ;;
        --username=* )
          username="${1#*=}"
          ;;
        --password=* )
          password="${1#*=}"
          ;;
        --endpoint=* )
          endpoint=${1#*=}
          ;;
        --port=*)
          port=${1#*=}
    esac
    # shift to get past both the -o and the next
    shift
done