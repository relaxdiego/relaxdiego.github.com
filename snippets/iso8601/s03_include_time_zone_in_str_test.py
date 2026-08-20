import sys

try:
    import s03_include_time_zone_in_str
except ValueError as e:
    if str(e) != "Invalid isoformat string: '1979-01-01T00:00:00Z'":
        raise

    sys.exit(0)

raise Exception("s03_include_time_zone_in_str did not fail as expected")
