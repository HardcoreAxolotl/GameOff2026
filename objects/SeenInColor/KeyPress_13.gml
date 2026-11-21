var vars = variable_instance_get_names(id);

show_debug_message("========== " + object_get_name(object_index) + " (ID: " + string(id) + ") ==========");

for (var i = 0; i < array_length(vars); i++) {
    var name = vars[i];
    var value = variable_instance_get(id, name);
    var type = typeof(value);

    var value_str;

    if (type == "array" || type == "struct") {
        value_str = json_stringify(value);
    }
    else {
        value_str = string(value);
    }

    show_debug_message(name + " [" + type + "] = " + value_str);
}