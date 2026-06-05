"""Utility functions with many repeated patterns."""


def process_item(item: dict) -> str:
    """Process a single item."""
    if not item:
        return ""

    result = ""
    for key, value in item.items():
        if value is not None:
            result += f"{key}={value},"

    return result.rstrip(",")


def validate_item(item: dict) -> bool:
    """Validate an item's structure."""
    if not item:
        return False

    required = ["id", "name", "type"]
    for field in required:
        if field not in item:
            return False

    return True


def format_item(item: dict) -> str:
    """Format an item for display."""
    if not item:
        return ""

    formatted = ""
    for key, value in item.items():
        if value is not None:
            formatted += f"  {key}: {value}\n"

    return formatted


def transform_item(item: dict, config: dict) -> dict:
    """Transform an item based on config rules."""
    if not item:
        return {}

    result = dict(item)
    for key, value in config.get("mappings", {}).items():
        if key in result:
            result[value] = result.pop(key)

    return result
