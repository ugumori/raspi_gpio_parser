from raspi_gpio_parser.motion import parser as motion_parser

parsers = []
def register_parser():
    parsers.append(motion_parser)

register_parser()
