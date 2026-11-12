# frozen_string_literal: true

name 'kubernetes'
run_list 'test::default'
cookbook 'kubernetes', path: '.'
cookbook 'test', path: './test/cookbooks/test'
