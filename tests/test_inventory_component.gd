extends GdUnitTestSuite


func test_add_and_remove_by_resource_path() -> void:
	var inventory: InventoryComponent = auto_free(InventoryComponent.new())
	var bread: ItemDefinition = load("res://data/items/bread.tres")
	var tail: ItemDefinition = load("res://data/items/rat_tail.tres")
	inventory.add(bread)
	inventory.add(tail)
	inventory.add(bread)
	inventory.remove(bread)
	assert_array(inventory.item_paths).contains_exactly([tail.resource_path, bread.resource_path])
	assert_object(inventory.items[0]).is_same(tail)
