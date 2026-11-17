if (!instance_exists(Existed)) {
    global.NewLevel = true;
    instance_create_layer(x,y,layer,Existed);
}
instance_destroy(self);