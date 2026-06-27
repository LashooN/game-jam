class_name RingBuffer

var _buffer: Array
var _front: int = 0
var _back: int = 0
var _size: int = 0
var _capacity: int

func _init(capacity: int) -> void:
	_capacity = capacity
	_buffer.resize(capacity)

func append(item) -> void:
	_buffer[_back] = item
	_back = (_back + 1) % _capacity
	if _size == _capacity:
		_front = (_front + 1) % _capacity
	else:
		_size += 1

func pop_front():
	if is_empty():
		return null
		
	var item = _buffer[_front]
	_buffer[_front] = null
	_front = (_front + 1) % _capacity
	_size -= 1
	return item
	
func peek_front():
	if is_empty():
		return null
	return _buffer[_front]

func peek_back():
	if is_empty():
		return null
	return _buffer[(_back - 1 + _capacity) % _capacity]

func is_empty() -> bool:
	return _size == 0

func size() -> int:
	return _size
	
func capacity() -> int:
	return _capacity
	
func get_elem(i: int):
	return _buffer[(_front + i) % _capacity]
	
func set_cap_to_size():
	if is_empty():
		return
	var new_buffer: Array = []
	new_buffer.resize(_size)
	for i in range(_size):
		new_buffer[i] = _buffer[(_front + i) % _capacity]
	_buffer = new_buffer
	_capacity = _size
	_front = 0
	_back = 0
