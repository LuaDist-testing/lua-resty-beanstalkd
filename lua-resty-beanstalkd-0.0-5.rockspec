-- This file was automatically generated for the LuaDist project.

package = "lua-resty-beanstalkd"
version = "0.0-5"

-- LuaDist source
source = {
  tag = "0.0-5",
  url = "git://github.com/LuaDist-testing/lua-resty-beanstalkd.git"
}
-- Original source
-- source = {
--     url = "git://github.com/smallfish/lua-resty-beanstalkd.git"
-- }

description = {
    summary = "Lua beastalkd client driver for the ngx_lua based on the cosocket API",
    detailed = "Lua beastalkd client driver for the ngx_lua based on the cosocket API",
    homepage = "https://github.com/smallfish/lua-resty-beanstalkd",
    maintainer = "smallfish <smallfish.xy@gmail.com>",
    license = "2bsd"
}

dependencies = {
    "lua >= 5.1"
}

build = {
    type = "builtin",
    modules = {
        ["resty.beanstalkd"] = "lib/resty/beanstalkd.lua"
    }
}