extends Control

## Placeholder popup (10-02): a title and "Coming soon". Every home-screen button
## opens this through the 10-01 popup host until its real screen lands
## (Chests 10-05, Daily 10-06, Settings 10-09). The opener sets `title`.

@export var title: String = "Title":
	set(value):
		title = value
		if is_node_ready():
			$TitleLabel.text = value


func _ready() -> void:
	$TitleLabel.text = title
