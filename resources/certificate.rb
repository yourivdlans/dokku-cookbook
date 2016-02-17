#
# Cookbook Name:: dokku
# Resource:: certificate
#
# Copyright (c) 2015 Nick Charlton, MIT licensed.
#

actions :add
default_action :add

attribute :app, kind_of: String, name_attribute: true
attribute :global, kind_of: [TrueClass, FalseClass], default: false
attribute :cert, kind_of: String
attribute :key, kind_of: String
