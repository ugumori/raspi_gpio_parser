from typing import Optional, TypedDict
import base64
import json

from raspi_gpio_parser.log import logger
from raspi_gpio_parser.parsers import parsers

def lambda_handler(event, context):
    logger.debug(event)
    models = []
    try:
        msgs = load_msgs(event)
        for m in msgs:
            models.append(parse(m))

    except Exception as err:
        import traceback

        logger.error(err)
        logger.error(traceback.format_exc())

    return respond("succeeded")


def parse(msg: str):
    models = []
    for p in parsers:
        models.append(p(msg))

    return models


def load_msgs(event: dict) -> list[str]:
    msg_list: list[str] = []
    for record in event["Records"]:
        payload = base64.b64decode(record["kinesis"]["data"]).decode()
        logger.debug("Decoded payload: " + payload)
        msg_list.append(payload)

    return msg_list


class LambdaResponse(TypedDict):
    statusCode: str
    body: str
    headers: dict


def respond(
    payload: object, status_code: int = 200, err: Optional[Exception] = None
) -> LambdaResponse:
    return {
        "statusCode": str(status_code),
        "body": str(err) if err else json.dumps(payload),
        "headers": {"Content-Type": "application/json"},
    }
