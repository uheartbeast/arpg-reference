extends Node

func choose(array):
	array.shuffle()
	return array.pop_front()
