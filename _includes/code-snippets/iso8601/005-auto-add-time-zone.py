from datetime import datetime


def datetime_from_iso8601(iso8601_str):
    if iso8601_str[-1].upper() == "Z":
        iso8601_str = f"{iso8601_str[:-1]}+00:00"

    dt = datetime.fromisoformat(iso8601_str)

    # Let's add that time zone if it's missing
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=get_timezone())

    return dt


def get_timezone():
    raise Exception("Wait...which timezone should I use???")


assert datetime_from_iso8601("2022-01-01") == datetime(2022, 1, 1)
assert datetime_from_iso8601("1979-01-01") == datetime(1979, 1, 1)

assert datetime_from_iso8601("1979-01-01T00:00:00Z").tzinfo is not None
assert datetime_from_iso8601("1979-01-01").tzinfo is not None
