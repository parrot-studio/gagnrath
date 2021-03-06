# coding: utf-8
require 'optparse'

options = {}
opt = OptionParser.new
opt.on('-e ENV', '--env=ENV', 'execute env, equal to RAILS_ENV=env'){|v| options[:env] = v}
opt.parse!(ARGV)

RAILS_ENV = options[:env] if options[:env]

AdminMailer.env_test.deliver!
exit
