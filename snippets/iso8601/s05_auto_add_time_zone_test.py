import sys

try:
    import s05_auto_add_time_zone
except Exception as e:
    if str(e) != "Wait...which timezone should I use???":
        raise

    sys.exit(0)

raise Exception("s05_auto_add_time_zone did not fail as expected")
