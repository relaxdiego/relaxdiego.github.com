import sys

try:
    import s02_check_time_zone
except AssertionError:
    sys.exit(0)

raise Exception("s02_check_time_zone did not fail as expected")
