#!/bin/bash
set -x

rm -Rf app/controllers/dashboard
rm -Rf app/views/dashboard
rm app/models/dashboard.rb
rm test/models/dashboard/school_test.rb
rm -Rf app/models/dashboard/*
rm -Rf test/controllers/dashboard
rm -Rf test/model/dashboard*
