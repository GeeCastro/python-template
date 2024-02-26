from loguru import logger


def parse_message() -> str:
    return "Running python template..."


if __name__ == "__main__":
    logger.info(parse_message())
