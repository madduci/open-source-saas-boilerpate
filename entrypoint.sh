#!/bin/bash

ln -sd /node_modules /workspace/node_modules

. /dev_environment/bin/activate

#flask dbcreate
npm run dev
flask run