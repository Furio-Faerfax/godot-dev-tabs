class_name dev_tab_file_handler

signal file_deleted(path)


func save(path, data):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_line(data)
	file.close()

func loading(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var data = file.get_as_text()
		file.close()
		#print(data)-
		var data_arr = data.split("\n")
		var data_array := []
		for line in data_arr:
			var t = line.split("|")
			t.push_back("")
			t.push_back(path)
			data_array.push_back(t)
		#print(data_array)
		return data_array
	else:
		file_deleted.emit(path)
		return [["This file was moved or deleted!", path, "file_deleted", path]]


func load_reloaded(path, split_by):
	var file = FileAccess.open(path, FileAccess.READ)
	var data_content : Array
	if file: 
		var data = file.get_as_text()
		file.close()
		var data_arr: Array = data.split("\n")
		
		if data_arr[0] == "":
			data_arr.pop_front()
		if data_arr[data_arr.size()-1] == "":
			data_arr.pop_back()
		
		if split_by != "":
			for line in data_arr:
				data_content.push_back(line.split(split_by))
		else:
			data_content = data_arr
	return data_content
