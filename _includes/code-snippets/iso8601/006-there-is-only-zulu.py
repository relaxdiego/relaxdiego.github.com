from datetime import datetime, timezone


def datetime_from_iso8601(iso8601_str):
    if iso8601_str[-1].upper() == "Z":
        iso8601_str = f"{iso8601_str[:-1]}+00:00"

    dt = datetime.fromisoformat(iso8601_str)

    if dt.tzinfo is None:
        #
        # There is only Zulu!
        #
        dt = dt.replace(tzinfo=timezone.utc)

    return dt


assert datetime_from_iso8601("2022-01-01") == datetime(2022, 1, 1, tzinfo=timezone.utc)
assert datetime_from_iso8601("1979-01-01") == datetime(1979, 1, 1, tzinfo=timezone.utc)
assert datetime_from_iso8601("1979-01-01T11:11") == datetime(
    1979, 1, 1, 11, 11, tzinfo=timezone.utc
)

assert datetime_from_iso8601("1979-01-01T00:00:00Z").tzinfo is not None
assert datetime_from_iso8601("1979-01-01").tzinfo is not None
