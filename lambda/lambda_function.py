from raspi_gpio_parser.log import logger

def lambda_handler(event, context):
    logger.debug(event)
