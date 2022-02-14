from datetime import datetime


def datetime_from_iso8601(iso8601_str):
    # I mean, it's just one silly character anyway...
    if iso8601_str[-1].upper() == "Z":
        iso8601_str = f"{iso8601_str[:-1]}+00:00"

    return datetime.fromisoformat(iso8601_str)


assert datetime_from_iso8601("2022-01-01") == datetime(2022, 1, 1)
assert datetime_from_iso8601("1979-01-01") == datetime(1979, 1, 1)

assert datetime_from_iso8601("1979-01-01T00:00:00Z").tzinfo is not None
