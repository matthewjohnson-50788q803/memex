#! /bin/bash

# script for building docker images and starting them using docker-compose
# assumes directory of invocation is memex-service/docker, parent of this script

if [[ -z ${DEFAULT_USER_USERNAME} ]]; then
  echo "Enter value for DEFAULT_USER_USERNAME: "
  read DEFAULT_USER_USERNAME
  export DEFAULT_USER_USERNAME=${DEFAULT_USER_USERNAME}
fi

if [[ -z ${DEFAULT_USER_PW} ]]; then
  echo "Enter value for DEFAULT_USER_PW: "
  read DEFAULT_USER_PW
  export DEFAULT_USER_PW=${DEFAULT_USER_PW}
fi

if [[ -z ${AUTH_TOKEN_ENC_KEY_SECRET} ]]; then
  echo "Enter value for AUTH_TOKEN_ENC_KEY_SECRET: "
  read AUTH_TOKEN_ENC_KEY_SECRET
  export AUTH_TOKEN_ENC_KEY_SECRET=${AUTH_TOKEN_ENC_KEY_SECRET}
fi

if [[ -z ${USERPASS_ENC_KEY_SECRET} ]]; then
  echo "Enter value for USERPASS_ENC_KEY_SECRET: "
  read USERPASS_ENC_KEY_SECRET
  export USERPASS_ENC_KEY_SECRET=${USERPASS_ENC_KEY_SECRET}
fi

# environment variables are inherited by child docker compose process, then loaded by java spring program in the started docker container
if [[ -z ${SPRING_PROFILES_ACTIVE} ]]; then
  echo "Enter value for SPRING_PROFILES_ACTIVE (dev, prod, something else): "
  read SPRING_PROFILES_ACTIVE
  export SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE}
fi

# build
../../mvnw clean install -f ../../pom.xml
docker build --tag memex-service:1.0.0 --file app/Dockerfile ..

# start containers
docker-compose --file mongo/docker-compose.yml up --detach
echo "waiting for mongo to initialize" && sleep 5
docker-compose --file elasticsearch/docker-compose.yml up --detach
echo "waiting for elastic to initialize" && sleep 15
docker-compose --file app/docker-compose.yml up --detach
echo "waiting for app to initialize" && sleep 15

if [[ "${SPRING_PROFILES_ACTIVE}" =~ "dev" ]]; then
  echo "Initializing Mongo userDetails database with encrypted credential"
  DEFAULT_USER_PW_ENCODED=$(curl -X "POST" -H "Content-Type: application/json" -d "{\"password\":\"${DEFAULT_USER_PW}\"}" localhost:8080/api/v0/auth/getEncryptedPassword | sed 's/.*{.*"encryptedPassword".*:[^"]*"//' | sed 's/".*}.*//')
  if [[ $? -ne 0 ]]; then
    echo "Mogno userDetails collection was not successfully initialized"
    echo "Failed to retrieve hex encoded encrypted password from memex-service"
    exit 1
  fi
  cat mongo/dbInit.js | sed "s/\${DEFAULT_USER_USERNAME}/${DEFAULT_USER_USERNAME}/g" | sed "s/\${DEFAULT_USER_PW_ENCODED}/${DEFAULT_USER_PW_ENCODED}/g" > mongo/dbInitInterpolated.js
  mongo < mongo/dbInitInterpolated.js
  if [[ $? -eq 0 ]]; then
    echo "Mongo userDetails collection initialized successfully"
  else
    echo "Mogno userDetails collection was not successfully initialized"
    exit 1
  fi
fi
