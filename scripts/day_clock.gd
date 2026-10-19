extends RefCounted

## THE one "what day is it" helper for everything that resets daily: the store's
## daily deals and monthly card (10-04), and later the login gift, quests and
## spin (10-06). Don't compute day boundaries anywhere else.
##
## Days come from the device clock in LOCAL time, so they turn over at the
## player's midnight. That can be cheated by changing the clock until a server
## exists (F5/F8, Epic 12/13) — accepted for now.
##
## Consumers `preload()` this (see resource_dir.gd for why not class_name).


## Today's local date as a day number (days since 1970-01-01). Consecutive days
## differ by exactly 1, so "N days from now" is plain addition.
static func today() -> int:
	return day_of(int(Time.get_unix_time_from_system()))


## The local day number a unix timestamp falls on.
static func day_of(unix_time: int) -> int:
	var bias_sec: int = int(Time.get_time_zone_from_system().get("bias", 0)) * 60
	return int(floor(float(unix_time + bias_sec) / 86400.0))
