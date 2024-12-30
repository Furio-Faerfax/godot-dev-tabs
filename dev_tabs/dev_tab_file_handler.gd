class_name dev_tab_file_handler

signal file_deleted(path)


func save(path, data: String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_line(data)
	file.close()

func loading(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var data = file.get_as_text()
		file.close()
		#print(data)
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
