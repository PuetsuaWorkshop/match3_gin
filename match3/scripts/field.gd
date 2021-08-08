tool
extends Container

export var columns : int = 1 setget _set_columns
export(int, 
	"Top Left", "Top Center", "Top Right",
	"Middle Left", "Middle Center", "Middle Right",
	"Bottom Left", "Bottom Center", "Bottom Right"
) var alignment = 0 setget _set_alignment
export(Vector2) var cell_size = Vector2(50, 50) setget _set_cell_size
export(Vector2) var cell_spacing = Vector2(5, 5) setget _set_cell_spacing

var disable_sort = false


func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		_sort()


func _set_columns(value):
	columns = value
	queue_sort()


func _set_alignment(value):
	alignment = value
	queue_sort()


func _set_cell_size(value):
	cell_size = value
	queue_sort()


func _set_cell_spacing(value):
	cell_spacing = value
	queue_sort()


func _sort():
	if disable_sort:
		return

	var num_col = 0
	var num_row = 0
	var column_width = cell_size.x+cell_spacing.x
	var row_height = cell_size.y+cell_spacing.y
	var offset = Vector2.ZERO
	var children = get_children()
	
	var actual_columns = children.size()
	if actual_columns > columns:
		actual_columns = columns
		
	var actual_rows = children.size() / columns
	
	if alignment % 3 == 1:
		offset.x = (self.rect_size.x - actual_columns*column_width + cell_spacing.x) / 2
	elif alignment % 3 == 2:
		offset.x = self.rect_size.x - actual_columns*column_width + cell_spacing.x
	
	if alignment / 3 == 1:
		offset.y = (self.rect_size.y - actual_rows*row_height + cell_spacing.y)/2
	elif alignment / 3 == 2:
		offset.y = self.rect_size.y - actual_rows*row_height + cell_spacing.y
	
	for c in children:
		var child : Control = c
		fit_child_in_rect(child, Rect2(Vector2(
			offset.x + num_col*column_width, 
			offset.y + num_row*row_height),
			child.rect_size))

		num_col += 1
		if num_col >= actual_columns:
			num_row += 1
			num_col = 0
