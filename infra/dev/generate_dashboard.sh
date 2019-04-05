#!/bin/bash
set -x

rails g scaffold dashboard/school name:string \
  --model-name=School \
  --force \
  --no-migration \
  --no-skip-routes \
  --no-helper \
  --no-assets \
  --no-javascripts  \
  --no-factory \
  --no-fixture \
  --no-stylesheets

rails g scaffold dashboard/schools/user first_name:string last_name:string email:string \
  --model-name=User \
  --force \
  --no-migration \
  --no-skip-routes \
  --no-helper \
  --no-assets \
  --no-javascripts  \
  --no-factory \
  --no-fixture \
  --no-stylesheets

rails g scaffold dashboard/schools/class_room name:string \
  --model-name=ClassRoom \
  --force \
  --no-migration \
  --no-skip-routes \
  --no-helper \
  --no-assets \
  --no-javascripts  \
  --no-factory \
  --no-fixture \
  --no-stylesheets

rails g scaffold dashboard/schools/class_rooms/student first_name:string last_name resume_educational_background:string resume_volunteer_work:string resume_other:string resume_languages:string  \
  --model-name=Student \
  --force \
  --no-migration \
  --no-skip-routes \
  --no-helper \
  --no-assets \
  --no-javascripts  \
  --no-factory \
  --no-fixture \
  --no-stylesheets

