#!/bin/sh

# dockerイメージのビルド、タグ付け、ECRへのpush、Lambdaへのデプロイを一括して実行する.
# docker loginは済ませておく.

REPO_NAME=raspi_gpio/db_writer
FUNC_NAME=raspi_gpio_db_writer

ARGS=`echo $@ | sed -E 's/^[a-zA-Z0-9]*[ \f\n\r\t]*//g'`

if [ -z $1 ]; then
    echo "Usage: deploy.sh AWS_ACCOUNT_ID"
    exit 0
fi

ACCOUNT_ID=$1

export DOCKER_BUILDKIT=1
tar -cJh . | docker build -t $REPO_NAME:latest --ssh default -
docker tag $REPO_NAME ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/$REPO_NAME
PUSH_RESULT=$(docker push ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/$REPO_NAME:latest)
HASH_CODE=$(echo $PUSH_RESULT | grep -o 'sha256:[a-z0-9]*' | cut -d " " -f3)
aws lambda update-function-code --region ap-northeast-1 --function-name $FUNC_NAME --image-uri ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/$REPO_NAME@$HASH_CODE ${ARGS}
