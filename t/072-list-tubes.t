# vim:set ft= ts=4 sw=4 et:

use Test::Nginx::Socket;
use Cwd qw(cwd);

repeat_each(2);

plan tests => repeat_each() * (3 * blocks());

my $pwd = cwd();

our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;;";
};

$ENV{TEST_NGINX_RESOLVER} = '8.8.8.8';
$ENV{TEST_NGINX_BEANSTALKD_PORT} ||= 11300;

no_long_string();
no_shuffle();

run_tests();

__DATA__

=== TEST 1: list-tubes
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local beanstalkd = require "resty.beanstalkd"

            local bean, err = beanstalkd:new()

            local ok, err = bean:connect("127.0.0.1", $TEST_NGINX_BEANSTALKD_PORT)
            if not ok then
                ngx.say("1: failed to connect: ", err)
                return
            end

            local res, err = bean:list_tubes()
            if not res then
                ngx.say("2: failed to stats: ", err)
                return
            end

            bean:close()

            ngx.say(res)
        }
    }
--- request
GET /t
--- response_body_like chop
---
[\s\S]*\- default[\s\S]*
--- no_error_log
[error]

=== TEST 2: list-tube-used
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local beanstalkd = require "resty.beanstalkd"

            local bean, err = beanstalkd:new()

            local ok, err = bean:connect("127.0.0.1", $TEST_NGINX_BEANSTALKD_PORT)
            if not ok then
                ngx.say("1: failed to connect: ", err)
                return
            end

            ok, err = bean:use("list_tube_used")
            if not ok then
                ngx.say("2: failed to use tube: ", err)
                return
            end

            local res, err = bean:list_tube_used()
            if not res then
                ngx.say("3: failed to list used tube: ", err)
                return
            end

            bean:close()
            ngx.say(res)
        }
    }
--- request
GET /t
--- response_body_like chop
list_tube_used
--- no_error_log
[error]

=== TEST 3: list-tubes-watched
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local beanstalkd = require "resty.beanstalkd"

            local bean, err = beanstalkd:new()

            local ok, err = bean:connect("127.0.0.1", $TEST_NGINX_BEANSTALKD_PORT)
            if not ok then
                ngx.say("1: failed to connect: ", err)
                return
            end

            ok, err = bean:watch("list_tubes_watched")
            if not ok then
                ngx.say("2: failed to watch: ", err)
                return
            end

            local res, err = bean:list_tubes_watched()
            if not res then
                ngx.say("3: failed to stats: ", err)
                return
            end

            bean:close()

            ngx.say(res)
        ';
    }
--- request
GET /t
--- response_body_like chop
---
- default
- list_tubes_watched
--- no_error_log
[error]

