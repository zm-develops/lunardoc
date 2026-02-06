package = "lunardoc"
version = "dev-1"
source = {
   url = "git+https://github.com/zm-develops/lunardoc-documentation-generator.git"
}
description = {
   homepage = "https://github.com/zm-develops/lunardoc-documentation-generator",
   license = "GPLV3"
}
dependencies = {
   "lua >= 5.1",
   "luautf8 >= 0.2.0",
   "penlight >= 1.13.0"
}
build = {
   type = "builtin",
   modules = {}
}
