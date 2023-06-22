#!/bin/sh

FUNC=raspi_gpio_parser

ARGS=`echo $@ | sed -E 's/^[a-zA-Z0-9]*[ \f\n\r\t]*//g'`

if [ -z $1 ]; then
    echo "Usage: deploy.sh AWS_ACCOUNT_ID"
    exit 0
fi

ACCOUNT_ID=$1

export DOCKER_BUILDKIT=1
tar -cJh . | docker build -t $FUNC:latest --ssh default -
docker tag $FUNC ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/$FUNC
PUSH_RESULT=$(docker push ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/$FUNC:latest)
HASH_CODE=$(echo $PUSH_RESULT | grep latest | cut -d " " -f3)
aws lambda update-function-code --region ap-northeast-1 --function-name anemometer_parser_${UNAAS_ENV} --image-uri ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/$FUNC@$HASH_CODE ${ARGS}
