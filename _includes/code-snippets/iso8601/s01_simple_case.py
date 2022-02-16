from datetime import datetime


def datetime_from_iso8601(iso8601_str):
    return datetime.fromisoformat(iso8601_str)


assert datetime_from_iso8601("2022-01-01") == datetime(2022, 1, 1)
assert datetime_from_iso8601("1979-01-01") == datetime(1979, 1, 1)
